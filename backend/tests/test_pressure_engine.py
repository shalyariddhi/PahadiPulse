import pytest
from fastapi.testclient import TestClient
from app.main import app
from app.services.pressure_service import pressure_service
from app.models.domain import PressureStatus

client = TestClient(app)

def test_low_pressure_score():
    """Score <= 30 categorized as LOW with clear explanation."""
    score, status, explanation = pressure_service.calculate_score(
        tourism=20.0, water=15.0, waste=10.0, traffic=10.0, environment=15.0
    )
    # (0.30*20 + 0.25*15 + 0.20*10 + 0.15*10 + 0.10*15) = 6.0 + 3.75 + 2.0 + 1.5 + 1.5 = 14.75 -> 14.8
    assert score <= 30.0
    assert status == PressureStatus.LOW
    assert "low" in explanation.lower()

def test_moderate_pressure_score():
    """Score between 31 and 50 categorized as MODERATE."""
    score, status, explanation = pressure_service.calculate_score(
        tourism=45.0, water=40.0, waste=35.0, traffic=40.0, environment=30.0
    )
    # (0.30*45 + 0.25*40 + 0.20*35 + 0.15*40 + 0.10*30) = 13.5 + 10.0 + 7.0 + 6.0 + 3.0 = 39.5
    assert 31.0 <= score <= 50.0
    assert status == PressureStatus.MODERATE
    assert "moderate" in explanation.lower()

def test_high_pressure_score():
    """Score between 51 and 70 categorized as HIGH."""
    score, status, explanation = pressure_service.calculate_score(
        tourism=68.0, water=62.0, waste=58.0, traffic=65.0, environment=45.0
    )
    # (0.30*68 + 0.25*62 + 0.20*58 + 0.15*65 + 0.10*45) = 20.4 + 15.5 + 11.6 + 9.75 + 4.5 = 61.75 -> 61.8
    assert 51.0 <= score <= 70.0
    assert status == PressureStatus.HIGH
    assert "high" in explanation.lower()
    assert "elevated" in explanation.lower()

def test_critical_pressure_score():
    """Score >= 71 categorized as CRITICAL with severe strain explanation."""
    score, status, explanation = pressure_service.calculate_score(
        tourism=95.0, water=88.0, waste=85.0, traffic=90.0, environment=70.0
    )
    # (0.30*95 + 0.25*88 + 0.20*85 + 0.15*90 + 0.10*70) = 28.5 + 22.0 + 17.0 + 13.5 + 7.0 = 88.0
    assert score >= 71.0
    assert status == PressureStatus.CRITICAL
    assert "critical" in explanation.lower()

def test_boundary_values():
    """Strict evaluation of boundary transitions."""
    # Boundary 0.0 -> LOW
    s0, stat0, _ = pressure_service.calculate_score(0, 0, 0, 0, 0)
    assert s0 == 0.0
    assert stat0 == PressureStatus.LOW

    # Boundary 30.0 -> LOW
    s30, stat30, _ = pressure_service.calculate_score(30, 30, 30, 30, 30)
    assert s30 == 30.0
    assert stat30 == PressureStatus.LOW

    # Boundary 31.0 -> MODERATE
    s31, stat31, _ = pressure_service.calculate_score(31, 31, 31, 31, 31)
    assert s31 == 31.0
    assert stat31 == PressureStatus.MODERATE

    # Boundary 50.0 -> MODERATE
    s50, stat50, _ = pressure_service.calculate_score(50, 50, 50, 50, 50)
    assert s50 == 50.0
    assert stat50 == PressureStatus.MODERATE

    # Boundary 51.0 -> HIGH
    s51, stat51, _ = pressure_service.calculate_score(51, 51, 51, 51, 51)
    assert s51 == 51.0
    assert stat51 == PressureStatus.HIGH

    # Boundary 70.0 -> HIGH
    s70, stat70, _ = pressure_service.calculate_score(70, 70, 70, 70, 70)
    assert s70 == 70.0
    assert stat70 == PressureStatus.HIGH

    # Boundary 71.0 -> CRITICAL
    s71, stat71, _ = pressure_service.calculate_score(71, 71, 71, 71, 71)
    assert s71 == 71.0
    assert stat71 == PressureStatus.CRITICAL

    # Boundary 100.0 -> CRITICAL
    s100, stat100, _ = pressure_service.calculate_score(100, 100, 100, 100, 100)
    assert s100 == 100.0
    assert stat100 == PressureStatus.CRITICAL

def test_invalid_and_out_of_range_inputs():
    """Ensure out-of-range and invalid values are clamped safely without crashing."""
    # Below 0 clamped to 0
    s_neg, stat_neg, _ = pressure_service.calculate_score(-50, -100, -10, -5, -20)
    assert s_neg == 0.0
    assert stat_neg == PressureStatus.LOW

    # Above 100 clamped to 100
    s_over, stat_over, _ = pressure_service.calculate_score(250, 180, 500, 105, 999)
    assert s_over == 100.0
    assert stat_over == PressureStatus.CRITICAL

    # Non-numeric gracefully handled
    s_none, stat_none, _ = pressure_service.calculate_score(None, "invalid", 40, 40, 40)
    assert 0.0 <= s_none <= 100.0

def test_configurable_weights_and_normalization():
    """Custom weights calculate correctly and normalize if sum != 1.0."""
    # Water-heavy custom weights (e.g. drought season crisis)
    custom_weights = {
        "tourism": 0.10,
        "water": 0.60,
        "waste": 0.10,
        "traffic": 0.10,
        "environment": 0.10
    }
    score, status, _ = pressure_service.calculate_score(
        tourism=20.0, water=100.0, waste=20.0, traffic=20.0, environment=20.0,
        custom_weights=custom_weights
    )
    # (0.10*20 + 0.60*100 + 0.10*20 + 0.10*20 + 0.10*20) = 2 + 60 + 2 + 2 + 2 = 68.0
    assert score == 68.0
    assert status == PressureStatus.HIGH

    # Non-normalized weights (e.g. sum to 2.0)
    unnormalized_weights = {
        "tourism": 0.60,
        "water": 0.50,
        "waste": 0.40,
        "traffic": 0.30,
        "environment": 0.20
    }
    norm_w = pressure_service.normalize_weights(unnormalized_weights)
    assert abs(sum(norm_w.values()) - 1.0) < 1e-4

def test_api_destination_pressure_endpoint():
    """GET /api/destinations/{id}/pressure returns structured breakdown."""
    res = client.get("/api/destinations/mussoorie/pressure")
    assert res.status_code == 200
    data = res.json()
    assert "score" in data
    assert "status" in data
    assert "tourismScore" in data
    assert "waterScore" in data
    assert "wasteScore" in data
    assert "trafficScore" in data
    assert "environmentScore" in data
    assert "explanation" in data
    assert len(data["explanation"]) > 10

def test_api_destination_history_endpoint():
    """GET /api/destinations/{id}/history returns time-series snapshots."""
    res = client.get("/api/destinations/mussoorie/history?days=7")
    assert res.status_code == 200
    data = res.json()
    assert data["destinationId"] == "mussoorie"
    assert "history" in data
    assert len(data["history"]) == 7
    assert "score" in data["history"][0]
    assert "date" in data["history"][0]

def test_api_regional_aggregate_endpoint():
    """GET /api/region/pressure returns statewide telemetry."""
    res = client.get("/api/region/pressure")
    assert res.status_code == 200
    data = res.json()
    assert "averageScore" in data
    assert "overallStatus" in data
    assert "totalDestinations" in data
    assert data["totalDestinations"] >= 20
    assert "statusDistribution" in data
    assert "criticalBottlenecks" in data
    assert "sustainableAlternatives" in data
    assert "districtAverages" in data
