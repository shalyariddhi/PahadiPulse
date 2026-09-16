from fastapi import APIRouter, HTTPException, Query, Depends
from typing import List, Optional
from app.models.schemas import ReportCreate, ReportResponse, ReportStatusUpdate
from app.services.report_service import report_service
from app.core.security import require_admin

router = APIRouter(prefix="/reports", tags=["Citizen Infrastructure Reports"])

@router.post("", response_model=ReportResponse)
def submit_report(report: ReportCreate):
    return report_service.create_report(report)

@router.get("", response_model=List[ReportResponse])
def get_reports(
    destination_id: Optional[str] = Query(None),
    status: Optional[str] = Query(None),
    category: Optional[str] = Query(None)
):
    return report_service.list_reports(
        destination_id=destination_id,
        status=status,
        category=category
    )

@router.patch("/{report_id}/status", response_model=ReportResponse)
def update_report_status(report_id: str, update: ReportStatusUpdate, _ = Depends(require_admin)):
    updated = report_service.update_status(report_id, update)
    if not updated:
        raise HTTPException(status_code=404, detail="Report not found")
    return updated
