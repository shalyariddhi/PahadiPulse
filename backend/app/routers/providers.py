from fastapi import APIRouter, HTTPException, Query, Depends
from typing import List, Optional
from app.models.schemas import LocalProviderResponse, LocalProviderCreate
from app.services.provider_service import provider_service
from app.core.security import require_admin

router = APIRouter(prefix="/providers", tags=["Local Livelihoods & Homestays"])

@router.get("", response_model=List[LocalProviderResponse])
def get_providers(
    destination_id: Optional[str] = Query(None),
    category: Optional[str] = Query(None),
    verified_only: bool = Query(False)
):
    return provider_service.list_providers(
        destination_id=destination_id,
        category=category,
        verified_only=verified_only
    )

@router.post("", response_model=LocalProviderResponse)
def create_provider(data: LocalProviderCreate, _ = Depends(require_admin)):
    return provider_service.create_provider(data)
