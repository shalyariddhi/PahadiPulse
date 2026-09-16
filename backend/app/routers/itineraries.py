from fastapi import APIRouter
from app.models.schemas import ItineraryRequest, ItineraryResponse
from app.services.itinerary_service import itinerary_service

router = APIRouter(prefix="/itineraries", tags=["Smart Itinerary Optimization"])

@router.post("/generate", response_model=ItineraryResponse)
def generate_itinerary(req: ItineraryRequest):
    return itinerary_service.generate_itinerary(req)
