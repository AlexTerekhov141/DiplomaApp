from django.urls import include, path
from rest_framework.routers import DefaultRouter

from .views import CategoryListView, PhotoViewSet, TagListView

app_name = "photos"

router = DefaultRouter()
router.register(r"photos", PhotoViewSet, basename="photo")

urlpatterns = [
    path("", include(router.urls)),
    path("categories/", CategoryListView.as_view(), name="category-list"),
    path("tags/", TagListView.as_view(), name="tag-list"),
]
