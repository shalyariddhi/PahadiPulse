import uuid
from typing import List, Optional, Dict, Any
from app.core.firebase import db
from app.models.schemas import LocalProviderResponse, LocalProviderCreate
from app.models.domain import ProviderCategory

class ProviderService:
    @staticmethod
    def list_providers(
        destination_id: Optional[str] = None,
        category: Optional[str] = None,
        verified_only: bool = False
    ) -> List[LocalProviderResponse]:
        items = db.get_all("local_providers")
        destinations = {d["id"]: d["name"] for d in db.get_all("destinations")}
        
        result = []
        for item in items:
            if destination_id and item.get("destinationId") != destination_id:
                continue
            if category and item.get("category") != category:
                continue
            if verified_only and not item.get("verified", False):
                continue
            
            dest_id = item.get("destinationId", "")
            item["destinationName"] = destinations.get(dest_id, dest_id)
            result.append(LocalProviderResponse(**item))

        result.sort(key=lambda x: x.rating, reverse=True)
        return result

    @staticmethod
    def create_provider(data: LocalProviderCreate) -> LocalProviderResponse:
        prov_id = data.id or f"prov_{uuid.uuid4().hex[:8]}"
        doc = data.dict()
        doc["id"] = prov_id
        
        dest = db.get_by_id("destinations", data.destinationId)
        doc["destinationName"] = dest.get("name", data.destinationId) if dest else data.destinationId

        saved = db.save("local_providers", prov_id, doc)
        return LocalProviderResponse(**saved)

provider_service = ProviderService()
