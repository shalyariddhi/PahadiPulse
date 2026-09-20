import pytest
from fastapi.testclient import TestClient
from app.main import app
from app.models.domain import ReportCategory, ReportSeverity
from app.ml.report_classifier import report_classifier

client = TestClient(app)

def test_classifier_direct_inference():
    # 1. Waste category
    res_waste = report_classifier.classify("Overflowing garbage and uncollected plastic litter near public bus stand")
    assert res_waste.category == ReportCategory.WASTE
    assert res_waste.severity in [ReportSeverity.MEDIUM, ReportSeverity.HIGH]
    assert res_waste.confidence >= 0.80
    assert "waste" in res_waste.explanation.lower() or "garbage" in res_waste.explanation.lower()
    assert "not claimed as production-grade" in res_waste.disclaimer.lower()

    # 2. Road landslide (Critical)
    res_road = report_classifier.classify("Massive landslide and rockfall boulder blocking highway traffic completely")
    assert res_road.category == ReportCategory.ROAD
    assert res_road.severity == ReportSeverity.CRITICAL
    assert res_road.confidence >= 0.85
    assert "road" in res_road.explanation.lower() or "slope" in res_road.explanation.lower()

    # 3. Water deficit
    res_water = report_classifier.classify("Drinking water pipeline burst; dry taps and no water supply for 3 days")
    assert res_water.category == ReportCategory.WATER
    assert res_water.severity in [ReportSeverity.HIGH, ReportSeverity.CRITICAL]
    assert res_water.confidence >= 0.85

    # 4. Traffic bottleneck
    res_traffic = report_classifier.classify("Severe 5km traffic congestion and gridlock on Mall Road bypass")
    assert res_traffic.category == ReportCategory.TRAFFIC
    assert res_traffic.severity in [ReportSeverity.HIGH, ReportSeverity.CRITICAL]

    # 5. Health emergency
    res_health = report_classifier.classify("Medical emergency near viewpoint, injured tourist and no ambulance available")
    assert res_health.category == ReportCategory.HEALTH
    assert res_health.severity == ReportSeverity.CRITICAL

    # 6. Connectivity outage
    res_conn = report_classifier.classify("Mobile network tower down and complete blackout power cut in village")
    assert res_conn.category == ReportCategory.CONNECTIVITY
    assert res_conn.severity in [ReportSeverity.HIGH, ReportSeverity.CRITICAL]

    # 7. Tourism overcharging
    res_tour = report_classifier.classify("Unauthorized guide tourist scam and overcharging entry fee harassment")
    assert res_tour.category == ReportCategory.TOURISM
    assert res_tour.severity in [ReportSeverity.MEDIUM, ReportSeverity.HIGH]

    # 8. Environment hazard
    res_env = report_classifier.classify("Cloudburst and sudden flash flood warning on mountain slope")
    assert res_env.category == ReportCategory.ENVIRONMENT
    assert res_env.severity == ReportSeverity.CRITICAL

    # 9. Other civic
    res_other = report_classifier.classify("Broken park bench and streetlight flickering in residential lane")
    assert res_other.category == ReportCategory.OTHER
    assert res_other.severity in [ReportSeverity.LOW, ReportSeverity.MEDIUM]

def test_api_classify_report_endpoint():
    payload = {
        "text": "Solid waste dump overflowing near temple stairs with strong smell",
        "imageUrl": "https://example.com/waste.jpg"
    }
    res = client.post("/api/ai/classify-report", json=payload)
    assert res.status_code == 200
    data = res.json()
    assert data["category"] == "WASTE"
    assert data["severity"] in ["MEDIUM", "HIGH"]
    assert data["confidence"] > 0.8
    assert len(data["explanation"]) > 20
    assert "disclaimer" in data
    # Verify backward compatibility fields
    assert data["aiCategory"] == "WASTE"
    assert data["aiSeverity"] in [3, 4]
    assert data["aiConfidence"] == data["confidence"]

def test_classification_stored_with_report():
    report_payload = {
        "destinationId": "kanatal",
        "category": "OTHER",
        "description": "Massive pipeline burst flooding road and leaving upper village with no water supply",
        "latitude": 30.41,
        "longitude": 78.34,
        "imageUrl": "https://example.com/pipe.jpg"
    }
    create_res = client.post("/api/reports", json=report_payload)
    assert create_res.status_code == 201
    rep = create_res.json()
    
    # Must store classification
    assert rep["category"] in ["WATER", "ROAD"]
    assert rep["severity"] in ["HIGH", "CRITICAL"]
    assert rep["aiCategory"] in ["WATER", "ROAD"]
    assert rep["aiSeverity"] >= 4
    assert rep["aiConfidence"] > 0.8
    assert "explanation" in rep["aiExplanation"].lower() or len(rep["aiExplanation"]) > 10

def test_admin_review_and_correction():
    # 1. Create a report initially
    report_payload = {
        "destinationId": "mussoorie",
        "category": "OTHER",
        "description": "Civic issue reported near municipal garden",
        "latitude": 30.45,
        "longitude": 78.06
    }
    create_res = client.post("/api/reports", json=report_payload)
    assert create_res.status_code == 201
    rep_id = create_res.json()["id"]

    # 2. Admin reviews and corrects classification (e.g. from OTHER -> WASTE, severity -> HIGH)
    review_payload = {
        "category": "WASTE",
        "severity": "HIGH",
        "status": "VERIFIED",
        "adminNotes": "Confirmed by Municipal Sanitation Inspector; team dispatched."
    }
    admin_headers = {"Authorization": "Bearer admin_secret_pahadi"}
    
    review_res = client.patch(f"/api/reports/{rep_id}/review", json=review_payload, headers=admin_headers)
    assert review_res.status_code == 200
    updated = review_res.json()
    
    assert updated["category"] == "WASTE"
    assert updated["severity"] == "HIGH"
    assert updated["aiCategory"] == "WASTE"
    assert updated["aiSeverity"] == 4
    assert updated["status"] == "VERIFIED"
    assert updated["adminReviewed"] is True
    assert "Sanitation Inspector" in updated["adminNotes"]
