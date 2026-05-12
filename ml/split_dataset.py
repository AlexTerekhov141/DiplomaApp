import argparse
import hashlib
import random
import shutil
from dataclasses import dataclass
from pathlib import Path

from PIL import Image, ImageOps, UnidentifiedImageError

from config import CLASSES, RAW_DATASET_DIR, SEED, SPLIT_DATASET_DIR

IMAGE_EXTENSIONS = {".jpg", ".jpeg", ".png", ".bmp", ".webp"}


@dataclass(frozen=True)
class SplitRatio:
    train: float = 0.70
    val: float = 0.15
    test: float = 0.15

    def validate(self) -> None:
        total = self.train + self.val + self.test
        if abs(total - 1.0) > 1e-6:
            raise ValueError(f"Split ratios must sum to 1.0, got {total}")


def image_files(directory: Path) -> list[Path]:
    if not directory.exists():
        return []
    return sorted(
        p for p in directory.iterdir() if p.is_file() and p.suffix.lower() in IMAGE_EXTENSIONS
    )


def validate_image(path: Path) -> bool:
    try:
        with Image.open(path) as img:
            img.verify()
        return True
    except (OSError, UnidentifiedImageError):
        return False


def md5(path: Path) -> str:
    digest = hashlib.md5()
    with path.open("rb") as file:
        for chunk in iter(lambda: file.read(1024 * 1024), b""):
            digest.update(chunk)
    return digest.hexdigest()


def deduplicate_by_hash(files: list[Path]) -> tuple[list[Path], int]:
    unique: list[Path] = []
    seen: set[str] = set()
    duplicates = 0

    for path in files:
        file_hash = md5(path)
        if file_hash in seen:
            duplicates += 1
            continue
        seen.add(file_hash)
        unique.append(path)

    return unique, duplicates


def copy_image(src: Path, dst: Path) -> None:
    dst.parent.mkdir(parents=True, exist_ok=True)
    shutil.copy2(src, dst)


def augment_image(src: Path, dst: Path, variant: int) -> None:
    """Create conservative train-only augmentations."""
    dst.parent.mkdir(parents=True, exist_ok=True)
    with Image.open(src).convert("RGB") as image:
        image = ImageOps.exif_transpose(image)

        if variant % 4 == 0:
            image = ImageOps.mirror(image)
        elif variant % 4 == 1:
            image = image.rotate(5, resample=Image.Resampling.BILINEAR, expand=False)
        elif variant % 4 == 2:
            image = ImageOps.autocontrast(image)
        else:
            image = image.rotate(-5, resample=Image.Resampling.BILINEAR, expand=False)

        image.save(dst, quality=92)


def split_class(files: list[Path], ratio: SplitRatio, rng: random.Random) -> dict[str, list[Path]]:
    shuffled = files[:]
    rng.shuffle(shuffled)

    total = len(shuffled)
    val_count = max(1, round(total * ratio.val)) if total >= 3 else 0
    test_count = max(1, round(total * ratio.test)) if total >= 3 else 0
    train_count = max(0, total - val_count - test_count)

    return {
        "train": shuffled[:train_count],
        "val": shuffled[train_count : train_count + val_count],
        "test": shuffled[train_count + val_count :],
    }


def prepare_split(
    source_dir: Path,
    output_dir: Path,
    ratio: SplitRatio,
    seed: int,
    min_train_per_class: int,
    balance_strategy: str,
    max_per_class: int | None,
    clean: bool,
) -> None:
    ratio.validate()
    rng = random.Random(seed)

    if clean and output_dir.exists():
        shutil.rmtree(output_dir)

    print(f"Source: {source_dir}")
    print(f"Output: {output_dir}")

    class_files: dict[str, list[Path]] = {}
    duplicate_counts: dict[str, int] = {}

    for class_name in CLASSES:
        class_source = source_dir / class_name
        valid_files = [path for path in image_files(class_source) if validate_image(path)]
        originals, duplicate_count = deduplicate_by_hash(valid_files)
        class_files[class_name] = originals
        duplicate_counts[class_name] = duplicate_count

    if balance_strategy == "min":
        target_per_class = min(len(files) for files in class_files.values())
    elif balance_strategy == "fixed":
        if max_per_class is None:
            raise ValueError("--max-per-class is required when --balance-strategy fixed")
        target_per_class = max_per_class
    else:
        target_per_class = None

    if target_per_class is not None:
        print(f"Balance strategy: {balance_strategy}, target_per_class={target_per_class}")

    for class_name in CLASSES:
        originals = class_files[class_name]
        duplicate_count = duplicate_counts[class_name]

        if target_per_class is not None and len(originals) > target_per_class:
            originals = originals[:]
            rng.shuffle(originals)
            originals = originals[:target_per_class]

        splits = split_class(originals, ratio, rng)

        print(
            f"\n{class_name}: unique={len(class_files[class_name])} used={len(originals)} "
            f"duplicates_removed={duplicate_count} "
            f"train={len(splits['train'])} val={len(splits['val'])} test={len(splits['test'])}"
        )

        for split_name, paths in splits.items():
            for path in paths:
                copy_image(path, output_dir / split_name / class_name / path.name)

        train_paths = splits["train"]
        if not train_paths:
            continue

        needed = max(0, min_train_per_class - len(train_paths))
        for idx in range(needed):
            src = train_paths[idx % len(train_paths)]
            dst_name = f"aug_{idx:04d}_{src.stem}.jpg"
            augment_image(src, output_dir / "train" / class_name / dst_name, idx)

        if needed:
            print(f"  added train-only augmentations={needed}")


def main() -> None:
    parser = argparse.ArgumentParser(
        description=(
            "Create a leakage-free train/val/test split. "
            "Augmentations are generated only in train."
        )
    )
    parser.add_argument("--source", type=Path, default=RAW_DATASET_DIR)
    parser.add_argument("--output", type=Path, default=SPLIT_DATASET_DIR)
    parser.add_argument("--seed", type=int, default=SEED)
    parser.add_argument("--train-ratio", type=float, default=0.70)
    parser.add_argument("--val-ratio", type=float, default=0.15)
    parser.add_argument("--test-ratio", type=float, default=0.15)
    parser.add_argument(
        "--min-train-per-class",
        type=int,
        default=0,
        help="Augment train-only small classes up to this count.",
    )
    parser.add_argument(
        "--balance-strategy",
        choices=["none", "min", "fixed"],
        default="min",
        help=(
            "none: keep all unique images; min: downsample every class to the "
            "smallest class; fixed: downsample every class to --max-per-class."
        ),
    )
    parser.add_argument(
        "--max-per-class",
        type=int,
        default=None,
        help="Target images per class for --balance-strategy fixed.",
    )
    parser.add_argument(
        "--no-clean",
        action="store_true",
        help="Do not remove the existing output directory before splitting.",
    )
    args = parser.parse_args()

    prepare_split(
        source_dir=args.source,
        output_dir=args.output,
        ratio=SplitRatio(args.train_ratio, args.val_ratio, args.test_ratio),
        seed=args.seed,
        min_train_per_class=args.min_train_per_class,
        balance_strategy=args.balance_strategy,
        max_per_class=args.max_per_class,
        clean=not args.no_clean,
    )

    print("\nDone. Next steps:")
    print("  python dataset_audit.py --root dataset_splits")
    print("  python train_model.py")


if __name__ == "__main__":
    main()
