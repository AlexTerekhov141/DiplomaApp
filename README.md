# PhotoAI Classifier

## Структура
- `backend/` — Django REST API.
- `frontend/` — Flutter-приложение.
- `ml/` — Модели для классификации изображений.

## Установка
1. Бэкенд:
   ```bash
   cd backend
   python -m venv .venv
   # Windows
   .\.venv\Scripts\activate
   # macOS/Linux
   source .venv/bin/activate
   pip install -r requirements.txt
   python manage.py makemigrations
   python manage.py migrate
   python manage.py runserver
   ```
2. Фронтенд:
   ```bash
   cd frontend
   flutter pub get
   flutter run
   ```