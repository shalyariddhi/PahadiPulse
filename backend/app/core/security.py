from fastapi import Depends, HTTPException, Request, status
from fastapi.security import HTTPBearer, HTTPAuthorizationCredentials
from typing import Optional, List, Dict, Any
from app.models.domain import UserRole
from app.models.schemas import AuthTokenInfo
from app.core.firebase import db
from app.config import settings
import logging
import time
from collections import defaultdict
import threading

logger = logging.getLogger("pahadipulse.security")
security = HTTPBearer(auto_error=False)

# Thread-safe in-memory rate limiter
class InMemoryRateLimiter:
    def __init__(self):
        self._requests: Dict[str, List[float]] = defaultdict(list)
        self._lock = threading.Lock()

    def is_rate_limited(self, key: str, max_requests: int = 60, window_seconds: int = 60) -> bool:
        now = time.time()
        with self._lock:
            timestamps = self._requests[key]
            # Prune older than window
            cutoff = now - window_seconds
            self._requests[key] = [t for t in timestamps if t > cutoff]
            if len(self._requests[key]) >= max_requests:
                return True
            self._requests[key].append(now)
            return False

rate_limiter = InMemoryRateLimiter()

def check_rate_limit(max_requests: int = 60, window_seconds: int = 60):
    def dependency(request: Request):
        client_ip = request.client.host if request.client else "unknown_client"
        endpoint = request.url.path
        rate_key = f"{client_ip}:{endpoint}"
        if rate_limiter.is_rate_limited(rate_key, max_requests=max_requests, window_seconds=window_seconds):
            raise HTTPException(
                status_code=status.HTTP_429_TOO_MANY_REQUESTS,
                detail=f"Rate limit exceeded. Maximum {max_requests} requests per {window_seconds} seconds."
            )
    return dependency

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

    # 1. Demo / Hackathon evaluation tokens (active in development/demo environments)
    if settings.ENVIRONMENT != "production":
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
                detail="Invalid or expired authentication credentials"
            )

    # Fallback for local testing in development only
    if settings.ENVIRONMENT != "production":
        return AuthTokenInfo(
            uid=token[:20],
            email=f"{token[:8]}@pahadipulse.in",
            role=UserRole.TOURIST,
            isVerified=True
        )

    raise HTTPException(
        status_code=status.HTTP_401_UNAUTHORIZED,
        detail="Authentication token invalid"
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
