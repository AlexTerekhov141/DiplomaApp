import argparse
import hashlib
import shutil
from pathlib import Path

from PIL import Image, UnidentifiedImageError

from config import CLASSES, RAW_DATASET_DIR

IMAGE_EXTENSIONS = {".jpg", ".jpeg", ".png", ".bmp", ".webp"}


def safe_part(value: str) -> str:
    keep = []
    for char in value:
        if char.isalnum() or char in {"-", "_"}:
            keep.append(char)
        else:
            keep.append("_")
    return "".join(keep).strip("_") or "image"


def image_files(source: Path) -> list[Path]:
    return sorted(
        path
        for path in source.rglob("*")
        if path.is_file() and path.suffix.lower() in IMAGE_EXTENSIONS
    )


def validate_image(path: Path) -> bool:
    try:
        with Image.open(path) as image:
            image.verify()
        return True
    except (OSError, UnidentifiedImageError):
        return False


def md5(path: Path) -> str:
    digest = hashlib.md5()
    with path.open("rb") as file:
        for chunk in iter(lambda: file.read(1024 * 1024), b""):
            digest.update(chunk)
    return digest.hexdigest()


def build_name(source_root: Path, path: Path, prefix: str) -> str:
    relative = path.relative_to(source_root)
    stem = safe_part("__".join(relative.with_suffix("").parts))
    digest = md5(path)[:10]
    suffix = path.suffix.lower()
    return f"{prefix}_{stem}_{digest}{suffix}"


def import_dataset(
    source_folder: Path,
    target_folder: Path,
    prefix: str,
    clean_target: bool,
) -> None:
    """Recursively import images from a raw dataset into one class folder."""
    if clean_target and target_folder.exists():
        shutil.rmtree(target_folder)

    target_folder.mkdir(parents=True, exist_ok=True)
    files = image_files(source_folder)

    copied = 0
    skipped_broken = 0
    skipped_duplicate = 0
    seen_hashes: set[str] = set()

    for path in files:
        if not validate_image(path):
            skipped_broken += 1
            continue

        file_hash = md5(path)
        if file_hash in seen_hashes:
            skipped_duplicate += 1
            continue

        seen_hashes.add(file_hash)
        dst = target_folder / build_name(source_folder, path, prefix)
        shutil.copy2(path, dst)
        copied += 1

    print(f"Source: {source_folder}")
    print(f"Target: {target_folder}")
    print(f"Found images: {len(files)}")
    print(f"Copied unique valid images: {copied}")
    print(f"Skipped broken images: {skipped_broken}")
    print(f"Skipped duplicate images: {skipped_duplicate}")


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description="Import a raw recursive image dataset into dataset/train/<class>."
    )
    parser.add_argument("--source", type=Path, required=True)
    parser.add_argument("--class-name", choices=CLASSES, required=True)
    parser.add_argument("--target-root", type=Path, default=RAW_DATASET_DIR)
    parser.add_argument(
        "--prefix",
        default=None,
        help="Filename prefix. Defaults to class name.",
    )
    parser.add_argument(
        "--clean-target",
        action="store_true",
        help="Remove the existing target class folder before import.",
    )
    return parser.parse_args()


if __name__ == "__main__":
    args = parse_args()
    import_dataset(
        source_folder=args.source,
        target_folder=args.target_root / args.class_name,
        prefix=args.prefix or args.class_name,
        clean_target=args.clean_target,
    )