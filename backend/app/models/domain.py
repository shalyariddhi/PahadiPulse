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
