from fastapi import APIRouter, HTTPException, Query, Depends, status
from typing import List, Optional, Dict, Any
from app.models.schemas import (
    DestinationResponse,
    DestinationCreate,
    DestinationUpdate,
    PressureDetailResponse,
    PressureHistoryResponse,
    DestinationPredictionResponse
)
from app.services.destination_service import destination_service
from app.services.pressure_service import pressure_service
from app.core.security import require_admin

router = APIRouter(prefix="/destinations", tags=["Destinations & Regional Telemetry"])

@router.get("", response_model=List[DestinationResponse])
def list_destinations(
    district: Optional[str] = Query(None, description="Filter by Uttarakhand district (e.g. Dehradun, Tehri Garhwal, Nainital)"),
    status: Optional[str] = Query(None, description="Filter by pressure status (LOW, MODERATE, HIGH, CRITICAL)"),
    search: Optional[str] = Query(None, description="Keyword search in destination name, district, or tags"),
    min_pressure: Optional[float] = Query(None, ge=0.0, le=100.0, description="Minimum pressure threshold"),
    max_pressure: Optional[float] = Query(None, ge=0.0, le=100.0, description="Maximum pressure threshold")
):
    """
    Returns all registered destinations with dynamically evaluated pressure scores and carrying capacities.
    """
    return destination_service.list_destinations(
        district=district,
        status=status,
        search=search,
        min_pressure=min_pressure,
        max_pressure=max_pressure
    )

@router.get("/{destination_id}", response_model=DestinationResponse)
def get_destination_detail(destination_id: str):
    """
    Returns granular destination details including carrying capacity and sub-score metrics.
    """
    dest = destination_service.get_destination(destination_id)
    if not dest:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail=f"Destination '{destination_id}' not found")
    return dest

@router.get("/{destination_id}/pressure", response_model=PressureDetailResponse)
def get_destination_pressure(
    destination_id: str,
    weight_tourism: Optional[float] = Query(None, ge=0.0, le=1.0, description="Custom weight for tourism (default: 0.30)"),
    weight_water: Optional[float] = Query(None, ge=0.0, le=1.0, description="Custom weight for water (default: 0.25)"),
    weight_waste: Optional[float] = Query(None, ge=0.0, le=1.0, description="Custom weight for waste (default: 0.20)"),
    weight_traffic: Optional[float] = Query(None, ge=0.0, le=1.0, description="Custom weight for traffic (default: 0.15)"),
    weight_environment: Optional[float] = Query(None, ge=0.0, le=1.0, description="Custom weight for environment (default: 0.10)")
):
    """
    Returns the deterministic 5-factor weighted pressure breakdown, status, and transparent explanation for the specified destination.
    Supports configurable custom weights.
    """
    dest = destination_service.get_destination(destination_id)
    if not dest:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail=f"Destination '{destination_id}' not found")
    
    custom_weights = None
    if any(w is not None for w in [weight_tourism, weight_water, weight_waste, weight_traffic, weight_environment]):
        custom_weights = {
            "tourism": weight_tourism if weight_tourism is not None else 0.30,
            "water": weight_water if weight_water is not None else 0.25,
            "waste": weight_waste if weight_waste is not None else 0.20,
            "traffic": weight_traffic if weight_traffic is not None else 0.15,
            "environment": weight_environment if weight_environment is not None else 0.10,
        }
    
    return pressure_service.get_pressure_detail(dest.model_dump(), custom_weights=custom_weights)

@router.get("/{destination_id}/history", response_model=PressureHistoryResponse)
def get_destination_history(
    destination_id: str,
    days: int = Query(14, ge=1, le=90, description="Number of past days for historical pressure records")
):
    """
    Returns historical pressure time-series logs for the specified destination.
    """
    dest = destination_service.get_destination(destination_id)
    if not dest:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail=f"Destination '{destination_id}' not found")
    return pressure_service.get_historical_pressure(destination_id, days=days)

@router.get("/{destination_id}/prediction", response_model=DestinationPredictionResponse)
def get_destination_prediction(
    destination_id: str,
    horizon_days: int = Query(3, ge=1, le=14, description="Forecast horizon in days (1-14)")
):
    """
    Generates ML-based regional pressure prediction using trained ensemble regression models.
    Transparently labels synthetic dataset origin and estimated confidence intervals.
    """
    from app.services.ml_service import ml_service
    dest = destination_service.get_destination(destination_id)
    if not dest:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail=f"Destination '{destination_id}' not found")
    return ml_service.predict_pressure(dest.model_dump(), horizon_days=horizon_days)

@router.post("", response_model=DestinationResponse, status_code=status.HTTP_201_CREATED)
def create_destination(data: DestinationCreate, _ = Depends(require_admin)):
    """
    Admin-protected endpoint to register a new destination.
    """
    return destination_service.create_destination(data)

@router.patch("/{destination_id}", response_model=DestinationResponse)
def update_destination(destination_id: str, updates: DestinationUpdate, _ = Depends(require_admin)):
    """
    Admin-protected endpoint to update carrying capacities or sub-scores with automatic pressure recalculation.
    """
    updated = destination_service.update_destination(destination_id, updates)
    if not updated:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail=f"Destination '{destination_id}' not found")
    return updated
