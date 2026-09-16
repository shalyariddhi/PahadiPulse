import React, { useState } from 'react';
import { MapContainer, TileLayer, CircleMarker, Popup, Marker, LayersControl } from 'react-leaflet';
import L from 'leaflet';
import { Destination, Report, LocalProvider } from '../../types';
import { ShieldAlert, Droplets, Trash2, Car, Trees, Home, UserCheck } from 'lucide-react';

// Fix leaflet default marker icons in bundlers
delete (L.Icon.Default.prototype as any)._getIconUrl;
L.Icon.Default.mergeOptions({
  iconRetinaUrl: 'https://unpkg.com/leaflet@1.9.4/dist/images/marker-icon-2x.png',
  iconUrl: 'https://unpkg.com/leaflet@1.9.4/dist/images/marker-icon.png',
  shadowUrl: 'https://unpkg.com/leaflet@1.9.4/dist/images/marker-shadow.png',
});

// Custom Report Icon
const createReportIcon = (severity: number) => {
  const color = severity >= 4 ? '#ef4444' : severity === 3 ? '#f97316' : '#f59e0b';
  return L.divIcon({
    className: 'custom-report-pin',
    html: `<div style="background-color: ${color}; width: 26px; height: 26px; border-radius: 50%; display: flex; align-items: center; justify-content: center; border: 2px solid #fff; box-shadow: 0 0 10px ${color}; color: #fff; font-size: 12px; font-weight: bold;">!</div>`,
    iconSize: [26, 26],
    iconAnchor: [13, 13]
  });
};

// Custom Provider Icon
const providerIcon = L.divIcon({
  className: 'custom-provider-pin',
  html: `<div style="background-color: #10b981; width: 24px; height: 24px; border-radius: 50%; display: flex; align-items: center; justify-content: center; border: 2px solid #fff; box-shadow: 0 0 8px #10b981; color: #fff; font-size: 11px;">🏠</div>`,
  iconSize: [24, 24],
  iconAnchor: [12, 12]
});

interface MapProps {
  destinations: Destination[];
  reports?: Report[];
  providers?: LocalProvider[];
  onSelectDestination?: (dest: Destination) => void;
  selectedDestinationId?: string;
}

export const RegionalLeafletMap: React.FC<MapProps> = ({
  destinations,
  reports = [],
  providers = [],
  onSelectDestination,
  selectedDestinationId
}) => {
  const [showReports, setShowReports] = useState(true);
  const [showProviders, setShowProviders] = useState(true);

  // Center on Uttarakhand
  const center: [number, number] = [30.3165, 78.8500];

  const getStatusColor = (score: number) => {
    if (score <= 30) return '#10b981'; // Low
    if (score <= 50) return '#f59e0b'; // Moderate
    if (score <= 70) return '#f97316'; // High
    return '#ef4444'; // Critical
  };

  return (
    <div style={{ position: 'relative', width: '100%', height: '100%', minHeight: '520px', borderRadius: '16px', overflow: 'hidden' }}>
      {/* Map Filter Controls Overlay */}
      <div style={{
        position: 'absolute', top: '16px', right: '16px', zIndex: 1000,
        background: 'rgba(15, 25, 20, 0.9)', backdropFilter: 'blur(10px)',
        padding: '12px 16px', borderRadius: '12px', border: '1px solid var(--border-subtle)',
        display: 'flex', gap: '16px', alignItems: 'center', fontSize: '0.85rem'
      }}>
        <label style={{ display: 'flex', alignItems: 'center', gap: '6px', cursor: 'pointer', color: '#f8fafc' }}>
          <input
            type="checkbox"
            checked={showReports}
            onChange={(e) => setShowReports(e.target.checked)}
            style={{ accentColor: '#ef4444' }}
          />
          <span style={{ color: '#ef4444', fontWeight: 600 }}>•</span> Active Citizen Reports ({reports.length})
        </label>
        <label style={{ display: 'flex', alignItems: 'center', gap: '6px', cursor: 'pointer', color: '#f8fafc' }}>
          <input
            type="checkbox"
            checked={showProviders}
            onChange={(e) => setShowProviders(e.target.checked)}
            style={{ accentColor: '#10b981' }}
          />
          <span style={{ color: '#10b981', fontWeight: 600 }}>•</span> Local Homestays ({providers.length})
        </label>
      </div>

      <MapContainer
        center={center}
        zoom={8}
        scrollWheelZoom={true}
        style={{ width: '100%', height: '100%', minHeight: '520px' }}
      >
        <TileLayer
          attribution='&copy; <a href="https://www.openstreetmap.org/copyright">OpenStreetMap</a> contributors &copy; <a href="https://carto.com/attributions">CARTO</a>'
          url="https://{s}.basemaps.cartocdn.com/rastertiles/voyager/{z}/{x}/{y}{r}.png"
        />

        {/* 1. Destination Pressure Circles */}
        {destinations.map((dest) => {
          const color = getStatusColor(dest.pressureScore);
          const isSelected = dest.id === selectedDestinationId;

          return (
            <CircleMarker
              key={dest.id}
              center={[dest.latitude, dest.longitude]}
              radius={isSelected ? 26 : Math.max(12, Math.min(22, dest.pressureScore / 3.5))}
              pathOptions={{
                fillColor: color,
                fillOpacity: isSelected ? 0.85 : 0.65,
                color: isSelected ? '#ffffff' : color,
                weight: isSelected ? 3 : 1.5
              }}
              eventHandlers={{
                click: () => onSelectDestination && onSelectDestination(dest)
              }}
            >
              <Popup>
                <div style={{ minWidth: '220px', padding: '4px' }}>
                  <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '8px' }}>
                    <h3 style={{ fontSize: '1rem', color: '#fff', margin: 0 }}>{dest.name}</h3>
                    <span className={`badge badge-${dest.status.toLowerCase()}`}>
                      {dest.status} ({dest.pressureScore.toFixed(1)})
                    </span>
                  </div>
                  <p style={{ fontSize: '0.75rem', color: '#94a3b8', marginBottom: '10px' }}>
                    {dest.district} District | Alt: {dest.altitudeMeters}m
                  </p>

                  <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: '6px', fontSize: '0.75rem', background: 'rgba(0,0,0,0.25)', padding: '8px', borderRadius: '8px' }}>
                    <div>👥 Tourism: <strong>{dest.subScores?.tourism || dest.tourismScore}%</strong></div>
                    <div>💧 Water: <strong>{dest.subScores?.water || dest.waterScore}%</strong></div>
                    <div>🗑️ Waste: <strong>{dest.subScores?.waste || dest.wasteScore}%</strong></div>
                    <div>🚗 Traffic: <strong>{dest.subScores?.traffic || dest.trafficScore}%</strong></div>
                  </div>

                  <div style={{ marginTop: '10px', fontSize: '0.75rem', color: '#cbd5e1' }}>
                    Est. Visitors Today: <strong>{dest.currentVisitorsEst?.toLocaleString() || 'N/A'}</strong> / {dest.capacityDailyTourists?.toLocaleString()} cap
                  </div>
                </div>
              </Popup>
            </CircleMarker>
          );
        })}

        {/* 2. Citizen Reports Pins */}
        {showReports && reports.map((rep) => (
          <Marker
            key={rep.id}
            position={[rep.latitude, rep.longitude]}
            icon={createReportIcon(rep.aiSeverity)}
          >
            <Popup>
              <div style={{ minWidth: '220px' }}>
                <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '4px' }}>
                  <span style={{ fontSize: '0.7rem', color: '#ef4444', fontWeight: 700, textTransform: 'uppercase' }}>
                    ⚠️ {rep.aiCategory} REPORT
                  </span>
                  <span style={{ fontSize: '0.7rem', background: 'rgba(239,68,68,0.2)', color: '#ef4444', padding: '2px 6px', borderRadius: '6px' }}>
                    Severity: {rep.aiSeverity}/5
                  </span>
                </div>
                <p style={{ fontSize: '0.8rem', color: '#fff', margin: '6px 0' }}>
                  {rep.description}
                </p>
                <div style={{ fontSize: '0.7rem', color: '#94a3b8' }}>
                  Status: <strong>{rep.status}</strong> | Reported in {rep.destinationName}
                </div>
              </div>
            </Popup>
          </Marker>
        ))}

        {/* 3. Local Providers */}
        {showProviders && providers.map((prov) => (
          <Marker
            key={prov.id}
            position={[prov.latitude, prov.longitude]}
            icon={providerIcon}
          >
            <Popup>
              <div style={{ minWidth: '200px' }}>
                <h4 style={{ fontSize: '0.85rem', color: '#10b981', margin: '0 0 4px 0' }}>{prov.name}</h4>
                <p style={{ fontSize: '0.75rem', color: '#e2e8f0', margin: '0 0 6px 0' }}>{prov.description}</p>
                <div style={{ fontSize: '0.7rem', color: '#94a3b8' }}>
                  💰 Starting at <strong>₹{prov.priceStartingINR}</strong> ({prov.pricingUnit})
                </div>
              </div>
            </Popup>
          </Marker>
        ))}
      </MapContainer>
    </div>
  );
};
