from pydantic import BaseModel, Field, EmailStr, field_validator
from typing import Optional, List, Dict, Any
from datetime import datetime
from app.models.domain import (
    PressureStatus,
    ReportCategory,
    ReportStatus,
    ReportSeverity,
    ProviderCategory,
    UserRole,
    NotificationType
)

# ----------------- User & Authentication Schemas -----------------
class UserProfileBase(BaseModel):
    uid: str
    email: EmailStr
    displayName: Optional[str] = "PahadiPulse Member"
    role: UserRole = UserRole.TOURIST
    phoneNumber: Optional[str] = None
    photoUrl: Optional[str] = ""
    isBlocked: bool = False

class UserCreate(BaseModel):
    uid: str
    email: EmailStr
    displayName: Optional[str] = "PahadiPulse Member"
    role: UserRole = UserRole.TOURIST
    phoneNumber: Optional[str] = None

class UserUpdate(BaseModel):
    displayName: Optional[str] = None
    phoneNumber: Optional[str] = None
    photoUrl: Optional[str] = None
    role: Optional[UserRole] = None

class UserProfileResponse(UserProfileBase):
    createdAt: str
    updatedAt: str

class AuthTokenInfo(BaseModel):
    uid: str
    email: Optional[str] = None
    role: UserRole
    isVerified: bool = True

# ----------------- Destination Schemas -----------------
class PressureBreakdown(BaseModel):
    tourism: float = Field(..., ge=0.0, le=100.0, description="Crowd and visitor load (0-100)")
    water: float = Field(..., ge=0.0, le=100.0, description="Water resource stress index (0-100)")
    waste: float = Field(..., ge=0.0, le=100.0, description="Solid waste accumulation level (0-100)")
    traffic: float = Field(..., ge=0.0, le=100.0, description="Road congestion & transit delay (0-100)")
    environment: float = Field(..., ge=0.0, le=100.0, description="Seasonal & slope hazard (0-100)")
    compositeScore: float = Field(..., ge=0.0, le=100.0, description="Weighted composite score (0-100)")
    status: PressureStatus
    explanation: str
    formula: str = "30% Tourism + 25% Water + 20% Waste + 15% Traffic + 10% Environment"

class DestinationBase(BaseModel):
    name: str = Field(..., min_length=2, max_length=100)
    district: str = Field(..., min_length=2, max_length=100)
    latitude: float = Field(..., ge=28.0, le=32.0, description="Uttarakhand latitude boundary")
    longitude: float = Field(..., ge=77.0, le=82.0, description="Uttarakhand longitude boundary")
    description: str = Field(..., min_length=10)
    capacity: int = Field(..., ge=100, description="Daily tourist carrying capacity limit")
    currentVisitorsEst: int = Field(default=0, ge=0, description="Estimated current active visitors")
    tourismScore: float = Field(default=20.0, ge=0.0, le=100.0)
    waterScore: float = Field(default=20.0, ge=0.0, le=100.0)
    wasteScore: float = Field(default=20.0, ge=0.0, le=100.0)
    trafficScore: float = Field(default=20.0, ge=0.0, le=100.0)
    environmentScore: float = Field(default=20.0, ge=0.0, le=100.0)
    altitudeMeters: Optional[int] = 1500
    tags: List[str] = []
    bestSeasons: List[str] = []
    avgDailyBudgetINR: float = 2500.0
    popularSpots: List[str] = []
    imageUrl: str = ""
    isDemo: bool = True
    dataSource: str = "DEMO_SYNTHETIC_HACKATHON"

class DestinationCreate(DestinationBase):
    id: Optional[str] = None

class DestinationUpdate(BaseModel):
    name: Optional[str] = None
    district: Optional[str] = None
    description: Optional[str] = None
    capacity: Optional[int] = None
    currentVisitorsEst: Optional[int] = None
    tourismScore: Optional[float] = Field(None, ge=0.0, le=100.0)
    waterScore: Optional[float] = Field(None, ge=0.0, le=100.0)
    wasteScore: Optional[float] = Field(None, ge=0.0, le=100.0)
    trafficScore: Optional[float] = Field(None, ge=0.0, le=100.0)
    environmentScore: Optional[float] = Field(None, ge=0.0, le=100.0)
    altitudeMeters: Optional[int] = None
    tags: Optional[List[str]] = None
    avgDailyBudgetINR: Optional[float] = None

class DestinationResponse(DestinationBase):
    id: str
    pressureScore: float
    status: PressureStatus
    subScores: Dict[str, float]
    updatedAt: str

class PressureDetailResponse(BaseModel):
    destinationId: Optional[str] = None
    destinationName: Optional[str] = None
    score: float = Field(..., ge=0.0, le=100.0)
    compositeScore: Optional[float] = None
    status: PressureStatus
    tourismScore: float = Field(..., ge=0.0, le=100.0)
    waterScore: float = Field(..., ge=0.0, le=100.0)
    wasteScore: float = Field(..., ge=0.0, le=100.0)
    trafficScore: float = Field(..., ge=0.0, le=100.0)
    environmentScore: float = Field(..., ge=0.0, le=100.0)
    tourism: Optional[float] = None
    water: Optional[float] = None
    waste: Optional[float] = None
    traffic: Optional[float] = None
    environment: Optional[float] = None
    explanation: str
    formula: Optional[str] = "30% Tourism + 25% Water + 20% Waste + 15% Traffic + 10% Environment"
    weightsUsed: Optional[Dict[str, float]] = None
    updatedAt: Optional[str] = None

# ----------------- Pressure History & Forecast -----------------
class PressureHistoryPoint(BaseModel):
    date: str
    timestamp: str
    score: float = Field(..., ge=0.0, le=100.0)
    status: PressureStatus
    tourismScore: float
    waterScore: float
    wasteScore: float
    trafficScore: float
    environmentScore: float

class PressureHistoryResponse(BaseModel):
    destinationId: str
    destinationName: str
    days: int
    history: List[PressureHistoryPoint]

class RegionalPressureAggregate(BaseModel):
    averageScore: float
    overallStatus: PressureStatus
    totalDestinations: int
    statusDistribution: Dict[str, int]
    criticalBottlenecks: List[Dict[str, Any]]
    sustainableAlternatives: List[Dict[str, Any]]
    districtAverages: Dict[str, float]
    generatedAt: str

class PressurePredictionPoint(BaseModel):
    forecastDate: str
    predictedPressure: float
    confidenceLower: float
    confidenceUpper: float
    primaryRiskFactor: str

class DestinationForecastResponse(BaseModel):
    destinationId: str
    destinationName: str
    currentPressure: float
    currentStatus: PressureStatus
    generatedAt: str
    forecast7Days: List[PressurePredictionPoint]

class DestinationPredictionResponse(BaseModel):
    destinationId: str
    destinationName: str
    currentScore: float
    predictedScore: float
    predictionHorizonDays: int
    targetDate: str
    riskLevel: PressureStatus
    modelConfidence: float
    confidenceRange: Dict[str, float]
    modelDetails: Dict[str, Any]
    primaryRiskFactor: str
    isDemo: bool = True
    dataSource: str = "SYNTHETIC_ML_PIPELINE"
    disclaimer: str

from app.models.domain import (
    PressureStatus,
    ReportCategory,
    ReportSeverity,
    ReportStatus,
    ProviderCategory,
    UserRole,
    severity_to_numeric,
    numeric_to_severity
)

# ----------------- Citizen Reports -----------------
class ReportCreate(BaseModel):
    userId: Optional[str] = None
    userName: Optional[str] = None
    destinationId: str = Field(..., min_length=2)
    category: Optional[ReportCategory] = ReportCategory.OTHER
    description: str = Field(..., min_length=5, max_length=2000, description="Detailed description of issue")
    imageUrl: Optional[str] = ""
    latitude: float = Field(..., ge=-90.0, le=90.0)
    longitude: float = Field(..., ge=-180.0, le=180.0)
    userSeverity: Optional[int] = Field(None, ge=1, le=5, description="Optional user-reported severity (1 to 5)")

class AIReportClassification(BaseModel):
    category: ReportCategory
    severity: ReportSeverity
    confidence: float = Field(..., ge=0.0, le=1.0)
    explanation: str
    recommendedAction: str
    disclaimer: str = "Lightweight ML/NLP regional triage model for IBM Hackathon demonstration (not claimed as production-grade computer vision/LLM)."
    
    # Backward compatibility aliases
    aiCategory: Optional[ReportCategory] = None
    aiSeverity: Optional[int] = None
    aiConfidence: Optional[float] = None
    aiExplanation: Optional[str] = None

    def model_post_init(self, __context: Any) -> None:
        if self.aiCategory is None:
            self.aiCategory = self.category
        if self.aiSeverity is None:
            self.aiSeverity = severity_to_numeric(self.severity)
        if self.aiConfidence is None:
            self.aiConfidence = self.confidence
        if self.aiExplanation is None:
            self.aiExplanation = self.explanation

class ReportStatusUpdate(BaseModel):
    status: ReportStatus
    adminNotes: Optional[str] = None

class ReportReviewRequest(BaseModel):
    category: Optional[ReportCategory] = Field(None, description="Admin corrected category")
    severity: Optional[ReportSeverity] = Field(None, description="Admin corrected severity")
    status: Optional[ReportStatus] = Field(None, description="Updated workflow state")
    adminNotes: Optional[str] = Field(None, description="Administrative notes or dispatch details")

class ReportResponse(BaseModel):
    id: str
    userId: str
    userName: str
    destinationId: str
    destinationName: str
    category: ReportCategory
    description: str
    imageUrl: Optional[str] = ""
    latitude: float
    longitude: float
    userSeverity: Optional[int] = None
    severity: Optional[ReportSeverity] = None
    aiCategory: ReportCategory
    aiSeverity: int
    aiConfidence: float
    aiExplanation: str
    status: ReportStatus
    adminNotes: Optional[str] = None
    adminReviewed: bool = False
    reviewedBy: Optional[str] = None
    createdAt: str
    resolvedAt: Optional[str] = None
    isDemo: bool = True

class ImageUploadResponse(BaseModel):
    imageUrl: str
    filename: str
    sizeBytes: int
    contentType: str
    message: str = "Image uploaded successfully"



# ----------------- Local Providers -----------------
class LocalProviderBase(BaseModel):
    destinationId: str = Field(..., min_length=2)
    name: str = Field(..., min_length=2, max_length=150)
    category: ProviderCategory
    description: str = Field(..., min_length=5)
    ownerName: Optional[str] = "Local Host"
    contactPhone: str = Field(..., min_length=5)
    contactEmail: Optional[str] = None
    locationAddress: str = Field(..., min_length=2)
    latitude: float = Field(..., ge=-90.0, le=90.0)
    longitude: float = Field(..., ge=-180.0, le=180.0)
    priceStartingINR: float = Field(..., ge=0.0)
    pricingUnit: str = "per unit"
    verified: bool = True
    externalBookingUrl: Optional[str] = ""
    imageUrl: Optional[str] = ""
    rating: float = Field(default=4.8, ge=0.0, le=5.0)
    reviewCount: int = Field(default=24, ge=0)
    isDemo: bool = True
    disclaimer: str = "Synthetic demo provider for regional economic empowerment demonstration (not a real commercial business)."
    price: Optional[float] = None
    location: Optional[str] = None
    contact: Optional[str] = None

    def model_post_init(self, __context: Any) -> None:
        if self.price is None:
            self.price = self.priceStartingINR
        if self.location is None:
            self.location = self.locationAddress
        if self.contact is None:
            self.contact = self.contactPhone

class LocalProviderCreate(LocalProviderBase):
    id: Optional[str] = None

class LocalProviderUpdate(BaseModel):
    name: Optional[str] = None
    category: Optional[ProviderCategory] = None
    description: Optional[str] = None
    destinationId: Optional[str] = None
    ownerName: Optional[str] = None
    contactPhone: Optional[str] = None
    contactEmail: Optional[str] = None
    locationAddress: Optional[str] = None
    latitude: Optional[float] = None
    longitude: Optional[float] = None
    priceStartingINR: Optional[float] = None
    pricingUnit: Optional[str] = None
    verified: Optional[bool] = None
    externalBookingUrl: Optional[str] = None
    imageUrl: Optional[str] = None
    rating: Optional[float] = None
    reviewCount: Optional[int] = None

class LocalProviderResponse(LocalProviderBase):
    id: str
    destinationName: str

# ----------------- Smart Itinerary -----------------
class ItineraryRequest(BaseModel):
    daysCount: int = Field(..., ge=1, le=14)
    travellersCount: int = Field(..., ge=1, le=20)
    budgetPerPersonINR: float = Field(..., ge=1000)
    interests: List[str] = Field(default_factory=lambda: ["Nature", "Relaxation"])
    startingRegion: Optional[str] = "Dehradun / Rishikesh"
    travelDates: Optional[Dict[str, str]] = None
    travelMode: Optional[str] = "CAR"

class ItineraryActivity(BaseModel):
    time: str
    title: str
    description: str
    category: str
    providerName: Optional[str] = None
    costEstimateINR: float

class ItineraryStay(BaseModel):
    providerId: Optional[str] = None
    name: str
    type: str
    costPerNightINR: float
    bookingContact: Optional[str] = None

class ItineraryCostBreakdown(BaseModel):
    stayCostINR: float
    activitiesCostINR: float
    foodEstimateINR: float
    transitEstimateINR: float
    totalPerPersonINR: float
    grandTotalINR: float

class ItineraryDay(BaseModel):
    dayNumber: int
    destinationId: str
    destinationName: str
    district: str
    pressureLevel: PressureStatus
    pressureScore: float
    stayRecommendation: ItineraryStay
    activities: List[ItineraryActivity]
    travelNote: str
    selectionReason: Optional[str] = None
    travelTimeFromPrevHours: Optional[float] = 0.0
    distanceKmFromPrev: Optional[float] = 0.0

class ItineraryResponse(BaseModel):
    id: str
    title: str
    tripSummary: Optional[str] = None
    daysCount: int
    travellersCount: int
    budgetPerPersonINR: float
    totalEstimatedCostINR: float
    pressureMitigationScore: float
    economicLocalSharePct: Optional[float] = 85.0
    totalTravelTimeHours: Optional[float] = 0.0
    interests: List[str]
    travelMode: Optional[str] = "CAR"
    startingRegion: str
    travelDates: Optional[Dict[str, str]] = None
    rationale: str
    explanation: Optional[str] = None
    warnings: List[str] = Field(default_factory=list)
    destinations: List[Dict[str, Any]] = Field(default_factory=list)
    costBreakdown: Optional[ItineraryCostBreakdown] = None
    rankedDestinations: List[Dict[str, Any]] = Field(default_factory=list)
    days: List[ItineraryDay]
    createdAt: str

# ----------------- Admin Analytics -----------------
class DistrictPressureMetric(BaseModel):
    district: str
    avgPressure: float
    destinationsCount: int
    criticalCount: int

class DailyPressurePoint(BaseModel):
    date: str
    avgPressure: float
    highPressureCount: int
    criticalCount: int

class DestinationPressureMetric(BaseModel):
    destinationId: str
    name: str
    district: str
    pressureScore: float
    status: PressureStatus
    currentVisitors: int
    capacity: int
    loadPercentage: float

class DestinationFactorMetric(BaseModel):
    destinationId: str
    name: str
    district: str
    tourism: float
    water: float
    waste: float
    traffic: float
    environment: float
    compositeScore: float

class PredictionComparisonMetric(BaseModel):
    destinationId: str
    name: str
    district: str
    currentPressure: float
    predictedPressure: float
    delta: float
    riskLevel: str
    primaryRiskFactor: str

class AdminAnalyticsResponse(BaseModel):
    totalDestinations: int
    highPressureDestinations: int
    criticalIssuesCount: int
    openReportsCount: int
    resolvedReportsCount: int
    totalLocalProviders: int
    avgRegionalPressure: float
    districtSummaries: List[DistrictPressureMetric]
    categoryDistribution: Dict[str, int]
    recentCriticalIncidents: List[ReportResponse]
    # 9 Granular Analytics Dimensions
    regionalPressureTrend: List[DailyPressurePoint] = Field(default_factory=list)
    destinationPressureComparison: List[DestinationPressureMetric] = Field(default_factory=list)
    pressureFactorComparison: List[DestinationFactorMetric] = Field(default_factory=list)
    reportCategoryDistribution: Dict[str, int] = Field(default_factory=dict)
    reportSeverityDistribution: Dict[str, int] = Field(default_factory=dict)
    reportStatusDistribution: Dict[str, int] = Field(default_factory=dict)
    providerCategoryDistribution: Dict[str, int] = Field(default_factory=dict)
    tourismPressureTrends: List[DestinationPressureMetric] = Field(default_factory=list)
    predictionVsCurrent: List[PredictionComparisonMetric] = Field(default_factory=list)

# ----------------- Notifications -----------------
class NotificationCreate(BaseModel):
    userId: Optional[str] = None
    title: str = Field(..., min_length=2, max_length=150)
    message: str = Field(..., min_length=5)
    type: NotificationType
    relatedEntityId: Optional[str] = None
    relatedEntityType: Optional[str] = None
    targetRole: Optional[UserRole] = None
    metadata: Dict[str, Any] = Field(default_factory=dict)

class NotificationResponse(BaseModel):
    id: str
    userId: Optional[str] = None
    title: str
    message: str
    type: NotificationType
    read: bool = False
    createdAt: str
    relatedEntityId: Optional[str] = None
    relatedEntityType: Optional[str] = None
    targetRole: Optional[UserRole] = None
    metadata: Dict[str, Any] = Field(default_factory=dict)

class NotificationUnreadCountResponse(BaseModel):
    unreadCount: int
    totalCount: int

class NotificationBulkReadResponse(BaseModel):
    success: bool
    markedCount: int
    message: str

