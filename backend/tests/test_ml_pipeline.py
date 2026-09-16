import os
import sys

# Ensure repository root is in sys.path
sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__)))))

import pytest
from fastapi.testclient import TestClient
from app.main import app
from ml.inference.predictor import pressure_predictor
from app.models.domain import PressureStatus

client = TestClient(app)

def test_ml_artifacts_exist():
    """Verify that ML model, preprocessor, and metadata artifacts were serialized successfully."""
    base_dir = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
    model_path = os.path.join(base_dir, "ml", "models", "pressure_regressor.joblib")
    prep_path = os.path.join(base_dir, "ml", "models", "preprocessor.joblib")
    meta_path = os.path.join(base_dir, "ml", "models", "model_metadata.json")

    assert os.path.exists(model_path), "Serialized model missing"
    assert os.path.exists(prep_path), "Preprocessor missing"
    assert os.path.exists(meta_path), "Model metadata JSON missing"

def test_predictor_direct_inference():
    """Direct inference check through PressurePredictor."""
    sample_dest = {
        "id": "mussoorie",
        "name": "Mussoorie",
        "capacity": 15000,
        "tourismScore": 88.0,
        "waterScore": 82.0,
        "wasteScore": 76.0,
        "trafficScore": 92.0,
        "environmentScore": 45.0,
        "currentVisitorsEst": 22000
    }

    pred = pressure_predictor.predict_destination(sample_dest, horizon_days=3)

    assert pred["destinationId"] == "mussoorie"
    assert "predictedScore" in pred
    assert 0.0 <= pred["predictedScore"] <= 100.0
    assert pred["predictionHorizonDays"] == 3
    assert "confidenceRange" in pred
    assert pred["confidenceRange"]["lower"] <= pred["predictedScore"] <= pred["confidenceRange"]["upper"]
    assert pred["isDemo"] is True
    assert pred["dataSource"] == "SYNTHETIC_ML_PIPELINE"
    assert "synthetic" in pred["disclaimer"].lower()

def test_api_destination_prediction_endpoint():
    """Test GET /api/destinations/{id}/prediction endpoint."""
    res = client.get("/api/destinations/mussoorie/prediction?horizon_days=3")
    assert res.status_code == 200
    data = res.json()

    assert data["destinationId"] == "mussoorie"
    assert "currentScore" in data
    assert "predictedScore" in data
    assert "riskLevel" in data
    assert data["riskLevel"] in ["LOW", "MODERATE", "HIGH", "CRITICAL"]
    assert "modelConfidence" in data
    assert 0.50 <= data["modelConfidence"] <= 1.0
    assert "modelDetails" in data
    assert "algorithm" in data["modelDetails"]
    assert "validationR2" in data["modelDetails"]
    assert data["isDemo"] is True
    assert "disclaimer" in data

def test_api_destination_prediction_horizons():
    """Test multiple forecast horizons (1 day, 7 days, 14 days)."""
    for horizon in [1, 7, 14]:
        res = client.get(f"/api/destinations/kanatal/prediction?horizon_days={horizon}")
        assert res.status_code == 200
        data = res.json()
        assert data["predictionHorizonDays"] == horizon
        assert 0.0 <= data["predictedScore"] <= 100.0

def test_api_destination_prediction_invalid_destination():
    """404 returned for non-existent destination."""
    res = client.get("/api/destinations/non_existent_valley_99/prediction")
    assert res.status_code == 404

def test_api_pressure_forecast_endpoint():
    """Test GET /api/pressure/forecast/{id} multi-day time-series."""
    res = client.get("/api/pressure/forecast/rishikesh?days=7")
    assert res.status_code == 200
    data = res.json()
    assert data["destinationId"] == "rishikesh"
    assert "forecast7Days" in data
    assert len(data["forecast7Days"]) == 7
    for pt in data["forecast7Days"]:
        assert 0.0 <= pt["predictedPressure"] <= 100.0
        assert pt["confidenceLower"] <= pt["predictedPressure"] <= pt["confidenceUpper"]
