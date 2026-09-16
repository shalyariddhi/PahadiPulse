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

export interface Destination {
  id: string;
  name: string;
  district: string;
  latitude: number;
  longitude: number;
  description: string;
  altitudeMeters: number;
  capacityDailyTourists: number;
  currentVisitorsEst: number;
  tourismScore: number;
  waterScore: number;
  wasteScore: number;
  trafficScore: number;
  environmentScore: number;
  pressureScore: number;
  status: PressureStatus;
  subScores: {
    tourism: number;
    water: number;
    waste: number;
    traffic: number;
    environment: number;
  };
  tags: string[];
  bestSeasons: string[];
  avgDailyBudgetINR: number;
  popularSpots: string[];
  imageUrl: string;
  updatedAt: string;
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
  aiCategory: ReportCategory;
  aiSeverity: number;
  aiConfidence: number;
  aiExplanation: string;
  status: ReportStatus;
  adminNotes?: string;
  createdAt: string;
  resolvedAt?: string;
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
}

export interface PressurePredictionPoint {
  forecastDate: string;
  predictedPressure: number;
  confidenceLower: number;
  confidenceUpper: number;
  primaryRiskFactor: string;
}

export interface ForecastResponse {
  destinationId: string;
  destinationName: string;
  currentPressure: number;
  currentStatus: PressureStatus;
  generatedAt: string;
  forecast7Days: PressurePredictionPoint[];
}

export interface DistrictSummary {
  district: string;
  avgPressure: number;
  destinationsCount: number;
  criticalCount: number;
}

export interface AdminAnalytics {
  totalDestinations: number;
  highPressureDestinations: number;
  criticalIssuesCount: number;
  openReportsCount: number;
  resolvedReportsCount: number;
  totalLocalProviders: number;
  avgRegionalPressure: number;
  districtSummaries: DistrictSummary[];
  categoryDistribution: Record<string, number>;
  recentCriticalIncidents: Report[];
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
