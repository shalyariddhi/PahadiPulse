import React, { useState } from 'react';
import { Destination, DestinationCreate, DestinationUpdate } from '../../types';
import { createDestination, updateDestination } from '../../services/api';
import { X, Save, Plus, Sliders, MapPin, Compass } from 'lucide-react';

interface DestinationEditModalProps {
  destination?: Destination | null;
  onClose: () => void;
  onSaved: (saved: Destination) => void;
}

export const DestinationEditModal: React.FC<DestinationEditModalProps> = ({
  destination,
  onClose,
  onSaved
}) => {
  const isEditing = !!destination;

  const [name, setName] = useState(destination?.name || '');
  const [district, setDistrict] = useState(destination?.district || 'Dehradun');
  const [latitude, setLatitude] = useState(destination?.latitude || 30.3165);
  const [longitude, setLongitude] = useState(destination?.longitude || 78.0322);
  const [description, setDescription] = useState(destination?.description || '');
  const [capacity, setCapacity] = useState(destination?.capacityDailyTourists || destination?.capacity || 10000);
  const [currentVisitorsEst, setCurrentVisitorsEst] = useState(destination?.currentVisitorsEst || 3500);
  const [altitudeMeters, setAltitudeMeters] = useState(destination?.altitudeMeters || 1800);
  const [avgDailyBudgetINR, setAvgDailyBudgetINR] = useState(destination?.avgDailyBudgetINR || 3000);

  // 5 subscores
  const [tourismScore, setTourismScore] = useState(destination?.subScores?.tourism || destination?.tourismScore || 30);
  const [waterScore, setWaterScore] = useState(destination?.subScores?.water || destination?.waterScore || 25);
  const [wasteScore, setWasteScore] = useState(destination?.subScores?.waste || destination?.wasteScore || 20);
  const [trafficScore, setTrafficScore] = useState(destination?.subScores?.traffic || destination?.trafficScore || 20);
  const [environmentScore, setEnvironmentScore] = useState(destination?.subScores?.environment || destination?.environmentScore || 15);

  const [saving, setSaving] = useState(false);
  const [error, setError] = useState('');

  // Live estimated composite score
  const computedScore = Number((
    (tourismScore * 0.30) +
    (waterScore * 0.25) +
    (wasteScore * 0.20) +
    (trafficScore * 0.15) +
    (environmentScore * 0.10)
  ).toFixed(1));

  const getStatus = (score: number) => {
    if (score <= 30) return 'LOW';
    if (score <= 50) return 'MODERATE';
    if (score <= 70) return 'HIGH';
    return 'CRITICAL';
  };

  const districts = [
    'Dehradun', 'Tehri Garhwal', 'Nainital', 'Chamoli', 'Uttarkashi',
    'Rudraprayag', 'Pauri Garhwal', 'Almora', 'Pithoragarh',
    'Haridwar', 'Bageshwar', 'Champawat', 'Udham Singh Nagar'
  ];

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setSaving(true);
    setError('');

    try {
      if (isEditing && destination) {
        const updates: DestinationUpdate = {
          name,
          district,
          description,
          capacity,
          currentVisitorsEst,
          tourismScore,
          waterScore,
          wasteScore,
          trafficScore,
          environmentScore,
          altitudeMeters,
          avgDailyBudgetINR
        };
        const res = await updateDestination(destination.id, updates);
        onSaved(res);
      } else {
        const payload: DestinationCreate = {
          name,
          district,
          latitude,
          longitude,
          description,
          capacity,
          currentVisitorsEst,
          tourismScore,
          waterScore,
          wasteScore,
          trafficScore,
          environmentScore,
          altitudeMeters,
          avgDailyBudgetINR,
          tags: ['Scenic', 'Uttarakhand', district],
          bestSeasons: ['March-June', 'Sept-Nov']
        };
        const res = await createDestination(payload);
        onSaved(res);
      }
      onClose();
    } catch (err: any) {
      setError(err?.response?.data?.detail || err.message || 'Failed to save destination telemetry');
    } finally {
      setSaving(false);
    }
  };

  return (
    <div style={{
      position: 'fixed', top: 0, left: 0, right: 0, bottom: 0,
      background: 'rgba(5, 10, 8, 0.85)', backdropFilter: 'blur(8px)',
      display: 'flex', alignItems: 'center', justifyContent: 'center',
      zIndex: 2000, padding: '20px'
    }}>
      <div className="glass-panel" style={{
        width: '100%', maxWidth: '720px', maxHeight: '92vh',
        overflowY: 'auto', padding: '28px', position: 'relative'
      }}>
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

        <div style={{ display: 'flex', alignItems: 'center', gap: '10px', marginBottom: '16px' }}>
          <Compass size={22} color="#10b981" />
          <div>
            <h3 style={{ fontSize: '1.25rem', color: '#fff', margin: 0 }}>
              {isEditing ? `Edit Destination: ${destination.name}` : 'Register New Destination'}
            </h3>
            <p style={{ fontSize: '0.75rem', color: '#94a3b8', margin: 0 }}>
              Carrying capacity limits & sub-factor telemetry calibration
            </p>
          </div>
        </div>

        {error && (
          <div style={{ background: 'rgba(239, 68, 68, 0.15)', border: '1px solid rgba(239, 68, 68, 0.4)', borderRadius: '8px', padding: '10px', color: '#f87171', fontSize: '0.85rem', marginBottom: '14px' }}>
            {error}
          </div>
        )}

        <form onSubmit={handleSubmit} style={{ display: 'flex', flexDirection: 'column', gap: '16px' }}>
          {/* Row 1: Name & District */}
          <div style={{ display: 'grid', gridTemplateColumns: '1.4fr 1fr', gap: '14px' }}>
            <div>
              <label style={{ display: 'block', fontSize: '0.75rem', color: '#94a3b8', marginBottom: '4px', fontWeight: 600 }}>
                Destination Name
              </label>
              <input
                type="text"
                value={name}
                onChange={(e) => setName(e.target.value)}
                required
                style={{ width: '100%', background: 'rgba(0,0,0,0.3)', border: '1px solid var(--border-subtle)', borderRadius: '8px', padding: '9px 12px', color: '#fff', fontSize: '0.85rem' }}
              />
            </div>

            <div>
              <label style={{ display: 'block', fontSize: '0.75rem', color: '#94a3b8', marginBottom: '4px', fontWeight: 600 }}>
                District
              </label>
              <select
                value={district}
                onChange={(e) => setDistrict(e.target.value)}
                style={{ width: '100%', background: 'rgba(0,0,0,0.3)', border: '1px solid var(--border-subtle)', borderRadius: '8px', padding: '9px 12px', color: '#fff', fontSize: '0.85rem' }}
              >
                {districts.map((d) => (
                  <option key={d} value={d} style={{ background: '#12231b' }}>{d}</option>
                ))}
              </select>
            </div>
          </div>

          {/* Row 2: Lat, Lng, Alt, Budget */}
          <div style={{ display: 'grid', gridTemplateColumns: 'repeat(4, 1fr)', gap: '10px' }}>
            <div>
              <label style={{ display: 'block', fontSize: '0.7rem', color: '#94a3b8', marginBottom: '4px' }}>Latitude</label>
              <input
                type="number"
                step="0.0001"
                value={latitude}
                onChange={(e) => setLatitude(parseFloat(e.target.value))}
                required
                style={{ width: '100%', background: 'rgba(0,0,0,0.3)', border: '1px solid var(--border-subtle)', borderRadius: '8px', padding: '8px', color: '#fff', fontSize: '0.8rem' }}
              />
            </div>
            <div>
              <label style={{ display: 'block', fontSize: '0.7rem', color: '#94a3b8', marginBottom: '4px' }}>Longitude</label>
              <input
                type="number"
                step="0.0001"
                value={longitude}
                onChange={(e) => setLongitude(parseFloat(e.target.value))}
                required
                style={{ width: '100%', background: 'rgba(0,0,0,0.3)', border: '1px solid var(--border-subtle)', borderRadius: '8px', padding: '8px', color: '#fff', fontSize: '0.8rem' }}
              />
            </div>
            <div>
              <label style={{ display: 'block', fontSize: '0.7rem', color: '#94a3b8', marginBottom: '4px' }}>Altitude (m)</label>
              <input
                type="number"
                value={altitudeMeters}
                onChange={(e) => setAltitudeMeters(parseInt(e.target.value))}
                style={{ width: '100%', background: 'rgba(0,0,0,0.3)', border: '1px solid var(--border-subtle)', borderRadius: '8px', padding: '8px', color: '#fff', fontSize: '0.8rem' }}
              />
            </div>
            <div>
              <label style={{ display: 'block', fontSize: '0.7rem', color: '#94a3b8', marginBottom: '4px' }}>Daily Budget (₹)</label>
              <input
                type="number"
                value={avgDailyBudgetINR}
                onChange={(e) => setAvgDailyBudgetINR(parseFloat(e.target.value))}
                style={{ width: '100%', background: 'rgba(0,0,0,0.3)', border: '1px solid var(--border-subtle)', borderRadius: '8px', padding: '8px', color: '#fff', fontSize: '0.8rem' }}
              />
            </div>
          </div>

          {/* Row 3: Capacity & Current Visitors */}
          <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: '14px' }}>
            <div>
              <label style={{ display: 'block', fontSize: '0.75rem', color: '#94a3b8', marginBottom: '4px', fontWeight: 600 }}>
                Carrying Capacity Limit (Daily Visitors)
              </label>
              <input
                type="number"
                value={capacity}
                onChange={(e) => setCapacity(parseInt(e.target.value))}
                required
                style={{ width: '100%', background: 'rgba(0,0,0,0.3)', border: '1px solid var(--border-subtle)', borderRadius: '8px', padding: '9px 12px', color: '#fff', fontSize: '0.85rem' }}
              />
            </div>
            <div>
              <label style={{ display: 'block', fontSize: '0.75rem', color: '#94a3b8', marginBottom: '4px', fontWeight: 600 }}>
                Estimated Current Active Visitors
              </label>
              <input
                type="number"
                value={currentVisitorsEst}
                onChange={(e) => setCurrentVisitorsEst(parseInt(e.target.value))}
                style={{ width: '100%', background: 'rgba(0,0,0,0.3)', border: '1px solid var(--border-subtle)', borderRadius: '8px', padding: '9px 12px', color: '#fff', fontSize: '0.85rem' }}
              />
            </div>
          </div>

          {/* Row 4: 5-Factor Score Sliders with Live Composite Score */}
          <div style={{ background: 'rgba(0,0,0,0.25)', border: '1px solid var(--border-subtle)', borderRadius: '12px', padding: '16px' }}>
            <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '12px' }}>
              <span style={{ fontSize: '0.8rem', fontWeight: 700, color: '#10b981' }}>
                5-Factor Sub-Score Telemetry (0 - 100)
              </span>
              <span className={`badge badge-${getStatus(computedScore).toLowerCase()}`}>
                Composite: {computedScore} ({getStatus(computedScore)})
              </span>
            </div>

            <div style={{ display: 'flex', flexDirection: 'column', gap: '12px' }}>
              <div>
                <div style={{ display: 'flex', justifyContent: 'space-between', fontSize: '0.75rem', color: '#cbd5e1', marginBottom: '3px' }}>
                  <span>👥 Tourism Load (30%)</span>
                  <strong>{tourismScore}%</strong>
                </div>
                <input
                  type="range" min="0" max="100" value={tourismScore}
                  onChange={(e) => setTourismScore(parseFloat(e.target.value))}
                  style={{ width: '100%', accentColor: '#10b981' }}
                />
              </div>

              <div>
                <div style={{ display: 'flex', justifyContent: 'space-between', fontSize: '0.75rem', color: '#cbd5e1', marginBottom: '3px' }}>
                  <span>💧 Water Resource Stress (25%)</span>
                  <strong>{waterScore}%</strong>
                </div>
                <input
                  type="range" min="0" max="100" value={waterScore}
                  onChange={(e) => setWaterScore(parseFloat(e.target.value))}
                  style={{ width: '100%', accentColor: '#38bdf8' }}
                />
              </div>

              <div>
                <div style={{ display: 'flex', justifyContent: 'space-between', fontSize: '0.75rem', color: '#cbd5e1', marginBottom: '3px' }}>
                  <span>🗑️ Solid Waste Accumulation (20%)</span>
                  <strong>{wasteScore}%</strong>
                </div>
                <input
                  type="range" min="0" max="100" value={wasteScore}
                  onChange={(e) => setWasteScore(parseFloat(e.target.value))}
                  style={{ width: '100%', accentColor: '#fbbf24' }}
                />
              </div>

              <div>
                <div style={{ display: 'flex', justifyContent: 'space-between', fontSize: '0.75rem', color: '#cbd5e1', marginBottom: '3px' }}>
                  <span>🚗 Road & Transit Congestion (15%)</span>
                  <strong>{trafficScore}%</strong>
                </div>
                <input
                  type="range" min="0" max="100" value={trafficScore}
                  onChange={(e) => setTrafficScore(parseFloat(e.target.value))}
                  style={{ width: '100%', accentColor: '#f97316' }}
                />
              </div>

              <div>
                <div style={{ display: 'flex', justifyContent: 'space-between', fontSize: '0.75rem', color: '#cbd5e1', marginBottom: '3px' }}>
                  <span>🌲 Slope & Seasonal Hazard (10%)</span>
                  <strong>{environmentScore}%</strong>
                </div>
                <input
                  type="range" min="0" max="100" value={environmentScore}
                  onChange={(e) => setEnvironmentScore(parseFloat(e.target.value))}
                  style={{ width: '100%', accentColor: '#ef4444' }}
                />
              </div>
            </div>
          </div>

          {/* Description */}
          <div>
            <label style={{ display: 'block', fontSize: '0.75rem', color: '#94a3b8', marginBottom: '4px', fontWeight: 600 }}>
              Regional Description
            </label>
            <textarea
              value={description}
              onChange={(e) => setDescription(e.target.value)}
              rows={3}
              required
              style={{ width: '100%', background: 'rgba(0,0,0,0.3)', border: '1px solid var(--border-subtle)', borderRadius: '8px', padding: '10px', color: '#fff', fontSize: '0.85rem' }}
            />
          </div>

          <div style={{ display: 'flex', justifyContent: 'flex-end', gap: '12px', marginTop: '6px' }}>
            <button type="button" onClick={onClose} className="btn-secondary">
              Cancel
            </button>
            <button type="submit" disabled={saving} className="btn-primary">
              <Save size={16} />
              {saving ? 'Saving...' : isEditing ? 'Update Telemetry' : 'Register Destination'}
            </button>
          </div>
        </form>
      </div>
    </div>
  );
};
