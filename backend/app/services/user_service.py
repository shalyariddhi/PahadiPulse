from typing import Optional, List, Dict, Any
from datetime import datetime, timezone
from app.core.firebase import db
from app.models.domain import UserRole
from app.models.schemas import UserCreate, UserUpdate, UserProfileResponse

class UserService:
    @staticmethod
    def sync_user(user_data: UserCreate) -> UserProfileResponse:
        """
        Synchronizes or creates a user profile in Firestore upon Firebase login.
        """
        existing = db.get_by_id("users", user_data.uid)
        now = datetime.now(timezone.utc).isoformat() + "Z"

        if existing:
            # Preserve existing role and createdAt
            existing["email"] = user_data.email
            existing["displayName"] = user_data.displayName or existing.get("displayName", "PahadiPulse Member")
            if user_data.phoneNumber:
                existing["phoneNumber"] = user_data.phoneNumber
            existing["updatedAt"] = now
            saved = db.save("users", user_data.uid, existing)
            return UserProfileResponse(**saved)

        # Create new user record
        doc = {
            "uid": user_data.uid,
            "id": user_data.uid,
            "email": user_data.email,
            "displayName": user_data.displayName or "PahadiPulse Member",
            "role": user_data.role or UserRole.TOURIST,
            "phoneNumber": user_data.phoneNumber,
            "photoUrl": "",
            "isBlocked": False,
            "createdAt": now,
            "updatedAt": now
        }
        saved = db.save("users", user_data.uid, doc)
        return UserProfileResponse(**saved)

    @staticmethod
    def get_user_by_id(uid: str) -> Optional[UserProfileResponse]:
        doc = db.get_by_id("users", uid)
        if not doc:
            return None
        return UserProfileResponse(**doc)

    @staticmethod
    def update_user_role(uid: str, new_role: UserRole) -> Optional[UserProfileResponse]:
        doc = db.get_by_id("users", uid)
        if not doc:
            return None
        
        doc["role"] = new_role
        doc["updatedAt"] = datetime.now(timezone.utc).isoformat() + "Z"
        saved = db.save("users", uid, doc)
        return UserProfileResponse(**saved)

    @staticmethod
    def list_users() -> List[UserProfileResponse]:
        docs = db.get_all("users")
        return [UserProfileResponse(**d) for d in docs]

user_service = UserService()
