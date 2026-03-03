# PhotoAI Classifier

## Структура
- `backend/` — Django REST API.
- `frontend/` — Flutter-приложение.
- `ml/` — Модели для классификации изображений.

## Установка
### 1. Бэкенд:
   #### 1.1 Базовая настройка
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
   #### 1.2 Redis/Celery
   ```bash
   # Предварительно запускаем Docker Desktop + открываем новый терминал
   docker run -d -p 6379:6379 --name redis redis
   cd backend
   celery -A config worker --loglevel=info --pool=solo
   ```
### 2. Фронтенд:
   ```bash
   cd frontend
   flutter pub get
   flutter run
   ```