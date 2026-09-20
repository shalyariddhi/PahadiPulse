from fastapi import APIRouter, Depends, HTTPException, status
from typing import List
from app.models.schemas import UserCreate, UserProfileResponse, AuthTokenInfo
from app.models.domain import UserRole
from app.services.user_service import user_service
from app.core.security import get_current_user_info, require_admin, require_role

router = APIRouter(prefix="/auth", tags=["Authentication & User Roles"])

@router.post("/sync-user", response_model=UserProfileResponse)
def sync_user(user: UserCreate, auth_info: AuthTokenInfo = Depends(get_current_user_info)):
    """
    Called after Firebase Auth login to synchronize the user document in Firestore.
    Ensures the calling UID matches the authenticated token and prevents unprivileged role escalation.
    """
    is_admin = (auth_info.role == UserRole.ADMIN)
    if auth_info.uid != user.uid and not is_admin:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Cannot sync profile for another user ID"
        )
    return user_service.sync_user(user, caller_is_admin=is_admin)

@router.get("/me", response_model=UserProfileResponse)
def get_current_profile(auth_info: AuthTokenInfo = Depends(get_current_user_info)):
    """
    Returns the authenticated user's profile and server-verified role.
    """
    user = user_service.get_user_by_id(auth_info.uid)
    if not user:
        # Auto-create tourist profile if first time
        user = user_service.sync_user(UserCreate(
            uid=auth_info.uid,
            email=auth_info.email or f"{auth_info.uid}@pahadipulse.in",
            displayName="PahadiPulse Member",
            role=auth_info.role
        ))
    return user

@router.get("/users", response_model=List[UserProfileResponse])
def list_users(_ = Depends(require_admin)):
    """
    Protected Admin endpoint to list all registered users.
    """
    return user_service.list_users()

@router.patch("/users/{uid}/role", response_model=UserProfileResponse)
def update_user_role(uid: str, role: UserRole, _ = Depends(require_admin)):
    """
    Protected Admin endpoint to change a user's role (e.g. promote to citizen or admin).
    """
    updated = user_service.update_user_role(uid, role)
    if not updated:
        raise HTTPException(status_code=404, detail="User not found")
    return updated
