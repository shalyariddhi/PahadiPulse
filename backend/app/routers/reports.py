from fastapi import APIRouter, HTTPException, Query, Depends, UploadFile, File, status
from typing import List, Optional
from app.models.schemas import (
    ReportCreate,
    ReportResponse,
    ReportStatusUpdate,
    ReportReviewRequest,
    ImageUploadResponse,
    AuthTokenInfo
)

from app.services.report_service import report_service
from app.core.security import get_current_user_info, require_admin, security

router = APIRouter(prefix="/reports", tags=["Citizen Infrastructure Reports"])

@router.post("", response_model=ReportResponse, status_code=status.HTTP_201_CREATED)
def submit_report(
    report: ReportCreate,
    auth_header = Depends(security)
):
    """
    Submit a citizen or tourist regional issue report.
    Automatically runs AI categorization, severity scoring (1-5), and alerts nodal authorities.
    """
    auth_uid = None
    auth_name = None
    if auth_header:
        try:
            info = get_current_user_info(auth_header)
            auth_uid = info.uid
            auth_name = info.email.split("@")[0].title() if info.email else "Verified Citizen"
        except Exception:
            pass

    return report_service.create_report(report, auth_uid=auth_uid, auth_name=auth_name)

@router.post("/upload-image", response_model=ImageUploadResponse)
async def upload_report_image(file: UploadFile = File(...)):
    """
    Upload an issue photo to Firebase Storage with size (<5MB) and MIME type validation.
    """
    if not file:
        raise HTTPException(status_code=400, detail="No image file provided")

    file_bytes = await file.read()
    content_type = file.content_type or "image/jpeg"
    filename = file.filename or "photo.jpg"

    return report_service.upload_report_image(
        file_bytes=file_bytes,
        filename=filename,
        content_type=content_type
    )

@router.get("/my", response_model=List[ReportResponse])
def get_my_reports(auth_info: AuthTokenInfo = Depends(get_current_user_info)):
    """
    Retrieve all reports submitted by the authenticated citizen/tourist.
    """
    return report_service.get_my_reports(user_id=auth_info.uid)

@router.get("", response_model=List[ReportResponse])
def get_reports(
    destination_id: Optional[str] = Query(None, description="Filter by destination ID"),
    status: Optional[str] = Query(None, description="Filter by report status"),
    category: Optional[str] = Query(None, description="Filter by issue category"),
    user_id: Optional[str] = Query(None, description="Filter by user ID")
):
    """
    List all reports with optional filtering by destination, status, category, or user.
    """
    return report_service.list_reports(
        destination_id=destination_id,
        status=status,
        category=category,
        user_id=user_id
    )

@router.get("/{report_id}", response_model=ReportResponse)
def get_report_by_id(report_id: str):
    """
    Retrieve single report metadata, AI classification details, and workflow progress.
    """
    rep = report_service.get_report_by_id(report_id)
    if not rep:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail=f"Report '{report_id}' not found")
    return rep

@router.patch("/{report_id}/status", response_model=ReportResponse)
def update_report_status(
    report_id: str,
    update: ReportStatusUpdate,
    _ = Depends(require_admin)
):
    """
    Admin workflow progression: SUBMITTED -> AI_CLASSIFIED -> VERIFIED -> ASSIGNED -> RESOLVED.
    """
    updated = report_service.update_status(report_id, update)
    if not updated:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail=f"Report '{report_id}' not found")
    return updated

@router.patch("/{report_id}/review", response_model=ReportResponse)
def review_and_correct_classification(
    report_id: str,
    review: ReportReviewRequest,
    auth_info: AuthTokenInfo = Depends(require_admin)
):
    """
    Admin review & correction endpoint.
    Allows designated officers to override AI-assigned category and severity,
    update workflow status, and append administrative dispatch directives.
    """
    updated = report_service.review_report(
        report_id=report_id,
        review=review,
        admin_uid=auth_info.uid
    )
    if not updated:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail=f"Report '{report_id}' not found")
    return updated


