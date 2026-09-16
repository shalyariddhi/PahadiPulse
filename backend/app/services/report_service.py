import uuid
from typing import List, Optional, Dict, Any
from datetime import datetime, timezone
from app.core.firebase import db
from app.models.domain import ReportStatus, ReportCategory
from app.models.schemas import ReportCreate, ReportResponse, ReportStatusUpdate
from app.services.ml_service import ml_service

class ReportService:
    @staticmethod
    def create_report(req: ReportCreate) -> ReportResponse:
        report_id = f"rep_{uuid.uuid4().hex[:8]}"
        
        # Trigger ML classification
        ai_res = ml_service.classify_report(req.description)
        
        dest = db.get_by_id("destinations", req.destinationId)
        dest_name = dest.get("name", req.destinationId) if dest else req.destinationId

        doc = {
            "id": report_id,
            "userId": req.userId or "demo_citizen",
            "userName": req.userName or "Pahadi Citizen",
            "destinationId": req.destinationId,
            "destinationName": dest_name,
            "category": req.category if req.category != ReportCategory.OTHER else ai_res.aiCategory,
            "description": req.description,
            "imageUrl": req.imageUrl or "",
            "latitude": req.latitude,
            "longitude": req.longitude,
            "aiCategory": ai_res.aiCategory,
            "aiSeverity": ai_res.aiSeverity,
            "aiConfidence": ai_res.aiConfidence,
            "aiExplanation": ai_res.aiExplanation,
            "status": ReportStatus.AI_CLASSIFIED,
            "adminNotes": f"AI Recommendation: {ai_res.recommendedAction}",
            "createdAt": datetime.now(timezone.utc).isoformat() + "Z",
            "resolvedAt": None
        }

        db.save("reports", report_id, doc)
        return ReportResponse(**doc)

    @staticmethod
    def list_reports(
        destination_id: Optional[str] = None,
        status: Optional[str] = None,
        category: Optional[str] = None
    ) -> List[ReportResponse]:
        items = db.get_all("reports")
        filtered = []
        for item in items:
            if destination_id and item.get("destinationId") != destination_id:
                continue
            if status and item.get("status", "").upper() != status.upper():
                continue
            if category and item.get("aiCategory", "").upper() != category.upper() and item.get("category", "").upper() != category.upper():
                continue
            filtered.append(ReportResponse(**item))

        # Sort recent reports first
        filtered.sort(key=lambda x: x.createdAt, reverse=True)
        return filtered

    @staticmethod
    def update_status(report_id: str, update: ReportStatusUpdate) -> Optional[ReportResponse]:
        item = db.get_by_id("reports", report_id)
        if not item:
            return None

        item["status"] = update.status
        if update.adminNotes:
            item["adminNotes"] = update.adminNotes
        if update.status == ReportStatus.RESOLVED:
            item["resolvedAt"] = datetime.utcnow().isoformat() + "Z"

        saved = db.save("reports", report_id, item)
        return ReportResponse(**saved)

report_service = ReportService()
