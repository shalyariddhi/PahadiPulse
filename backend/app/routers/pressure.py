from fastapi import APIRouter, HTTPException, Query
from app.models.schemas import DestinationForecastResponse
from app.services.destination_service import destination_service
from app.services.ml_service import ml_service

router = APIRouter(prefix="/pressure", tags=["Regional Pressure & Forecasting"])

@router.get("/forecast/{destination_id}", response_model=DestinationForecastResponse)
def get_forecast(destination_id: str, days: int = Query(7, ge=1, le=14)):
    dest = destination_service.get_destination(destination_id)
    if not dest:
        raise HTTPException(status_code=404, detail="Destination not found")
    return ml_service.forecast_pressure(dest.model_dump(), days=days)
