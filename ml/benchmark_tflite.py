import argparse
import json
import time
from pathlib import Path

import numpy as np
import tensorflow as tf
from PIL import Image, ImageOps

from config import IMG_SIZE, REPORTS_DIR, SPLIT_DATASET_DIR, TFLITE_INT8_MODEL_PATH

IMAGE_EXTENSIONS = {".jpg", ".jpeg", ".png", ".bmp", ".webp"}


def image_files(directory: Path, limit: int) -> list[Path]:
    paths = sorted(
        p
        for p in directory.rglob("*")
        if p.is_file() and p.suffix.lower() in IMAGE_EXTENSIONS
    )
    return paths[:limit]


def load_input(path: Path, input_details: dict) -> np.ndarray:
    with Image.open(path).convert("RGB") as image:
        image = ImageOps.exif_transpose(image).resize(IMG_SIZE)
        array = np.asarray(image)

    dtype = input_details["dtype"]
    if dtype == np.float32:
        array = array.astype(np.float32)
    elif dtype == np.uint8:
        array = array.astype(np.uint8)
    else:
        scale, zero_point = input_details["quantization"]
        array = array.astype(np.float32) / scale + zero_point
        array = array.astype(dtype)

    return np.expand_dims(array, axis=0)


def percentile(values: list[float], q: float) -> float:
    if not values:
        return 0.0
    return float(np.percentile(np.asarray(values), q))


def benchmark(args: argparse.Namespace) -> dict:
    interpreter = tf.lite.Interpreter(model_path=str(args.model))
    interpreter.allocate_tensors()
    input_details = interpreter.get_input_details()[0]
    output_details = interpreter.get_output_details()[0]

    paths = image_files(args.dataset / args.split, args.limit)
    if not paths:
        raise RuntimeError(f"No images found in {args.dataset / args.split}")

    # Warm-up removes one-time interpreter allocation noise from the report.
    sample = load_input(paths[0], input_details)
    for _ in range(args.warmup):
        interpreter.set_tensor(input_details["index"], sample)
        interpreter.invoke()
        interpreter.get_tensor(output_details["index"])

    latencies_ms: list[float] = []
    for path in paths:
        array = load_input(path, input_details)
        start = time.perf_counter()
        interpreter.set_tensor(input_details["index"], array)
        interpreter.invoke()
        interpreter.get_tensor(output_details["index"])
        latencies_ms.append((time.perf_counter() - start) * 1000)

    report = {
        "model": str(args.model),
        "model_size_mb": args.model.stat().st_size / 1024 / 1024,
        "samples": len(paths),
        "mean_latency_ms": float(np.mean(latencies_ms)),
        "median_latency_ms": float(np.median(latencies_ms)),
        "p90_latency_ms": percentile(latencies_ms, 90),
        "p95_latency_ms": percentile(latencies_ms, 95),
        "min_latency_ms": min(latencies_ms),
        "max_latency_ms": max(latencies_ms),
        "device_note": ("This is a desktop sanity benchmark."),
    }

    args.output.parent.mkdir(parents=True, exist_ok=True)
    args.output.write_text(
        json.dumps(report, ensure_ascii=False, indent=2), encoding="utf-8"
    )

    print(f"Model size: {report['model_size_mb']:.2f} MB")
    print(f"Samples: {report['samples']}")
    print(f"Mean latency: {report['mean_latency_ms']:.2f} ms")
    print(f"Median latency: {report['median_latency_ms']:.2f} ms")
    print(f"P95 latency: {report['p95_latency_ms']:.2f} ms")
    print(f"Saved report: {args.output}")
    return report


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description="Benchmark a TFLite classifier.")
    parser.add_argument("--model", type=Path, default=TFLITE_INT8_MODEL_PATH)
    parser.add_argument("--dataset", type=Path, default=SPLIT_DATASET_DIR)
    parser.add_argument("--split", choices=["train", "val", "test"], default="test")
    parser.add_argument("--limit", type=int, default=200)
    parser.add_argument("--warmup", type=int, default=10)
    parser.add_argument(
        "--output", type=Path, default=REPORTS_DIR / "tflite_benchmark.json"
    )
    return parser.parse_args()


if __name__ == "__main__":
    benchmark(parse_args())
