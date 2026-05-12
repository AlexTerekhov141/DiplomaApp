import argparse
import csv
import json
import shutil
from pathlib import Path

import matplotlib.pyplot as plt
import numpy as np
import tensorflow as tf
from PIL import Image, ImageOps
from sklearn.metrics import (
    accuracy_score,
    balanced_accuracy_score,
    classification_report,
    confusion_matrix,
    f1_score,
)

from config import (
    CLASSES,
    IMG_SIZE,
    LEGACY_MODEL_PATH,
    MODEL_PATH,
    REPORTS_DIR,
    SPLIT_DATASET_DIR,
)

IMAGE_EXTENSIONS = {".jpg", ".jpeg", ".png", ".bmp", ".webp"}


def image_files(directory: Path) -> list[Path]:
    if not directory.exists():
        return []
    return sorted(
        p
        for p in directory.iterdir()
        if p.is_file() and p.suffix.lower() in IMAGE_EXTENSIONS
    )


def load_image(path: Path, legacy_rescale: bool) -> np.ndarray:
    with Image.open(path).convert("RGB") as image:
        image = ImageOps.exif_transpose(image)
        image = image.resize(IMG_SIZE)
        array = np.asarray(image, dtype=np.float32)
        if legacy_rescale:
            array = array / 255.0
        return np.expand_dims(array, axis=0)


def collect_predictions(
    model: tf.keras.Model, split_dir: Path, legacy_rescale: bool
) -> tuple[list[int], list[int], list[float], list[Path]]:
    y_true: list[int] = []
    y_pred: list[int] = []
    confidences: list[float] = []
    paths: list[Path] = []

    for class_idx, class_name in enumerate(CLASSES):
        for path in image_files(split_dir / class_name):
            preds = model.predict(load_image(path, legacy_rescale), verbose=0)[0]
            pred_idx = int(np.argmax(preds))
            y_true.append(class_idx)
            y_pred.append(pred_idx)
            confidences.append(float(preds[pred_idx]))
            paths.append(path)

    return y_true, y_pred, confidences, paths


def save_confusion_matrix(matrix: np.ndarray, output_path: Path) -> None:
    fig, ax = plt.subplots(figsize=(8, 7))
    image = ax.imshow(matrix, interpolation="nearest", cmap="Blues")
    fig.colorbar(image, ax=ax)
    ax.set(
        xticks=np.arange(len(CLASSES)),
        yticks=np.arange(len(CLASSES)),
        xticklabels=CLASSES,
        yticklabels=CLASSES,
        ylabel="True label",
        xlabel="Predicted label",
        title="Confusion Matrix",
    )
    plt.setp(ax.get_xticklabels(), rotation=45, ha="right", rotation_mode="anchor")

    threshold = matrix.max() / 2 if matrix.size else 0
    for i in range(matrix.shape[0]):
        for j in range(matrix.shape[1]):
            ax.text(
                j,
                i,
                str(matrix[i, j]),
                ha="center",
                va="center",
                color="white" if matrix[i, j] > threshold else "black",
            )

    fig.tight_layout()
    output_path.parent.mkdir(parents=True, exist_ok=True)
    fig.savefig(output_path, dpi=150, bbox_inches="tight")
    plt.close(fig)


def save_errors(
    y_true: list[int],
    y_pred: list[int],
    confidences: list[float],
    paths: list[Path],
    output_dir: Path,
    limit: int,
) -> list[dict]:
    errors = []
    error_dir = output_dir / "errors"
    if error_dir.exists():
        shutil.rmtree(error_dir)
    error_dir.mkdir(parents=True, exist_ok=True)

    for true_idx, pred_idx, confidence, path in zip(y_true, y_pred, confidences, paths):
        if true_idx == pred_idx:
            continue

        item = {
            "path": str(path),
            "true": CLASSES[true_idx],
            "predicted": CLASSES[pred_idx],
            "confidence": round(confidence, 4),
        }
        errors.append(item)

        if len(errors) <= limit:
            dst = (
                error_dir
                / f"{len(errors):03d}_{CLASSES[true_idx]}_as_{CLASSES[pred_idx]}_{path.name}"
            )
            shutil.copy2(path, dst)

    return errors


def evaluate(args: argparse.Namespace) -> dict:
    model_path = args.model
    if not model_path.exists() and LEGACY_MODEL_PATH.exists():
        model_path = LEGACY_MODEL_PATH

    model = tf.keras.models.load_model(model_path)
    legacy_rescale = model_path.name.endswith(".h5")
    split_dir = args.dataset / args.split
    y_true, y_pred, confidences, paths = collect_predictions(
        model, split_dir, legacy_rescale
    )

    if not y_true:
        raise RuntimeError(f"No images found in {split_dir}")

    report_dict = classification_report(
        y_true,
        y_pred,
        target_names=CLASSES,
        output_dict=True,
        zero_division=0,
    )
    matrix = confusion_matrix(y_true, y_pred, labels=list(range(len(CLASSES))))

    summary = {
        "model": str(model_path),
        "split": args.split,
        "samples": len(y_true),
        "accuracy": accuracy_score(y_true, y_pred),
        "balanced_accuracy": balanced_accuracy_score(y_true, y_pred),
        "macro_f1": f1_score(y_true, y_pred, average="macro"),
        "weighted_f1": f1_score(y_true, y_pred, average="weighted"),
        "classification_report": report_dict,
        "confusion_matrix": matrix.tolist(),
    }

    output_dir = args.output
    output_dir.mkdir(parents=True, exist_ok=True)
    errors = save_errors(
        y_true, y_pred, confidences, paths, output_dir, args.error_limit
    )
    summary["errors"] = errors

    (output_dir / "metrics.json").write_text(
        json.dumps(summary, ensure_ascii=False, indent=2),
        encoding="utf-8",
    )
    save_confusion_matrix(matrix, output_dir / "confusion_matrix.png")

    with (output_dir / "predictions.csv").open(
        "w", newline="", encoding="utf-8"
    ) as file:
        writer = csv.DictWriter(
            file, fieldnames=["path", "true", "predicted", "confidence", "correct"]
        )
        writer.writeheader()
        for true_idx, pred_idx, confidence, path in zip(
            y_true, y_pred, confidences, paths
        ):
            writer.writerow(
                {
                    "path": path,
                    "true": CLASSES[true_idx],
                    "predicted": CLASSES[pred_idx],
                    "confidence": round(confidence, 4),
                    "correct": true_idx == pred_idx,
                }
            )

    print(f"Model: {model_path}")
    print(f"Split: {split_dir}")
    print(f"Samples: {summary['samples']}")
    print(f"Accuracy: {summary['accuracy']:.4f}")
    print(f"Balanced accuracy: {summary['balanced_accuracy']:.4f}")
    print(f"Macro F1: {summary['macro_f1']:.4f}")
    print(f"Weighted F1: {summary['weighted_f1']:.4f}")
    print("\nPer-class report:")
    print(
        classification_report(
            y_true, y_pred, target_names=CLASSES, digits=4, zero_division=0
        )
    )
    print(f"Saved report: {output_dir / 'metrics.json'}")
    print(f"Saved confusion matrix: {output_dir / 'confusion_matrix.png'}")

    return summary


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description="Evaluate photo classifier.")
    parser.add_argument("--model", type=Path, default=MODEL_PATH)
    parser.add_argument("--dataset", type=Path, default=SPLIT_DATASET_DIR)
    parser.add_argument("--split", choices=["train", "val", "test"], default="test")
    parser.add_argument("--output", type=Path, default=REPORTS_DIR / "evaluation")
    parser.add_argument("--error-limit", type=int, default=50)
    return parser.parse_args()


if __name__ == "__main__":
    evaluate(parse_args())
