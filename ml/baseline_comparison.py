import argparse
import csv
import json
from pathlib import Path

import matplotlib.pyplot as plt
import numpy as np
import tensorflow as tf
from sklearn.metrics import (
    accuracy_score,
    balanced_accuracy_score,
    classification_report,
    confusion_matrix,
    f1_score,
)

from config import CLASSES, MODEL_PATH, REPORTS_DIR, SEED, SPLIT_DATASET_DIR
from evaluate_model import collect_predictions, save_confusion_matrix
from train_model import create_model


def evaluate_in_memory_model(
    model: tf.keras.Model,
    dataset_dir: Path,
    split: str,
    model_name: str,
) -> dict:
    split_dir = dataset_dir / split
    y_true, y_pred, confidences, paths = collect_predictions(
        model,
        split_dir,
        legacy_rescale=False,
    )
    if not y_true:
        raise RuntimeError(f"No images found in {split_dir}")

    report = classification_report(
        y_true,
        y_pred,
        target_names=CLASSES,
        output_dict=True,
        zero_division=0,
    )
    matrix = confusion_matrix(y_true, y_pred, labels=list(range(len(CLASSES))))

    errors = []
    for true_idx, pred_idx, confidence, path in zip(y_true, y_pred, confidences, paths):
        if true_idx != pred_idx:
            errors.append(
                {
                    "path": str(path),
                    "true": CLASSES[true_idx],
                    "predicted": CLASSES[pred_idx],
                    "confidence": round(float(confidence), 4),
                }
            )

    return {
        "name": model_name,
        "split": split,
        "samples": len(y_true),
        "accuracy": accuracy_score(y_true, y_pred),
        "balanced_accuracy": balanced_accuracy_score(y_true, y_pred),
        "macro_f1": f1_score(y_true, y_pred, average="macro"),
        "weighted_f1": f1_score(y_true, y_pred, average="weighted"),
        "classification_report": report,
        "confusion_matrix": matrix.tolist(),
        "errors_count": len(errors),
        "errors_preview": errors[:20],
    }


def class_rows(before: dict, after: dict) -> list[dict]:
    rows = []
    for class_name in CLASSES:
        before_report = before["classification_report"][class_name]
        after_report = after["classification_report"][class_name]
        rows.append(
            {
                "class": class_name,
                "support": int(after_report["support"]),
                "before_precision": before_report["precision"],
                "before_recall": before_report["recall"],
                "before_f1": before_report["f1-score"],
                "after_precision": after_report["precision"],
                "after_recall": after_report["recall"],
                "after_f1": after_report["f1-score"],
                "delta_f1": after_report["f1-score"] - before_report["f1-score"],
            }
        )
    return rows


def save_class_csv(rows: list[dict], path: Path) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    with path.open("w", newline="", encoding="utf-8") as file:
        writer = csv.DictWriter(file, fieldnames=list(rows[0].keys()))
        writer.writeheader()
        writer.writerows(rows)


def save_summary_plot(before: dict, after: dict, rows: list[dict], path: Path) -> None:
    labels = ["accuracy", "balanced_accuracy", "macro_f1", "weighted_f1"]
    before_values = [before[label] for label in labels]
    after_values = [after[label] for label in labels]

    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(15, 5))

    x = np.arange(len(labels))
    width = 0.35
    ax1.bar(x - width / 2, before_values, width, label="before training")
    ax1.bar(x + width / 2, after_values, width, label="after training")
    ax1.set_xticks(x)
    ax1.set_xticklabels(labels, rotation=25, ha="right")
    ax1.set_ylim(0, 1.05)
    ax1.set_title("Overall Metrics")
    ax1.legend()
    ax1.grid(axis="y", alpha=0.3)

    class_names = [row["class"] for row in rows]
    before_f1 = [row["before_f1"] for row in rows]
    after_f1 = [row["after_f1"] for row in rows]
    x2 = np.arange(len(class_names))
    ax2.bar(x2 - width / 2, before_f1, width, label="before training")
    ax2.bar(x2 + width / 2, after_f1, width, label="after training")
    ax2.set_xticks(x2)
    ax2.set_xticklabels(class_names, rotation=25, ha="right")
    ax2.set_ylim(0, 1.05)
    ax2.set_title("Per-Class F1")
    ax2.legend()
    ax2.grid(axis="y", alpha=0.3)

    fig.tight_layout()
    path.parent.mkdir(parents=True, exist_ok=True)
    fig.savefig(path, dpi=150, bbox_inches="tight")
    plt.close(fig)


def print_summary(before: dict, after: dict, rows: list[dict]) -> None:
    print("\nBaseline comparison")
    print("=" * 60)
    for metric in ["accuracy", "balanced_accuracy", "macro_f1", "weighted_f1"]:
        print(
            f"{metric:18s}: before={before[metric]:.4f} "
            f"after={after[metric]:.4f} delta={after[metric] - before[metric]:+.4f}"
        )

    print("\nPer-class F1")
    for row in rows:
        print(
            f"{row['class']:10s}: before={row['before_f1']:.4f} "
            f"after={row['after_f1']:.4f} delta={row['delta_f1']:+.4f}"
        )

    print(f"\nErrors before training: {before['errors_count']}/{before['samples']}")
    print(f"Errors after training:  {after['errors_count']}/{after['samples']}")


def run(args: argparse.Namespace) -> dict:
    tf.keras.utils.set_random_seed(args.seed)
    output_dir = args.output
    output_dir.mkdir(parents=True, exist_ok=True)

    before_model, _ = create_model(dropout=args.dropout)
    after_model = tf.keras.models.load_model(args.model)

    before = evaluate_in_memory_model(
        before_model,
        dataset_dir=args.dataset,
        split=args.split,
        model_name="before_training_imagenet_backbone_random_head",
    )
    after = evaluate_in_memory_model(
        after_model,
        dataset_dir=args.dataset,
        split=args.split,
        model_name="after_training_photo_classifier",
    )

    rows = class_rows(before, after)
    result = {
        "definition": {
            "before_training": (
                "The same single-stage MobileNetV2 architecture with ImageNet "
                "pretrained backbone and a newly initialized 5-class classification "
                "head. No training on the project dataset."
            ),
            "after_training": "The saved single-stage classifier trained on dataset_splits/train.",
        },
        "before": before,
        "after": after,
        "per_class_comparison": rows,
    }

    (output_dir / "baseline_comparison.json").write_text(
        json.dumps(result, ensure_ascii=False, indent=2),
        encoding="utf-8",
    )
    save_class_csv(rows, output_dir / "baseline_per_class.csv")
    save_confusion_matrix(
        np.array(before["confusion_matrix"]),
        output_dir / "confusion_matrix_before.png",
    )
    save_confusion_matrix(
        np.array(after["confusion_matrix"]),
        output_dir / "confusion_matrix_after.png",
    )
    save_summary_plot(before, after, rows, output_dir / "baseline_comparison.png")

    print_summary(before, after, rows)
    print(f"\nSaved report: {output_dir / 'baseline_comparison.json'}")
    print(f"Saved per-class CSV: {output_dir / 'baseline_per_class.csv'}")
    print(f"Saved plot: {output_dir / 'baseline_comparison.png'}")

    return result


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description="Compare the classifier before and after training on project data."
    )
    parser.add_argument("--dataset", type=Path, default=SPLIT_DATASET_DIR)
    parser.add_argument("--model", type=Path, default=MODEL_PATH)
    parser.add_argument("--split", choices=["train", "val", "test"], default="test")
    parser.add_argument("--output", type=Path, default=REPORTS_DIR / "baseline")
    parser.add_argument("--seed", type=int, default=SEED)
    parser.add_argument("--dropout", type=float, default=0.35)
    return parser.parse_args()


if __name__ == "__main__":
    run(parse_args())
