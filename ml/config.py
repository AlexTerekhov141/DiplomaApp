from pathlib import Path

CLASSES = ["document", "screenshot", "food", "landscape", "portrait"]

IMG_SIZE = (224, 224)
BATCH_SIZE = 32
SEED = 42

ML_DIR = Path(__file__).resolve().parent

# Оригинальный датасет:
# dataset/train/<class_name>/*.jpg
RAW_DATASET_DIR = ML_DIR / "dataset" / "train"

# Датасет, разделенный на классы:
# dataset_splits/{train,val,test}/<class_name>/*.jpg
SPLIT_DATASET_DIR = ML_DIR / "dataset_splits"

ARTIFACTS_DIR = ML_DIR / "artifacts"
REPORTS_DIR = ML_DIR / "reports"

MODEL_PATH = ARTIFACTS_DIR / "photo_classifier.keras"
LEGACY_MODEL_PATH = ML_DIR / "photo_classifier.h5"
TFLITE_MODEL_PATH = ARTIFACTS_DIR / "photo_classifier_float32.tflite"
TFLITE_INT8_MODEL_PATH = ARTIFACTS_DIR / "photo_classifier_int8.tflite"

LABELS_PATH = ARTIFACTS_DIR / "labels.txt"
