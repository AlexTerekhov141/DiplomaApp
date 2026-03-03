import logging

import numpy as np
from PIL import Image

from django.conf import settings

logger = logging.getLogger(__name__)

CATEGORIES = ["document", "screenshot", "food", "landscape", "portrait"]
INPUT_SIZE = (224, 224)


class MLService:
    """Класс для запросов к модели"""

    _model = None

    @classmethod
    def _load_model(cls):
        if cls._model is not None:
            return cls._model

        model_path = getattr(settings, "ML_MODEL_PATH", None)
        if not model_path:
            raise RuntimeError("ML_MODEL_PATH is not configured in settings")

        import tensorflow as tf

        cls._model = tf.keras.models.load_model(model_path)
        logger.info("ML model loaded from %s", model_path)
        return cls._model

    def analyze(self, image_path: str) -> dict:
        """
        Классифицируем и считаем качество фото

        Возвращает:
            Словарь с ключами: category, confidence, quality_score
        """
        model = self._load_model()

        img = Image.open(image_path).convert("RGB")
        img_resized = img.resize(INPUT_SIZE)
        img_array = np.array(img_resized) / 255.0
        img_array = np.expand_dims(img_array, axis=0)

        predictions = model.predict(img_array)
        predicted_idx = int(np.argmax(predictions[0]))
        confidence = float(predictions[0][predicted_idx])

        width, height = img.size
        resolution_score = min(1.0, (width * height) / (1920 * 1080))
        quality_score = round(0.6 * confidence + 0.4 * resolution_score, 4)

        return {
            "category": CATEGORIES[predicted_idx],
            "confidence": confidence,
            "quality_score": quality_score,
        }
