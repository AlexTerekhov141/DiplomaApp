from django.db.models import Count
from rest_framework import generics, status, viewsets
from rest_framework.decorators import action
from rest_framework.parsers import FormParser, MultiPartParser
from rest_framework.permissions import IsAuthenticated
from rest_framework.response import Response

from .models import Category, Photo, Tag
from .serializers import (
    BulkPhotoUploadSerializer,
    CategorySerializer,
    PhotoCreateSerializer,
    PhotoDetailSerializer,
    PhotoListSerializer,
    PhotoUpdateSerializer,
    TagSerializer,
)


class PhotoViewSet(viewsets.ModelViewSet):
    """
    API эндпоинты для фото

    list:    GET    /api/photos/
    create:  POST   /api/photos/
    read:    GET    /api/photos/{id}/
    update:  PUT    /api/photos/{id}/
    partial: PATCH  /api/photos/{id}/
    delete:  DELETE /api/photos/{id}/
    """

    permission_classes = (IsAuthenticated,)
    parser_classes = (MultiPartParser, FormParser)

    def get_queryset(self):
        """Фото с фильтрацией"""
        qs = (
            Photo.objects.filter(user=self.request.user)
            .select_related("category")
            .prefetch_related("tags")
        )

        # Фильтр по категории
        category_id = self.request.query_params.get("category")
        if category_id:
            qs = qs.filter(category_id=category_id)

        # Фильтр по тегу
        tag_id = self.request.query_params.get("tag")
        if tag_id:
            qs = qs.filter(tags__id=tag_id)

        # Фильтр по статусу обработки
        is_processed = self.request.query_params.get("is_processed")
        if is_processed is not None:
            qs = qs.filter(is_processed=is_processed.lower() == "true")

        # Поиск по названию/описанию
        search = self.request.query_params.get("search")
        if search:
            qs = qs.filter(title__icontains=search) | qs.filter(
                description__icontains=search
            )

        return qs.distinct()

    def get_serializer_class(self):
        if self.action == "list":
            return PhotoListSerializer
        if self.action == "retrieve":
            return PhotoDetailSerializer
        if self.action in ("update", "partial_update"):
            return PhotoUpdateSerializer
        if self.action == "bulk_upload":
            return BulkPhotoUploadSerializer
        return PhotoCreateSerializer

    @action(detail=False, methods=["post"], url_path="bulk-upload")
    def bulk_upload(self, request):
        """
        Массовая загрузка фото

        POST /api/photos/bulk-upload/
        """
        serializer = self.get_serializer(data=request.data)
        serializer.is_valid(raise_exception=True)

        images = serializer.validated_data["images"]
        category = serializer.validated_data.get("category")
        tags = serializer.validated_data.get("tags", [])

        photos = []
        for image in images:
            photo = Photo.objects.create(
                user=request.user,
                image=image,
                category=category,
            )
            if tags:
                photo.tags.set(tags)
            photos.append(photo)

        result = PhotoListSerializer(photos, many=True, context={"request": request})
        return Response(result.data, status=status.HTTP_201_CREATED)

    @action(detail=False, methods=["get"], url_path="best")
    def best(self, request):
        """
        Лучшие фото пользователя (сортируем по quality_score)

        GET /api/photos/best/
        """
        qs = (
            Photo.objects.filter(
                user=request.user,
                is_processed=True,
                quality_score__isnull=False,
            )
            .select_related("category")
            .prefetch_related("tags")
            .order_by("-quality_score")
        )

        page = self.paginate_queryset(qs)
        if page is not None:
            serializer = PhotoListSerializer(
                page, many=True, context={"request": request}
            )
            return self.get_paginated_response(serializer.data)

        serializer = PhotoListSerializer(qs, many=True, context={"request": request})
        return Response(serializer.data)


class CategoryListView(generics.ListAPIView):
    """
    Список всех категорий

    GET /api/categories/
    """

    permission_classes = (IsAuthenticated,)
    serializer_class = CategorySerializer
    queryset = Category.objects.annotate(photos_count=Count("photos"))
    pagination_class = None


class TagListView(generics.ListAPIView):
    """
    Список всех тегов

    GET /api/tags/
    """

    permission_classes = (IsAuthenticated,)
    serializer_class = TagSerializer
    queryset = Tag.objects.annotate(photos_count=Count("photos"))
    pagination_class = None
