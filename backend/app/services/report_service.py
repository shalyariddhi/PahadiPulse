import os
import re
import uuid
import base64
import logging
from typing import List, Optional, Dict, Any
from datetime import datetime, timezone
from fastapi import HTTPException, status
from app.core.firebase import db
from app.config import settings
from app.models.domain import (
    ReportStatus,
    ReportCategory,
    ReportSeverity,
    severity_to_numeric,
    numeric_to_severity
)
from app.models.schemas import (
    ReportCreate,
    ReportResponse,
    ReportStatusUpdate,
    ReportReviewRequest,
    ImageUploadResponse
)
from app.services.ml_service import ml_service

logger = logging.getLogger("pahadipulse.reports")

ALLOWED_IMAGE_TYPES = {"image/jpeg", "image/png", "image/webp", "image/jpg"}
MAX_IMAGE_SIZE_BYTES = 5 * 1024 * 1024  # 5 MB

def sanitize_text(text: str) -> str:
    """Removes null bytes and strips HTML tags from user text input."""
    if not text:
        return ""
    text = text.replace("\x00", "")
    # Strip HTML tags
    clean = re.sub(r'<[^>]*>', '', text)
    return clean.strip()

def validate_image_magic_bytes(file_bytes: bytes, content_type: str) -> bool:
    """Verifies file binary magic bytes match the declared image format."""
    if len(file_bytes) < 12:
        return False
    # JPEG magic bytes: FF D8 FF
    if "jpeg" in content_type or "jpg" in content_type:
        return file_bytes[:3] == b"\xff\xd8\xff"
    # PNG magic bytes: 89 50 4E 47 0D 0A 1A 0A
    if "png" in content_type:
        return file_bytes[:8] == b"\x89PNG\r\n\x1a\n"
    # WebP magic bytes: RIFF....WEBP
    if "webp" in content_type:
        return file_bytes[:4] == b"RIFF" and file_bytes[8:12] == b"WEBP"
    return True

class ReportService:
    def __init__(self):
        self.uploads_dir = os.path.join(db.data_dir, "uploads")
        os.makedirs(self.uploads_dir, exist_ok=True)

    def create_report(
        self,
        req: ReportCreate,
        auth_uid: Optional[str] = None,
        auth_name: Optional[str] = None
    ) -> ReportResponse:
        report_id = f"rep_{uuid.uuid4().hex[:8]}"
        
        # Sanitize input description
        sanitized_desc = sanitize_text(req.description)
        
        # Trigger lightweight ML/NLP classification for category, severity, and action
        ai_res = ml_service.classify_report(sanitized_desc, image_url=req.imageUrl)
        
        # Resolve destination name
        dest = db.get_by_id("destinations", req.destinationId)
        if dest:
            dest_name = dest.get("name", req.destinationId.title())
        elif req.destinationId.lower() in ["custom", "current_location", "gps", "other"]:
            dest_name = f"Geo-Location ({req.latitude:.3f}°N, {req.longitude:.3f}°E)"
        else:
            dest_name = req.destinationId.replace("_", " ").title()

        doc_user_id = auth_uid or req.userId or "citizen_demo_user"
        doc_user_name = auth_name or req.userName or "Pahadi Citizen"

        final_category = req.category if (req.category and req.category != ReportCategory.OTHER) else ai_res.category

        doc = {
            "id": report_id,
            "userId": doc_user_id,
            "userName": doc_user_name,
            "destinationId": req.destinationId,
            "destinationName": dest_name,
            "category": final_category,
            "description": sanitized_desc,
            "imageUrl": req.imageUrl or "",
            "latitude": float(req.latitude),
            "longitude": float(req.longitude),
            "userSeverity": req.userSeverity,
            "severity": ai_res.severity,
            "aiCategory": ai_res.category,
            "aiSeverity": severity_to_numeric(ai_res.severity),
            "aiConfidence": round(ai_res.confidence, 3),
            "aiExplanation": ai_res.explanation,
            "status": ReportStatus.AI_CLASSIFIED,
            "adminNotes": f"AI Recommendation: {ai_res.recommendedAction}",
            "adminReviewed": False,
            "reviewedBy": None,
            "createdAt": datetime.now(timezone.utc).isoformat() + "Z",
            "resolvedAt": None,
            "isDemo": False
        }

        # Persist report metadata in Firestore / backend db
        saved_doc = db.save("reports", report_id, doc)

        # Trigger proactive Admin In-App Alert for high/critical urgency reports
        try:
            from app.services.notification_service import notification_service
            from app.models.domain import NotificationType, UserRole
            from app.models.schemas import NotificationCreate

            if ai_res.severity in [ReportSeverity.CRITICAL, ReportSeverity.HIGH]:
                notif_type = NotificationType.CRITICAL_REPORT if ai_res.severity == ReportSeverity.CRITICAL else NotificationType.HIGH_SEVERITY_ISSUE
                notification_service.create_notification(NotificationCreate(
                    title=f"Incident Alert: {final_category.value} ({dest_name})",
                    message=f"[{ai_res.severity.value}] {sanitized_desc[:120]}... Dispatch recommendation: {ai_res.recommendedAction}",
                    type=notif_type,
                    relatedEntityId=report_id,
                    relatedEntityType="report",
                    targetRole=UserRole.ADMIN,
                    metadata={"severity": ai_res.severity.value, "category": final_category.value, "destination": dest_name}
                ))
        except Exception as e:
            logger.warning(f"Failed to create notification for report {report_id}: {e}")

        return ReportResponse(**saved_doc)

    def get_report_by_id(self, report_id: str) -> Optional[ReportResponse]:
        doc = db.get_by_id("reports", report_id)
        if not doc:
            return None
        return ReportResponse(**doc)

    def get_my_reports(self, user_id: str) -> List[ReportResponse]:
        all_reports = db.get_all("reports")
        user_reports = [
            ReportResponse(**r) for r in all_reports
            if r.get("userId") == user_id or (user_id.startswith("citizen") and r.get("userId", "").startswith("citizen"))
        ]
        user_reports.sort(key=lambda x: x.createdAt, reverse=True)
        return user_reports

    def list_reports(
        self,
        destination_id: Optional[str] = None,
        status: Optional[str] = None,
        category: Optional[str] = None,
        user_id: Optional[str] = None
    ) -> List[ReportResponse]:
        items = db.get_all("reports")
        filtered = []
        for item in items:
            if user_id and item.get("userId") != user_id:
                continue
            if destination_id and item.get("destinationId") != destination_id:
                continue
            if status and item.get("status", "").upper() != status.upper():
                continue
            if category:
                item_cat = item.get("category", "")
                ai_cat = item.get("aiCategory", "")
                if item_cat.upper() != category.upper() and ai_cat.upper() != category.upper():
                    continue
            filtered.append(ReportResponse(**item))

        filtered.sort(key=lambda x: x.createdAt, reverse=True)
        return filtered

    def update_status(self, report_id: str, update: ReportStatusUpdate) -> Optional[ReportResponse]:
        item = db.get_by_id("reports", report_id)
        if not item:
            return None

        item["status"] = update.status
        if update.adminNotes:
            item["adminNotes"] = update.adminNotes
        if update.status == ReportStatus.RESOLVED:
            item["resolvedAt"] = datetime.now(timezone.utc).isoformat() + "Z"

        saved = db.save("reports", report_id, item)
        return ReportResponse(**saved)

    def review_report(
        self,
        report_id: str,
        review: ReportReviewRequest,
        admin_uid: str
    ) -> Optional[ReportResponse]:
        """
        Allows admin to review, override, and correct AI classification (Category, Severity, Status, Notes).
        """
        item = db.get_by_id("reports", report_id)
        if not item:
            return None

        if review.category is not None:
            item["category"] = review.category
            item["aiCategory"] = review.category
        
        if review.severity is not None:
            item["severity"] = review.severity
            item["aiSeverity"] = severity_to_numeric(review.severity)

        if review.status is not None:
            item["status"] = review.status
            if review.status == ReportStatus.RESOLVED:
                item["resolvedAt"] = datetime.now(timezone.utc).isoformat() + "Z"

        if review.adminNotes:
            existing = item.get("adminNotes", "")
            item["adminNotes"] = f"{existing} | Admin Note: {review.adminNotes}".strip(" | ")

        item["adminReviewed"] = True
        item["reviewedBy"] = admin_uid
        item["updatedAt"] = datetime.now(timezone.utc).isoformat() + "Z"

        saved = db.save("reports", report_id, item)
        return ReportResponse(**saved)


    def upload_report_image(
        self,
        file_bytes: bytes,
        filename: str,
        content_type: str
    ) -> ImageUploadResponse:
        # 1. Validation: File size
        if len(file_bytes) > MAX_IMAGE_SIZE_BYTES:
            raise HTTPException(
                status_code=status.HTTP_413_REQUEST_ENTITY_TOO_LARGE,
                detail=f"File exceeds maximum allowed size of 5MB (Received {len(file_bytes) / (1024 * 1024):.2f}MB)"
            )

        # 2. Validation: Content Type
        clean_content_type = content_type.lower().split(";")[0].strip()
        if clean_content_type not in ALLOWED_IMAGE_TYPES:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail=f"Invalid image type '{content_type}'. Allowed types: JPEG, PNG, WebP."
            )

        # 3. Validation: Binary Magic Bytes Inspection (Anti-spoofing)
        if not validate_image_magic_bytes(file_bytes, clean_content_type):
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail=f"File binary header does not match declared content type '{clean_content_type}'. Upload rejected."
            )

        # Generate unique storage filename
        safe_ext = ".jpg"
        if "png" in clean_content_type:
            safe_ext = ".png"
        elif "webp" in clean_content_type:
            safe_ext = ".webp"
        elif "jpeg" in clean_content_type or "jpg" in clean_content_type:
            safe_ext = ".jpg"

        storage_filename = f"report_{uuid.uuid4().hex[:12]}{safe_ext}"

        # 3. Attempt Firebase Storage upload if configured
        if db.is_connected and db.firebase_app:
            try:
                from firebase_admin import storage
                bucket = storage.bucket(settings.FIREBASE_STORAGE_BUCKET)
                blob = bucket.blob(f"reports/{storage_filename}")
                blob.upload_from_string(file_bytes, content_type=clean_content_type)
                blob.make_public()
                public_url = blob.public_url
                logger.info(f"Uploaded report image to Firebase Storage: {public_url}")
                return ImageUploadResponse(
                    imageUrl=public_url,
                    filename=storage_filename,
                    sizeBytes=len(file_bytes),
                    contentType=clean_content_type,
                    message="Uploaded directly to Firebase Storage"
                )
            except Exception as e:
                logger.warning(f"Firebase Storage upload failed: {e}. Falling back to local storage cache.")

        # 4. Fallback: Save to backend static uploads directory & construct local media URL
        local_filepath = os.path.join(self.uploads_dir, storage_filename)
        with open(local_filepath, "wb") as f:
            f.write(file_bytes)

        # Also prepare data URL fallback for instant offline Flutter rendering if needed
        data_uri = f"/static/uploads/{storage_filename}"
        
        return ImageUploadResponse(
            imageUrl=data_uri,
            filename=storage_filename,
            sizeBytes=len(file_bytes),
            contentType=clean_content_type,
            message="Image stored in local resilient media cache"
        )

report_service = ReportService()

