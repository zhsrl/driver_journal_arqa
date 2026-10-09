import json
import hashlib
from pathlib import Path

# Вычисляем абсолютный путь к папке backend (на уровень выше папки app)
BASE_DIR = Path(__file__).resolve().parent.parent
# Теперь сервер всегда будет искать trips.json именно в папке backend
DATA_FILE = BASE_DIR / "trips.json"

def load_trips() -> list[dict]:
    """Загрузка поездок из JSON-файла."""
    if not DATA_FILE.exists():
        return []
    with open(DATA_FILE, "r", encoding="utf-8") as f:
        try:
            return json.load(f)
        except json.JSONDecodeError:
            return []

def save_trips(trips: list[dict]) -> None:
    """Сохранение поездок в JSON-файл."""
    with open(DATA_FILE, "w", encoding="utf-8") as f:
        json.dump(trips, f, ensure_ascii=False, indent=2)

def generate_trip_hash(trip_data: dict) -> str:
    """
    Генерирует уникальный SHA-256 хэш поездки по ключевым полям.
    Служит для обнаружения повторно отправленной поездки (защита от дублей).
    """
    raw_str = (
        f"{trip_data['start_time']}_"
        f"{trip_data['end_time']}_"
        f"{trip_data['amount']}_"
        f"{trip_data['payment_method']}"
    )
    return hashlib.sha256(raw_str.encode()).hexdigest()

def calculate_daily_summary(trips: list[dict], target_date_str: str) -> dict:
    """Считает сводную статистику за указанный день (YYYY-MM-DD)."""
    filtered = [
        t for t in trips 
        if t["start_time"].startswith(target_date_str)
    ]
    
    total_trips = len(filtered)
    revenue = sum(t["amount"] for t in filtered)
    commission = sum(t["commission"] for t in filtered)
    net_income = revenue - commission
    
    cash_total = sum(t["amount"] for t in filtered if t["payment_method"] == "cash")
    card_total = sum(t["amount"] for t in filtered if t["payment_method"] == "card")

    return {
        "date": target_date_str,
        "total_trips": total_trips,
        "revenue": round(revenue, 2),
        "commission": round(commission, 2),
        "net_income": round(net_income, 2),
        "breakdown": {
            "cash": round(cash_total, 2),
            "card": round(card_total, 2)
        },
        "trips": filtered
    }