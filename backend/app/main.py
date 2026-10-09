from datetime import datetime
from typing import Literal, Optional
from fastapi import FastAPI, Query, status
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel, Field, field_validator

from app.database import (
    load_trips,
    save_trips,
    generate_trip_hash,
    calculate_daily_summary
    
)


app = FastAPI(title="Driver Journal API")

# Включаем CORS для свободного подключения Flutter (с веб, эмулятора или мобилки)
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

class TripCreate(BaseModel):
    id: Optional[str] = None
    start_time: datetime
    end_time: datetime
    amount: float = Field(..., gt=0, description="Сумма должна быть строго больше 0")
    payment_method: Literal["cash", "card"]
    commission: float = Field(0.0, ge=0, description="Комиссия не может быть отрицательной")

    @field_validator("end_time")
    @classmethod
    def validate_times(cls, end_time: datetime, info):
        start_time = info.data.get("start_time")
        if start_time and end_time <= start_time:
            raise ValueError("Время окончания должно быть строго позже времени начала")
        return end_time

@app.get("/api/trips/summary")
def get_daily_summary(
    date: str = Query(..., pattern=r"^\d{4}-\d{2}-\d{2}$", description="Формат даты: YYYY-MM-DD")
):
    """Возвращает сводку и список поездок за указанный день."""
    trips = load_trips()
    return calculate_daily_summary(trips, date)

@app.post("/api/trips", status_code=status.HTTP_201_CREATED)
def add_trip(trip: TripCreate):
    """Добавляет новую поездку с проверкой на дубликаты."""
    trips = load_trips()
    trip_dict = trip.model_dump()
    
    # Приводим datetime к ISO-формату
    trip_dict["start_time"] = trip.start_time.isoformat()
    trip_dict["end_time"] = trip.end_time.isoformat()

    # Если ID не передан — генерируем хэш поездки
    unique_key = trip.id or generate_trip_hash(trip_dict)
    trip_dict["id"] = unique_key

    # Проверка на дубликаты
    for existing in trips:
        existing_hash = existing.get("id") or generate_trip_hash(existing)
        if existing.get("id") == unique_key or existing_hash == generate_trip_hash(trip_dict):
            # Если дубликат — возвращаем его со статусом duplicate без повторной записи
            return {
                "status": "duplicate",
                "message": "Поездка уже существует",
                "trip": existing
            }

    trips.append(trip_dict)
    save_trips(trips)
    return {"status": "created", "trip": trip_dict}