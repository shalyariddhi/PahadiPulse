from fastapi import APIRouter, Depends, HTTPException, Query, status
from typing import List, Optional
from app.models.domain import NotificationType, UserRole
from app.models.schemas import (
    NotificationCreate,
    NotificationResponse,
    NotificationUnreadCountResponse,
    NotificationBulkReadResponse
)
from app.services.notification_service import notification_service
from app.core.security import require_admin

router = APIRouter(prefix="/notifications", tags=["In-App Notifications & Alerts"])

@router.get("", response_model=List[NotificationResponse])
def get_notifications(
    role: Optional[UserRole] = Query(None, description="Filter notifications by target persona (tourist/admin)"),
    type: Optional[NotificationType] = Query(None, description="Filter by notification alert type"),
    unread_only: bool = Query(False, description="Fetch only unread notifications"),
    limit: int = Query(50, ge=1, le=100, description="Max notifications to retrieve")
):
    """
    Retrieves in-app notifications and proactive alerts with flexible filtering.
    """
    return notification_service.get_notifications(
        role=role,
        notification_type=type,
        unread_only=unread_only,
        limit=limit
    )

@router.get("/unread-count", response_model=NotificationUnreadCountResponse)
def get_unread_count(
    role: Optional[UserRole] = Query(None, description="Scope count to specific role (tourist/admin)")
):
    """
    Returns unread and total notification counts for badge rendering.
    """
    return notification_service.get_unread_count(role=role)

@router.patch("/{notification_id}/read", response_model=NotificationResponse)
@router.post("/{notification_id}/read", response_model=NotificationResponse)
def mark_notification_read(notification_id: str):
    """
    Marks a single notification as read.
    """
    notif = notification_service.mark_as_read(notification_id)
    if not notif:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=f"Notification with ID '{notification_id}' not found."
        )
    return notif

@router.post("/mark-all-read", response_model=NotificationBulkReadResponse)
def mark_all_notifications_read(
    role: Optional[UserRole] = Query(None, description="Scope mark-all-read to specific role (tourist/admin)")
):
    """
    Marks all notifications for the specified persona as read in bulk.
    """
    return notification_service.mark_all_read(role=role)

@router.post("", response_model=NotificationResponse, status_code=status.HTTP_201_CREATED)
def create_notification(req: NotificationCreate, _ = Depends(require_admin)):
    """
    Creates a new in-app alert or notification (admin / system triggered).
    """
    return notification_service.create_notification(req)
