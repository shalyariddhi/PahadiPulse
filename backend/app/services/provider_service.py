import uuid
from typing import List, Optional, Dict, Any
from app.core.firebase import db
from app.models.schemas import LocalProviderResponse, LocalProviderCreate, LocalProviderUpdate
from app.models.domain import ProviderCategory

class ProviderService:
    @staticmethod
    def list_providers(
        destination_id: Optional[str] = None,
        destination: Optional[str] = None,
        category: Optional[str] = None,
        min_price: Optional[float] = None,
        max_price: Optional[float] = None,
        verified: Optional[bool] = None,
        search: Optional[str] = None
    ) -> List[LocalProviderResponse]:
        items = db.get_all("local_providers")
        destinations = {d["id"]: d["name"] for d in db.get_all("destinations")}
        
        target_dest = destination_id or destination

        result = []
        for item in items:
            dest_id = item.get("destinationId", "")
            dest_name = destinations.get(dest_id, item.get("destinationName", dest_id))
            item["destinationName"] = dest_name

            # Filter by destination (id or name match)
            if target_dest:
                target_lower = target_dest.strip().lower()
                if dest_id.lower() != target_lower and dest_name.lower() != target_lower:
                    continue

            # Filter by category
            if category:
                cat_val = category.strip().upper().replace(" ", "_")
                if item.get("category", "").upper() != cat_val:
                    continue

            # Filter by verified
            if verified is not None:
                if bool(item.get("verified", True)) != verified:
                    continue

            # Filter by price range
            price_val = float(item.get("priceStartingINR", item.get("price", 0.0)))
            if min_price is not None and price_val < min_price:
                continue
            if max_price is not None and price_val > max_price:
                continue

            # Filter by search
            if search:
                s_lower = search.strip().lower()
                name_match = s_lower in item.get("name", "").lower()
                desc_match = s_lower in item.get("description", "").lower()
                loc_match = s_lower in item.get("locationAddress", "").lower()
                dest_match = s_lower in dest_name.lower()
                if not (name_match or desc_match or loc_match or dest_match):
                    continue

            result.append(LocalProviderResponse(**item))

        result.sort(key=lambda x: x.rating, reverse=True)
        return result

    @staticmethod
    def get_provider_by_id(provider_id: str) -> Optional[LocalProviderResponse]:
        doc = db.get_by_id("local_providers", provider_id)
        if not doc:
            return None
        
        dest_id = doc.get("destinationId", "")
        dest = db.get_by_id("destinations", dest_id)
        doc["destinationName"] = dest.get("name", doc.get("destinationName", dest_id)) if dest else doc.get("destinationName", dest_id)
        return LocalProviderResponse(**doc)

    @staticmethod
    def create_provider(data: LocalProviderCreate) -> LocalProviderResponse:
        prov_id = data.id or f"prov_{uuid.uuid4().hex[:8]}"
        doc = data.model_dump()
        doc["id"] = prov_id
        
        dest = db.get_by_id("destinations", data.destinationId)
        doc["destinationName"] = dest.get("name", data.destinationId) if dest else data.destinationId

        saved = db.save("local_providers", prov_id, doc)
        return LocalProviderResponse(**saved)

    @staticmethod
    def update_provider(provider_id: str, data: LocalProviderUpdate) -> Optional[LocalProviderResponse]:
        doc = db.get_by_id("local_providers", provider_id)
        if not doc:
            return None

        update_data = {k: v for k, v in data.model_dump().items() if v is not None}
        doc.update(update_data)

        if "destinationId" in update_data:
            dest = db.get_by_id("destinations", update_data["destinationId"])
            doc["destinationName"] = dest.get("name", update_data["destinationId"]) if dest else update_data["destinationId"]
        else:
            dest_id = doc.get("destinationId", "")
            dest = db.get_by_id("destinations", dest_id)
            doc["destinationName"] = dest.get("name", doc.get("destinationName", dest_id)) if dest else doc.get("destinationName", dest_id)

        saved = db.save("local_providers", provider_id, doc)
        return LocalProviderResponse(**saved)

    @staticmethod
    def delete_provider(provider_id: str) -> bool:
        doc = db.get_by_id("local_providers", provider_id)
        if not doc:
            return False
        return db.delete("local_providers", provider_id)

provider_service = ProviderService()
