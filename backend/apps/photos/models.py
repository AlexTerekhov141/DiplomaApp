from django.db import models
from django.contrib.auth import get_user_model

User = get_user_model()


class Category(models.Model):
    """Категории для фото"""

    name = models.CharField(max_length=100, unique=True, verbose_name="Название")
    description = models.TextField(blank=True, verbose_name="Описание")
    created_at = models.DateTimeField(auto_now_add=True, verbose_name="Создано")

    class Meta:
        verbose_name = "Категория"
        verbose_name_plural = "Категории"
        ordering = ["name"]

    def __str__(self):
        return self.name


class Tag(models.Model):
    """Теги для фото"""

    name = models.CharField(max_length=50, unique=True, verbose_name="Название")
    created_at = models.DateTimeField(auto_now_add=True, verbose_name="Создано")

    class Meta:
        verbose_name = "Тег"
        verbose_name_plural = "Теги"
        ordering = ["name"]

    def __str__(self):
        return self.name


class Photo(models.Model):
    """Модель фотографии"""

    user = models.ForeignKey(
        User,
        on_delete=models.CASCADE,
        related_name="photos",
        verbose_name="Пользователь",
    )
    image = models.ImageField(upload_to="photos/%Y/%m/%d/", verbose_name="Изображение")
    title = models.CharField(max_length=255, blank=True, verbose_name="Название")
    description = models.TextField(blank=True, verbose_name="Описание")
    category = models.ForeignKey(
        Category,
        on_delete=models.SET_NULL,
        null=True,
        blank=True,
        related_name="photos",
        verbose_name="Категория",
    )
    tags = models.ManyToManyField(
        Tag,
        blank=True,
        related_name="photos",
        verbose_name="Теги",
    )
    quality_score = models.FloatField(
        null=True,
        blank=True,
        verbose_name="Оценка качества",
        help_text="Оценка качества от ML-модели (0-1)",
    )
    is_processed = models.BooleanField(
        default=False,
        verbose_name="Обработано",
        help_text="Флаг завершения ML-обработки",
    )
    uploaded_at = models.DateTimeField(auto_now_add=True, verbose_name="Создано")
    updated_at = models.DateTimeField(auto_now=True, verbose_name="Обновлено")

    class Meta:
        verbose_name = "Фотография"
        verbose_name_plural = "Фотографии"
        ordering = ["-uploaded_at"]

    def __str__(self):
        return f"{self.title or 'Photo'} ({self.pk})"
