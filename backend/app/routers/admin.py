from fastapi import APIRouter, Query, Depends
from typing import Dict, List, Optional
from collections import defaultdict
from datetime import datetime, timedelta, timezone
from app.models.schemas import (
    AdminAnalyticsResponse,
    DistrictPressureMetric,
    ReportResponse,
    DailyPressurePoint,
    DestinationPressureMetric,
    DestinationFactorMetric,
    PredictionComparisonMetric
)
from app.models.domain import PressureStatus, ReportStatus
from app.services.destination_service import destination_service
from app.services.report_service import report_service
from app.services.provider_service import provider_service
from app.services.pressure_service import pressure_service
from app.core.security import require_admin

router = APIRouter(prefix="/admin", tags=["Admin Portal & Analytics"])

@router.get("/analytics", response_model=AdminAnalyticsResponse)
def get_admin_analytics(
    days: int = Query(14, ge=1, le=90, description="Historical trend days"),
    district: Optional[str] = Query(None, description="Filter analytics by district"),
    category: Optional[str] = Query(None, description="Filter reports/providers by category"),
    _ = Depends(require_admin)
):
    all_destinations = destination_service.list_destinations()
    all_reports = report_service.list_reports()
    all_providers = provider_service.list_providers()

    # Apply filters if provided
    destinations = [
        d for d in all_destinations 
        if (not district or district == 'ALL' or d.district.lower() == district.lower())
    ]
    reports = [
        r for r in all_reports
        if (not category or category == 'ALL' or r.aiCategory == category or r.category == category)
    ]
    providers = [
        p for p in all_providers
        if (not category or category == 'ALL' or p.category == category)
    ]

    total_destinations = len(destinations)
    high_pressure_destinations = sum(1 for d in destinations if d.status in [PressureStatus.HIGH, PressureStatus.CRITICAL])
    critical_issues = sum(1 for r in reports if r.aiSeverity >= 4 and r.status != ReportStatus.RESOLVED)
    open_reports = sum(1 for r in reports if r.status != ReportStatus.RESOLVED)
    resolved_reports = sum(1 for r in reports if r.status == ReportStatus.RESOLVED)
    
    avg_pressure = (
        sum(d.pressureScore for d in destinations) / max(1, total_destinations)
        if total_destinations > 0 else 0.0
    )

    # 1. District summaries
    district_data = defaultdict(lambda: {"total": 0.0, "count": 0, "critical": 0})
    for d in destinations:
        district_data[d.district]["total"] += d.pressureScore
        district_data[d.district]["count"] += 1
        if d.status == PressureStatus.CRITICAL:
            district_data[d.district]["critical"] += 1

    district_summaries = [
        DistrictPressureMetric(
            district=k,
            avgPressure=round(v["total"] / max(1, v["count"]), 1),
            destinationsCount=v["count"],
            criticalCount=v["critical"]
        )
        for k, v in district_data.items()
    ]
    district_summaries.sort(key=lambda x: x.avgPressure, reverse=True)

    # 2. Category distribution for reports
    cat_counts = defaultdict(int)
    for r in reports:
        cat_counts[r.aiCategory] += 1

    # 3. Severity distribution for reports
    sev_counts = defaultdict(int)
    for r in reports:
        if r.aiSeverity >= 5:
            sev_counts["CRITICAL"] += 1
        elif r.aiSeverity == 4:
            sev_counts["HIGH"] += 1
        elif r.aiSeverity == 3:
            sev_counts["MEDIUM"] += 1
        else:
            sev_counts["LOW"] += 1

    # 4. Report status distribution
    status_counts = defaultdict(int)
    for r in reports:
        status_counts[r.status] += 1

    # 5. Provider distribution by category
    provider_cat_counts = defaultdict(int)
    for p in providers:
        provider_cat_counts[p.category] += 1

    # 6. Destination pressure comparison
    destination_pressure_comparison = [
        DestinationPressureMetric(
            destinationId=d.id,
            name=d.name,
            district=d.district,
            pressureScore=round(d.pressureScore, 1),
            status=d.status,
            currentVisitors=d.currentVisitorsEst,
            capacity=d.capacity,
            loadPercentage=round(((d.currentVisitorsEst / max(1, d.capacity)) * 100), 1)
        )
        for d in destinations
    ]
    destination_pressure_comparison.sort(key=lambda x: x.pressureScore, reverse=True)

    # 7. 5-Factor comparison
    factor_comparison = [
        DestinationFactorMetric(
            destinationId=d.id,
            name=d.name,
            district=d.district,
            tourism=round(d.subScores.get("tourism", d.tourismScore), 1),
            water=round(d.subScores.get("water", d.waterScore), 1),
            waste=round(d.subScores.get("waste", d.wasteScore), 1),
            traffic=round(d.subScores.get("traffic", d.trafficScore), 1),
            environment=round(d.subScores.get("environment", d.environmentScore), 1),
            compositeScore=round(d.pressureScore, 1)
        )
        for d in destinations
    ]

    # 8. Regional pressure historical trend
    now = datetime.now(timezone.utc)
    regional_trend = []
    for day_offset in range(days - 1, -1, -1):
        d_date = (now - timedelta(days=day_offset)).strftime("%Y-%m-%d")
        # Synthesize historical regional mean based on actual base pressure and day pattern
        day_factor = 1.0 + (0.08 if (day_offset % 7 in [5, 6]) else -0.04)
        day_avg = round(min(100.0, max(0.0, avg_pressure * day_factor)), 1)
        crit_c = sum(1 for d in destinations if (d.pressureScore * day_factor) >= 70)
        high_c = sum(1 for d in destinations if (d.pressureScore * day_factor) >= 50)
        regional_trend.append(DailyPressurePoint(
            date=d_date,
            avgPressure=day_avg,
            highPressureCount=high_c,
            criticalCount=crit_c
        ))

    # 9. Prediction vs Current comparison
    prediction_comparison = []
    for d in destinations[:10]:
        # Generate simulated ML projection delta based on ML model baseline
        proj_delta = round((d.pressureScore * 0.05) + (2.0 if d.pressureScore >= 50 else -1.5), 1)
        pred_val = round(min(100.0, max(0.0, d.pressureScore + proj_delta)), 1)
        risk = "CRITICAL" if pred_val >= 70 else "HIGH" if pred_val >= 50 else "MODERATE" if pred_val >= 30 else "LOW"
        primary_risk = (
            "Visitor Influx / Mall Road Chokepoint" if d.subScores.get("traffic", 0) >= 60
            else "Seasonal Water Shortage" if d.subScores.get("water", 0) >= 60
            else "Solid Waste Overflow" if d.subScores.get("waste", 0) >= 60
            else "Slope / Monsoon Hazards"
        )
        prediction_comparison.append(PredictionComparisonMetric(
            destinationId=d.id,
            name=d.name,
            district=d.district,
            currentPressure=round(d.pressureScore, 1),
            predictedPressure=pred_val,
            delta=proj_delta,
            riskLevel=risk,
            primaryRiskFactor=primary_risk
        ))

    # Recent critical incidents
    recent_critical = [r for r in reports if r.aiSeverity >= 4][:5]

    return AdminAnalyticsResponse(
        totalDestinations=total_destinations,
        highPressureDestinations=high_pressure_destinations,
        criticalIssuesCount=critical_issues,
        openReportsCount=open_reports,
        resolvedReportsCount=resolved_reports,
        totalLocalProviders=len(providers),
        avgRegionalPressure=round(avg_pressure, 1),
        districtSummaries=district_summaries,
        categoryDistribution=dict(cat_counts),
        recentCriticalIncidents=recent_critical,
        regionalPressureTrend=regional_trend,
        destinationPressureComparison=destination_pressure_comparison,
        pressureFactorComparison=factor_comparison,
        reportCategoryDistribution=dict(cat_counts),
        reportSeverityDistribution=dict(sev_counts),
        reportStatusDistribution=dict(status_counts),
        providerCategoryDistribution=dict(provider_cat_counts),
        tourismPressureTrends=destination_pressure_comparison,
        predictionVsCurrent=prediction_comparison
    )
