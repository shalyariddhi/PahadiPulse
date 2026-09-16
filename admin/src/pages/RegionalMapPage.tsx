import React, { useState } from 'react';
import { Destination, Report, LocalProvider } from '../types';
import { RegionalLeafletMap } from '../components/maps/RegionalLeafletMap';
import { Filter, Compass, Search } from 'lucide-react';

interface RegionalMapPageProps {
  destinations: Destination[];
  reports: Report[];
  providers: LocalProvider[];
  onSelectDestination: (dest: Destination) => void;
}

export const RegionalMapPage: React.FC<RegionalMapPageProps> = ({
  destinations,
  reports,
  providers,
  onSelectDestination
}) => {
  const [districtFilter, setDistrictFilter] = useState('ALL');
  const [statusFilter, setStatusFilter] = useState('ALL');
  const [search, setSearch] = useState('');

  const districts = ['ALL', ...Array.from(new Set(destinations.map((d) => d.district)))];

  const filteredDests = destinations.filter((d) => {
    const matchDistrict = districtFilter === 'ALL' || d.district === districtFilter;
    const matchStatus = statusFilter === 'ALL' || d.status === statusFilter;
    const matchSearch = d.name.toLowerCase().includes(search.toLowerCase()) || d.district.toLowerCase().includes(search.toLowerCase());
    return matchDistrict && matchStatus && matchSearch;
  });

  return (
    <div style={{ display: 'flex', flexDirection: 'column', gap: '16px', height: 'calc(100vh - 140px)' }}>
      {/* Top Filter Bar */}
      <div className="glass-panel" style={{ padding: '12px 20px', display: 'flex', gap: '16px', alignItems: 'center', flexWrap: 'wrap', justifyContent: 'space-between' }}>
        <div style={{ display: 'flex', alignItems: 'center', gap: '12px' }}>
          <Compass size={20} color="#10b981" />
          <h2 style={{ fontSize: '1.1rem', color: '#fff', margin: 0 }}>
            Uttarakhand Spatial Pressure & Telemetry Map
          </h2>
        </div>

        <div style={{ display: 'flex', gap: '12px', alignItems: 'center' }}>
          {/* Search */}
          <input
            type="text"
            placeholder="Search destination..."
            value={search}
            onChange={(e) => setSearch(e.target.value)}
            style={{
              background: 'rgba(0,0,0,0.3)', border: '1px solid var(--border-subtle)',
              borderRadius: '8px', padding: '6px 12px', color: '#fff', fontSize: '0.85rem'
            }}
          />

          {/* District Filter */}
          <select
            value={districtFilter}
            onChange={(e) => setDistrictFilter(e.target.value)}
            style={{
              background: 'rgba(0,0,0,0.3)', border: '1px solid var(--border-subtle)',
              borderRadius: '8px', padding: '6px 12px', color: '#fff', fontSize: '0.85rem'
            }}
          >
            {districts.map((dist) => (
              <option key={dist} value={dist} style={{ background: '#12231b' }}>
                {dist === 'ALL' ? 'All Districts' : dist}
              </option>
            ))}
          </select>

          {/* Status Filter */}
          <select
            value={statusFilter}
            onChange={(e) => setStatusFilter(e.target.value)}
            style={{
              background: 'rgba(0,0,0,0.3)', border: '1px solid var(--border-subtle)',
              borderRadius: '8px', padding: '6px 12px', color: '#fff', fontSize: '0.85rem'
            }}
          >
            <option value="ALL" style={{ background: '#12231b' }}>All Pressure Levels</option>
            <option value="LOW" style={{ background: '#12231b' }}>🟢 Low (0-30)</option>
            <option value="MODERATE" style={{ background: '#12231b' }}>🟡 Moderate (31-50)</option>
            <option value="HIGH" style={{ background: '#12231b' }}>🟠 High (51-70)</option>
            <option value="CRITICAL" style={{ background: '#12231b' }}>🔴 Critical (71-100)</option>
          </select>
        </div>
      </div>

      {/* Map Canvas */}
      <div className="glass-panel" style={{ flex: 1, padding: '8px', overflow: 'hidden' }}>
        <RegionalLeafletMap
          destinations={filteredDests}
          reports={reports}
          providers={providers}
          onSelectDestination={onSelectDestination}
        />
      </div>
    </div>
  );
};
