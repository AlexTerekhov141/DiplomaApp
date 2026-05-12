import argparse
from pathlib import Path

import numpy as np
import tensorflow as tf
from PIL import Image, ImageOps

from config import (
    IMG_SIZE,
    MODEL_PATH,
    SPLIT_DATASET_DIR,
    TFLITE_INT8_MODEL_PATH,
    TFLITE_MODEL_PATH,
)

IMAGE_EXTENSIONS = {".jpg", ".jpeg", ".png", ".bmp", ".webp"}


def image_files(directory: Path) -> list[Path]:
    if not directory.exists():
        return []
    return sorted(
        p for p in directory.rglob("*") if p.is_file() and p.suffix.lower() in IMAGE_EXTENSIONS
    )


def representative_dataset(dataset_dir: Path, limit: int):
    paths = image_files(dataset_dir / "train")[:limit]

    def generator():
        for path in paths:
            with Image.open(path).convert("RGB") as image:
                image = ImageOps.exif_transpose(image).resize(IMG_SIZE)
                array = np.asarray(image, dtype=np.float32)
                yield [np.expand_dims(array, axis=0)]

    return generator


def export_float32(model: tf.keras.Model, output_path: Path) -> None:
    converter = tf.lite.TFLiteConverter.from_keras_model(model)
    tflite_model = converter.convert()
    output_path.parent.mkdir(parents=True, exist_ok=True)
    output_path.write_bytes(tflite_model)
    print(f"Saved float32 TFLite: {output_path} ({output_path.stat().st_size / 1024 / 1024:.2f} MB)")


def export_int8(model: tf.keras.Model, dataset_dir: Path, output_path: Path, samples: int) -> None:
    converter = tf.lite.TFLiteConverter.from_keras_model(model)
    converter.optimizations = [tf.lite.Optimize.DEFAULT]
    converter.representative_dataset = representative_dataset(dataset_dir, samples)
    converter.target_spec.supported_ops = [tf.lite.OpsSet.TFLITE_BUILTINS_INT8]
    converter.inference_input_type = tf.uint8
    converter.inference_output_type = tf.uint8
    tflite_model = converter.convert()
    output_path.parent.mkdir(parents=True, exist_ok=True)
    output_path.write_bytes(tflite_model)
    print(f"Saved int8 TFLite: {output_path} ({output_path.stat().st_size / 1024 / 1024:.2f} MB)")


def main() -> None:
    parser = argparse.ArgumentParser(description="Export classifier to TFLite.")
    parser.add_argument("--model", type=Path, default=MODEL_PATH)
    parser.add_argument("--dataset", type=Path, default=SPLIT_DATASET_DIR)
    parser.add_argument("--float-output", type=Path, default=TFLITE_MODEL_PATH)
    parser.add_argument("--int8-output", type=Path, default=TFLITE_INT8_MODEL_PATH)
    parser.add_argument("--representative-samples", type=int, default=200)
    parser.add_argument("--skip-int8", action="store_true")
    args = parser.parse_args()

    model = tf.keras.models.load_model(args.model)
    export_float32(model, args.float_output)
    if not args.skip_int8:
        export_int8(model, args.dataset, args.int8_output, args.representative_samples)


if __name__ == "__main__":
    main()
