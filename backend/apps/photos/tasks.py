import logging

from celery import shared_task

logger = logging.getLogger(__name__)


@shared_task(bind=True, max_retries=3, default_retry_delay=60)
def process_photo_task(self, photo_id):
    """Запуск классификации, оценки качества и тегирования для одного фото"""
    from apps.photos.models import Category, Photo, Tag
    from apps.photos.services.ml_service import MLService

    try:
        photo = Photo.objects.get(pk=photo_id)
    except Photo.DoesNotExist:
        logger.error("Photo %s not found, skipping", photo_id)
        return

    try:
        ml = MLService()
        result = ml.analyze(photo.image.path)

        if result.get("category"):
            category, _ = Category.objects.get_or_create(name=result["category"])
            photo.category = category

        if result.get("quality_score") is not None:
            photo.quality_score = result["quality_score"]

        if result.get("tags"):
            tag_objects = []
            for tag_name in result["tags"]:
                tag_obj, _ = Tag.objects.get_or_create(name=tag_name)
                tag_objects.append(tag_obj)
            photo.tags.set(tag_objects)

        photo.is_processed = True
        photo.save(
            update_fields=["category", "quality_score", "is_processed", "updated_at"]
        )

        logger.info(
            "Photo %s processed: category=%s, score=%.2f, tags=%s",
            photo_id,
            result.get("category"),
            result.get("quality_score", 0),
            result.get("tags", []),
        )
    except Exception as exc:
        logger.exception("Error processing photo %s", photo_id)
        raise self.retry(exc=exc)


@shared_task
def process_photos_bulk(photo_ids):
    """Массовая обработка фотографий"""
    for pid in photo_ids:
        process_photo_task.delay(pid)
