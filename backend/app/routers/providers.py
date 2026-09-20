from fastapi import APIRouter, HTTPException, Query, Depends, status
from typing import List, Optional
from app.models.schemas import LocalProviderResponse, LocalProviderCreate, LocalProviderUpdate
from app.services.provider_service import provider_service
from app.core.security import require_admin

router = APIRouter(prefix="/providers", tags=["Local Livelihoods & Homestays"])

@router.get("", response_model=List[LocalProviderResponse])
def get_providers(
    destination: Optional[str] = Query(None, description="Filter by destination ID or name"),
    destination_id: Optional[str] = Query(None, description="Filter by destination ID"),
    category: Optional[str] = Query(None, description="Filter by provider category (e.g. HOMESTAY, LOCAL_GUIDE, LOCAL_FOOD, HANDICRAFTS, LOCAL_PRODUCTS, CULTURAL_EXPERIENCE, RENTAL)"),
    min_price: Optional[float] = Query(None, ge=0.0, description="Minimum price filter"),
    max_price: Optional[float] = Query(None, ge=0.0, description="Maximum price filter"),
    price: Optional[float] = Query(None, ge=0.0, description="Max budget price filter"),
    verified: Optional[bool] = Query(None, description="Filter by verification status"),
    verified_only: Optional[bool] = Query(None, description="Backward compatible flag for verified only"),
    search: Optional[str] = Query(None, description="Search keyword in name, description, address")
):
    # Resolve price and verified parameters
    resolved_max_price = max_price if max_price is not None else price
    resolved_verified = verified if verified is not None else (True if verified_only else None)

    return provider_service.list_providers(
        destination_id=destination_id,
        destination=destination,
        category=category,
        min_price=min_price,
        max_price=resolved_max_price,
        verified=resolved_verified,
        search=search
    )

@router.get("/{provider_id}", response_model=LocalProviderResponse)
def get_provider(provider_id: str):
    provider = provider_service.get_provider_by_id(provider_id)
    if not provider:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=f"Local provider with ID '{provider_id}' not found."
        )
    return provider

@router.post("", response_model=LocalProviderResponse, status_code=status.HTTP_201_CREATED)
def create_provider(data: LocalProviderCreate, _ = Depends(require_admin)):
    return provider_service.create_provider(data)

@router.patch("/{provider_id}", response_model=LocalProviderResponse)
def update_provider_patch(provider_id: str, data: LocalProviderUpdate, _ = Depends(require_admin)):
    updated = provider_service.update_provider(provider_id, data)
    if not updated:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=f"Local provider with ID '{provider_id}' not found for update."
        )
    return updated

@router.put("/{provider_id}", response_model=LocalProviderResponse)
def update_provider_put(provider_id: str, data: LocalProviderUpdate, _ = Depends(require_admin)):
    updated = provider_service.update_provider(provider_id, data)
    if not updated:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=f"Local provider with ID '{provider_id}' not found for update."
        )
    return updated

@router.delete("/{provider_id}")
def delete_provider(provider_id: str, _ = Depends(require_admin)):
    success = provider_service.delete_provider(provider_id)
    if not success:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=f"Local provider with ID '{provider_id}' not found for deletion."
        )
    return {"message": "Local provider deleted successfully", "id": provider_id}
