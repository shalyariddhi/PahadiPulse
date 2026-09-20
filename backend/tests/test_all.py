import pytest
from fastapi.testclient import TestClient
from app.main import app
from app.services.pressure_service import pressure_service
from app.models.domain import PressureStatus

client = TestClient(app)

def test_health():
    res = client.get("/api/health")
    assert res.status_code == 200
    assert res.json()["status"] == "healthy"

def test_pressure_formula():
    # Test formula: 30% tourism (90) + 25% water (80) + 20% waste (70) + 15% traffic (90) + 10% env (50)
    # = 27 + 20 + 14 + 13.5 + 5 = 79.5 (CRITICAL)
    score, status, exp = pressure_service.calculate_score(90, 80, 70, 90, 50)
    assert score == 79.5
    assert status == PressureStatus.CRITICAL
    assert "critical" in exp.lower()
    assert "elevated" in exp.lower()

def test_destinations_api():
    res = client.get("/api/destinations")
    assert res.status_code == 200
    data = res.json()
    assert len(data) >= 20
    mussoorie = next((d for d in data if d["id"] == "mussoorie"), None)
    assert mussoorie is not None
    assert mussoorie["status"] == "CRITICAL"
    assert mussoorie["pressureScore"] > 70.0

def test_destination_pressure_breakdown():
    res = client.get("/api/destinations/mussoorie/pressure")
    assert res.status_code == 200
    data = res.json()
    assert "compositeScore" in data
    assert data["tourism"] == 88.0
    assert data["status"] == "CRITICAL"

def test_forecast_api():
    res = client.get("/api/pressure/forecast/mussoorie?days=7")
    assert res.status_code == 200
    data = res.json()
    assert data["destinationId"] == "mussoorie"
    assert len(data["forecast7Days"]) == 7
    assert data["forecast7Days"][0]["predictedPressure"] > 0

def test_ai_classify_report():
    payload = {"text": "Drinking water pipeline burst near mall road; no water for 3 days"}
    res = client.post("/api/ai/classify-report", json=payload)
    assert res.status_code == 200
    data = res.json()
    assert data["aiCategory"] == "WATER"
    assert data["aiSeverity"] >= 4

def test_submit_report():
    payload = {
        "userId": "citizen_test",
        "userName": "Tester",
        "destinationId": "mussoorie",
        "category": "OTHER",
        "description": "Massive traffic jam stretching 5km on the ghat road.",
        "latitude": 30.45,
        "longitude": 78.06,
        "userSeverity": 4,
        "imageUrl": "https://example.com/traffic.jpg"
    }
    res = client.post("/api/reports", json=payload)
    assert res.status_code == 201
    data = res.json()
    assert data["status"] == "AI_CLASSIFIED"
    assert data["aiCategory"] in ["TRAFFIC", "ROAD"]
    assert data["userSeverity"] == 4
    assert data["id"].startswith("rep_")
    assert "id" in data
    assert "aiSeverity" in data

    # Test GET /api/reports/{id}
    rep_id = data["id"]
    get_res = client.get(f"/api/reports/{rep_id}")
    assert get_res.status_code == 200
    assert get_res.json()["id"] == rep_id
    assert get_res.json()["description"] == payload["description"]

def test_get_my_reports():
    token = "citizen-token-test-user"
    headers = {"Authorization": f"Bearer {token}"}
    
    # Submit a report first
    payload = {
        "destinationId": "kanatal",
        "category": "WATER",
        "description": "Acute water scarcity in upper village sector",
        "latitude": 30.41,
        "longitude": 78.34,
        "userSeverity": 3
    }
    sub_res = client.post("/api/reports", json=payload, headers=headers)
    assert sub_res.status_code == 201
    
    # Fetch my reports
    res = client.get("/api/reports/my", headers=headers)
    assert res.status_code == 200
    my_list = res.json()
    assert isinstance(my_list, list)
    assert len(my_list) >= 1

def test_upload_report_image():
    # Valid JPEG image upload
    dummy_jpeg = b"\xff\xd8\xff\xe0\x00\x10JFIF\x00\x01\x01\x01\x00`\x00`\x00\x00\xff\xdb\x00C\x00" + b"\x00" * 100
    files = {"file": ("test_road_issue.jpg", dummy_jpeg, "image/jpeg")}
    res = client.post("/api/reports/upload-image", files=files)
    assert res.status_code == 200
    data = res.json()
    assert "imageUrl" in data
    assert data["sizeBytes"] == len(dummy_jpeg)
    assert data["contentType"] == "image/jpeg"

def test_upload_report_image_validation_error():
    # Invalid file type
    files = {"file": ("test.txt", b"Hello world text file", "text/plain")}
    res = client.post("/api/reports/upload-image", files=files)
    assert res.status_code == 400

def test_all_report_categories_classification():
    test_cases = [
        ("Water shortage and pipe burst in Mall road", "WATER"),
        ("Garbage and plastic waste dump overflowing", "WASTE"),
        ("Massive landslide and rockfall blocking highway", "ROAD"),
        ("Severe traffic congestion and 5km vehicle gridlock", "TRAFFIC"),
        ("Medical emergency near viewpoint no ambulance clinic", "HEALTH"),
        ("Cell phone network tower down and no mobile signal", "CONNECTIVITY"),
        ("Tourists overcharging scam by unauthorized guides", "TOURISM"),
        ("Cloudburst and forest wildfire hazard on mountain slope", "ENVIRONMENT")
    ]
    for text, expected_cat in test_cases:
        res = client.post("/api/ai/classify-report", json={"text": text})
        assert res.status_code == 200
        cat = res.json()["aiCategory"]
        assert cat == expected_cat, f"Expected {expected_cat} for '{text}', got {cat}"

def test_generate_itinerary():
    payload = {
        "daysCount": 4,
        "travellersCount": 3,
        "budgetPerPersonINR": 10000,
        "interests": ["Nature", "Adventure"],
        "startingRegion": "Dehradun"
    }
    res = client.post("/api/itineraries/generate", json=payload)
    assert res.status_code == 200
    data = res.json()
    assert len(data["days"]) == 4
    assert data["pressureMitigationScore"] > 0
    # Must prioritize lower pressure destinations
    chosen_names = [d["destinationName"] for d in data["days"]]
    assert any(name in ["Kanatal", "Dhanaulti", "Chopta", "Chakrata"] for name in chosen_names)

def test_admin_analytics():
    # Unauthorized request without admin token should fail with 401 or 403
    unauth_res = client.get("/api/admin/analytics")
    assert unauth_res.status_code in [401, 403]

    # Authorized request with admin token
    admin_headers = {"Authorization": "Bearer admin-token-officer"}
    res = client.get("/api/admin/analytics", headers=admin_headers)
    assert res.status_code == 200
    data = res.json()
    assert data["totalDestinations"] >= 20
    assert data["highPressureDestinations"] >= 1
    assert len(data["districtSummaries"]) > 0

