import React, { useEffect, useState } from 'react';
import { Destination, ForecastResponse } from '../../types';
import { getForecast } from '../../services/api';
import { X, TrendingUp, AlertTriangle, Droplets, Trash2, Car, Trees, Users } from 'lucide-react';
import { AreaChart, Area, XAxis, YAxis, Tooltip, ResponsiveContainer, CartesianGrid } from 'recharts';

interface ModalProps {
  destination: Destination | null;
  onClose: () => void;
}

export const PressureBreakdownModal: React.FC<ModalProps> = ({ destination, onClose }) => {
  const [forecast, setForecast] = useState<ForecastResponse | null>(null);
  const [loading, setLoading] = useState(false);

  useEffect(() => {
    if (destination) {
      setLoading(true);
      getForecast(destination.id, 7)
        .then((data) => setForecast(data))
        .catch((err) => console.error(err))
        .finally(() => setLoading(false));
    }
  }, [destination]);

  if (!destination) return null;

  const subScores = destination.subScores || {
    tourism: destination.tourismScore,
    water: destination.waterScore,
    waste: destination.wasteScore,
    traffic: destination.trafficScore,
    environment: destination.environmentScore
  };

  const chartData = forecast?.forecast7Days.map((f) => ({
    date: f.forecastDate.slice(5),
    predicted: f.predictedPressure,
    lower: f.confidenceLower,
    upper: f.confidenceUpper,
    risk: f.primaryRiskFactor
  })) || [];

  return (
    <div style={{
      position: 'fixed', top: 0, left: 0, right: 0, bottom: 0,
      background: 'rgba(5, 10, 8, 0.85)', backdropFilter: 'blur(8px)',
      display: 'flex', alignItems: 'center', justifyContent: 'center',
      zIndex: 2000, padding: '20px'
    }}>
      <div className="glass-panel" style={{ width: '100%', maxWidth: '780px', maxHeight: '90vh', overflowY: 'auto', padding: '28px', position: 'relative' }}>
        <button
          onClick={onClose}
          style={{ position: 'absolute', top: '20px', right: '20px', background: 'rgba(255,255,255,0.1)', border: 'none', color: '#fff', borderRadius: '50%', width: '32px', height: '32px', cursor: 'pointer', display: 'flex', alignItems: 'center', justifyContent: 'center' }}
        >
          <X size={18} />
        </button>

        <div style={{ display: 'flex', alignItems: 'center', gap: '14px', marginBottom: '16px' }}>
          <div>
            <h2 style={{ fontSize: '1.5rem', color: '#fff', margin: 0 }}>
              {destination.name}
            </h2>
            <p style={{ fontSize: '0.85rem', color: '#94a3b8' }}>
              {destination.district} District | Altitude: {destination.altitudeMeters}m
            </p>
          </div>
          <span className={`badge badge-${destination.status.toLowerCase()}`} style={{ fontSize: '0.85rem', padding: '6px 14px' }}>
            {destination.status} • {destination.pressureScore.toFixed(1)} / 100
          </span>
        </div>

        {/* Breakdown Formula Card */}
        <div style={{ background: 'rgba(10, 20, 15, 0.6)', border: '1px solid var(--border-subtle)', borderRadius: '12px', padding: '16px', marginBottom: '20px' }}>
          <h4 style={{ fontSize: '0.85rem', color: '#10b981', textTransform: 'uppercase', letterSpacing: '0.05em', marginBottom: '12px' }}>
            Multi-Dimensional Pressure Matrix Breakdown
          </h4>
          
          <div style={{ display: 'grid', gridTemplateColumns: 'repeat(auto-fit, minmax(130px, 1fr))', gap: '12px' }}>
            <div style={{ background: 'rgba(255,255,255,0.04)', padding: '10px', borderRadius: '8px', textAlign: 'center' }}>
              <div style={{ fontSize: '0.75rem', color: '#94a3b8' }}>30% Tourism</div>
              <div style={{ fontSize: '1.25rem', fontWeight: 700, color: subScores.tourism >= 70 ? '#ef4444' : '#f8fafc' }}>
                {subScores.tourism}%
              </div>
            </div>

            <div style={{ background: 'rgba(255,255,255,0.04)', padding: '10px', borderRadius: '8px', textAlign: 'center' }}>
              <div style={{ fontSize: '0.75rem', color: '#94a3b8' }}>25% Water Stress</div>
              <div style={{ fontSize: '1.25rem', fontWeight: 700, color: subScores.water >= 70 ? '#ef4444' : '#f8fafc' }}>
                {subScores.water}%
              </div>
            </div>

            <div style={{ background: 'rgba(255,255,255,0.04)', padding: '10px', borderRadius: '8px', textAlign: 'center' }}>
              <div style={{ fontSize: '0.75rem', color: '#94a3b8' }}>20% Waste Pressure</div>
              <div style={{ fontSize: '1.25rem', fontWeight: 700, color: subScores.waste >= 70 ? '#ef4444' : '#f8fafc' }}>
                {subScores.waste}%
              </div>
            </div>

            <div style={{ background: 'rgba(255,255,255,0.04)', padding: '10px', borderRadius: '8px', textAlign: 'center' }}>
              <div style={{ fontSize: '0.75rem', color: '#94a3b8' }}>15% Traffic Congestion</div>
              <div style={{ fontSize: '1.25rem', fontWeight: 700, color: subScores.traffic >= 70 ? '#ef4444' : '#f8fafc' }}>
                {subScores.traffic}%
              </div>
            </div>

            <div style={{ background: 'rgba(255,255,255,0.04)', padding: '10px', borderRadius: '8px', textAlign: 'center' }}>
              <div style={{ fontSize: '0.75rem', color: '#94a3b8' }}>10% Env Hazard</div>
              <div style={{ fontSize: '1.25rem', fontWeight: 700, color: subScores.environment >= 70 ? '#ef4444' : '#f8fafc' }}>
                {subScores.environment}%
              </div>
            </div>
          </div>
        </div>

        {/* 7-Day ML Forecast Graph */}
        <div style={{ marginBottom: '16px' }}>
          <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '8px' }}>
            <h4 style={{ fontSize: '0.95rem', color: '#fff', display: 'flex', alignItems: 'center', gap: '8px' }}>
              <TrendingUp size={18} color="#10b981" /> 7-Day ML Forecast & Trend Analysis
            </h4>
            <span style={{ fontSize: '0.75rem', color: '#94a3b8' }}>Random Forest Regression Model</span>
          </div>

          <div style={{ height: '220px', width: '100%', background: 'rgba(0,0,0,0.3)', borderRadius: '12px', padding: '12px 12px 0 0' }}>
            <ResponsiveContainer width="100%" height="100%">
              <AreaChart data={chartData}>
                <defs>
                  <linearGradient id="pressureGradient" x1="0" y1="0" x2="0" y2="1">
                    <stop offset="5%" stopColor="#10b981" stopOpacity={0.6}/>
                    <stop offset="95%" stopColor="#10b981" stopOpacity={0.0}/>
                  </linearGradient>
                </defs>
                <CartesianGrid strokeDasharray="3 3" stroke="rgba(255,255,255,0.08)" />
                <XAxis dataKey="date" stroke="#94a3b8" fontSize={12} />
                <YAxis domain={[0, 100]} stroke="#94a3b8" fontSize={12} />
                <Tooltip
                  contentStyle={{ background: '#12231b', borderColor: '#2d5a43', borderRadius: '8px', color: '#fff' }}
                  formatter={(val: any) => [`${val}% Pressure`, 'Predicted']}
                />
                <Area type="monotone" dataKey="predicted" stroke="#10b981" strokeWidth={2} fillOpacity={1} fill="url(#pressureGradient)" />
              </AreaChart>
            </ResponsiveContainer>
          </div>
        </div>

        {/* Capacity vs Demand stats */}
        <div style={{ display: 'flex', justifyContent: 'space-between', padding: '12px 16px', background: 'rgba(255,255,255,0.03)', borderRadius: '10px', fontSize: '0.85rem' }}>
          <div>Estimated Current Visitors: <strong style={{ color: '#fff' }}>{destination.currentVisitorsEst?.toLocaleString()}</strong></div>
          <div>Daily Carrying Capacity: <strong style={{ color: '#10b981' }}>{destination.capacityDailyTourists?.toLocaleString()}</strong></div>
          <div>Load Ratio: <strong style={{ color: destination.currentVisitorsEst > destination.capacityDailyTourists ? '#ef4444' : '#10b981' }}>
            {((destination.currentVisitorsEst / destination.capacityDailyTourists) * 100).toFixed(0)}%
          </strong></div>
        </div>
      </div>
    </div>
  );
};
