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
        "longitude": 78.06
    }
    res = client.post("/api/reports", json=payload)
    assert res.status_code == 200
    data = res.json()
    assert data["status"] == "AI_CLASSIFIED"
    assert data["aiCategory"] in ["TRAFFIC", "ROAD"]

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
    res = client.get("/api/admin/analytics")
    assert res.status_code == 200
    data = res.json()
    assert data["totalDestinations"] >= 20
    assert data["highPressureDestinations"] >= 1
    assert len(data["districtSummaries"]) > 0
