import React, { useState } from 'react';
import { Destination } from '../types';
import { Flame, Compass, AlertTriangle, ArrowUpRight, Filter, Layers, BarChart2 } from 'lucide-react';

interface PressureHeatmapPageProps {
  destinations: Destination[];
  onSelectDestination: (dest: Destination) => void;
}

export const PressureHeatmapPage: React.FC<PressureHeatmapPageProps> = ({
  destinations,
  onSelectDestination
}) => {
  const [selectedDistrict, setSelectedDistrict] = useState('ALL');
  const [selectedLevel, setSelectedLevel] = useState('ALL');

  const districts = [
    'Dehradun', 'Tehri Garhwal', 'Nainital', 'Chamoli', 'Uttarkashi',
    'Rudraprayag', 'Pauri Garhwal', 'Almora', 'Pithoragarh',
    'Haridwar', 'Bageshwar', 'Champawat', 'Udham Singh Nagar'
  ];

  // Group destinations by district
  const districtGroups = districts.map((district) => {
    const dests = destinations.filter((d) => d.district.toLowerCase() === district.toLowerCase() || d.district.toLowerCase().includes(district.toLowerCase().split(' ')[0]));
    const avgScore = dests.length > 0
      ? Number((dests.reduce((acc, curr) => acc + curr.pressureScore, 0) / dests.length).toFixed(1))
      : 0;
    const criticalCount = dests.filter((d) => d.status === 'CRITICAL' || d.status === 'HIGH').length;
    return {
      district,
      destinations: dests,
      avgScore,
      criticalCount
    };
  }).sort((a, b) => b.avgScore - a.avgScore);

  const filteredDistricts = districtGroups.filter((g) => {
    if (selectedDistrict !== 'ALL' && g.district !== selectedDistrict) return false;
    if (selectedLevel === 'CRITICAL' && g.avgScore < 70) return false;
    if (selectedLevel === 'HIGH' && (g.avgScore < 50 || g.avgScore >= 70)) return false;
    if (selectedLevel === 'MODERATE' && (g.avgScore < 30 || g.avgScore >= 50)) return false;
    if (selectedLevel === 'LOW' && g.avgScore >= 30) return false;
    return true;
  });

  const getHeatColor = (score: number) => {
    if (score >= 70) return 'linear-gradient(135deg, rgba(239, 68, 68, 0.4) 0%, rgba(153, 27, 27, 0.7) 100%)';
    if (score >= 50) return 'linear-gradient(135deg, rgba(249, 115, 22, 0.35) 0%, rgba(194, 65, 12, 0.6) 100%)';
    if (score >= 30) return 'linear-gradient(135deg, rgba(245, 158, 11, 0.3) 0%, rgba(180, 83, 9, 0.5) 100%)';
    return 'linear-gradient(135deg, rgba(16, 185, 129, 0.3) 0%, rgba(6, 78, 59, 0.5) 100%)';
  };

  const getBorderColor = (score: number) => {
    if (score >= 70) return 'rgba(239, 68, 68, 0.6)';
    if (score >= 50) return 'rgba(249, 115, 22, 0.5)';
    if (score >= 30) return 'rgba(245, 158, 11, 0.4)';
    return 'rgba(16, 185, 129, 0.4)';
  };

  return (
    <div style={{ display: 'flex', flexDirection: 'column', gap: '20px' }}>
      {/* Header & Controls */}
      <div className="glass-panel" style={{ padding: '20px 24px', display: 'flex', justifyContent: 'space-between', alignItems: 'center', flexWrap: 'wrap', gap: '16px' }}>
        <div>
          <div style={{ display: 'flex', alignItems: 'center', gap: '10px', marginBottom: '4px' }}>
            <Flame size={22} color="#ef4444" />
            <h2 style={{ fontSize: '1.3rem', color: '#fff', margin: 0 }}>
              Regional Pressure Heatmap & Thermal Density
            </h2>
          </div>
          <p style={{ fontSize: '0.8rem', color: '#94a3b8', margin: 0 }}>
            Spatial stress concentration across 13 Uttarakhand districts and dynamic tourism hotspots
          </p>
        </div>

        <div style={{ display: 'flex', gap: '12px', alignItems: 'center' }}>
          <select
            value={selectedDistrict}
            onChange={(e) => setSelectedDistrict(e.target.value)}
            style={{
              background: 'rgba(0,0,0,0.3)', border: '1px solid var(--border-subtle)',
              borderRadius: '8px', padding: '8px 14px', color: '#fff', fontSize: '0.85rem'
            }}
          >
            <option value="ALL" style={{ background: '#12231b' }}>All 13 Districts</option>
            {districts.map((d) => (
              <option key={d} value={d} style={{ background: '#12231b' }}>{d}</option>
            ))}
          </select>

          <select
            value={selectedLevel}
            onChange={(e) => setSelectedLevel(e.target.value)}
            style={{
              background: 'rgba(0,0,0,0.3)', border: '1px solid var(--border-subtle)',
              borderRadius: '8px', padding: '8px 14px', color: '#fff', fontSize: '0.85rem'
            }}
          >
            <option value="ALL" style={{ background: '#12231b' }}>All Heat Intensities</option>
            <option value="CRITICAL" style={{ background: '#12231b' }}>🔴 Critical Thermal (70-100)</option>
            <option value="HIGH" style={{ background: '#12231b' }}>🟠 High Stress (50-69)</option>
            <option value="MODERATE" style={{ background: '#12231b' }}>🟡 Moderate (30-49)</option>
            <option value="LOW" style={{ background: '#12231b' }}>🟢 Low / Sustainable (0-29)</option>
          </select>
        </div>
      </div>

      {/* District Thermal Intensity Grid */}
      <div style={{ display: 'grid', gridTemplateColumns: 'repeat(auto-fill, minmax(340px, 1fr))', gap: '18px' }}>
        {filteredDistricts.map((group) => (
          <div
            key={group.district}
            className="glass-panel glass-panel-hover"
            style={{
              padding: '20px',
              background: getHeatColor(group.avgScore),
              border: `1px solid ${getBorderColor(group.avgScore)}`,
              borderRadius: '16px',
              display: 'flex',
              flexDirection: 'column',
              justifyContent: 'space-between',
              position: 'relative',
              overflow: 'hidden'
            }}
          >
            <div>
              <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '10px' }}>
                <h3 style={{ fontSize: '1.15rem', color: '#fff', margin: 0, fontWeight: 700 }}>
                  {group.district}
                </h3>
                <span style={{
                  fontSize: '1rem', fontWeight: 800, color: '#fff',
                  background: 'rgba(0,0,0,0.4)', padding: '4px 10px', borderRadius: '12px',
                  border: '1px solid rgba(255,255,255,0.2)'
                }}>
                  {group.avgScore.toFixed(1)} / 100
                </span>
              </div>

              <div style={{ display: 'flex', gap: '12px', fontSize: '0.75rem', color: '#cbd5e1', marginBottom: '14px' }}>
                <span>Monitored Hubs: <strong>{group.destinations.length}</strong></span>
                {group.criticalCount > 0 && (
                  <span style={{ color: '#f87171', fontWeight: 600 }}>⚠️ {group.criticalCount} Critical Hubs</span>
                )}
              </div>

              {/* Destination Hotspot Badges */}
              <div style={{ display: 'flex', flexWrap: 'wrap', gap: '8px', marginBottom: '12px' }}>
                {group.destinations.length === 0 ? (
                  <span style={{ fontSize: '0.75rem', color: 'rgba(255,255,255,0.6)', fontStyle: 'italic' }}>
                    Telemetry stations in nominal standby
                  </span>
                ) : (
                  group.destinations.map((d) => (
                    <button
                      key={d.id}
                      onClick={() => onSelectDestination(d)}
                      style={{
                        background: 'rgba(0,0,0,0.45)',
                        border: '1px solid rgba(255,255,255,0.15)',
                        borderRadius: '8px',
                        padding: '6px 10px',
                        color: '#fff',
                        fontSize: '0.75rem',
                        cursor: 'pointer',
                        display: 'flex',
                        alignItems: 'center',
                        gap: '6px',
                        transition: 'all 0.2s ease'
                      }}
                    >
                      <span>{d.name}</span>
                      <strong style={{ color: d.pressureScore >= 70 ? '#ef4444' : d.pressureScore >= 50 ? '#f97316' : '#10b981' }}>
                        {d.pressureScore.toFixed(0)}
                      </strong>
                    </button>
                  ))
                )}
              </div>
            </div>

            {/* Carrying Capacity Heat Meter */}
            <div style={{ borderTop: '1px solid rgba(255,255,255,0.15)', paddingTop: '10px', display: 'flex', justifyContent: 'space-between', alignItems: 'center', fontSize: '0.75rem', color: '#e2e8f0' }}>
              <span>Thermal Level: <strong>{group.avgScore >= 70 ? 'CRITICAL STRESS' : group.avgScore >= 50 ? 'HIGH PRESSURE' : group.avgScore >= 30 ? 'MODERATE' : 'SUSTAINABLE'}</strong></span>
              <span style={{ color: '#fff', display: 'flex', alignItems: 'center', gap: '4px' }}>
                Inspect <ArrowUpRight size={14} />
              </span>
            </div>
          </div>
        ))}
      </div>
    </div>
  );
};
