import pytest
import uuid
from fastapi.testclient import TestClient
from app.main import app
from app.models.domain import UserRole

client = TestClient(app)

def test_missing_auth_token():
    """Unauthenticated requests to protected endpoints must return 401."""
    res = client.get("/api/auth/me")
    assert res.status_code == 401
    assert "detail" in res.json()

def test_tourist_role_access():
    """Tourist role cannot access admin endpoints."""
    headers = {"Authorization": "Bearer tourist-token-12345"}
    
    # Can access profile
    res_me = client.get("/api/auth/me", headers=headers)
    assert res_me.status_code == 200
    assert res_me.json()["role"] == "tourist"

    # Cannot access admin users list (403 Forbidden)
    res_admin = client.get("/api/auth/users", headers=headers)
    assert res_admin.status_code == 403
    assert "Admin privileges required" in res_admin.json()["detail"]

def test_admin_role_access():
    """Admin role can access admin endpoints and manage user roles."""
    headers = {"Authorization": "Bearer admin_secret_pahadi"}
    unique_uid = f"citizen_{uuid.uuid4().hex[:8]}"

    # Can access admin users list
    res = client.get("/api/auth/users", headers=headers)
    assert res.status_code == 200
    assert isinstance(res.json(), list)

    # Can sync user profile
    user_payload = {
        "uid": unique_uid,
        "email": f"{unique_uid}@pahadipulse.in",
        "displayName": "Test Citizen",
        "role": "citizen"
    }
    sync_res = client.post("/api/auth/sync-user", json=user_payload, headers=headers)
    assert sync_res.status_code == 200
    assert sync_res.json()["role"] == "citizen"

    # Admin can change user role
    role_change_res = client.patch(
        f"/api/auth/users/{unique_uid}/role?role=admin",
        headers=headers
    )
    assert role_change_res.status_code == 200
    assert role_change_res.json()["role"] == "admin"

def test_user_sync_security():
    """Non-admin user cannot sync/modify someone else's UID profile."""
    headers = {"Authorization": "Bearer tourist-token-attacker"}
    malicious_payload = {
        "uid": "different_victim_uid",
        "email": "victim@pahadipulse.in",
        "displayName": "Victim",
        "role": "admin"
    }
    res = client.post("/api/auth/sync-user", json=malicious_payload, headers=headers)
    assert res.status_code == 403
