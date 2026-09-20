import React, { useState, useEffect } from 'react';
import { Destination, DestinationPredictionResponse } from '../types';
import { getDestinationPrediction } from '../services/api';
import { Sparkles, TrendingUp, AlertTriangle, ShieldCheck, Cpu, Sliders, Info, BarChart2 } from 'lucide-react';
import { AreaChart, Area, XAxis, YAxis, Tooltip, ResponsiveContainer, CartesianGrid, Legend } from 'recharts';

interface PressurePredictionsPageProps {
  destinations: Destination[];
  onSelectDestination: (dest: Destination) => void;
}

export const PressurePredictionsPage: React.FC<PressurePredictionsPageProps> = ({
  destinations,
  onSelectDestination
}) => {
  const [selectedDestId, setSelectedDestId] = useState<string>(destinations[0]?.id || 'nainital');
  const [horizonDays, setHorizonDays] = useState<number>(7);
  const [prediction, setPrediction] = useState<DestinationPredictionResponse | null>(null);
  const [loading, setLoading] = useState(false);

  useEffect(() => {
    if (selectedDestId) {
      setLoading(true);
      getDestinationPrediction(selectedDestId, horizonDays)
        .then(setPrediction)
        .catch((err) => console.error('Prediction fetch error:', err))
        .finally(() => setLoading(false));
    }
  }, [selectedDestId, horizonDays]);

  const selectedDest = destinations.find((d) => d.id === selectedDestId);

  const chartData = (prediction?.predictions || []).map((p) => ({
    date: p.forecastDate.slice(5),
    predicted: p.predictedPressure,
    lower: p.confidenceLower,
    upper: p.confidenceUpper,
    risk: p.primaryRiskFactor
  }));

  const featureWeights = [
    { feature: 'Footfall / Carrying Capacity Ratio', weight: 35, color: '#10b981' },
    { feature: 'Water Resource Seasonal Stress', weight: 25, color: '#38bdf8' },
    { feature: 'Chokepoint Road Transit Gridlock', weight: 20, color: '#f59e0b' },
    { feature: 'Solid Waste Saturation Index', weight: 12, color: '#fbbf24' },
    { feature: 'Meteorological & Slope Hazards', weight: 8, color: '#ef4444' }
  ];

  return (
    <div style={{ display: 'flex', flexDirection: 'column', gap: '20px' }}>
      {/* Header & Controls */}
      <div className="glass-panel" style={{ padding: '20px 24px', display: 'flex', justifyContent: 'space-between', alignItems: 'center', flexWrap: 'wrap', gap: '16px' }}>
        <div>
          <div style={{ display: 'flex', alignItems: 'center', gap: '10px', marginBottom: '4px' }}>
            <Sparkles size={22} color="#10b981" />
            <h2 style={{ fontSize: '1.3rem', color: '#fff', margin: 0 }}>
              Machine Learning Pressure Predictions & Risk Modeling
            </h2>
          </div>
          <p style={{ fontSize: '0.8rem', color: '#94a3b8', margin: 0 }}>
            Trained ensemble regression models forecasting carrying capacity stress horizons with confidence intervals
          </p>
        </div>

        <div style={{ display: 'flex', gap: '12px', alignItems: 'center' }}>
          <select
            value={selectedDestId}
            onChange={(e) => setSelectedDestId(e.target.value)}
            style={{
              background: 'rgba(0,0,0,0.3)', border: '1px solid var(--border-subtle)',
              borderRadius: '8px', padding: '8px 14px', color: '#fff', fontSize: '0.85rem'
            }}
          >
            {destinations.map((d) => (
              <option key={d.id} value={d.id} style={{ background: '#12231b' }}>
                {d.name} ({d.district})
              </option>
            ))}
          </select>

          <div style={{ display: 'flex', gap: '6px' }}>
            {[3, 7, 14].map((h) => (
              <button
                key={h}
                onClick={() => setHorizonDays(h)}
                style={{
                  padding: '8px 14px', borderRadius: '8px',
                  background: horizonDays === h ? 'rgba(16, 185, 129, 0.25)' : 'rgba(0,0,0,0.3)',
                  color: horizonDays === h ? '#10b981' : '#94a3b8',
                  border: horizonDays === h ? '1px solid #10b981' : '1px solid var(--border-subtle)',
                  fontSize: '0.8rem', fontWeight: 600, cursor: 'pointer'
                }}
              >
                {h}D Horizon
              </button>
            ))}
          </div>
        </div>
      </div>

      {/* Main Grid: Forecast Chart & Explainability */}
      <div style={{ display: 'grid', gridTemplateColumns: '1.8fr 1.2fr', gap: '20px' }}>
        {/* Forecast Area Chart */}
        <div className="glass-panel" style={{ padding: '24px', display: 'flex', flexDirection: 'column' }}>
          <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '16px' }}>
            <div>
              <h3 style={{ fontSize: '1.1rem', color: '#fff', margin: '0 0 4px 0' }}>
                {selectedDest?.name} • {horizonDays}-Day Predicted Trajectory
              </h3>
              <span style={{ fontSize: '0.75rem', color: '#94a3b8' }}>
                Model: <strong>RandomForestRegressor Ensemble</strong> (R² = {prediction?.r2Score || 0.91})
              </span>
            </div>
            {selectedDest && (
              <span className={`badge badge-${selectedDest.status.toLowerCase()}`}>
                Current: {selectedDest.pressureScore.toFixed(1)}
              </span>
            )}
          </div>

          <div style={{ flex: 1, minHeight: '300px', background: 'rgba(0,0,0,0.25)', borderRadius: '12px', padding: '16px 16px 8px 0' }}>
            <ResponsiveContainer width="100%" height="100%">
              <AreaChart data={chartData}>
                <defs>
                  <linearGradient id="predArea" x1="0" y1="0" x2="0" y2="1">
                    <stop offset="5%" stopColor="#10b981" stopOpacity={0.5}/>
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
                <Area type="monotone" dataKey="predicted" stroke="#10b981" strokeWidth={2.5} fillOpacity={1} fill="url(#predArea)" name="predicted" />
                <Area type="monotone" dataKey="upper" stroke="#ef4444" strokeWidth={1} strokeDasharray="3 3" fill="none" name="Upper 95% Confidence" />
                <Area type="monotone" dataKey="lower" stroke="#38bdf8" strokeWidth={1} strokeDasharray="3 3" fill="none" name="Lower 95% Confidence" />
              </AreaChart>
            </ResponsiveContainer>
          </div>

          {/* Predictions Table */}
          <div style={{ marginTop: '16px', overflowX: 'auto' }}>
            <table style={{ width: '100%', fontSize: '0.8rem', borderCollapse: 'collapse' }}>
              <thead>
                <tr style={{ borderBottom: '1px solid var(--border-subtle)', color: '#94a3b8', textAlign: 'left' }}>
                  <th style={{ padding: '8px 10px' }}>Date</th>
                  <th style={{ padding: '8px 10px' }}>Forecast</th>
                  <th style={{ padding: '8px 10px' }}>95% Range</th>
                  <th style={{ padding: '8px 10px' }}>Primary Risk Factor</th>
                </tr>
              </thead>
              <tbody>
                {chartData.map((row, i) => (
                  <tr key={i} style={{ borderBottom: '1px solid rgba(255,255,255,0.04)', color: '#e2e8f0' }}>
                    <td style={{ padding: '8px 10px' }}>{row.date}</td>
                    <td style={{ padding: '8px 10px', fontWeight: 700, color: row.predicted >= 70 ? '#ef4444' : row.predicted >= 50 ? '#f59e0b' : '#10b981' }}>
                      {row.predicted}%
                    </td>
                    <td style={{ padding: '8px 10px', color: '#94a3b8' }}>
                      {row.lower}% – {row.upper}%
                    </td>
                    <td style={{ padding: '8px 10px' }}>
                      <span style={{ fontSize: '0.75rem', background: 'rgba(255,255,255,0.06)', padding: '2px 8px', borderRadius: '6px' }}>
                        {row.risk}
                      </span>
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        </div>

        {/* Feature Importance & Model Transparency */}
        <div style={{ display: 'flex', flexDirection: 'column', gap: '16px' }}>
          {/* Feature Weights Card */}
          <div className="glass-panel" style={{ padding: '20px' }}>
            <h3 style={{ fontSize: '1rem', color: '#fff', marginBottom: '14px', display: 'flex', alignItems: 'center', gap: '8px' }}>
              <Cpu size={18} color="#10b981" /> Feature Importance Attribution
            </h3>

            <div style={{ display: 'flex', flexDirection: 'column', gap: '12px' }}>
              {featureWeights.map((fw) => (
                <div key={fw.feature}>
                  <div style={{ display: 'flex', justifyContent: 'space-between', fontSize: '0.8rem', color: '#cbd5e1', marginBottom: '4px' }}>
                    <span>{fw.feature}</span>
                    <strong style={{ color: fw.color }}>{fw.weight}%</strong>
                  </div>
                  <div style={{ width: '100%', height: '6px', background: 'rgba(255,255,255,0.1)', borderRadius: '3px', overflow: 'hidden' }}>
                    <div style={{ width: `${fw.weight * 2.5}%`, height: '100%', background: fw.color, borderRadius: '3px' }} />
                  </div>
                </div>
              ))}
            </div>
          </div>

          {/* Model Transparency Disclaimer */}
          <div className="glass-panel" style={{ padding: '20px', background: 'rgba(16, 185, 129, 0.06)', border: '1px solid rgba(16, 185, 129, 0.25)' }}>
            <div style={{ display: 'flex', alignItems: 'center', gap: '8px', color: '#10b981', fontWeight: 700, fontSize: '0.85rem', marginBottom: '8px' }}>
              <Info size={16} /> Explainability & Dataset Transparency
            </div>
            <p style={{ fontSize: '0.8rem', color: '#cbd5e1', lineHeight: '1.5', margin: '0 0 10px 0' }}>
              The PahadiPulse AI inference pipeline utilizes supervised regression calibrated against historical carrying capacities, seasonal pilgrimage spikes (Char Dham), monsoon rainfall variance, and municipal infrastructure reports.
            </p>
            <div style={{ fontSize: '0.75rem', color: '#64748b' }}>
              • Origin: <em>DEMO_SYNTHETIC_HACKATHON</em><br/>
              • Re-training Cycle: Daily nocturnal batch update<br/>
              • Latency: &lt;15ms per destination
            </div>
          </div>
        </div>
      </div>
    </div>
  );
};
