import pytest
from fastapi.testclient import TestClient
from app.main import app
from app.models.domain import NotificationType, UserRole

client = TestClient(app)

def test_get_notifications_list():
    res = client.get("/api/notifications")
    assert res.status_code == 200
    data = res.json()
    assert isinstance(data, list)
    assert len(data) >= 4
    
    # Check fields in response
    first = data[0]
    assert "id" in first
    assert "title" in first
    assert "message" in first
    assert "type" in first
    assert "read" in first
    assert "createdAt" in first
    assert "relatedEntityId" in first

def test_filter_notifications_by_role():
    # Tourist notifications
    t_res = client.get("/api/notifications?role=tourist")
    assert t_res.status_code == 200
    t_data = t_res.json()
    assert len(t_data) >= 1
    for item in t_data:
        if item.get("targetRole"):
            assert item["targetRole"] in ["tourist", "ALL"]

    # Admin notifications
    a_res = client.get("/api/notifications?role=admin")
    assert a_res.status_code == 200
    a_data = a_res.json()
    assert len(a_data) >= 1
    for item in a_data:
        if item.get("targetRole"):
            assert item["targetRole"] in ["admin", "ALL"]

def test_get_unread_count():
    res = client.get("/api/notifications/unread-count")
    assert res.status_code == 200
    data = res.json()
    assert "unreadCount" in data
    assert "totalCount" in data
    assert data["totalCount"] >= data["unreadCount"]

def test_create_and_mark_read():
    # 1. Test unauthorized notification creation rejected
    payload = {
        "title": "Severe Avalanche Alert near Mana Pass",
        "message": "High-altitude slope instability detected by SDRF. Avoid backcountry expeditions.",
        "type": "PREDICTION_WARNING",
        "relatedEntityId": "mana_pass",
        "relatedEntityType": "destination",
        "targetRole": "tourist",
        "metadata": {"risk": "HIGH"}
    }
    unauth_res = client.post("/api/notifications", json=payload)
    assert unauth_res.status_code in [401, 403]

    # Authorized creation with admin token
    admin_headers = {"Authorization": "Bearer admin-token-officer"}
    create_res = client.post("/api/notifications", json=payload, headers=admin_headers)
    assert create_res.status_code == 201
    created = create_res.json()
    notif_id = created["id"]
    assert created["read"] is False
    assert created["title"] == payload["title"]

    # 2. Mark single as read
    read_res = client.patch(f"/api/notifications/{notif_id}/read")
    assert read_res.status_code == 200
    assert read_res.json()["read"] is True

    # 3. Verify in list
    verify_res = client.get("/api/notifications")
    matched = next((n for n in verify_res.json() if n["id"] == notif_id), None)
    assert matched is not None
    assert matched["read"] is True

def test_mark_all_read():
    res = client.post("/api/notifications/mark-all-read?role=admin")
    assert res.status_code == 200
    data = res.json()
    assert data["success"] is True
    assert "markedCount" in data
