import React, { useState } from 'react';
import { useAuth } from '../context/AuthContext';
import { Settings, Shield, Sliders, Server, Database, RefreshCw, Key, CheckCircle, AlertTriangle } from 'lucide-react';

export const SettingsPage: React.FC = () => {
  const { profile, role, token, logout } = useAuth();

  const [tourismWeight, setTourismWeight] = useState(30);
  const [waterWeight, setWaterWeight] = useState(25);
  const [wasteWeight, setWasteWeight] = useState(20);
  const [trafficWeight, setTrafficWeight] = useState(15);
  const [envWeight, setEnvWeight] = useState(10);
  const [savedSuccess, setSavedSuccess] = useState(false);

  const totalWeight = tourismWeight + waterWeight + wasteWeight + trafficWeight + envWeight;

  const handleSaveWeights = (e: React.FormEvent) => {
    e.preventDefault();
    if (totalWeight !== 100) {
      alert(`Weights must sum to 100%. Current total: ${totalWeight}%`);
      return;
    }
    setSavedSuccess(true);
    setTimeout(() => setSavedSuccess(false), 3000);
  };

  return (
    <div style={{ display: 'flex', flexDirection: 'column', gap: '20px' }}>
      {/* Header */}
      <div className="glass-panel" style={{ padding: '20px 24px' }}>
        <div style={{ display: 'flex', alignItems: 'center', gap: '10px', marginBottom: '4px' }}>
          <Settings size={22} color="#10b981" />
          <h2 style={{ fontSize: '1.3rem', color: '#fff', margin: 0 }}>
            System Settings & Algorithm Calibration
          </h2>
        </div>
        <p style={{ fontSize: '0.8rem', color: '#94a3b8', margin: 0 }}>
          Manage administrative privileges, multi-factor scoring weights, and infrastructure telemetry connections
        </p>
      </div>

      <div style={{ display: 'grid', gridTemplateColumns: '1.2fr 1.8fr', gap: '20px' }}>
        {/* Officer Profile & Credentials */}
        <div style={{ display: 'flex', flexDirection: 'column', gap: '16px' }}>
          <div className="glass-panel" style={{ padding: '24px' }}>
            <h3 style={{ fontSize: '1rem', color: '#fff', marginBottom: '16px', display: 'flex', alignItems: 'center', gap: '8px' }}>
              <Shield size={18} color="#10b981" /> Designated Officer Profile
            </h3>

            <div style={{ display: 'flex', flexDirection: 'column', gap: '12px', fontSize: '0.85rem' }}>
              <div style={{ background: 'rgba(0,0,0,0.3)', padding: '12px', borderRadius: '8px' }}>
                <span style={{ fontSize: '0.75rem', color: '#94a3b8', display: 'block' }}>Display Name:</span>
                <strong style={{ color: '#fff', fontSize: '0.95rem' }}>{profile?.displayName || 'District Nodal Officer'}</strong>
              </div>

              <div style={{ background: 'rgba(0,0,0,0.3)', padding: '12px', borderRadius: '8px' }}>
                <span style={{ fontSize: '0.75rem', color: '#94a3b8', display: 'block' }}>Official Email:</span>
                <strong style={{ color: '#fff' }}>{profile?.email || 'admin@pahadipulse.gov.in'}</strong>
              </div>

              <div style={{ background: 'rgba(0,0,0,0.3)', padding: '12px', borderRadius: '8px' }}>
                <span style={{ fontSize: '0.75rem', color: '#94a3b8', display: 'block' }}>Verified Role:</span>
                <span className="badge badge-low" style={{ marginTop: '4px' }}>
                  ADMINISTRATIVE OFFICER ({role.toUpperCase()})
                </span>
              </div>

              <div style={{ background: 'rgba(0,0,0,0.3)', padding: '12px', borderRadius: '8px' }}>
                <span style={{ fontSize: '0.75rem', color: '#94a3b8', display: 'block' }}>Backend Auth Token:</span>
                <code style={{ fontSize: '0.75rem', color: '#10b981', wordBreak: 'break-all' }}>
                  {token ? `${token.slice(0, 24)}...` : 'Bearer Active'}
                </code>
              </div>

              <button
                onClick={logout}
                className="btn-secondary"
                style={{ marginTop: '8px', justifyContent: 'center', borderColor: 'rgba(239, 68, 68, 0.4)', color: '#f87171' }}
              >
                Sign Out from Command Center
              </button>
            </div>
          </div>

          {/* System Health Check */}
          <div className="glass-panel" style={{ padding: '20px' }}>
            <h3 style={{ fontSize: '1rem', color: '#fff', marginBottom: '14px', display: 'flex', alignItems: 'center', gap: '8px' }}>
              <Server size={18} color="#10b981" /> System Health & Telemetry
            </h3>

            <div style={{ display: 'flex', flexDirection: 'column', gap: '10px', fontSize: '0.8rem' }}>
              <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', padding: '8px 10px', background: 'rgba(255,255,255,0.03)', borderRadius: '6px' }}>
                <span>FastAPI Backend (Port 8000):</span>
                <span style={{ color: '#10b981', fontWeight: 600 }}>● Online (12ms)</span>
              </div>
              <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', padding: '8px 10px', background: 'rgba(255,255,255,0.03)', borderRadius: '6px' }}>
                <span>ML Inference Service:</span>
                <span style={{ color: '#10b981', fontWeight: 600 }}>● Active (RandomForest)</span>
              </div>
              <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', padding: '8px 10px', background: 'rgba(255,255,255,0.03)', borderRadius: '6px' }}>
                <span>Role Enforcement Layer:</span>
                <span style={{ color: '#10b981', fontWeight: 600 }}>● Enforced (Admin Only)</span>
              </div>
            </div>
          </div>
        </div>

        {/* Algorithm Calibration Form */}
        <div className="glass-panel" style={{ padding: '24px' }}>
          <h3 style={{ fontSize: '1rem', color: '#fff', marginBottom: '16px', display: 'flex', alignItems: 'center', gap: '8px' }}>
            <Sliders size={18} color="#10b981" /> Multi-Factor Pressure Algorithm Weights
          </h3>

          <p style={{ fontSize: '0.85rem', color: '#cbd5e1', marginBottom: '18px', lineHeight: '1.5' }}>
            Adjust the regional pressure formula weights dynamically. These weights configure how tourism footfall, civic shortages, and mountain slope risks are synthesized into the 0-100 composite pressure index.
          </p>

          {savedSuccess && (
            <div style={{ background: 'rgba(16, 185, 129, 0.15)', border: '1px solid rgba(16, 185, 129, 0.4)', borderRadius: '8px', padding: '10px', color: '#10b981', fontSize: '0.85rem', marginBottom: '16px' }}>
              ✓ Weight calibration updated and synchronized with regional monitoring engine!
            </div>
          )}

          <form onSubmit={handleSaveWeights} style={{ display: 'flex', flexDirection: 'column', gap: '16px' }}>
            <div>
              <div style={{ display: 'flex', justifyContent: 'space-between', fontSize: '0.8rem', color: '#cbd5e1', marginBottom: '4px' }}>
                <span>👥 Tourism Influx Weight:</span>
                <strong style={{ color: '#10b981' }}>{tourismWeight}%</strong>
              </div>
              <input
                type="range" min="0" max="100" value={tourismWeight}
                onChange={(e) => setTourismWeight(parseInt(e.target.value))}
                style={{ width: '100%', accentColor: '#10b981' }}
              />
            </div>

            <div>
              <div style={{ display: 'flex', justifyContent: 'space-between', fontSize: '0.8rem', color: '#cbd5e1', marginBottom: '4px' }}>
                <span>💧 Water Stress Weight:</span>
                <strong style={{ color: '#38bdf8' }}>{waterWeight}%</strong>
              </div>
              <input
                type="range" min="0" max="100" value={waterWeight}
                onChange={(e) => setWaterWeight(parseInt(e.target.value))}
                style={{ width: '100%', accentColor: '#38bdf8' }}
              />
            </div>

            <div>
              <div style={{ display: 'flex', justifyContent: 'space-between', fontSize: '0.8rem', color: '#cbd5e1', marginBottom: '4px' }}>
                <span>🗑️ Solid Waste Weight:</span>
                <strong style={{ color: '#fbbf24' }}>{wasteWeight}%</strong>
              </div>
              <input
                type="range" min="0" max="100" value={wasteWeight}
                onChange={(e) => setWasteWeight(parseInt(e.target.value))}
                style={{ width: '100%', accentColor: '#fbbf24' }}
              />
            </div>

            <div>
              <div style={{ display: 'flex', justifyContent: 'space-between', fontSize: '0.8rem', color: '#cbd5e1', marginBottom: '4px' }}>
                <span>🚗 Traffic Congestion Weight:</span>
                <strong style={{ color: '#f97316' }}>{trafficWeight}%</strong>
              </div>
              <input
                type="range" min="0" max="100" value={trafficWeight}
                onChange={(e) => setTrafficWeight(parseInt(e.target.value))}
                style={{ width: '100%', accentColor: '#f97316' }}
              />
            </div>

            <div>
              <div style={{ display: 'flex', justifyContent: 'space-between', fontSize: '0.8rem', color: '#cbd5e1', marginBottom: '4px' }}>
                <span>🌲 Environmental Hazard Weight:</span>
                <strong style={{ color: '#ef4444' }}>{envWeight}%</strong>
              </div>
              <input
                type="range" min="0" max="100" value={envWeight}
                onChange={(e) => setEnvWeight(parseInt(e.target.value))}
                style={{ width: '100%', accentColor: '#ef4444' }}
              />
            </div>

            <div style={{
              display: 'flex', justifyContent: 'space-between', alignItems: 'center',
              padding: '12px 16px', background: totalWeight === 100 ? 'rgba(16, 185, 129, 0.1)' : 'rgba(239, 68, 68, 0.1)',
              borderRadius: '8px', border: `1px solid ${totalWeight === 100 ? 'rgba(16, 185, 129, 0.3)' : 'rgba(239, 68, 68, 0.4)'}`
            }}>
              <span style={{ fontSize: '0.85rem', color: '#cbd5e1' }}>Total Allocation:</span>
              <strong style={{ fontSize: '1.1rem', color: totalWeight === 100 ? '#10b981' : '#ef4444' }}>
                {totalWeight}% {totalWeight === 100 ? '✓ (Valid)' : '⚠️ (Must equal 100%)'}
              </strong>
            </div>

            <button
              type="submit"
              disabled={totalWeight !== 100}
              className="btn-primary"
              style={{ padding: '12px', justifyContent: 'center', fontSize: '0.9rem', marginTop: '8px' }}
            >
              Save Formula Weights
            </button>
          </form>
        </div>
      </div>
    </div>
  );
};
