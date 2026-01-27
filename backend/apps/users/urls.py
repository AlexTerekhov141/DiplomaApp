from django.urls import path
from rest_framework_simplejwt.views import (
    TokenObtainPairView,
    TokenRefreshView,
)

from .views import (
    ChangePasswordView,
    LogoutView,
    UserProfileView,
    UserRegistrationView,
)

app_name = "users"

urlpatterns = [
    # Регистрация
    path("register/", UserRegistrationView.as_view(), name="register"),

    # JWT
    path("login/", TokenObtainPairView.as_view(), name="login"),
    path("refresh/", TokenRefreshView.as_view(), name="token_refresh"),

    # Профиль
    path("profile/", UserProfileView.as_view(), name="profile"),

    # Смена пароля
    path("change-password/", ChangePasswordView.as_view(), name="change_password"),

    # Выход
    path("logout/", LogoutView.as_view(), name="logout"),
]
