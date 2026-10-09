# Дневник смен водителя (Fullstack: FastAPI + Flutter Web)

Приложение для учета поездок и смен водителя. Позволяет смотреть сводку за день, фильтровать поездки по дате и добавлять новые поездки с автоматической проверкой на дубликаты.

---

## 🛠 Стек технологий

- **Backend**: Python 3.10+, FastAPI, Pydantic v2, Uvicorn, Pytest
- **Frontend**: Flutter Web, Dart, `http`, `intl`
- **Хранение данных**: Файл `trips.json`

---

## 📁 Структура проекта

```text
driver_journal/
├── backend/                  # Серверная часть (FastAPI)
│   ├── app/
│   │   ├── __init__.py
│   │   ├── database.py       # Логика работы с JSON, расчеты и дедупликация
│   │   └── main.py           # FastAPI сервер и эндпоинты
│   ├── tests/
│   │   └── test_journal.py   # Тесты Pytest
│   ├── trips.json            # Файл с данными о поездках
│   └── requirements.txt      # Зависимости Python
│
├── frontend/                 # Клиентская часть (Flutter Web)
│   ├── lib/
│   │   ├── models/           # Модели данных (Trip, DailySummary)
│   │   ├── services/         # Сервис взаимодействия с API
│   │   └── main.dart         # Flutter Web UI
│   ├── test/
│   │   └── unit_test.dart    # Тесты Dart
│   └── pubspec.yaml          # Зависимости Flutter
│
├── .gitignore                # Исключения Git
└── README.md                 # Данная инструкция
```

---

## 🚀 Инструкция по запуску

Для запуска проекта необходимы установленные Python 3.10+ и Flutter SDK.

### 1. Запуск Бэкенда (FastAPI)

Перейдите в папку бэкенда:

```bash
cd backend
```

Создайте и активируйте виртуальное окружение:

- **Windows:**
  ```bash
  python -m venv venv
  venv\Scripts\activate
  ```
- **macOS / Linux:**
  ```bash
  python3 -m venv venv
  source venv/bin/activate
  ```

Установите зависимости:

```bash
pip install -r requirements.txt
```

Запустите сервер:

```bash
uvicorn app.main:app --reload
```

- **Сервер доступен по адресу:** http://127.0.0.1:8000
- **Swagger UI (документация API):** http://127.0.0.1:8000/docs

---

### 2. Запуск Фронтенда (Flutter Web)

В новом окне терминала перейдите в папку фронтенда:

```bash
cd frontend
```

Загрузите зависимости Flutter:

```bash
flutter pub get
```

Запустите веб-клиент в Chrome:

```bash
flutter run -d chrome
```

---

## 🧪 Запуск тестов

**Тесты бэкенда (Pytest):**

```bash
cd backend
pytest
```

_(проверяют расчет сводки, валидацию сумм/времени и защиту от дублей)_

**Тесты фронтенда (Flutter Test):**

```bash
cd frontend
flutter test
```
