import React, { useState } from 'react';
import { Destination } from '../types';
import { Compass, Eye, TrendingUp, Search, Plus, Edit3, Sliders, MapPin } from 'lucide-react';

interface DestinationsPageProps {
  destinations: Destination[];
  onSelectDestination: (dest: Destination) => void;
  onAddDestination?: () => void;
  onEditDestination?: (dest: Destination) => void;
}

export const DestinationsPage: React.FC<DestinationsPageProps> = ({
  destinations,
  onSelectDestination,
  onAddDestination,
  onEditDestination
}) => {
  const [search, setSearch] = useState('');
  const [districtFilter, setDistrictFilter] = useState('ALL');
  const [statusFilter, setStatusFilter] = useState('ALL');

  const districts = ['ALL', ...Array.from(new Set(destinations.map((d) => d.district)))];

  const filtered = destinations.filter((d) => {
    const matchDistrict = districtFilter === 'ALL' || d.district === districtFilter;
    const matchStatus = statusFilter === 'ALL' || d.status === statusFilter;
    const matchSearch = d.name.toLowerCase().includes(search.toLowerCase()) || d.district.toLowerCase().includes(search.toLowerCase());
    return matchDistrict && matchStatus && matchSearch;
  });

  return (
    <div style={{ display: 'flex', flexDirection: 'column', gap: '16px' }}>
      {/* Header & Controls */}
      <div className="glass-panel" style={{ padding: '18px 24px', display: 'flex', justifyContent: 'space-between', alignItems: 'center', flexWrap: 'wrap', gap: '16px' }}>
        <div>
          <div style={{ display: 'flex', alignItems: 'center', gap: '10px', marginBottom: '4px' }}>
            <Compass size={22} color="#10b981" />
            <h2 style={{ fontSize: '1.25rem', color: '#fff', margin: 0 }}>
              Regional Destinations & Carrying Capacities
            </h2>
          </div>
          <p style={{ fontSize: '0.8rem', color: '#94a3b8', margin: 0 }}>
            Active telemetry across {destinations.length} destinations in Uttarakhand
          </p>
        </div>

        <div style={{ display: 'flex', gap: '12px', alignItems: 'center', flexWrap: 'wrap' }}>
          <input
            type="text"
            placeholder="Search destination..."
            value={search}
            onChange={(e) => setSearch(e.target.value)}
            style={{
              background: 'rgba(0,0,0,0.3)', border: '1px solid var(--border-subtle)',
              borderRadius: '8px', padding: '8px 14px', color: '#fff', fontSize: '0.85rem'
            }}
          />

          <select
            value={districtFilter}
            onChange={(e) => setDistrictFilter(e.target.value)}
            style={{
              background: 'rgba(0,0,0,0.3)', border: '1px solid var(--border-subtle)',
              borderRadius: '8px', padding: '8px 14px', color: '#fff', fontSize: '0.85rem'
            }}
          >
            {districts.map((dist) => (
              <option key={dist} value={dist} style={{ background: '#12231b' }}>
                {dist === 'ALL' ? 'All Districts' : dist}
              </option>
            ))}
          </select>

          <select
            value={statusFilter}
            onChange={(e) => setStatusFilter(e.target.value)}
            style={{
              background: 'rgba(0,0,0,0.3)', border: '1px solid var(--border-subtle)',
              borderRadius: '8px', padding: '8px 14px', color: '#fff', fontSize: '0.85rem'
            }}
          >
            <option value="ALL" style={{ background: '#12231b' }}>All Pressure Statuses</option>
            <option value="LOW" style={{ background: '#12231b' }}>🟢 Low (0-30)</option>
            <option value="MODERATE" style={{ background: '#12231b' }}>🟡 Moderate (31-50)</option>
            <option value="HIGH" style={{ background: '#12231b' }}>🟠 High (51-70)</option>
            <option value="CRITICAL" style={{ background: '#12231b' }}>🔴 Critical (71-100)</option>
          </select>

          {onAddDestination && (
            <button onClick={onAddDestination} className="btn-primary" style={{ padding: '8px 16px', fontSize: '0.85rem' }}>
              <Plus size={16} /> Add Destination
            </button>
          )}
        </div>
      </div>

      {/* Grid of Destination Cards */}
      <div style={{ display: 'grid', gridTemplateColumns: 'repeat(auto-fill, minmax(330px, 1fr))', gap: '16px' }}>
        {filtered.map((dest) => {
          const capLimit = dest.capacityDailyTourists || dest.capacity || 10000;
          const loadRatio = Math.round(((dest.currentVisitorsEst || 0) / capLimit) * 100);

          return (
            <div
              key={dest.id}
              className="glass-panel glass-panel-hover"
              style={{ padding: '20px', display: 'flex', flexDirection: 'column', justifyContent: 'space-between' }}
            >
              <div>
                <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'flex-start', marginBottom: '10px' }}>
                  <div>
                    <h3 style={{ fontSize: '1.2rem', color: '#fff', margin: '0 0 4px 0' }}>{dest.name}</h3>
                    <span style={{ fontSize: '0.75rem', color: '#94a3b8' }}>{dest.district} District • Alt: {dest.altitudeMeters}m</span>
                  </div>
                  <span className={`badge badge-${dest.status.toLowerCase()}`}>
                    {dest.pressureScore.toFixed(1)} / 100
                  </span>
                </div>

                <p style={{ fontSize: '0.8rem', color: '#cbd5e1', marginBottom: '14px', lineClamp: 2, display: '-webkit-box', WebkitLineClamp: 2, WebkitBoxOrient: 'vertical', overflow: 'hidden' }}>
                  {dest.description}
                </p>

                {/* Sub-Score Bars */}
                <div style={{ display: 'flex', flexDirection: 'column', gap: '6px', marginBottom: '16px', background: 'rgba(0,0,0,0.25)', padding: '10px', borderRadius: '8px' }}>
                  <div style={{ display: 'flex', justifyContent: 'space-between', fontSize: '0.75rem' }}>
                    <span style={{ color: '#94a3b8' }}>👥 Tourism Load (30%)</span>
                    <strong style={{ color: '#fff' }}>{dest.subScores?.tourism || dest.tourismScore}%</strong>
                  </div>
                  <div style={{ display: 'flex', justifyContent: 'space-between', fontSize: '0.75rem' }}>
                    <span style={{ color: '#94a3b8' }}>💧 Water Stress (25%)</span>
                    <strong style={{ color: '#fff' }}>{dest.subScores?.water || dest.waterScore}%</strong>
                  </div>
                  <div style={{ display: 'flex', justifyContent: 'space-between', fontSize: '0.75rem' }}>
                    <span style={{ color: '#94a3b8' }}>🗑️ Waste Pressure (20%)</span>
                    <strong style={{ color: '#fff' }}>{dest.subScores?.waste || dest.wasteScore}%</strong>
                  </div>
                  <div style={{ display: 'flex', justifyContent: 'space-between', fontSize: '0.75rem' }}>
                    <span style={{ color: '#94a3b8' }}>🚗 Traffic Congestion (15%)</span>
                    <strong style={{ color: '#fff' }}>{dest.subScores?.traffic || dest.trafficScore}%</strong>
                  </div>
                </div>
              </div>

              <div>
                <div style={{ display: 'flex', justifyContent: 'space-between', fontSize: '0.75rem', color: '#94a3b8', marginBottom: '4px' }}>
                  <span>Capacity Load:</span>
                  <strong style={{ color: loadRatio > 100 ? '#ef4444' : '#10b981' }}>{loadRatio}% ({dest.currentVisitorsEst?.toLocaleString()} / {capLimit.toLocaleString()})</strong>
                </div>

                <div style={{ width: '100%', height: '6px', background: 'rgba(255,255,255,0.1)', borderRadius: '3px', overflow: 'hidden', marginBottom: '12px' }}>
                  <div style={{
                    width: `${Math.min(100, loadRatio)}%`,
                    height: '100%',
                    background: loadRatio >= 90 ? '#ef4444' : loadRatio >= 70 ? '#f59e0b' : '#10b981',
                    borderRadius: '3px'
                  }} />
                </div>

                <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', paddingTop: '10px', borderTop: '1px solid var(--border-subtle)' }}>
                  {onEditDestination ? (
                    <button
                      onClick={() => onEditDestination(dest)}
                      className="btn-secondary"
                      style={{ padding: '6px 12px', fontSize: '0.75rem' }}
                    >
                      <Edit3 size={13} /> Edit
                    </button>
                  ) : <div />}

                  <button
                    onClick={() => onSelectDestination(dest)}
                    className="btn-primary"
                    style={{ padding: '6px 14px', fontSize: '0.8rem' }}
                  >
                    <Eye size={14} /> Full Breakdown
                  </button>
                </div>
              </div>
            </div>
          );
        })}
      </div>
    </div>
  );
};
