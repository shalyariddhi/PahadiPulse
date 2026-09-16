from fastapi import APIRouter
from app.models.schemas import RegionalPressureAggregate
from app.services.pressure_service import pressure_service

router = APIRouter(prefix="/region", tags=["Regional Pressure & State Macro Telemetry"])

@router.get("/pressure", response_model=RegionalPressureAggregate)
def get_regional_aggregate_pressure():
    """
    Returns aggregated Uttarakhand macro regional pressure metrics, status distribution,
    top bottleneck destinations, sustainable alternatives, and district-level pressure averages.
    """
    return pressure_service.get_regional_aggregate()
