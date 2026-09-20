import axios from 'axios';
import { 
  Destination, DestinationCreate, DestinationUpdate, 
  Report, ReportStatus, ReportReviewPayload,
  LocalProvider, LocalProviderCreate, LocalProviderUpdate,
  ForecastResponse, PressureDetailResponse, PressureHistoryResponse, DestinationPredictionResponse,
  AdminAnalytics, ItineraryRequest, ItineraryResponse,
  NotificationItem, NotificationUnreadCount
} from '../types';

const API_BASE_URL = 'http://localhost:8000/api';

export const api = axios.create({
  baseURL: API_BASE_URL,
  headers: {
    'Content-Type': 'application/json'
  },
  timeout: 10000
});

// Request interceptor to attach active Auth token
api.interceptors.request.use((config) => {
  const token = localStorage.getItem('pahadi_admin_token') || 'admin_secret_pahadi';
  if (token) {
    config.headers.Authorization = `Bearer ${token}`;
  }
  return config;
}, (error) => {
  return Promise.reject(error);
});

// ----------------- Destinations API -----------------
export const getDestinations = async (
  district?: string, 
  status?: string,
  search?: string,
  min_pressure?: number,
  max_pressure?: number
): Promise<Destination[]> => {
  const params: Record<string, any> = {};
  if (district && district !== 'ALL') params.district = district;
  if (status && status !== 'ALL') params.status = status;
  if (search) params.search = search;
  if (min_pressure !== undefined) params.min_pressure = min_pressure;
  if (max_pressure !== undefined) params.max_pressure = max_pressure;

  const res = await api.get('/destinations', { params });
  return res.data;
};

export const getDestinationById = async (id: string): Promise<Destination> => {
  const res = await api.get(`/destinations/${id}`);
  return res.data;
};

export const getDestinationPressure = async (
  id: string, 
  weights?: { tourism?: number; water?: number; waste?: number; traffic?: number; environment?: number }
): Promise<PressureDetailResponse> => {
  const params: Record<string, any> = {};
  if (weights) {
    if (weights.tourism !== undefined) params.weight_tourism = weights.tourism;
    if (weights.water !== undefined) params.weight_water = weights.water;
    if (weights.waste !== undefined) params.weight_waste = weights.waste;
    if (weights.traffic !== undefined) params.weight_traffic = weights.traffic;
    if (weights.environment !== undefined) params.weight_environment = weights.environment;
  }
  const res = await api.get(`/destinations/${id}/pressure`, { params });
  return res.data;
};

export const getDestinationHistory = async (id: string, days = 14): Promise<PressureHistoryResponse> => {
  const res = await api.get(`/destinations/${id}/history`, { params: { days } });
  return res.data;
};

export const getDestinationPrediction = async (id: string, horizon_days = 7): Promise<DestinationPredictionResponse> => {
  const res = await api.get(`/destinations/${id}/prediction`, { params: { horizon_days } });
  return res.data;
};

export const createDestination = async (data: DestinationCreate): Promise<Destination> => {
  const res = await api.post('/destinations', data);
  return res.data;
};

export const updateDestination = async (id: string, updates: DestinationUpdate): Promise<Destination> => {
  const res = await api.patch(`/destinations/${id}`, updates);
  return res.data;
};

export const getForecast = async (id: string, days = 7): Promise<ForecastResponse> => {
  const res = await api.get(`/pressure/forecast/${id}`, { params: { days } });
  return res.data;
};

// ----------------- Reports & Triage API -----------------
export const getReports = async (
  destinationId?: string, 
  status?: string, 
  category?: string,
  user_id?: string
): Promise<Report[]> => {
  const params: Record<string, string> = {};
  if (destinationId && destinationId !== 'ALL') params.destination_id = destinationId;
  if (status && status !== 'ALL') params.status = status;
  if (category && category !== 'ALL') params.category = category;
  if (user_id) params.user_id = user_id;

  const res = await api.get('/reports', { params });
  return res.data;
};

export const getReportById = async (id: string): Promise<Report> => {
  const res = await api.get(`/reports/${id}`);
  return res.data;
};

export const updateReportStatus = async (reportId: string, status: ReportStatus, adminNotes?: string): Promise<Report> => {
  const res = await api.patch(`/reports/${reportId}/status`, { status, adminNotes });
  return res.data;
};

export const reviewReportClassification = async (
  reportId: string,
  payload: ReportReviewPayload
): Promise<Report> => {
  const res = await api.patch(`/reports/${reportId}/review`, payload);
  return res.data;
};

export const submitReport = async (data: {
  userId?: string;
  userName?: string;
  destinationId: string;
  category?: string;
  description: string;
  imageUrl?: string;
  latitude: number;
  longitude: number;
  severity?: string;
}): Promise<Report> => {
  const res = await api.post('/reports', data);
  return res.data;
};

// ----------------- Local Providers API -----------------
export const getProviders = async (
  destinationId?: string, 
  category?: string,
  min_price?: number,
  max_price?: number,
  verified?: boolean,
  search?: string
): Promise<LocalProvider[]> => {
  const params: Record<string, any> = {};
  if (destinationId && destinationId !== 'ALL') params.destination_id = destinationId;
  if (category && category !== 'ALL') params.category = category;
  if (min_price !== undefined) params.min_price = min_price;
  if (max_price !== undefined) params.max_price = max_price;
  if (verified !== undefined) params.verified = verified;
  if (search) params.search = search;

  const res = await api.get('/providers', { params });
  return res.data;
};

export const getProviderById = async (id: string): Promise<LocalProvider> => {
  const res = await api.get(`/providers/${id}`);
  return res.data;
};

export const createProvider = async (data: LocalProviderCreate): Promise<LocalProvider> => {
  const res = await api.post('/providers', data);
  return res.data;
};

export const updateProvider = async (id: string, data: LocalProviderUpdate): Promise<LocalProvider> => {
  const res = await api.patch(`/providers/${id}`, data);
  return res.data;
};

export const deleteProvider = async (id: string): Promise<{ message: string; id: string }> => {
  const res = await api.delete(`/providers/${id}`);
  return res.data;
};

// ----------------- Admin Analytics & AI -----------------
export const getAdminAnalytics = async (
  days = 14,
  district?: string,
  category?: string
): Promise<AdminAnalytics> => {
  const params: Record<string, any> = { days };
  if (district && district !== 'ALL') params.district = district;
  if (category && category !== 'ALL') params.category = category;

  const res = await api.get('/admin/analytics', { params });
  return res.data;
};

export const generateItinerary = async (req: ItineraryRequest): Promise<ItineraryResponse> => {
  const res = await api.post('/itineraries/generate', req);
  return res.data;
};

export const classifyReportAI = async (text: string) => {
  const res = await api.post('/ai/classify-report', { text });
  return res.data;
};

// ----------------- Auth API -----------------
export const getCurrentUserProfile = async () => {
  const res = await api.get('/auth/me');
  return res.data;
};

export const syncUserProfile = async (user: { uid: string; email: string; displayName?: string; role?: string }) => {
  const res = await api.post('/auth/sync-user', user);
  return res.data;
};

// ----------------- In-App Notifications & Tactical Alerts -----------------
export const getNotifications = async (
  role = 'admin',
  type?: string,
  unreadOnly = false,
  limit = 50
): Promise<NotificationItem[]> => {
  const params: Record<string, any> = { role, limit };
  if (type && type !== 'ALL') params.type = type;
  if (unreadOnly) params.unread_only = true;

  const res = await api.get('/notifications', { params });
  return res.data;
};

export const getUnreadNotificationCount = async (role = 'admin'): Promise<NotificationUnreadCount> => {
  const res = await api.get('/notifications/unread-count', { params: { role } });
  return res.data;
};

export const markNotificationRead = async (id: string): Promise<NotificationItem> => {
  const res = await api.patch(`/notifications/${id}/read`);
  return res.data;
};

export const markAllNotificationsRead = async (role = 'admin'): Promise<{ success: boolean; markedCount: number; message: string }> => {
  const res = await api.post('/notifications/mark-all-read', null, { params: { role } });
  return res.data;
};

export const createNotification = async (data: Partial<NotificationItem>): Promise<NotificationItem> => {
  const res = await api.post('/notifications', data);
  return res.data;
};

