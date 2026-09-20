import os
import sys
import numpy as np
from datetime import datetime, timezone, timedelta
from typing import Dict, Any, List, Optional
import joblib

# Ensure repository root is in sys.path
sys.path.insert(0, os.path.abspath(os.path.join(os.path.dirname(__file__), "..", "..", "..")))

from app.models.domain import ReportCategory, PressureStatus
from app.models.schemas import (
    AIReportClassification,
    PressurePredictionPoint,
    DestinationForecastResponse,
    DestinationPredictionResponse
)
from ml.inference.predictor import pressure_predictor
from app.core.firebase import db

from app.ml.report_classifier import report_classifier

class MLService:
    def __init__(self):
        self.predictor = pressure_predictor
        self.report_classifier = report_classifier

    def predict_pressure(self, dest_data: Dict[str, Any], horizon_days: int = 3) -> DestinationPredictionResponse:
        """
        Runs ML inference for a destination given current features and historical records.
        """
        dest_id = dest_data.get("id", "")
        # Retrieve historical context for lag feature calculation
        all_hist = db.get_all("pressure_history")
        dest_hist = [r for r in all_hist if r.get("destinationId") == dest_id]
        
        pred_dict = self.predictor.predict_destination(
            destination_data=dest_data,
            horizon_days=horizon_days,
            historical_records=dest_hist
        )
        return DestinationPredictionResponse(**pred_dict)

    def classify_report(self, description: str, image_url: Optional[str] = None) -> AIReportClassification:
        """
        Classifies citizen issue description into Category, Severity (LOW, MEDIUM, HIGH, CRITICAL),
        confidence, and explanation using lightweight NLP/ML engine.
        """
        return self.report_classifier.classify(description, image_url=image_url)


    def forecast_pressure(self, dest_data: Dict[str, Any], days: int = 7) -> DestinationForecastResponse:
        """
        Generates 7-day predicted pressure trend with confidence intervals using ML engine.
        """
        today = datetime.now(timezone.utc)
        points: List[PressurePredictionPoint] = []
        dest_id = dest_data.get("id", "")

        all_hist = db.get_all("pressure_history")
        dest_hist = [r for r in all_hist if r.get("destinationId") == dest_id]

        for i in range(1, days + 1):
            pred_res = self.predictor.predict_destination(
                destination_data=dest_data,
                horizon_days=i,
                historical_records=dest_hist
            )
            future_date = today + timedelta(days=i)
            points.append(PressurePredictionPoint(
                forecastDate=future_date.strftime("%Y-%m-%d"),
                predictedPressure=pred_res["predictedScore"],
                confidenceLower=pred_res["confidenceRange"]["lower"],
                confidenceUpper=pred_res["confidenceRange"]["upper"],
                primaryRiskFactor=pred_res["primaryRiskFactor"]
            ))

        base_pressure = float(dest_data.get("pressureScore", 35.0))
        return DestinationForecastResponse(
            destinationId=dest_data.get("id", ""),
            destinationName=dest_data.get("name", ""),
            currentPressure=base_pressure,
            currentStatus=PressureStatus(dest_data.get("status", "MODERATE")),
            generatedAt=today.isoformat() + "Z",
            forecast7Days=points
        )

ml_service = MLService()
