from rest_framework import serializers

from .models import Category, Photo, Tag


class CategorySerializer(serializers.ModelSerializer):
    """Сериализатор для категории"""

    photos_count = serializers.IntegerField(read_only=True, required=False)

    class Meta:
        model = Category
        fields = ("id", "name", "description", "photos_count", "created_at")
        read_only_fields = ("id", "created_at")


class TagSerializer(serializers.ModelSerializer):
    """Сериализатор для тега"""

    photos_count = serializers.IntegerField(read_only=True, required=False)

    class Meta:
        model = Tag
        fields = ("id", "name", "photos_count", "created_at")
        read_only_fields = ("id", "created_at")


class PhotoListSerializer(serializers.ModelSerializer):
    """Сериализатор для списка фотографий"""

    category = CategorySerializer(read_only=True)
    tags = TagSerializer(many=True, read_only=True)

    class Meta:
        model = Photo
        fields = (
            "id",
            "image",
            "title",
            "category",
            "tags",
            "quality_score",
            "is_processed",
            "uploaded_at",
        )
        read_only_fields = ("id", "quality_score", "is_processed", "uploaded_at")


class PhotoDetailSerializer(serializers.ModelSerializer):
    """Сериализатор для деталей фото"""

    category = CategorySerializer(read_only=True)
    tags = TagSerializer(many=True, read_only=True)

    class Meta:
        model = Photo
        fields = (
            "id",
            "image",
            "title",
            "description",
            "category",
            "tags",
            "quality_score",
            "is_processed",
            "uploaded_at",
            "updated_at",
        )
        read_only_fields = (
            "id",
            "quality_score",
            "is_processed",
            "uploaded_at",
            "updated_at",
        )


class PhotoCreateSerializer(serializers.ModelSerializer):
    """Сериализатор для создания/загрузки фото"""

    tags = serializers.PrimaryKeyRelatedField(
        many=True,
        queryset=Tag.objects.all(),
        required=False,
    )

    class Meta:
        model = Photo
        fields = (
            "id",
            "image",
            "title",
            "description",
            "category",
            "tags",
        )
        read_only_fields = ("id",)

    def create(self, validated_data):
        tags = validated_data.pop("tags", [])
        validated_data["user"] = self.context["request"].user
        photo = Photo.objects.create(**validated_data)
        if tags:
            photo.tags.set(tags)
        return photo


class PhotoUpdateSerializer(serializers.ModelSerializer):
    """Сериализатор для обновления фото"""

    tags = serializers.PrimaryKeyRelatedField(
        many=True,
        queryset=Tag.objects.all(),
        required=False,
    )

    class Meta:
        model = Photo
        fields = (
            "title",
            "description",
            "category",
            "tags",
        )

    def update(self, instance, validated_data):
        tags = validated_data.pop("tags", None)
        for attr, value in validated_data.items():
            setattr(instance, attr, value)
        instance.save()
        if tags is not None:
            instance.tags.set(tags)
        return instance


class BulkPhotoUploadSerializer(serializers.Serializer):
    """Сериализатор для массовой загрузки фото"""

    images = serializers.ListField(
        child=serializers.ImageField(),
        allow_empty=False,
        max_length=20,
        help_text="Список изображений (макс. 20 за раз)",
    )
    category = serializers.PrimaryKeyRelatedField(
        queryset=Category.objects.all(),
        required=False,
        allow_null=True,
    )
    tags = serializers.PrimaryKeyRelatedField(
        many=True,
        queryset=Tag.objects.all(),
        required=False,
    )
