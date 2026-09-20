from enum import Enum
from typing import Optional, List, Dict, Any
from datetime import datetime

class UserRole(str, Enum):
    TOURIST = "tourist"
    CITIZEN = "citizen"
    ADMIN = "admin"

class PressureStatus(str, Enum):
    LOW = "LOW"             # 0 - 30
    MODERATE = "MODERATE"   # 31 - 50
    HIGH = "HIGH"           # 51 - 70
    CRITICAL = "CRITICAL"   # 71 - 100

class ReportCategory(str, Enum):
    WATER = "WATER"
    WASTE = "WASTE"
    ROAD = "ROAD"
    TRAFFIC = "TRAFFIC"
    HEALTH = "HEALTH"
    CONNECTIVITY = "CONNECTIVITY"
    TOURISM = "TOURISM"
    ENVIRONMENT = "ENVIRONMENT"
    OTHER = "OTHER"

class ReportSeverity(str, Enum):
    LOW = "LOW"
    MEDIUM = "MEDIUM"
    HIGH = "HIGH"
    CRITICAL = "CRITICAL"

def severity_to_numeric(sev: ReportSeverity) -> int:
    mapping = {
        ReportSeverity.LOW: 2,
        ReportSeverity.MEDIUM: 3,
        ReportSeverity.HIGH: 4,
        ReportSeverity.CRITICAL: 5,
    }
    return mapping.get(sev, 3)

def numeric_to_severity(val: int) -> ReportSeverity:
    if val >= 5:
        return ReportSeverity.CRITICAL
    elif val == 4:
        return ReportSeverity.HIGH
    elif val == 3:
        return ReportSeverity.MEDIUM
    else:
        return ReportSeverity.LOW

class ReportStatus(str, Enum):
    SUBMITTED = "SUBMITTED"
    AI_CLASSIFIED = "AI_CLASSIFIED"
    VERIFIED = "VERIFIED"
    ASSIGNED = "ASSIGNED"
    RESOLVED = "RESOLVED"

class ProviderCategory(str, Enum):
    HOMESTAY = "HOMESTAY"
    LOCAL_GUIDE = "LOCAL_GUIDE"
    LOCAL_FOOD = "LOCAL_FOOD"
    HANDICRAFTS = "HANDICRAFTS"
    LOCAL_PRODUCTS = "LOCAL_PRODUCTS"
    CULTURAL_EXPERIENCE = "CULTURAL_EXPERIENCE"
    RENTAL = "RENTAL"

class NotificationType(str, Enum):
    HIGH_PRESSURE_ALERT = "HIGH_PRESSURE_ALERT"
    ITINERARY_UPDATE = "ITINERARY_UPDATE"
    SAVED_DESTINATION_ALERT = "SAVED_DESTINATION_ALERT"
    CRITICAL_REPORT = "CRITICAL_REPORT"
    HIGH_SEVERITY_ISSUE = "HIGH_SEVERITY_ISSUE"
    PRESSURE_SPIKE = "PRESSURE_SPIKE"
    PREDICTION_WARNING = "PREDICTION_WARNING"
    GENERAL_ANNOUNCEMENT = "GENERAL_ANNOUNCEMENT"


