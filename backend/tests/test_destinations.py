import pytest
from fastapi.testclient import TestClient
from app.main import app
from app.services.pressure_service import pressure_service
from app.models.domain import PressureStatus

client = TestClient(app)

REQUIRED_DESTINATION_NAMES = [
    "Mussoorie", "Dhanaulti", "Kanatal", "Rishikesh", "Nainital",
    "Mukteshwar", "Auli", "Chopta", "Lansdowne", "Ranikhet",
    "Almora", "Binsar", "Tehri Lake & New Tehri", "Chakrata", "Harsil",
    "Munsiyari", "Kausani", "Devprayag", "Uttarkashi", "Pauri"
]

def test_all_20_destinations_exist():
    """Verify that all 20 required Uttarakhand destinations are present."""
    res = client.get("/api/destinations")
    assert res.status_code == 200
    data = res.json()
    assert len(data) >= 20

    dest_names = [d["name"] for d in data]
    for required_name in REQUIRED_DESTINATION_NAMES:
        assert any(required_name.lower() in name.lower() for name in dest_names), f"Missing destination: {required_name}"

def test_destination_fields_structure():
    """Verify that every destination contains all required schema fields and demo labels."""
    res = client.get("/api/destinations")
    assert res.status_code == 200
    data = res.json()

    for d in data:
        assert "id" in d and len(d["id"]) > 0
        assert "name" in d and len(d["name"]) > 0
        assert "district" in d and len(d["district"]) > 0
        assert "latitude" in d and 28.0 <= d["latitude"] <= 32.0
        assert "longitude" in d and 77.0 <= d["longitude"] <= 82.0
        assert "description" in d and len(d["description"]) > 0
        assert "capacity" in d and d["capacity"] > 0
        assert "tourismScore" in d and 0 <= d["tourismScore"] <= 100
        assert "waterScore" in d and 0 <= d["waterScore"] <= 100
        assert "wasteScore" in d and 0 <= d["wasteScore"] <= 100
        assert "trafficScore" in d and 0 <= d["trafficScore"] <= 100
        assert "environmentScore" in d and 0 <= d["environmentScore"] <= 100
        assert "pressureScore" in d and 0 <= d["pressureScore"] <= 100
        assert d["status"] in ["LOW", "MODERATE", "HIGH", "CRITICAL"]
        assert d["isDemo"] is True
        assert d["dataSource"] == "DEMO_SYNTHETIC_HACKATHON"

def test_pressure_formula_and_status_ranges():
    """
    Test exact 30/25/20/15/10 formula and status thresholds:
    0–30: LOW
    31–50: MODERATE
    51–70: HIGH
    71–100: CRITICAL
    """
    # 1. Low: (0.30*20) + (0.25*20) + (0.20*20) + (0.15*20) + (0.10*20) = 20.0
    s1, stat1, _ = pressure_service.calculate_score(20, 20, 20, 20, 20)
    assert s1 == 20.0
    assert stat1 == PressureStatus.LOW

    # 2. Low Boundary: exactly 30.0
    s2, stat2, _ = pressure_service.calculate_score(30, 30, 30, 30, 30)
    assert s2 == 30.0
    assert stat2 == PressureStatus.LOW

    # 3. Moderate: (0.30*40) + (0.25*40) + (0.20*40) + (0.15*40) + (0.10*40) = 40.0
    s3, stat3, _ = pressure_service.calculate_score(40, 40, 40, 40, 40)
    assert s3 == 40.0
    assert stat3 == PressureStatus.MODERATE

    # 4. Moderate Boundary: exactly 50.0
    s4, stat4, _ = pressure_service.calculate_score(50, 50, 50, 50, 50)
    assert s4 == 50.0
    assert stat4 == PressureStatus.MODERATE

    # 5. High: (0.30*60) + (0.25*60) + (0.20*60) + (0.15*60) + (0.10*60) = 60.0
    s5, stat5, _ = pressure_service.calculate_score(60, 60, 60, 60, 60)
    assert s5 == 60.0
    assert stat5 == PressureStatus.HIGH

    # 6. High Boundary: exactly 70.0
    s6, stat6, _ = pressure_service.calculate_score(70, 70, 70, 70, 70)
    assert s6 == 70.0
    assert stat6 == PressureStatus.HIGH

    # 7. Critical: (0.30*90) + (0.25*80) + (0.20*75) + (0.15*90) + (0.10*50)
    # = 27 + 20 + 15 + 13.5 + 5 = 80.5
    s7, stat7, exp7 = pressure_service.calculate_score(90, 80, 75, 90, 50)
    assert s7 == 80.5
    assert stat7 == PressureStatus.CRITICAL
    assert "critical" in exp7.lower()
    assert "elevated" in exp7.lower()

def test_destination_filtering_and_search():
    """Test query filtering by district, status, and search terms."""
    # Filter by district Dehradun (Mussoorie, Rishikesh, Chakrata)
    res_dist = client.get("/api/destinations?district=Dehradun")
    assert res_dist.status_code == 200
    dehradun_dests = res_dist.json()
    assert len(dehradun_dests) >= 3
    assert all(d["district"].lower() == "dehradun" for d in dehradun_dests)

    # Filter by status CRITICAL
    res_crit = client.get("/api/destinations?status=CRITICAL")
    assert res_crit.status_code == 200
    crit_dests = res_crit.json()
    assert len(crit_dests) >= 1
    assert all(d["status"] == "CRITICAL" for d in crit_dests)

    # Search keyword "trek" or "lake"
    res_search = client.get("/api/destinations?search=lake")
    assert res_search.status_code == 200
    search_dests = res_search.json()
    assert len(search_dests) >= 1

def test_destination_detail_and_pressure_breakdown():
    """Test detail and transparent breakdown endpoints for a specific destination."""
    res_detail = client.get("/api/destinations/kanatal")
    assert res_detail.status_code == 200
    dest = res_detail.json()
    assert dest["name"] == "Kanatal"
    assert dest["district"] == "Tehri Garhwal"
    assert dest["status"] == "LOW"

    res_pressure = client.get("/api/destinations/kanatal/pressure")
    assert res_pressure.status_code == 200
    p = res_pressure.json()
    assert "compositeScore" in p
    assert "formula" in p
    assert "explanation" in p
    assert p["tourism"] == dest["tourismScore"]

def test_dynamic_pressure_update():
    """Verify that updating sub-scores dynamically recalculates the aggregate pressure score."""
    headers = {"Authorization": "Bearer admin_secret_pahadi"}
    
    # Update Chopta with temporary high tourist rush
    update_payload = {
        "tourismScore": 95.0,
        "trafficScore": 90.0
    }
    patch_res = client.patch("/api/destinations/chopta", json=update_payload, headers=headers)
    assert patch_res.status_code == 200
    updated_chopta = patch_res.json()
    
    # Prior pressure was ~28.0 (LOW). With 95% tourism & 90% traffic, score increases substantially
    assert updated_chopta["pressureScore"] > 45.0
    assert updated_chopta["subScores"]["tourism"] == 95.0

    # Reset back to original seed value
    reset_payload = {
        "tourismScore": 24.0,
        "trafficScore": 14.0
    }
    client.patch("/api/destinations/chopta", json=reset_payload, headers=headers)
