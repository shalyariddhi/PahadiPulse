from typing import List, Optional, Dict, Any
from datetime import datetime, timezone
from app.core.firebase import db
from app.models.domain import PressureStatus
from app.models.schemas import DestinationResponse, DestinationCreate, DestinationUpdate
from app.services.pressure_service import pressure_service

class DestinationService:
    @staticmethod
    def list_destinations(
        district: Optional[str] = None,
        status: Optional[str] = None,
        search: Optional[str] = None,
        min_pressure: Optional[float] = None,
        max_pressure: Optional[float] = None,
    ) -> List[DestinationResponse]:
        items = db.get_all("destinations")
        result = []
        for item in items:
            if district and item.get("district", "").lower() != district.lower():
                continue
            
            # Recalculate dynamic pressure score
            t = float(item.get("tourismScore", 20.0))
            w = float(item.get("waterScore", 20.0))
            ws = float(item.get("wasteScore", 20.0))
            tr = float(item.get("trafficScore", 20.0))
            env = float(item.get("environmentScore", 20.0))
            score, stat, _ = pressure_service.calculate_score(t, w, ws, tr, env)

            if status and stat.value.upper() != status.upper():
                continue
            if min_pressure is not None and score < min_pressure:
                continue
            if max_pressure is not None and score > max_pressure:
                continue
            if search:
                s = search.lower()
                name_match = s in item.get("name", "").lower()
                dist_match = s in item.get("district", "").lower()
                tag_match = any(s in tag.lower() for tag in item.get("tags", []))
                if not (name_match or dist_match or tag_match):
                    continue

            item["capacity"] = item.get("capacity") or item.get("capacityDailyTourists", 10000)
            item["pressureScore"] = score
            item["status"] = stat
            item["subScores"] = {
                "tourism": t,
                "water": w,
                "waste": ws,
                "traffic": tr,
                "environment": env
            }
            item["isDemo"] = item.get("isDemo", True)
            item["dataSource"] = item.get("dataSource", "DEMO_SYNTHETIC_HACKATHON")

            result.append(DestinationResponse(**item))

        # Default ordering: lowest pressure score first (promoting low-pressure alternatives)
        result.sort(key=lambda x: x.pressureScore)
        return result

    @staticmethod
    def get_destination(dest_id: str) -> Optional[DestinationResponse]:
        item = db.get_by_id("destinations", dest_id)
        if not item:
            return None
        
        t = float(item.get("tourismScore", 20.0))
        w = float(item.get("waterScore", 20.0))
        ws = float(item.get("wasteScore", 20.0))
        tr = float(item.get("trafficScore", 20.0))
        env = float(item.get("environmentScore", 20.0))
        score, stat, _ = pressure_service.calculate_score(t, w, ws, tr, env)

        item["capacity"] = item.get("capacity") or item.get("capacityDailyTourists", 10000)
        item["pressureScore"] = score
        item["status"] = stat
        item["subScores"] = {
            "tourism": t,
            "water": w,
            "waste": ws,
            "traffic": tr,
            "environment": env
        }
        item["isDemo"] = item.get("isDemo", True)
        item["dataSource"] = item.get("dataSource", "DEMO_SYNTHETIC_HACKATHON")
        return DestinationResponse(**item)

    @staticmethod
    def create_destination(data: DestinationCreate) -> DestinationResponse:
        dest_id = data.id or data.name.lower().replace(" ", "_").replace("'", "")
        doc = data.dict()
        doc["id"] = dest_id
        
        score, stat, _ = pressure_service.calculate_score(
            data.tourismScore, data.waterScore, data.wasteScore,
            data.trafficScore, data.environmentScore
        )
        doc["capacity"] = data.capacity
        doc["pressureScore"] = score
        doc["status"] = stat
        doc["subScores"] = {
            "tourism": data.tourismScore,
            "water": data.waterScore,
            "waste": data.wasteScore,
            "traffic": data.trafficScore,
            "environment": data.environmentScore
        }
        doc["isDemo"] = data.isDemo
        doc["dataSource"] = data.dataSource
        doc["updatedAt"] = datetime.utcnow().isoformat() + "Z"
        
        saved = db.save("destinations", dest_id, doc)
        return DestinationResponse(**saved)

    @staticmethod
    def update_destination(dest_id: str, updates: DestinationUpdate) -> Optional[DestinationResponse]:
        existing = db.get_by_id("destinations", dest_id)
        if not existing:
            return None

        update_dict = updates.model_dump(exclude_unset=True)
        existing.update(update_dict)
        
        t = float(existing.get("tourismScore", 20.0))
        w = float(existing.get("waterScore", 20.0))
        ws = float(existing.get("wasteScore", 20.0))
        tr = float(existing.get("trafficScore", 20.0))
        env = float(existing.get("environmentScore", 20.0))
        score, stat, _ = pressure_service.calculate_score(t, w, ws, tr, env)

        existing["capacity"] = existing.get("capacity") or existing.get("capacityDailyTourists", 10000)
        existing["pressureScore"] = score
        existing["status"] = stat
        existing["subScores"] = {
            "tourism": t,
            "water": w,
            "waste": ws,
            "traffic": tr,
            "environment": env
        }
        existing["updatedAt"] = datetime.now(timezone.utc).isoformat() + "Z"
        
        saved = db.save("destinations", dest_id, existing)
        return DestinationResponse(**saved)

destination_service = DestinationService()
