from fastapi import APIRouter
from typing import Dict, List
from collections import defaultdict
from app.models.schemas import AdminAnalyticsResponse, DistrictPressureMetric, ReportResponse
from app.models.domain import PressureStatus, ReportStatus
from app.services.destination_service import destination_service
from app.services.report_service import report_service
from app.services.provider_service import provider_service

router = APIRouter(prefix="/admin", tags=["Admin Portal & Analytics"])

@router.get("/analytics", response_model=AdminAnalyticsResponse)
def get_admin_analytics():
    destinations = destination_service.list_destinations()
    reports = report_service.list_reports()
    providers = provider_service.list_providers()

    total_destinations = len(destinations)
    high_pressure_destinations = sum(1 for d in destinations if d.status in [PressureStatus.HIGH, PressureStatus.CRITICAL])
    critical_issues = sum(1 for r in reports if r.aiSeverity >= 4 and r.status != ReportStatus.RESOLVED)
    open_reports = sum(1 for r in reports if r.status != ReportStatus.RESOLVED)
    resolved_reports = sum(1 for r in reports if r.status == ReportStatus.RESOLVED)
    
    avg_pressure = (
        sum(d.pressureScore for d in destinations) / max(1, total_destinations)
        if total_destinations > 0 else 0.0
    )

    # District aggregations
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

    # Category distribution for reports
    cat_counts = defaultdict(int)
    for r in reports:
        cat_counts[r.aiCategory] += 1

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
        recentCriticalIncidents=recent_critical
    )
