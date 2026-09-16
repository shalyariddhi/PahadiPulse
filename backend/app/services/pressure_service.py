from typing import Dict, Any, Tuple, List, Optional
from datetime import datetime, timezone, timedelta
import random
from app.config import settings
from app.models.domain import PressureStatus
from app.models.schemas import (
    PressureBreakdown,
    PressureDetailResponse,
    PressureHistoryPoint,
    PressureHistoryResponse,
    RegionalPressureAggregate
)
from app.core.firebase import db

class PressureService:
    DEFAULT_WEIGHTS = {
        "tourism": 0.30,
        "water": 0.25,
        "waste": 0.20,
        "traffic": 0.15,
        "environment": 0.10
    }

    @staticmethod
    def normalize_weights(custom_weights: Optional[Dict[str, float]] = None) -> Dict[str, float]:
        """
        Validates and normalizes weights to sum exactly to 1.0.
        Falls back to default weights if not provided or invalid.
        """
        if not custom_weights:
            return dict(PressureService.DEFAULT_WEIGHTS)
        
        weights = {}
        for key in ["tourism", "water", "waste", "traffic", "environment"]:
            val = custom_weights.get(key)
            if val is not None and isinstance(val, (int, float)) and val >= 0:
                weights[key] = float(val)
            else:
                weights[key] = PressureService.DEFAULT_WEIGHTS[key]
        
        total = sum(weights.values())
        if total > 0 and abs(total - 1.0) > 1e-4:
            # Normalize to 1.0
            weights = {k: v / total for k, v in weights.items()}
        elif total == 0:
            weights = dict(PressureService.DEFAULT_WEIGHTS)
            
        return weights

    @staticmethod
    def calculate_status(score: float) -> PressureStatus:
        """
        Calculates status tier based on score:
          0–30: LOW
          31–50: MODERATE
          51–70: HIGH
          71–100: CRITICAL
        """
        clamped = max(0.0, min(100.0, float(score)))
        if clamped <= 30.0:
            return PressureStatus.LOW
        elif clamped <= 50.0:
            return PressureStatus.MODERATE
        elif clamped <= 70.0:
            return PressureStatus.HIGH
        else:
            return PressureStatus.CRITICAL

    @staticmethod
    def generate_explanation(
        tourism: float,
        water: float,
        waste: float,
        traffic: float,
        environment: float,
        status: PressureStatus
    ) -> str:
        """
        Deterministic, rule-based natural language explanation engine.
        Does NOT use an LLM.
        """
        factor_descriptors = {
            "tourism": "tourism density",
            "water": "water stress",
            "waste": "waste pressure",
            "traffic": "traffic bottlenecks",
            "environment": "environmental risk"
        }

        scores = {
            "tourism": tourism,
            "water": water,
            "waste": waste,
            "traffic": traffic,
            "environment": environment
        }

        # Find elevated factors
        if status == PressureStatus.CRITICAL:
            elevated = [k for k, v in scores.items() if v >= 65.0]
            if not elevated:
                elevated = sorted(scores.keys(), key=lambda k: scores[k], reverse=True)[:3]
            names = [factor_descriptors[k] for k in elevated]
            if len(names) == 1:
                factor_text = names[0]
            elif len(names) == 2:
                factor_text = f"{names[0]} and {names[1]}"
            else:
                factor_text = f"{', '.join(names[:-1])} and {names[-1]}"
            return f"Pressure is critical primarily because {factor_text} are severely elevated."

        elif status == PressureStatus.HIGH:
            elevated = [k for k, v in scores.items() if v >= 55.0]
            if not elevated:
                elevated = sorted(scores.keys(), key=lambda k: scores[k], reverse=True)[:2]
            names = [factor_descriptors[k] for k in elevated]
            if len(names) == 1:
                factor_text = names[0]
            elif len(names) == 2:
                factor_text = f"{names[0]} and {names[1]}"
            else:
                factor_text = f"{', '.join(names[:-1])} and {names[-1]}"
            return f"Pressure is high primarily because {factor_text} are elevated."

        elif status == PressureStatus.MODERATE:
            moderates = [factor_descriptors[k] for k, v in scores.items() if v >= 45.0]
            if moderates:
                return f"Pressure is moderate with emerging strain on {', '.join(moderates)}."
            return "Pressure is moderate with balanced tourist flow and manageable infrastructure load."

        else: # LOW
            return "Pressure is low with healthy carrying capacity and minimal infrastructure strain."

    @staticmethod
    def calculate_score(
        tourism: float,
        water: float,
        waste: float,
        traffic: float,
        environment: float,
        custom_weights: Optional[Dict[str, float]] = None
    ) -> Tuple[float, PressureStatus, str]:
        """
        Reusable Regional Pressure Calculation:
        Formula:
          30% Tourism/Crowd Pressure
          25% Water Stress
          20% Waste Pressure
          15% Traffic/Connectivity Pressure
          10% Seasonal/Environmental Risk
        
        Guarantees score is clamped strictly between 0.0 and 100.0.
        """
        # Clamp inputs between 0.0 and 100.0
        try:
            t = max(0.0, min(100.0, float(tourism)))
        except (ValueError, TypeError):
            t = 0.0

        try:
            w = max(0.0, min(100.0, float(water)))
        except (ValueError, TypeError):
            w = 0.0

        try:
            ws = max(0.0, min(100.0, float(waste)))
        except (ValueError, TypeError):
            ws = 0.0

        try:
            tr = max(0.0, min(100.0, float(traffic)))
        except (ValueError, TypeError):
            tr = 0.0

        try:
            env = max(0.0, min(100.0, float(environment)))
        except (ValueError, TypeError):
            env = 0.0

        weights = PressureService.normalize_weights(custom_weights)

        raw_score = (
            weights["tourism"] * t +
            weights["water"] * w +
            weights["waste"] * ws +
            weights["traffic"] * tr +
            weights["environment"] * env
        )
        
        score = round(max(0.0, min(100.0, float(raw_score))), 1)
        status = PressureService.calculate_status(score)
        explanation = PressureService.generate_explanation(t, w, ws, tr, env, status)

        return score, status, explanation

    @staticmethod
    def get_pressure_detail(
        dest_data: Dict[str, Any],
        custom_weights: Optional[Dict[str, float]] = None
    ) -> PressureDetailResponse:
        t = float(dest_data.get("tourismScore", 20.0))
        w = float(dest_data.get("waterScore", 20.0))
        ws = float(dest_data.get("wasteScore", 20.0))
        tr = float(dest_data.get("trafficScore", 20.0))
        env = float(dest_data.get("environmentScore", 20.0))

        score, status, explanation = PressureService.calculate_score(
            t, w, ws, tr, env, custom_weights
        )

        return PressureDetailResponse(
            destinationId=dest_data.get("id"),
            destinationName=dest_data.get("name"),
            score=score,
            compositeScore=score,
            status=status,
            tourismScore=t,
            waterScore=w,
            wasteScore=ws,
            trafficScore=tr,
            environmentScore=env,
            tourism=t,
            water=w,
            waste=ws,
            traffic=tr,
            environment=env,
            explanation=explanation,
            formula="30% Tourism + 25% Water + 20% Waste + 15% Traffic + 10% Environment",
            weightsUsed=PressureService.normalize_weights(custom_weights),
            updatedAt=dest_data.get("updatedAt", datetime.now(timezone.utc).isoformat() + "Z")
        )

    @staticmethod
    def get_breakdown(dest_data: Dict[str, Any]) -> PressureBreakdown:
        detail = PressureService.get_pressure_detail(dest_data)
        return PressureBreakdown(
            tourism=detail.tourismScore,
            water=detail.waterScore,
            waste=detail.wasteScore,
            traffic=detail.trafficScore,
            environment=detail.environmentScore,
            compositeScore=detail.score,
            status=detail.status,
            explanation=detail.explanation,
            formula=detail.formula or "30% Tourism + 25% Water + 20% Waste + 15% Traffic + 10% Environment"
        )

    @staticmethod
    def log_historical_snapshot(dest_id: str, snapshot_data: Dict[str, Any]) -> None:
        """
        Stores historical pressure record for a destination.
        """
        now = datetime.now(timezone.utc)
        record = {
            "id": f"{dest_id}_{now.strftime('%Y%m%d_%H%M%S')}",
            "destinationId": dest_id,
            "date": now.strftime("%Y-%m-%d"),
            "timestamp": now.isoformat() + "Z",
            "score": snapshot_data.get("score", 20.0),
            "status": snapshot_data.get("status", "LOW"),
            "tourismScore": snapshot_data.get("tourismScore", 20.0),
            "waterScore": snapshot_data.get("waterScore", 20.0),
            "wasteScore": snapshot_data.get("wasteScore", 20.0),
            "trafficScore": snapshot_data.get("trafficScore", 20.0),
            "environmentScore": snapshot_data.get("environmentScore", 20.0),
        }
        db.save("pressure_history", record["id"], record)

    @staticmethod
    def get_historical_pressure(dest_id: str, days: int = 14) -> PressureHistoryResponse:
        """
        Retrieves historical pressure time-series for a destination.
        Generates/ensures historical continuity if empty.
        """
        dest = db.get_by_id("destinations", dest_id)
        dest_name = dest.get("name", dest_id.capitalize()) if dest else dest_id.capitalize()

        all_records = db.get_all("pressure_history")
        dest_records = [r for r in all_records if r.get("destinationId") == dest_id]

        points: List[PressureHistoryPoint] = []
        
        if dest_records:
            # Sort by date ascending
            sorted_records = sorted(dest_records, key=lambda x: x.get("timestamp", ""))[-days:]
            for r in sorted_records:
                score = float(r.get("score", 20.0))
                status = PressureService.calculate_status(score)
                points.append(PressureHistoryPoint(
                    date=r.get("date", ""),
                    timestamp=r.get("timestamp", ""),
                    score=score,
                    status=status,
                    tourismScore=float(r.get("tourismScore", 20.0)),
                    waterScore=float(r.get("waterScore", 20.0)),
                    wasteScore=float(r.get("wasteScore", 20.0)),
                    trafficScore=float(r.get("trafficScore", 20.0)),
                    environmentScore=float(r.get("environmentScore", 20.0))
                ))
        else:
            # Generate deterministic synthetic daily history for the last N days
            base_t = float(dest.get("tourismScore", 30.0)) if dest else 30.0
            base_w = float(dest.get("waterScore", 30.0)) if dest else 30.0
            base_ws = float(dest.get("wasteScore", 30.0)) if dest else 30.0
            base_tr = float(dest.get("trafficScore", 30.0)) if dest else 30.0
            base_env = float(dest.get("environmentScore", 30.0)) if dest else 30.0

            now = datetime.now(timezone.utc)
            random.seed(hash(dest_id) % 10000)

            for i in range(days - 1, -1, -1):
                day_date = now - timedelta(days=i)
                # Slight weekday/weekend variation
                weekday_boost = 10.0 if day_date.weekday() in (5, 6) else -5.0
                jitter = (random.random() - 0.5) * 6.0
                
                t = max(0.0, min(100.0, base_t + weekday_boost + jitter))
                w = max(0.0, min(100.0, base_w + (weekday_boost * 0.5) + jitter))
                ws = max(0.0, min(100.0, base_ws + (weekday_boost * 0.6) + jitter))
                tr = max(0.0, min(100.0, base_tr + weekday_boost + jitter))
                env = max(0.0, min(100.0, base_env + (jitter * 0.5)))

                score, status, _ = PressureService.calculate_score(t, w, ws, tr, env)
                point = PressureHistoryPoint(
                    date=day_date.strftime("%Y-%m-%d"),
                    timestamp=day_date.isoformat() + "Z",
                    score=score,
                    status=status,
                    tourismScore=round(t, 1),
                    waterScore=round(w, 1),
                    wasteScore=round(ws, 1),
                    trafficScore=round(tr, 1),
                    environmentScore=round(env, 1)
                )
                points.append(point)

        return PressureHistoryResponse(
            destinationId=dest_id,
            destinationName=dest_name,
            days=days,
            history=points
        )

    @staticmethod
    def get_regional_aggregate() -> RegionalPressureAggregate:
        """
        Computes macroeconomic regional pressure metrics across all 20 Uttarakhand destinations.
        """
        destinations = db.get_all("destinations")
        if not destinations:
            return RegionalPressureAggregate(
                averageScore=0.0,
                overallStatus=PressureStatus.LOW,
                totalDestinations=0,
                statusDistribution={"LOW": 0, "MODERATE": 0, "HIGH": 0, "CRITICAL": 0},
                criticalBottlenecks=[],
                sustainableAlternatives=[],
                districtAverages={},
                generatedAt=datetime.now(timezone.utc).isoformat() + "Z"
            )

        scores = []
        status_dist = {"LOW": 0, "MODERATE": 0, "HIGH": 0, "CRITICAL": 0}
        district_scores: Dict[str, List[float]] = {}
        processed_destinations = []

        for d in destinations:
            t = float(d.get("tourismScore", 20.0))
            w = float(d.get("waterScore", 20.0))
            ws = float(d.get("wasteScore", 20.0))
            tr = float(d.get("trafficScore", 20.0))
            env = float(d.get("environmentScore", 20.0))

            score, status, explanation = PressureService.calculate_score(t, w, ws, tr, env)
            scores.append(score)
            status_dist[status.value] = status_dist.get(status.value, 0) + 1

            dist = d.get("district", "Unknown")
            if dist not in district_scores:
                district_scores[dist] = []
            district_scores[dist].append(score)

            processed_destinations.append({
                "id": d.get("id"),
                "name": d.get("name"),
                "district": dist,
                "score": score,
                "status": status.value,
                "tourismScore": t,
                "waterScore": w,
                "wasteScore": ws,
                "trafficScore": tr,
                "environmentScore": env,
                "explanation": explanation
            })

        avg_score = round(sum(scores) / len(scores), 1)
        overall_status = PressureService.calculate_status(avg_score)

        # Sort by score
        sorted_dest = sorted(processed_destinations, key=lambda x: x["score"], reverse=True)
        critical_bottlenecks = [d for d in sorted_dest if d["score"] >= 51.0][:5]
        sustainable_alternatives = [d for d in sorted_dest if d["score"] <= 35.0][:5]

        # District averages
        district_averages = {
            dist: round(sum(s_list) / len(s_list), 1)
            for dist, s_list in district_scores.items()
        }

        return RegionalPressureAggregate(
            averageScore=avg_score,
            overallStatus=overall_status,
            totalDestinations=len(destinations),
            statusDistribution=status_dist,
            criticalBottlenecks=critical_bottlenecks,
            sustainableAlternatives=sustainable_alternatives,
            districtAverages=district_averages,
            generatedAt=datetime.now(timezone.utc).isoformat() + "Z"
        )

pressure_service = PressureService()

