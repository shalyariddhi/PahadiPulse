import React, { useState } from 'react';
import { Destination } from '../types';
import { Compass, Eye, TrendingUp, Search, SlidersHorizontal } from 'lucide-react';

interface DestinationsPageProps {
  destinations: Destination[];
  onSelectDestination: (dest: Destination) => void;
}

export const DestinationsPage: React.FC<DestinationsPageProps> = ({
  destinations,
  onSelectDestination
}) => {
  const [search, setSearch] = useState('');
  const [districtFilter, setDistrictFilter] = useState('ALL');

  const districts = ['ALL', ...Array.from(new Set(destinations.map((d) => d.district)))];

  const filtered = destinations.filter((d) => {
    const matchDistrict = districtFilter === 'ALL' || d.district === districtFilter;
    const matchSearch = d.name.toLowerCase().includes(search.toLowerCase()) || d.district.toLowerCase().includes(search.toLowerCase());
    return matchDistrict && matchSearch;
  });

  return (
    <div style={{ display: 'flex', flexDirection: 'column', gap: '16px' }}>
      {/* Header & Controls */}
      <div className="glass-panel" style={{ padding: '18px 24px', display: 'flex', justifyContent: 'space-between', alignItems: 'center', flexWrap: 'wrap', gap: '16px' }}>
        <div>
          <h2 style={{ fontSize: '1.25rem', color: '#fff', margin: 0 }}>
            Regional Destinations & Carrying Capacities
          </h2>
          <p style={{ fontSize: '0.8rem', color: '#94a3b8' }}>
            Live multi-factor pressure ratings across {destinations.length} Uttarakhand destinations
          </p>
        </div>

        <div style={{ display: 'flex', gap: '12px', alignItems: 'center' }}>
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
        </div>
      </div>

      {/* Grid of Destination Cards */}
      <div style={{ display: 'grid', gridTemplateColumns: 'repeat(auto-fill, minmax(320px, 1fr))', gap: '16px' }}>
        {filtered.map((dest) => {
          const loadRatio = ((dest.currentVisitorsEst / (dest.capacityDailyTourists || 1)) * 100);
          return (
            <div
              key={dest.id}
              className="glass-panel glass-panel-hover"
              style={{ padding: '20px', display: 'flex', flexDirection: 'column', justifyContent: 'space-between' }}
            >
              <div>
                <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'flex-start', marginBottom: '10px' }}>
                  <div>
                    <h3 style={{ fontSize: '1.15rem', color: '#fff', margin: '0 0 4px 0' }}>{dest.name}</h3>
                    <span style={{ fontSize: '0.75rem', color: '#94a3b8' }}>{dest.district} • Alt: {dest.altitudeMeters}m</span>
                  </div>
                  <span className={`badge badge-${dest.status.toLowerCase()}`}>
                    {dest.pressureScore.toFixed(1)} / 100
                  </span>
                </div>

                <p style={{ fontSize: '0.8rem', color: '#cbd5e1', marginBottom: '14px', lineClamp: 2, display: '-webkit-box', WebkitLineClamp: 2, WebkitBoxOrient: 'vertical', overflow: 'hidden' }}>
                  {dest.description}
                </p>

                {/* Sub-Score Bars */}
                <div style={{ display: 'flex', flexDirection: 'column', gap: '6px', marginBottom: '16px', background: 'rgba(0,0,0,0.2)', padding: '10px', borderRadius: '8px' }}>
                  <div style={{ display: 'flex', justifyContent: 'space-between', fontSize: '0.75rem' }}>
                    <span style={{ color: '#94a3b8' }}>👥 Tourism Load</span>
                    <strong style={{ color: '#fff' }}>{dest.subScores?.tourism || dest.tourismScore}%</strong>
                  </div>
                  <div style={{ display: 'flex', justifyContent: 'space-between', fontSize: '0.75rem' }}>
                    <span style={{ color: '#94a3b8' }}>💧 Water Demand</span>
                    <strong style={{ color: '#fff' }}>{dest.subScores?.water || dest.waterScore}%</strong>
                  </div>
                  <div style={{ display: 'flex', justifyContent: 'space-between', fontSize: '0.75rem' }}>
                    <span style={{ color: '#94a3b8' }}>🚗 Traffic Gridlock</span>
                    <strong style={{ color: '#fff' }}>{dest.subScores?.traffic || dest.trafficScore}%</strong>
                  </div>
                </div>
              </div>

              <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', paddingTop: '10px', borderTop: '1px solid var(--border-subtle)' }}>
                <div style={{ fontSize: '0.75rem', color: loadRatio > 100 ? '#ef4444' : '#10b981' }}>
                  Capacity Load: <strong>{loadRatio.toFixed(0)}%</strong>
                </div>
                <button
                  onClick={() => onSelectDestination(dest)}
                  className="btn-primary"
                  style={{ padding: '6px 14px', fontSize: '0.8rem' }}
                >
                  <Eye size={14} /> Full Breakdown
                </button>
              </div>
            </div>
          );
        })}
      </div>
    </div>
  );
};
