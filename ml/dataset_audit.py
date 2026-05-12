import argparse
import hashlib
import json
from collections import defaultdict
from pathlib import Path

from PIL import Image, UnidentifiedImageError

from config import CLASSES, RAW_DATASET_DIR, REPORTS_DIR, SPLIT_DATASET_DIR

IMAGE_EXTENSIONS = {".jpg", ".jpeg", ".png", ".bmp", ".webp"}


def image_files(directory: Path) -> list[Path]:
    if not directory.exists():
        return []
    return sorted(
        p for p in directory.iterdir() if p.is_file() and p.suffix.lower() in IMAGE_EXTENSIONS
    )


def md5(path: Path) -> str:
    digest = hashlib.md5()
    with path.open("rb") as file:
        for chunk in iter(lambda: file.read(1024 * 1024), b""):
            digest.update(chunk)
    return digest.hexdigest()


def inspect_image(path: Path) -> dict:
    try:
        with Image.open(path) as img:
            img.verify()
        with Image.open(path) as img:
            width, height = img.size
            mode = img.mode
        return {
            "path": str(path),
            "ok": True,
            "width": width,
            "height": height,
            "mode": mode,
            "hash": md5(path),
        }
    except (OSError, UnidentifiedImageError) as exc:
        return {"path": str(path), "ok": False, "error": str(exc)}


def audit_split(root: Path) -> dict:
    report = {"root": str(root), "splits": {}, "duplicates": []}
    hash_index: dict[str, list[dict]] = defaultdict(list)

    split_names = ["train", "val", "test"] if (root / "train").exists() else ["train"]
    for split in split_names:
        split_dir = root / split
        split_report = {"total": 0, "classes": {}}
        for class_name in CLASSES:
            class_dir = split_dir / class_name
            files = image_files(class_dir)
            class_report = {
                "count": len(files),
                "broken": 0,
                "min_width": None,
                "min_height": None,
                "max_width": None,
                "max_height": None,
            }

            widths: list[int] = []
            heights: list[int] = []
            for path in files:
                info = inspect_image(path)
                if not info["ok"]:
                    class_report["broken"] += 1
                    continue

                widths.append(info["width"])
                heights.append(info["height"])
                hash_index[info["hash"]].append(
                    {"split": split, "class": class_name, "path": str(path)}
                )

            if widths:
                class_report.update(
                    {
                        "min_width": min(widths),
                        "min_height": min(heights),
                        "max_width": max(widths),
                        "max_height": max(heights),
                    }
                )

            split_report["classes"][class_name] = class_report
            split_report["total"] += len(files)

        report["splits"][split] = split_report

    for file_hash, items in hash_index.items():
        if len(items) > 1:
            report["duplicates"].append({"hash": file_hash, "items": items})

    return report


def print_summary(report: dict) -> None:
    print(f"\nDataset: {report['root']}")
    for split, split_report in report["splits"].items():
        print(f"\n{split.upper()} total={split_report['total']}")
        for class_name, class_report in split_report["classes"].items():
            print(
                f"  {class_name:10s} count={class_report['count']:5d} "
                f"broken={class_report['broken']:3d} "
                f"size=({class_report['min_width']}x{class_report['min_height']}.."
                f"{class_report['max_width']}x{class_report['max_height']})"
            )

    cross_split_duplicates = 0
    for duplicate in report["duplicates"]:
        splits = {item["split"] for item in duplicate["items"]}
        if len(splits) > 1:
            cross_split_duplicates += 1

    print(f"\nDuplicate hash groups: {len(report['duplicates'])}")
    print(f"Cross-split duplicate groups: {cross_split_duplicates}")


def main() -> None:
    parser = argparse.ArgumentParser(description="Audit photo classification datasets.")
    parser.add_argument(
        "--root",
        type=Path,
        default=SPLIT_DATASET_DIR if SPLIT_DATASET_DIR.exists() else RAW_DATASET_DIR.parent,
        help="Dataset root. Use dataset_splits or dataset by default.",
    )
    parser.add_argument(
        "--output",
        type=Path,
        default=REPORTS_DIR / "dataset_audit.json",
        help="Path to JSON report.",
    )
    args = parser.parse_args()

    report = audit_split(args.root)
    print_summary(report)

    args.output.parent.mkdir(parents=True, exist_ok=True)
    args.output.write_text(json.dumps(report, ensure_ascii=False, indent=2), encoding="utf-8")
    print(f"\nSaved report: {args.output}")


if __name__ == "__main__":
    main()
