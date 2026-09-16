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

class MLService:
    def __init__(self):
        self.predictor = pressure_predictor

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

    def classify_report(self, description: str) -> AIReportClassification:
        """
        Classifies citizen issue description into Category, Severity (1-5), and confidence.
        """
        desc_lower = description.lower()

        # Keyword heuristics for high-risk mountain emergency signals
        if any(w in desc_lower for w in ["landslide", "rockfall", "bridge collapsed", "cloudburst", "flash flood", "road block"]):
            pred_cat = ReportCategory.ROAD
            if any(w in desc_lower for w in ["cloudburst", "flash flood"]):
                pred_cat = ReportCategory.ENVIRONMENT
            pred_sev = 5
            confidence = 0.96
            explanation = "High-priority mountain hazard detected. Direct disruption to regional connectivity/life safety."
            action = "Immediate dispatch of district disaster response & PWD heavy clearance machinery."
            return AIReportClassification(
                aiCategory=pred_cat,
                aiSeverity=pred_sev,
                aiConfidence=confidence,
                aiExplanation=explanation,
                recommendedAction=action
            )

        if any(w in desc_lower for w in ["water shortage", "no water", "tanker", "pipe burst", "dry tap", "dirty water", "sewage"]):
            pred_cat = ReportCategory.WATER
            pred_sev = 4 if any(w in desc_lower for w in ["3 days", "dry", "burst", "dirty"]) else 3
            confidence = 0.92
            explanation = "Drinking water supply or filtration failure identified in municipal grid."
            action = "Alert Jal Sansthan water supply engineer & initiate emergency water tanker deployment."
            return AIReportClassification(
                aiCategory=pred_cat,
                aiSeverity=pred_sev,
                aiConfidence=confidence,
                aiExplanation=explanation,
                recommendedAction=action
            )

        if any(w in desc_lower for w in ["traffic", "jam", "congestion", "gridlock", "bottleneck", "parking full", "blocked vehicle"]):
            pred_cat = ReportCategory.TRAFFIC
            pred_sev = 4 if any(w in desc_lower for w in ["massive", "hours", "5km", "gridlock", "ambulance"]) else 3
            confidence = 0.94
            explanation = "Transit bottleneck or severe vehicular congestion identified on regional access route."
            action = "Alert regional traffic control and trigger dynamic detour recommendations."
            return AIReportClassification(
                aiCategory=pred_cat,
                aiSeverity=pred_sev,
                aiConfidence=confidence,
                aiExplanation=explanation,
                recommendedAction=action
            )

        if any(w in desc_lower for w in ["garbage", "waste", "trash", "litter", "dump", "plastic", "overflowing bin"]):
            pred_cat = ReportCategory.WASTE
            pred_sev = 3
            confidence = 0.91
            explanation = "Solid waste accumulation detected exceeding local municipal collection cadence."
            action = "Dispatch Nagar Palika waste management vehicle for priority clearance."
            return AIReportClassification(
                aiCategory=pred_cat,
                aiSeverity=pred_sev,
                aiConfidence=confidence,
                aiExplanation=explanation,
                recommendedAction=action
            )

        return AIReportClassification(
            aiCategory=ReportCategory.OTHER,
            aiSeverity=3,
            aiConfidence=0.75,
            aiExplanation="Civic report processed by keyword classifier for administrative review.",
            recommendedAction="District triage team verification."
        )

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
