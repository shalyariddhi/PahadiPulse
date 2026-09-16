import axios from 'axios';
import { 
  Destination, Report, LocalProvider, ForecastResponse, 
  AdminAnalytics, ItineraryRequest, ItineraryResponse, ReportStatus
} from '../types';

const API_BASE_URL = 'http://localhost:8000/api';

const api = axios.create({
  baseURL: API_BASE_URL,
  headers: {
    'Content-Type': 'application/json',
    'Authorization': 'Bearer admin_secret_pahadi'
  },
  timeout: 8000
});

export const getDestinations = async (district?: string, status?: string): Promise<Destination[]> => {
  const params: Record<string, string> = {};
  if (district) params.district = district;
  if (status) params.status = status;
  const res = await api.get('/destinations', { params });
  return res.data;
};

export const getDestinationById = async (id: string): Promise<Destination> => {
  const res = await api.get(`/destinations/${id}`);
  return res.data;
};

export const getForecast = async (id: string, days = 7): Promise<ForecastResponse> => {
  const res = await api.get(`/pressure/forecast/${id}`, { params: { days } });
  return res.data;
};

export const getReports = async (destinationId?: string, status?: string, category?: string): Promise<Report[]> => {
  const params: Record<string, string> = {};
  if (destinationId) params.destination_id = destinationId;
  if (status) params.status = status;
  if (category) params.category = category;
  const res = await api.get('/reports', { params });
  return res.data;
};

export const updateReportStatus = async (reportId: string, status: ReportStatus, adminNotes?: string): Promise<Report> => {
  const res = await api.patch(`/reports/${reportId}/status`, { status, adminNotes });
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
}): Promise<Report> => {
  const res = await api.post('/reports', data);
  return res.data;
};

export const getProviders = async (destinationId?: string, category?: string): Promise<LocalProvider[]> => {
  const params: Record<string, string> = {};
  if (destinationId) params.destination_id = destinationId;
  if (category) params.category = category;
  const res = await api.get('/providers', { params });
  return res.data;
};

export const getAdminAnalytics = async (): Promise<AdminAnalytics> => {
  const res = await api.get('/admin/analytics');
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
