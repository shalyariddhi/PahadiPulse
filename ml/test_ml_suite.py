import os
import sys
import pytest
import numpy as np
import pandas as pd

# Add project root and ml directory to sys.path
BASE_DIR = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
sys.path.insert(0, BASE_DIR)
sys.path.insert(0, os.path.join(BASE_DIR, "ml"))
sys.path.insert(0, os.path.join(BASE_DIR, "backend"))

from ml.inference.predictor import PressurePredictor
from ml.dataset import REPORTS_DATASET
from app.ml.report_classifier import LightweightReportClassifier
from app.services.pressure_service import pressure_service
from app.models.domain import PressureStatus

def test_reports_dataset_integrity():
    """Verify ML training dataset has samples across all 9 categories and severities 1 to 5."""
    assert len(REPORTS_DATASET) >= 40
    categories = set(item[1] for item in REPORTS_DATASET)
    severities = set(item[2] for item in REPORTS_DATASET)
    
    expected_categories = {"WATER", "WASTE", "ROAD", "TRAFFIC", "HEALTH", "CONNECTIVITY", "TOURISM", "ENVIRONMENT", "OTHER"}
    assert expected_categories.issubset(categories)
    assert {1, 2, 3, 4, 5}.issubset(severities)

def test_ml_pressure_predictor_inference():
    """Test predictor with typical destination parameters."""
    predictor = PressurePredictor()
    dest_data = {
        "id": "mussoorie",
        "name": "Mussoorie",
        "capacity": 15000,
        "currentVisitorsEst": 22000,
        "tourismScore": 88.0,
        "waterScore": 82.0,
        "wasteScore": 76.0,
        "trafficScore": 92.0,
        "environmentScore": 45.0
    }
    pred = predictor.predict_destination(dest_data, horizon_days=3)
    assert pred["destinationId"] == "mussoorie"
    assert 0.0 <= pred["predictedScore"] <= 100.0
    assert pred["riskLevel"] in [PressureStatus.HIGH, PressureStatus.CRITICAL]
    assert pred["confidenceRange"]["lower"] <= pred["predictedScore"] <= pred["confidenceRange"]["upper"]
    assert pred["modelConfidence"] > 0.60
    assert pred["primaryRiskFactor"] in ["Traffic Jam", "Tourism Rush", "Water Deficit", "Solid Waste"]

def test_ml_prediction_boundaries_clamping():
    """Test that extreme boundary values and negative values are strictly clamped between 0.0 and 100.0."""
    predictor = PressurePredictor()
    
    # Negative / under-capacity inputs
    negative_dest = {
        "id": "remote_village",
        "name": "Remote Village",
        "capacity": 5000,
        "currentVisitorsEst": -500,
        "tourismScore": -20.0,
        "waterScore": -10.0,
        "wasteScore": 0.0,
        "trafficScore": 0.0,
        "environmentScore": 0.0
    }
    neg_pred = predictor.predict_destination(negative_dest, horizon_days=7)
    assert neg_pred["predictedScore"] >= 0.0
    assert neg_pred["confidenceRange"]["lower"] >= 0.0

    # Extreme overflowing inputs (300% load)
    extreme_dest = {
        "id": "chokepoint",
        "name": "Chokepoint",
        "capacity": 1000,
        "currentVisitorsEst": 50000,
        "tourismScore": 150.0,
        "waterScore": 120.0,
        "wasteScore": 140.0,
        "trafficScore": 200.0,
        "environmentScore": 110.0
    }
    ext_pred = predictor.predict_destination(extreme_dest, horizon_days=1)
    assert ext_pred["predictedScore"] <= 100.0
    assert ext_pred["confidenceRange"]["upper"] <= 100.0
    assert ext_pred["riskLevel"] == PressureStatus.CRITICAL

def test_ml_invalid_inputs_handling():
    """Test predictor resiliency against missing or empty dictionaries."""
    predictor = PressurePredictor()
    empty_dest = {}
    pred = predictor.predict_destination(empty_dest, horizon_days=3)
    assert pred["destinationId"] == "unknown"
    assert 0.0 <= pred["predictedScore"] <= 100.0

def test_report_classifier_nlp_inference():
    """Test NLP report classification model for diverse citizen feedback."""
    classifier = LightweightReportClassifier()
    
    # Water problem
    res_water = classifier.classify("Dry taps and municipal water tanker missing for 4 days")
    assert res_water.category.value == "WATER"
    assert res_water.confidence > 0.5
    
    # Waste issue
    res_waste = classifier.classify("Massive piles of plastic bottles and garbage dumping on hill slopes")
    assert res_waste.category.value == "WASTE"
    
    # Road block / Landslide
    res_road = classifier.classify("Huge rockfall and landslide blocking Badrinath national highway")
    assert res_road.category.value == "ROAD"
    assert res_road.severity.value in ["HIGH", "CRITICAL"]

def test_report_classifier_empty_input_fallback():
    """Test NLP classifier handles single-word or short inputs gracefully."""
    classifier = LightweightReportClassifier()
    res = classifier.classify("Help")
    assert res.category is not None
    assert res.severity is not None
    assert 0.0 <= res.confidence <= 1.0
