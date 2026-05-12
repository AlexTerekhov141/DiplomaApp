import logging
import os

import cv2
import numpy as np
from PIL import Image

from django.conf import settings

logger = logging.getLogger(__name__)

CATEGORIES = ["document", "screenshot", "food", "landscape", "portrait"]
INPUT_SIZE = (224, 224)

TAGS = [
    # Природа
    "sunset",
    "sunrise",
    "sky",
    "clouds",
    "mountains",
    "ocean",
    "beach",
    "forest",
    "snow",
    "rain",
    "flowers",
    "lake",
    "river",
    # Люди
    "people",
    "group photo",
    "selfie",
    "child",
    "couple",
    "family",
    # Животные
    "cat",
    "dog",
    "bird",
    "animal",
    # Еда и напитки
    "food",
    "dessert",
    "coffee",
    "drink",
    "fruit",
    "restaurant",
    # Город
    "city",
    "building",
    "street",
    "car",
    "architecture",
    # Интерьер
    "interior",
    "room",
    # События
    "party",
    "wedding",
    "birthday",
    "concert",
    "sport",
    # Активности
    "travel",
    "hiking",
    # Документы
    "document",
    "text",
    "receipt",
    # "screenshot",
    # Время
    "night",
]

TAG_THRESHOLD = 0.20
TAG_TOP_K = 5


class MLService:
    """Единый ML-сервис: классификация, оценка качества, тегирование."""

    _classifier = None
    _nima_model = None
    _clip_model = None
    _clip_preprocess = None
    _text_features = None

    # ── Загрузчики моделей ──────────────────────────────

    @classmethod
    def _load_classifier(cls):
        if cls._classifier is not None:
            return cls._classifier

        path = getattr(settings, "ML_MODEL_PATH", None)
        if not path or not os.path.exists(path):
            raise RuntimeError(f"Classifier model not found: {path}")

        import tensorflow as tf

        cls._classifier = tf.keras.models.load_model(path)
        logger.info("Classifier loaded from %s", path)
        return cls._classifier

    @classmethod
    def _load_nima(cls):
        if cls._nima_model is not None:
            return cls._nima_model

        path = getattr(settings, "NIMA_MODEL_PATH", None)
        if not path or not os.path.exists(path):
            logger.warning(
                "NIMA model not found at %s — using technical metrics only", path
            )
            return None

        import tensorflow as tf

        cls._nima_model = tf.keras.models.load_model(
            path, custom_objects={"emd_loss": cls._emd_loss}
        )
        logger.info("NIMA model loaded from %s", path)
        return cls._nima_model

    @staticmethod
    def _emd_loss(y_true, y_pred):
        import tensorflow as tf

        cdf_true = tf.cumsum(y_true, axis=-1)
        cdf_pred = tf.cumsum(y_pred, axis=-1)
        return tf.sqrt(tf.reduce_mean(tf.square(cdf_true - cdf_pred), axis=-1))

    @classmethod
    def _load_clip(cls):
        if cls._clip_model is not None:
            return cls._clip_model, cls._clip_preprocess

        import open_clip
        import torch

        model, _, preprocess = open_clip.create_model_and_transforms(
            "ViT-B-32", pretrained="laion2b_s34b_b79k"
        )
        tokenizer = open_clip.get_tokenizer("ViT-B-32")
        model.eval()

        prompts = [f"a photo of {tag}" for tag in TAGS]
        tokens = tokenizer(prompts)
        with torch.no_grad():
            text_features = model.encode_text(tokens)
            text_features /= text_features.norm(dim=-1, keepdim=True)

        cls._clip_model = model
        cls._clip_preprocess = preprocess
        cls._text_features = text_features
        logger.info("CLIP model loaded (ViT-B-32)")
        return model, preprocess

    # ── Классификация ──────────────────────────────────────────

    def classify(self, image_path: str) -> dict:
        model = self._load_classifier()

        img = Image.open(image_path).convert("RGB").resize(INPUT_SIZE)
        arr = np.array(img, dtype=np.float32)
        model_path = getattr(settings, "ML_MODEL_PATH", "")
        if str(model_path).endswith(".h5"):
            arr = arr / 255.0
        arr = np.expand_dims(arr, axis=0)

        preds = model.predict(arr, verbose=0)[0]
        idx = int(np.argmax(preds))

        return {
            "category": CATEGORIES[idx],
            "confidence": round(float(preds[idx]), 4),
        }

    # ── Оценка качества ──────────────────────────────────────

    @staticmethod
    def _technical_metrics(image_path: str) -> dict:
        """Вычислить технические метрики качества (OpenCV)"""
        img = cv2.imread(image_path)
        if img is None:
            return {
                "sharpness": 0.5,
                "exposure": 0.5,
                "contrast": 0.5,
                "colorfulness": 0.5,
            }

        gray = cv2.cvtColor(img, cv2.COLOR_BGR2GRAY)

        sharpness = min(1.0, cv2.Laplacian(gray, cv2.CV_64F).var() / 500.0)

        mean_brightness = float(gray.mean())
        exposure = max(0.0, 1.0 - abs(mean_brightness - 128) / 128)

        contrast = min(1.0, float(gray.std()) / 80.0)

        # Цветность
        b, g, r = cv2.split(img.astype(np.float64))
        rg = r - g
        yb = 0.5 * (r + g) - b
        cf = float(
            np.sqrt(rg.std() ** 2 + yb.std() ** 2)
            + 0.3 * np.sqrt(rg.mean() ** 2 + yb.mean() ** 2)
        )
        colorfulness = min(1.0, cf / 150.0)

        return {
            "sharpness": round(sharpness, 4),
            "exposure": round(exposure, 4),
            "contrast": round(contrast, 4),
            "colorfulness": round(colorfulness, 4),
        }

    def _nima_score(self, image_path: str) -> float | None:
        """Эстетическая оценка от 0 до 1. Возвращает None, если NIMA недоступна."""
        model = self._load_nima()
        if model is None:
            return None

        img = Image.open(image_path).convert("RGB").resize(INPUT_SIZE)
        arr = np.expand_dims(np.array(img, dtype=np.float32) / 255.0, axis=0)

        dist = model.predict(arr, verbose=0)[0]
        mean_score = sum((i + 1) * d for i, d in enumerate(dist))
        return round((mean_score - 1) / 9, 4)

    def assess_quality(self, image_path: str) -> dict:
        """Комбинируем NIMA + технические метрики"""
        tech = self._technical_metrics(image_path)
        nima = self._nima_score(image_path)

        if nima is not None:
            score = (
                0.45 * nima
                + 0.20 * tech["sharpness"]
                + 0.15 * tech["exposure"]
                + 0.10 * tech["contrast"]
                + 0.10 * tech["colorfulness"]
            )
        else:
            score = (
                0.35 * tech["sharpness"]
                + 0.30 * tech["exposure"]
                + 0.20 * tech["contrast"]
                + 0.15 * tech["colorfulness"]
            )

        return {"quality_score": round(score, 4)}

    # ── Теги CLIP ───────────────────────────────────────────────

    def predict_tags(self, image_path: str) -> list[str]:
        """Тегирование изображений с помощью CLIP"""
        import torch

        model, preprocess = self._load_clip()

        img = preprocess(Image.open(image_path).convert("RGB")).unsqueeze(0)

        with torch.no_grad():
            image_features = model.encode_image(img)
            image_features /= image_features.norm(dim=-1, keepdim=True)
            similarity = (image_features @ self._text_features.T).squeeze(0)

        scored = sorted(
            [(TAGS[i], float(s)) for i, s in enumerate(similarity)],
            key=lambda x: x[1],
            reverse=True,
        )

        above = [tag for tag, s in scored if s > TAG_THRESHOLD]
        if len(above) < 2:
            above = [tag for tag, _ in scored[:2]]

        return above[:TAG_TOP_K]

    # ── Публичный API ──────────────────────────────────────────────

    def analyze(self, image_path: str) -> dict:
        """
        Полный анализ: классификация + качество + теги.

        Возвращает словарь с ключами: category, confidence, quality_score, tags.
        """
        result = self.classify(image_path)

        quality = self.assess_quality(image_path)
        result["quality_score"] = quality["quality_score"]

        try:
            result["tags"] = self.predict_tags(image_path)
        except Exception:
            logger.exception("Tag prediction failed for %s", image_path)
            result["tags"] = []

        return result
