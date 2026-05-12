"""
Одноэтапное обучение MobileNetV2 для категоризации фото.

Сначала запускаем split_dataset.py.
Val и test должны содержать только исходные изображения, без аугментированных копий из обучающей выборки.
"""

import argparse
import csv
from pathlib import Path

import matplotlib.pyplot as plt
import tensorflow as tf
from tensorflow.keras import layers
from tensorflow.keras.applications import MobileNetV2
from tensorflow.keras.applications.mobilenet_v2 import preprocess_input
from tensorflow.keras.callbacks import (
    CSVLogger,
    EarlyStopping,
    ModelCheckpoint,
    ReduceLROnPlateau,
)
from tensorflow.keras.regularizers import l2
from tensorflow.keras.models import Model
from tensorflow.keras.optimizers import Adam

from config import (
    ARTIFACTS_DIR,
    BATCH_SIZE,
    CLASSES,
    IMG_SIZE,
    LABELS_PATH,
    MODEL_PATH,
    REPORTS_DIR,
    SEED,
    SPLIT_DATASET_DIR,
)

IMAGE_EXTENSIONS = {".jpg", ".jpeg", ".png", ".bmp", ".webp"}


def count_images(directory: Path) -> int:
    if not directory.exists():
        return 0
    return sum(
        1 for path in directory.iterdir() if path.suffix.lower() in IMAGE_EXTENSIONS
    )


def compute_class_weights(train_dir: Path) -> dict[int, float]:
    counts = [count_images(train_dir / class_name) for class_name in CLASSES]
    if any(count == 0 for count in counts):
        raise ValueError(
            f"Every class must have train images, got {dict(zip(CLASSES, counts))}"
        )

    total = sum(counts)
    class_weights = {
        idx: total / (len(CLASSES) * count) for idx, count in enumerate(counts)
    }
    print("Train class counts:", dict(zip(CLASSES, counts)))
    print(
        "Class weights:",
        {CLASSES[idx]: round(value, 4) for idx, value in class_weights.items()},
    )
    return class_weights


def load_dataset(split_dir: Path, split: str, shuffle: bool) -> tf.data.Dataset:
    return tf.keras.utils.image_dataset_from_directory(
        split_dir / split,
        labels="inferred",
        label_mode="categorical",
        class_names=CLASSES,
        color_mode="rgb",
        batch_size=BATCH_SIZE,
        image_size=IMG_SIZE,
        shuffle=shuffle,
        seed=SEED,
    )


def build_datasets(split_dir: Path) -> tuple[tf.data.Dataset, tf.data.Dataset]:
    train_ds = load_dataset(split_dir, "train", shuffle=True)
    val_ds = load_dataset(split_dir, "val", shuffle=False)

    AUTOTUNE = tf.data.AUTOTUNE
    return train_ds.prefetch(AUTOTUNE), val_ds.prefetch(AUTOTUNE)


def create_model(
    dropout: float = 0.35,
    dense_units: int = 192,
    fine_tune_from: int = 120,
) -> tuple[Model, Model]:
    inputs = layers.Input(shape=(*IMG_SIZE, 3))

    augmentation = tf.keras.Sequential(
        [
            # Horizontal flips make text-heavy documents/screenshots unrealistic.
            layers.RandomRotation(0.025, seed=SEED),
            layers.RandomTranslation(0.04, 0.04, seed=SEED),
            layers.RandomZoom(0.08, seed=SEED),
            layers.RandomContrast(0.10, seed=SEED),
        ],
        name="train_augmentation",
    )

    base_model = MobileNetV2(
        weights="imagenet",
        include_top=False,
        input_shape=(*IMG_SIZE, 3),
    )
    base_model.trainable = True
    for layer in base_model.layers[:fine_tune_from]:
        layer.trainable = False
    for layer in base_model.layers:
        if isinstance(layer, layers.BatchNormalization):
            layer.trainable = False

    x = augmentation(inputs)
    x = preprocess_input(x)
    x = base_model(x, training=False)
    x = layers.GlobalAveragePooling2D()(x)
    x = layers.BatchNormalization()(x)
    x = layers.Dense(
        dense_units,
        activation="relu",
        kernel_regularizer=l2(1e-5),
        name="projection",
    )(x)
    x = layers.BatchNormalization()(x)
    x = layers.Dropout(dropout)(x)
    outputs = layers.Dense(len(CLASSES), activation="softmax", name="category")(x)

    return Model(inputs, outputs, name="photo_category_mobilenetv2"), base_model


def compile_model(
    model: Model,
    learning_rate: float,
    label_smoothing: float = 0.03,
) -> None:
    model.compile(
        optimizer=Adam(learning_rate=learning_rate),
        loss=tf.keras.losses.CategoricalCrossentropy(label_smoothing=label_smoothing),
        metrics=[
            tf.keras.metrics.CategoricalAccuracy(name="accuracy"),
            tf.keras.metrics.TopKCategoricalAccuracy(k=2, name="top2_accuracy"),
        ],
    )


def save_history_csv(history: tf.keras.callbacks.History, path: Path) -> None:
    rows = []
    for local_epoch in range(len(history.epoch)):
        row = {"epoch": local_epoch + 1}
        for key, values in history.history.items():
            row[key] = values[local_epoch]
        rows.append(row)

    if not rows:
        return

    path.parent.mkdir(parents=True, exist_ok=True)
    with path.open("w", newline="", encoding="utf-8") as file:
        writer = csv.DictWriter(file, fieldnames=rows[0].keys())
        writer.writeheader()
        writer.writerows(rows)


def plot_history(history: tf.keras.callbacks.History, path: Path) -> None:
    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 5))
    ax1.plot(history.history.get("accuracy", []), label="train")
    ax1.plot(history.history.get("val_accuracy", []), label="val")
    ax1.set_title("Single-Stage Accuracy")
    ax1.set_xlabel("Epoch")
    ax1.legend()
    ax1.grid(True, alpha=0.3)

    ax2.plot(history.history.get("loss", []), label="train")
    ax2.plot(history.history.get("val_loss", []), label="val")
    ax2.set_title("Single-Stage Loss")
    ax2.set_xlabel("Epoch")
    ax2.legend()
    ax2.grid(True, alpha=0.3)

    path.parent.mkdir(parents=True, exist_ok=True)
    fig.savefig(path, dpi=150, bbox_inches="tight")
    plt.close(fig)


def train(args: argparse.Namespace) -> Model:
    tf.keras.utils.set_random_seed(args.seed)
    ARTIFACTS_DIR.mkdir(parents=True, exist_ok=True)
    REPORTS_DIR.mkdir(parents=True, exist_ok=True)
    LABELS_PATH.write_text("\n".join(CLASSES), encoding="utf-8")

    train_ds, val_ds = build_datasets(args.dataset)
    class_weights = compute_class_weights(args.dataset / "train")
    model, base_model = create_model(
        dropout=args.dropout,
        dense_units=args.dense_units,
        fine_tune_from=args.fine_tune_from,
    )

    trainable_base_layers = sum(1 for layer in base_model.layers if layer.trainable)
    print(
        "Single-stage MobileNetV2 trainable layers: "
        f"{trainable_base_layers}/{len(base_model.layers)}"
    )

    callbacks = [
        EarlyStopping(
            monitor="val_loss",
            patience=args.patience,
            restore_best_weights=True,
            verbose=1,
        ),
        ModelCheckpoint(MODEL_PATH, monitor="val_loss", save_best_only=True, verbose=1),
        CSVLogger(REPORTS_DIR / "training_log.csv"),
        ReduceLROnPlateau(
            monitor="val_loss",
            factor=0.5,
            patience=max(2, args.patience // 2),
            min_lr=1e-7,
            verbose=1,
        ),
    ]

    print("\nSingle-stage training")
    compile_model(
        model,
        learning_rate=args.learning_rate,
        label_smoothing=args.label_smoothing,
    )
    model.summary()
    history = model.fit(
        train_ds,
        validation_data=val_ds,
        epochs=args.epochs,
        class_weight=class_weights,
        callbacks=callbacks,
    )

    save_history_csv(history, REPORTS_DIR / "training_history.csv")
    plot_history(history, REPORTS_DIR / "training_history.png")
    best_model = tf.keras.models.load_model(MODEL_PATH)
    print(f"\nSaved model: {MODEL_PATH}")
    print(f"Saved labels: {LABELS_PATH}")
    print(f"Saved history: {REPORTS_DIR / 'training_history.csv'}")
    return best_model


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description="Train single-stage photo category classifier."
    )
    parser.add_argument("--dataset", type=Path, default=SPLIT_DATASET_DIR)
    parser.add_argument("--seed", type=int, default=SEED)
    parser.add_argument("--epochs", type=int, default=25)
    parser.add_argument("--fine-tune-from", type=int, default=110)
    parser.add_argument("--learning-rate", type=float, default=7e-6)
    parser.add_argument("--dropout", type=float, default=0.35)
    parser.add_argument("--dense-units", type=int, default=192)
    parser.add_argument("--label-smoothing", type=float, default=0.03)
    parser.add_argument("--patience", type=int, default=7)
    return parser.parse_args()


if __name__ == "__main__":
    train(parse_args())
