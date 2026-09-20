import React, { useEffect, useState } from 'react';
import { Destination, ForecastResponse, DestinationPredictionResponse, PressureHistoryResponse } from '../../types';
import { getForecast, getDestinationPrediction, getDestinationHistory } from '../../services/api';
import { X, TrendingUp, AlertTriangle, Droplets, Trash2, Car, Trees, Users, Sparkles, Activity, ShieldCheck, Edit3 } from 'lucide-react';
import { AreaChart, Area, XAxis, YAxis, Tooltip, ResponsiveContainer, CartesianGrid, LineChart, Line } from 'recharts';

interface DestinationDetailModalProps {
  destination: Destination | null;
  onClose: () => void;
  onEdit?: (dest: Destination) => void;
}

export const DestinationDetailModal: React.FC<DestinationDetailModalProps> = ({
  destination,
  onClose,
  onEdit
}) => {
  const [forecast, setForecast] = useState<ForecastResponse | null>(null);
  const [prediction, setPrediction] = useState<DestinationPredictionResponse | null>(null);
  const [history, setHistory] = useState<PressureHistoryResponse | null>(null);
  const [activeTab, setActiveTab] = useState<'prediction' | 'history'>('prediction');
  const [loading, setLoading] = useState(false);

  useEffect(() => {
    if (destination) {
      setLoading(true);
      Promise.allSettled([
        getForecast(destination.id, 7),
        getDestinationPrediction(destination.id, 7),
        getDestinationHistory(destination.id, 14)
      ]).then(([fRes, pRes, hRes]) => {
        if (fRes.status === 'fulfilled') setForecast(fRes.value);
        if (pRes.status === 'fulfilled') setPrediction(pRes.value);
        if (hRes.status === 'fulfilled') setHistory(hRes.value);
      }).finally(() => setLoading(false));
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

  const predictionData = (prediction?.predictions || forecast?.forecast7Days || []).map((p: any) => ({
    date: (p.forecastDate || '').slice(5),
    predicted: p.predictedPressure,
    lower: p.confidenceLower,
    upper: p.confidenceUpper,
    risk: p.primaryRiskFactor || 'Visitor Influx'
  }));

  const historyData = (history?.history || []).map((h) => ({
    date: h.date.slice(5),
    score: h.pressureScore,
    visitors: h.visitorCount,
    water: h.waterStress,
    waste: h.wasteIndex,
    traffic: h.trafficDelay
  }));

  const loadPercentage = Math.round(((destination.currentVisitorsEst || 0) / (destination.capacityDailyTourists || destination.capacity || 10000)) * 100);

  return (
    <div style={{
      position: 'fixed', top: 0, left: 0, right: 0, bottom: 0,
      background: 'rgba(5, 10, 8, 0.85)', backdropFilter: 'blur(8px)',
      display: 'flex', alignItems: 'center', justifyContent: 'center',
      zIndex: 2000, padding: '20px'
    }}>
      <div className="glass-panel" style={{
        width: '100%', maxWidth: '820px', maxHeight: '92vh',
        overflowY: 'auto', padding: '28px', position: 'relative'
      }}>
        {/* Close Button */}
        <button
          onClick={onClose}
          style={{
            position: 'absolute', top: '20px', right: '20px',
            background: 'rgba(255,255,255,0.1)', border: 'none', color: '#fff',
            borderRadius: '50%', width: '32px', height: '32px', cursor: 'pointer',
            display: 'flex', alignItems: 'center', justifyContent: 'center'
          }}
        >
          <X size={18} />
        </button>

        {/* Header */}
        <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'flex-start', marginBottom: '18px', paddingRight: '40px' }}>
          <div>
            <div style={{ display: 'flex', alignItems: 'center', gap: '10px', marginBottom: '4px' }}>
              <h2 style={{ fontSize: '1.6rem', color: '#fff', margin: 0 }}>
                {destination.name}
              </h2>
              <span className={`badge badge-${destination.status.toLowerCase()}`}>
                {destination.status} • {destination.pressureScore.toFixed(1)}/100
              </span>
            </div>
            <p style={{ fontSize: '0.85rem', color: '#94a3b8', margin: 0 }}>
              {destination.district} District | Altitude: {destination.altitudeMeters}m | Lat: {destination.latitude.toFixed(4)}, Lng: {destination.longitude.toFixed(4)}
            </p>
          </div>

          {onEdit && (
            <button
              onClick={() => {
                onClose();
                onEdit(destination);
              }}
              className="btn-secondary"
              style={{ padding: '6px 14px', fontSize: '0.8rem' }}
            >
              <Edit3 size={14} /> Edit Telemetry
            </button>
          )}
        </div>

        {/* Carrying Capacity & Footfall Meter */}
        <div style={{
          background: 'rgba(15, 25, 20, 0.6)',
          border: '1px solid var(--border-subtle)',
          borderRadius: '12px',
          padding: '16px',
          marginBottom: '18px'
        }}>
          <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '8px' }}>
            <span style={{ fontSize: '0.85rem', fontWeight: 600, color: '#e2e8f0' }}>
              👥 Carrying Capacity Utilization: {loadPercentage}%
            </span>
            <span style={{ fontSize: '0.8rem', color: loadPercentage > 100 ? '#ef4444' : '#10b981', fontWeight: 700 }}>
              {loadPercentage > 100 ? '⚠️ OVER CAPACITY' : '✓ WITHIN SUSTAINABLE LIMITS'}
            </span>
          </div>

          <div style={{ width: '100%', height: '8px', background: 'rgba(255,255,255,0.1)', borderRadius: '4px', overflow: 'hidden' }}>
            <div style={{
              width: `${Math.min(100, loadPercentage)}%`,
              height: '100%',
              background: loadPercentage >= 90 ? '#ef4444' : loadPercentage >= 70 ? '#f59e0b' : '#10b981',
              borderRadius: '4px',
              transition: 'width 0.4s ease'
            }} />
          </div>

          <div style={{ display: 'flex', justifyContent: 'space-between', fontSize: '0.75rem', color: '#94a3b8', marginTop: '6px' }}>
            <span>Est. Active Visitors: <strong>{destination.currentVisitorsEst?.toLocaleString() || '0'}</strong></span>
            <span>Daily Ceiling Limit: <strong>{(destination.capacityDailyTourists || destination.capacity || 10000).toLocaleString()}</strong></span>
          </div>
        </div>

        {/* 5-Factor Pressure Matrix */}
        <div style={{
          background: 'rgba(10, 20, 15, 0.7)',
          border: '1px solid var(--border-subtle)',
          borderRadius: '12px',
          padding: '16px',
          marginBottom: '20px'
        }}>
          <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '12px' }}>
            <h4 style={{ fontSize: '0.85rem', color: '#10b981', textTransform: 'uppercase', letterSpacing: '0.05em', margin: 0 }}>
              Deterministic 5-Factor Pressure Matrix
            </h4>
            <span style={{ fontSize: '0.7rem', color: '#64748b' }}>
              Formula: 30% Tour + 25% Water + 20% Waste + 15% Traf + 10% Env
            </span>
          </div>

          <div style={{ display: 'grid', gridTemplateColumns: 'repeat(auto-fit, minmax(130px, 1fr))', gap: '10px' }}>
            <div style={{ background: 'rgba(255,255,255,0.03)', padding: '12px', borderRadius: '8px', textAlign: 'center' }}>
              <div style={{ fontSize: '0.75rem', color: '#94a3b8' }}>👥 Tourism (30%)</div>
              <div style={{ fontSize: '1.25rem', fontWeight: 700, color: subScores.tourism >= 70 ? '#ef4444' : '#f8fafc', marginTop: '4px' }}>
                {subScores.tourism}%
              </div>
            </div>

            <div style={{ background: 'rgba(255,255,255,0.03)', padding: '12px', borderRadius: '8px', textAlign: 'center' }}>
              <div style={{ fontSize: '0.75rem', color: '#94a3b8' }}>💧 Water (25%)</div>
              <div style={{ fontSize: '1.25rem', fontWeight: 700, color: subScores.water >= 70 ? '#ef4444' : '#f8fafc', marginTop: '4px' }}>
                {subScores.water}%
              </div>
            </div>

            <div style={{ background: 'rgba(255,255,255,0.03)', padding: '12px', borderRadius: '8px', textAlign: 'center' }}>
              <div style={{ fontSize: '0.75rem', color: '#94a3b8' }}>🗑️ Waste (20%)</div>
              <div style={{ fontSize: '1.25rem', fontWeight: 700, color: subScores.waste >= 70 ? '#ef4444' : '#f8fafc', marginTop: '4px' }}>
                {subScores.waste}%
              </div>
            </div>

            <div style={{ background: 'rgba(255,255,255,0.03)', padding: '12px', borderRadius: '8px', textAlign: 'center' }}>
              <div style={{ fontSize: '0.75rem', color: '#94a3b8' }}>🚗 Traffic (15%)</div>
              <div style={{ fontSize: '1.25rem', fontWeight: 700, color: subScores.traffic >= 70 ? '#ef4444' : '#f8fafc', marginTop: '4px' }}>
                {subScores.traffic}%
              </div>
            </div>

            <div style={{ background: 'rgba(255,255,255,0.03)', padding: '12px', borderRadius: '8px', textAlign: 'center' }}>
              <div style={{ fontSize: '0.75rem', color: '#94a3b8' }}>🌲 Hazard (10%)</div>
              <div style={{ fontSize: '1.25rem', fontWeight: 700, color: subScores.environment >= 70 ? '#ef4444' : '#f8fafc', marginTop: '4px' }}>
                {subScores.environment}%
              </div>
            </div>
          </div>
        </div>

        {/* Tab Toggle: ML Prediction vs Historical Trends */}
        <div style={{ marginBottom: '16px' }}>
          <div style={{ display: 'flex', gap: '8px', marginBottom: '12px', borderBottom: '1px solid var(--border-subtle)', paddingBottom: '8px' }}>
            <button
              onClick={() => setActiveTab('prediction')}
              style={{
                background: activeTab === 'prediction' ? 'rgba(16, 185, 129, 0.2)' : 'transparent',
                color: activeTab === 'prediction' ? '#10b981' : '#94a3b8',
                border: activeTab === 'prediction' ? '1px solid #10b981' : '1px solid transparent',
                borderRadius: '8px', padding: '6px 14px', fontSize: '0.85rem', fontWeight: 600, cursor: 'pointer',
                display: 'flex', alignItems: 'center', gap: '6px'
              }}
            >
              <TrendingUp size={15} /> 7-Day ML Forecast & Risk Factors
            </button>
            <button
              onClick={() => setActiveTab('history')}
              style={{
                background: activeTab === 'history' ? 'rgba(16, 185, 129, 0.2)' : 'transparent',
                color: activeTab === 'history' ? '#10b981' : '#94a3b8',
                border: activeTab === 'history' ? '1px solid #10b981' : '1px solid transparent',
                borderRadius: '8px', padding: '6px 14px', fontSize: '0.85rem', fontWeight: 600, cursor: 'pointer',
                display: 'flex', alignItems: 'center', gap: '6px'
              }}
            >
              <Activity size={15} /> 14-Day Historical Telemetry
            </button>
          </div>

          {activeTab === 'prediction' ? (
            <div>
              <div style={{ height: '220px', width: '100%', background: 'rgba(0,0,0,0.3)', borderRadius: '12px', padding: '12px 12px 0 0' }}>
                <ResponsiveContainer width="100%" height="100%">
                  <AreaChart data={predictionData}>
                    <defs>
                      <linearGradient id="predGrad" x1="0" y1="0" x2="0" y2="1">
                        <stop offset="5%" stopColor="#10b981" stopOpacity={0.6}/>
                        <stop offset="95%" stopColor="#10b981" stopOpacity={0.0}/>
                      </linearGradient>
                    </defs>
                    <CartesianGrid strokeDasharray="3 3" stroke="rgba(255,255,255,0.08)" />
                    <XAxis dataKey="date" stroke="#94a3b8" fontSize={11} />
                    <YAxis domain={[0, 100]} stroke="#94a3b8" fontSize={11} />
                    <Tooltip
                      contentStyle={{ background: '#12231b', borderColor: '#2d5a43', borderRadius: '8px', color: '#fff' }}
                      formatter={(val: any, name: string) => [`${val}%`, name === 'predicted' ? 'Predicted Pressure' : name]}
                    />
                    <Area type="monotone" dataKey="predicted" stroke="#10b981" strokeWidth={2} fillOpacity={1} fill="url(#predGrad)" name="predicted" />
                  </AreaChart>
                </ResponsiveContainer>
              </div>

              {/* AI Explanation Box */}
              <div style={{
                marginTop: '12px', background: 'rgba(16, 185, 129, 0.08)',
                border: '1px solid rgba(16, 185, 129, 0.3)', borderRadius: '10px', padding: '12px'
              }}>
                <div style={{ display: 'flex', alignItems: 'center', gap: '6px', fontSize: '0.8rem', fontWeight: 700, color: '#10b981', marginBottom: '4px' }}>
                  <Sparkles size={14} /> Explainable ML Assessment:
                </div>
                <p style={{ fontSize: '0.8rem', color: '#cbd5e1', margin: 0 }}>
                  {destination.status === 'HIGH' || destination.status === 'CRITICAL'
                    ? `${destination.name} exhibits severe pressure driven by excessive tourism footfall exceeding carrying capacity alongside acute water stress.`
                    : `${destination.name} maintains a sustainable carrying capacity balance, making it an ideal diversion target for regional dispersal.`}
                </p>
              </div>
            </div>
          ) : (
            <div style={{ height: '220px', width: '100%', background: 'rgba(0,0,0,0.3)', borderRadius: '12px', padding: '12px 12px 0 0' }}>
              <ResponsiveContainer width="100%" height="100%">
                <LineChart data={historyData}>
                  <CartesianGrid strokeDasharray="3 3" stroke="rgba(255,255,255,0.08)" />
                  <XAxis dataKey="date" stroke="#94a3b8" fontSize={11} />
                  <YAxis domain={[0, 100]} stroke="#94a3b8" fontSize={11} />
                  <Tooltip contentStyle={{ background: '#12231b', borderColor: '#2d5a43', borderRadius: '8px', color: '#fff' }} />
                  <Line type="monotone" dataKey="score" stroke="#10b981" strokeWidth={2} name="Pressure Score" dot={{ r: 3 }} />
                  <Line type="monotone" dataKey="water" stroke="#38bdf8" strokeWidth={1.5} name="Water Stress" dot={false} strokeDasharray="3 3" />
                  <Line type="monotone" dataKey="traffic" stroke="#f59e0b" strokeWidth={1.5} name="Traffic Delay" dot={false} strokeDasharray="3 3" />
                </LineChart>
              </ResponsiveContainer>
            </div>
          )}
        </div>

        {/* Footer */}
        <div style={{ display: 'flex', justifyContent: 'flex-end', paddingTop: '12px', borderTop: '1px solid var(--border-subtle)' }}>
          <button onClick={onClose} className="btn-secondary">
            Close Inspector
          </button>
        </div>
      </div>
    </div>
  );
};
