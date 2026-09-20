import uuid
import logging
from datetime import datetime, timezone, timedelta
from typing import List, Optional, Dict, Any
from app.core.firebase import db
from app.models.domain import NotificationType, UserRole
from app.models.schemas import (
    NotificationCreate,
    NotificationResponse,
    NotificationUnreadCountResponse,
    NotificationBulkReadResponse
)

logger = logging.getLogger("pahadipulse.notifications")

INITIAL_SEEDED_NOTIFICATIONS = [
    # Admin Alert: Critical Report
    {
        "id": "notif_adm_001",
        "userId": None,
        "title": "Critical Hazard Report Received",
        "message": "Arterial road blocked by active geological slope movement near Badrinath Highway (NH-07). PWD team dispatch required.",
        "type": NotificationType.CRITICAL_REPORT.value,
        "read": False,
        "createdAt": (datetime.now(timezone.utc) - timedelta(minutes=25)).isoformat() + "Z",
        "relatedEntityId": "rep_landslide_nh07",
        "relatedEntityType": "report",
        "targetRole": UserRole.ADMIN.value,
        "metadata": {"severity": "CRITICAL", "category": "ROAD", "location": "Joshimath Sector"}
    },
    # Admin Alert: Pressure Spike
    {
        "id": "notif_adm_002",
        "userId": None,
        "title": "Sudden Pressure Surge: Mussoorie",
        "message": "Carrying capacity load reached 92.4% with composite pressure score 84.5 (CRITICAL). Traffic gridlock detected on Library Chowk.",
        "type": NotificationType.PRESSURE_SPIKE.value,
        "read": False,
        "createdAt": (datetime.now(timezone.utc) - timedelta(hours=1, minutes=10)).isoformat() + "Z",
        "relatedEntityId": "mussoorie",
        "relatedEntityType": "destination",
        "targetRole": UserRole.ADMIN.value,
        "metadata": {"pressureScore": 84.5, "status": "CRITICAL", "currentVisitors": 14200}
    },
    # Admin Alert: Prediction Warning
    {
        "id": "notif_adm_003",
        "userId": None,
        "title": "ML Forecast Warning: Nainital Weekend Influx",
        "message": "Predictive model projects a +22% pressure surge (forecast 78.0) for Nainital over the next 48 hours. Dispersal protocols advised.",
        "type": NotificationType.PREDICTION_WARNING.value,
        "read": True,
        "createdAt": (datetime.now(timezone.utc) - timedelta(hours=4)).isoformat() + "Z",
        "relatedEntityId": "nainital",
        "relatedEntityType": "destination",
        "targetRole": UserRole.ADMIN.value,
        "metadata": {"predictedPressure": 78.0, "riskLevel": "CRITICAL", "horizonDays": 2}
    },
    # Admin Alert: High Severity Issue
    {
        "id": "notif_adm_004",
        "userId": None,
        "title": "High-Priority Water Grid Failure",
        "message": "Main distribution line burst reported in Almora municipal ward 4 affecting drinking water availability.",
        "type": NotificationType.HIGH_SEVERITY_ISSUE.value,
        "read": False,
        "createdAt": (datetime.now(timezone.utc) - timedelta(hours=6)).isoformat() + "Z",
        "relatedEntityId": "rep_water_almora",
        "relatedEntityType": "report",
        "targetRole": UserRole.ADMIN.value,
        "metadata": {"severity": "HIGH", "category": "WATER", "district": "Almora"}
    },
    # Tourist Alert: High Pressure Alert
    {
        "id": "notif_tour_001",
        "userId": None,  # Broadcast to tourists
        "title": "High Footfall Alert: Mussoorie & Mall Road",
        "message": "Mussoorie is currently experiencing peak visitor pressure (82/100). For a serene Himalayan retreat, explore nearby Dhanaulti or Kanatal.",
        "type": NotificationType.HIGH_PRESSURE_ALERT.value,
        "read": False,
        "createdAt": (datetime.now(timezone.utc) - timedelta(minutes=45)).isoformat() + "Z",
        "relatedEntityId": "mussoorie",
        "relatedEntityType": "destination",
        "targetRole": UserRole.TOURIST.value,
        "metadata": {"currentPressure": 82.0, "alternativeDestinations": ["dhanaulti", "kanatal"]}
    },
    # Tourist Alert: Itinerary Recommendation Update
    {
        "id": "notif_tour_002",
        "userId": None,
        "title": "Eco-Smart Route Optimization Available",
        "message": "Your Garhwal circuit itinerary has an updated dynamic route recommendation saving 45 minutes travel time and mitigating peak pressure.",
        "type": NotificationType.ITINERARY_UPDATE.value,
        "read": False,
        "createdAt": (datetime.now(timezone.utc) - timedelta(hours=2, minutes=30)).isoformat() + "Z",
        "relatedEntityId": "itin_sample_garhwal",
        "relatedEntityType": "itinerary",
        "targetRole": UserRole.TOURIST.value,
        "metadata": {"mitigationScore": 76.5, "savingMinutes": 45}
    },
    # Tourist Alert: Saved Destination Pressure Change
    {
        "id": "notif_tour_003",
        "userId": None,
        "title": "Saved Destination: Chopta at Optimal Capacity",
        "message": "Chopta is currently enjoying serene green pressure (22/100) with clear weather. Ideal conditions for the Tungnath alpine trail.",
        "type": NotificationType.SAVED_DESTINATION_ALERT.value,
        "read": True,
        "createdAt": (datetime.now(timezone.utc) - timedelta(hours=8)).isoformat() + "Z",
        "relatedEntityId": "chopta",
        "relatedEntityType": "destination",
        "targetRole": UserRole.TOURIST.value,
        "metadata": {"pressureScore": 22.0, "status": "LOW"}
    },
    # General Announcement
    {
        "id": "notif_tour_004",
        "userId": None,
        "title": "Uttarakhand State Travel Advisory",
        "message": "Autumn eco-tourism permits and high-altitude trekking registrations are now open with localized community homestay credits.",
        "type": NotificationType.GENERAL_ANNOUNCEMENT.value,
        "read": True,
        "createdAt": (datetime.now(timezone.utc) - timedelta(days=1)).isoformat() + "Z",
        "relatedEntityId": "advisory_autumn",
        "relatedEntityType": "announcement",
        "targetRole": UserRole.TOURIST.value,
        "metadata": {"season": "Autumn"}
    }
]

class NotificationService:
    def __init__(self):
        self._ensure_seed_data()

    def _ensure_seed_data(self):
        existing = db.get_all("notifications")
        if not existing:
            for item in INITIAL_SEEDED_NOTIFICATIONS:
                db.create("notifications", item["id"], item)
            logger.info("Seeded initial in-app notifications for Tourist and Admin personas.")

    def get_notifications(
        self,
        user_id: Optional[str] = None,
        role: Optional[UserRole] = None,
        notification_type: Optional[NotificationType] = None,
        unread_only: bool = False,
        limit: int = 50
    ) -> List[NotificationResponse]:
        all_notifs = db.get_all("notifications")
        if not all_notifs:
            self._ensure_seed_data()
            all_notifs = db.get_all("notifications")

        filtered = []
        for n in all_notifs:
            # Filter by target role if given
            target_role = n.get("targetRole")
            if role:
                if target_role and target_role != role.value and target_role != "ALL":
                    continue
            
            # Filter by user if given and not broadcast
            item_user = n.get("userId")
            if user_id and item_user and item_user != user_id:
                continue

            # Filter by notification type
            if notification_type and n.get("type") != notification_type.value:
                continue

            # Filter unread
            if unread_only and n.get("read", False):
                continue

            filtered.append(NotificationResponse(**n))

        # Sort descending by creation date
        filtered.sort(key=lambda x: x.createdAt, reverse=True)
        return filtered[:limit]

    def get_unread_count(
        self,
        user_id: Optional[str] = None,
        role: Optional[UserRole] = None
    ) -> NotificationUnreadCountResponse:
        notifs = self.get_notifications(user_id=user_id, role=role, limit=500)
        unread = sum(1 for n in notifs if not n.read)
        return NotificationUnreadCountResponse(
            unreadCount=unread,
            totalCount=len(notifs)
        )

    def mark_as_read(self, notification_id: str, user_id: Optional[str] = None) -> Optional[NotificationResponse]:
        doc = db.get_by_id("notifications", notification_id)
        if not doc:
            return None
        
        doc["read"] = True
        doc["updatedAt"] = datetime.now(timezone.utc).isoformat() + "Z"
        updated = db.update("notifications", notification_id, doc)
        return NotificationResponse(**updated)

    def mark_all_read(
        self,
        user_id: Optional[str] = None,
        role: Optional[UserRole] = None
    ) -> NotificationBulkReadResponse:
        notifs = self.get_notifications(user_id=user_id, role=role, unread_only=True, limit=500)
        count = 0
        now_str = datetime.now(timezone.utc).isoformat() + "Z"
        for n in notifs:
            doc = db.get_by_id("notifications", n.id)
            if doc:
                doc["read"] = True
                doc["updatedAt"] = now_str
                db.update("notifications", n.id, doc)
                count += 1

        return NotificationBulkReadResponse(
            success=True,
            markedCount=count,
            message=f"Successfully marked {count} notifications as read."
        )

    def create_notification(self, req: NotificationCreate) -> NotificationResponse:
        notif_id = f"notif_{uuid.uuid4().hex[:10]}"
        now_str = datetime.now(timezone.utc).isoformat() + "Z"
        data = {
            "id": notif_id,
            "userId": req.userId,
            "title": req.title,
            "message": req.message,
            "type": req.type.value,
            "read": False,
            "createdAt": now_str,
            "relatedEntityId": req.relatedEntityId,
            "relatedEntityType": req.relatedEntityType,
            "targetRole": req.targetRole.value if req.targetRole else None,
            "metadata": req.metadata
        }
        created = db.create("notifications", notif_id, data)
        return NotificationResponse(**created)

notification_service = NotificationService()
