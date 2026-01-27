from django.contrib import admin
from .models import Category, Tag, Photo
from django.contrib.auth.models import Group

admin.site.unregister(Group)

@admin.register(Category)
class CategoryAdmin(admin.ModelAdmin):
    list_display = ("name", "created_at")
    search_fields = ("name",)


@admin.register(Tag)
class TagAdmin(admin.ModelAdmin):
    list_display = ("name", "created_at")
    search_fields = ("name",)


@admin.register(Photo)
class PhotoAdmin(admin.ModelAdmin):
    list_display = ("id", "title", "user", "category", "is_processed", "quality_score", "uploaded_at")
    list_filter = ("is_processed", "category", "uploaded_at")
    search_fields = ("title", "description", "user__username")
    filter_horizontal = ("tags",)
    readonly_fields = ("quality_score", "is_processed", "uploaded_at", "updated_at")
