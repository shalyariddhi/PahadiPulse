export type PressureStatus = 'LOW' | 'MODERATE' | 'HIGH' | 'CRITICAL';

export type ReportCategory = 
  | 'WATER'
  | 'WASTE'
  | 'ROAD'
  | 'TRAFFIC'
  | 'HEALTH'
  | 'CONNECTIVITY'
  | 'TOURISM'
  | 'ENVIRONMENT'
  | 'OTHER';

export type ReportSeverity = 'LOW' | 'MEDIUM' | 'HIGH' | 'CRITICAL';

export type ReportStatus = 
  | 'SUBMITTED'
  | 'AI_CLASSIFIED'
  | 'VERIFIED'
  | 'ASSIGNED'
  | 'RESOLVED';

export type ProviderCategory = 
  | 'HOMESTAY'
  | 'LOCAL_GUIDE'
  | 'LOCAL_FOOD'
  | 'HANDICRAFTS'
  | 'LOCAL_PRODUCTS'
  | 'CULTURAL_EXPERIENCE'
  | 'RENTAL';

export interface DestinationSubScores {
  tourism: number;
  water: number;
  waste: number;
  traffic: number;
  environment: number;
}

export interface Destination {
  id: string;
  name: string;
  district: string;
  latitude: number;
  longitude: number;
  description: string;
  altitudeMeters: number;
  capacity?: number;
  capacityDailyTourists: number;
  currentVisitorsEst: number;
  tourismScore: number;
  waterScore: number;
  wasteScore: number;
  trafficScore: number;
  environmentScore: number;
  pressureScore: number;
  status: PressureStatus;
  subScores: DestinationSubScores;
  tags: string[];
  bestSeasons: string[];
  avgDailyBudgetINR: number;
  popularSpots: string[];
  imageUrl: string;
  isDemo?: boolean;
  dataSource?: string;
  updatedAt: string;
}

export interface DestinationCreate {
  id?: string;
  name: string;
  district: string;
  latitude: number;
  longitude: number;
  description: string;
  capacity: number;
  currentVisitorsEst?: number;
  tourismScore?: number;
  waterScore?: number;
  wasteScore?: number;
  trafficScore?: number;
  environmentScore?: number;
  altitudeMeters?: number;
  tags?: string[];
  bestSeasons?: string[];
  avgDailyBudgetINR?: number;
  popularSpots?: string[];
  imageUrl?: string;
  isDemo?: boolean;
  dataSource?: string;
}

export interface DestinationUpdate {
  name?: string;
  district?: string;
  description?: string;
  capacity?: number;
  currentVisitorsEst?: number;
  tourismScore?: number;
  waterScore?: number;
  wasteScore?: number;
  trafficScore?: number;
  environmentScore?: number;
  altitudeMeters?: number;
  tags?: string[];
  avgDailyBudgetINR?: number;
}

export interface PressureDetailResponse {
  destinationId?: string;
  destinationName?: string;
  score: number;
  compositeScore?: number;
  status: PressureStatus;
  tourismScore: number;
  waterScore: number;
  wasteScore: number;
  trafficScore: number;
  environmentScore: number;
  tourism?: number;
  water?: number;
  waste?: number;
  traffic?: number;
  environment?: number;
  explanation: string;
  formula?: string;
  weightsUsed?: Record<string, number>;
  updatedAt?: string;
}

export interface PressureHistoryPoint {
  date: string;
  pressureScore: number;
  visitorCount?: number;
  waterStress?: number;
  wasteIndex?: number;
  trafficDelay?: number;
}

export interface PressureHistoryResponse {
  destinationId: string;
  destinationName: string;
  recordsCount: number;
  history: PressureHistoryPoint[];
}

export interface PressurePredictionPoint {
  forecastDate: string;
  predictedPressure: number;
  confidenceLower: number;
  confidenceUpper: number;
  primaryRiskFactor: string;
}

export interface DestinationPredictionResponse {
  destinationId: string;
  destinationName: string;
  horizonDays: number;
  currentPressure: number;
  modelName: string;
  r2Score: number;
  predictions: PressurePredictionPoint[];
  generatedAt: string;
  dataSource?: string;
}

export interface ForecastResponse {
  destinationId: string;
  destinationName: string;
  currentPressure: number;
  currentStatus: PressureStatus;
  generatedAt: string;
  forecast7Days: PressurePredictionPoint[];
}

export interface Report {
  id: string;
  userId: string;
  userName: string;
  destinationId: string;
  destinationName: string;
  category: ReportCategory;
  description: string;
  imageUrl?: string;
  latitude: number;
  longitude: number;
  userSeverity?: number;
  severity?: ReportSeverity;
  aiCategory: ReportCategory;
  aiSeverity: number;
  aiConfidence: number;
  aiExplanation: string;
  status: ReportStatus;
  adminNotes?: string;
  adminReviewed?: boolean;
  reviewedBy?: string;
  createdAt: string;
  resolvedAt?: string;
}

export interface ReportReviewPayload {
  category?: ReportCategory;
  severity?: ReportSeverity;
  status?: ReportStatus;
  adminNotes?: string;
}

export interface LocalProvider {
  id: string;
  destinationId: string;
  destinationName: string;
  name: string;
  category: ProviderCategory;
  description: string;
  ownerName: string;
  contactPhone: string;
  contactEmail?: string;
  locationAddress: string;
  latitude: number;
  longitude: number;
  priceStartingINR: number;
  pricingUnit: string;
  verified: boolean;
  externalBookingUrl?: string;
  imageUrl?: string;
  rating: number;
  isDemo?: boolean;
  disclaimer?: string;
}

export interface LocalProviderCreate {
  name: string;
  category: ProviderCategory;
  description: string;
  destinationId: string;
  destinationName?: string;
  ownerName: string;
  contactPhone: string;
  contactEmail?: string;
  locationAddress: string;
  latitude: number;
  longitude: number;
  priceStartingINR: number;
  pricingUnit?: string;
  verified?: boolean;
  externalBookingUrl?: string;
  imageUrl?: string;
  rating?: number;
}

export interface LocalProviderUpdate {
  name?: string;
  category?: ProviderCategory;
  description?: string;
  ownerName?: string;
  contactPhone?: string;
  contactEmail?: string;
  locationAddress?: string;
  latitude?: number;
  longitude?: number;
  priceStartingINR?: number;
  pricingUnit?: string;
  verified?: boolean;
  externalBookingUrl?: string;
  imageUrl?: string;
  rating?: number;
}

export interface DistrictSummary {
  district: string;
  avgPressure: number;
  destinationsCount: number;
  criticalCount: number;
}

export interface DailyPressurePoint {
  date: string;
  avgPressure: number;
  highPressureCount: number;
  criticalCount: number;
}

export interface DestinationPressureMetric {
  destinationId: string;
  name: string;
  district: string;
  pressureScore: number;
  status: PressureStatus;
  currentVisitors: number;
  capacity: number;
  loadPercentage: number;
}

export interface DestinationFactorMetric {
  destinationId: string;
  name: string;
  district: string;
  tourism: number;
  water: number;
  waste: number;
  traffic: number;
  environment: number;
  compositeScore: number;
}

export interface PredictionComparisonMetric {
  destinationId: string;
  name: string;
  district: string;
  currentPressure: number;
  predictedPressure: number;
  delta: number;
  riskLevel: string;
  primaryRiskFactor: string;
}

export interface AdminAnalytics {
  totalDestinations: number;
  highPressureDestinations: number;
  criticalIssuesCount: number;
  openReportsCount: number;
  resolvedReportsCount: number;
  totalLocalProviders: number;
  avgRegionalPressure: number;
  predictedPressure?: number;
  districtSummaries: DistrictSummary[];
  categoryDistribution: Record<string, number>;
  recentCriticalIncidents: Report[];
  // 9 Granular Analytics Dimensions
  regionalPressureTrend?: DailyPressurePoint[];
  destinationPressureComparison?: DestinationPressureMetric[];
  pressureFactorComparison?: DestinationFactorMetric[];
  reportCategoryDistribution?: Record<string, number>;
  reportSeverityDistribution?: Record<string, number>;
  reportStatusDistribution?: Record<string, number>;
  providerCategoryDistribution?: Record<string, number>;
  tourismPressureTrends?: DestinationPressureMetric[];
  predictionVsCurrent?: PredictionComparisonMetric[];
}

export interface ItineraryRequest {
  daysCount: number;
  travellersCount: number;
  budgetPerPersonINR: number;
  interests: string[];
  startingRegion: string;
}

export interface ItineraryDay {
  dayNumber: number;
  destinationId: string;
  destinationName: string;
  district: string;
  pressureLevel: PressureStatus;
  pressureScore: number;
  stayRecommendation: {
    name: string;
    type: string;
    costPerNightINR: number;
    bookingContact?: string;
  };
  activities: {
    time: string;
    title: string;
    description: string;
    category: string;
    providerName?: string;
    costEstimateINR: number;
  }[];
  travelNote: string;
}

export interface ItineraryResponse {
  id: string;
  title: string;
  daysCount: number;
  travellersCount: number;
  budgetPerPersonINR: number;
  totalEstimatedCostINR: number;
  pressureMitigationScore: number;
  interests: string[];
  startingRegion: string;
  rationale: string;
  days: ItineraryDay[];
  createdAt: string;
}

export interface SystemSettings {
  tourismWeight: number;
  waterWeight: number;
  wasteWeight: number;
  trafficWeight: number;
  environmentWeight: number;
  refreshIntervalSec: number;
  apiBaseUrl: string;
}

export type NotificationType = 
  | 'HIGH_PRESSURE_ALERT'
  | 'ITINERARY_UPDATE'
  | 'SAVED_DESTINATION_ALERT'
  | 'CRITICAL_REPORT'
  | 'HIGH_SEVERITY_ISSUE'
  | 'PRESSURE_SPIKE'
  | 'PREDICTION_WARNING'
  | 'GENERAL_ANNOUNCEMENT';

export interface NotificationItem {
  id: string;
  userId?: string | null;
  title: string;
  message: string;
  type: NotificationType;
  read: boolean;
  createdAt: string;
  relatedEntityId?: string | null;
  relatedEntityType?: string | null;
  targetRole?: string | null;
  metadata?: Record<string, any>;
}

export interface NotificationUnreadCount {
  unreadCount: number;
  totalCount: number;
}

