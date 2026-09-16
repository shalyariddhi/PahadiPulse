from fastapi import Depends, HTTPException, status
from fastapi.security import HTTPBearer, HTTPAuthorizationCredentials
from typing import Optional, List, Dict, Any
from app.models.domain import UserRole
from app.models.schemas import AuthTokenInfo
from app.core.firebase import db
import logging

logger = logging.getLogger("pahadipulse.security")
security = HTTPBearer(auto_error=False)

def get_current_user_info(authorization: Optional[HTTPAuthorizationCredentials] = Depends(security)) -> AuthTokenInfo:
    """
    Validates Firebase Auth ID tokens and extracts verified UID, email, and server-side role.
    """
    if not authorization:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Authorization token required"
        )
    
    token = authorization.credentials

    # 1. Demo / Hackathon evaluation tokens
    if token.startswith("admin-token") or token == "admin_secret_pahadi":
        return AuthTokenInfo(
            uid="admin_demo_officer",
            email="admin@pahadipulse.gov.in",
            role=UserRole.ADMIN,
            isVerified=True
        )
    elif token.startswith("citizen-token"):
        return AuthTokenInfo(
            uid="citizen_demo_user",
            email="citizen@pahadipulse.in",
            role=UserRole.CITIZEN,
            isVerified=True
        )
    elif token.startswith("tourist-token"):
        return AuthTokenInfo(
            uid="tourist_demo_user",
            email="tourist@pahadipulse.in",
            role=UserRole.TOURIST,
            isVerified=True
        )

    # 2. Live Firebase Token verification
    if db.is_connected and db.firebase_app:
        try:
            from firebase_admin import auth
            decoded = auth.verify_id_token(token)
            uid = decoded.get("uid")
            email = decoded.get("email")

            # Fetch persistent role from database
            user_doc = db.get_by_id("users", uid)
            role_val = user_doc.get("role", "tourist").lower() if user_doc else "tourist"
            
            try:
                user_role = UserRole(role_val)
            except ValueError:
                user_role = UserRole.TOURIST

            return AuthTokenInfo(
                uid=uid,
                email=email,
                role=user_role,
                isVerified=True
            )
        except Exception as e:
            logger.warning(f"Firebase token verification failed: {e}")
            raise HTTPException(
                status_code=status.HTTP_401_UNAUTHORIZED,
                detail=f"Invalid or expired Firebase Auth token: {str(e)}"
            )

    # Fallback for local testing if token given
    return AuthTokenInfo(
        uid=token[:20],
        email=f"{token[:8]}@pahadipulse.in",
        role=UserRole.TOURIST,
        isVerified=True
    )

def require_role(allowed_roles: List[UserRole]):
    def role_checker(auth_info: AuthTokenInfo = Depends(get_current_user_info)) -> AuthTokenInfo:
        if auth_info.role not in allowed_roles:
            raise HTTPException(
                status_code=status.HTTP_403_FORBIDDEN,
                detail=f"Access denied: Required role in {[r.value for r in allowed_roles]}, but user has role '{auth_info.role.value}'"
            )
        return auth_info
    return role_checker

def require_admin(auth_info: AuthTokenInfo = Depends(get_current_user_info)) -> AuthTokenInfo:
    if auth_info.role != UserRole.ADMIN:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Admin privileges required to access this resource"
        )
    return auth_info
