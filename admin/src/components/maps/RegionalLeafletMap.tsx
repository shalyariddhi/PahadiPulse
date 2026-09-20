import React, { useState } from 'react';
import { MapContainer, TileLayer, Marker, Popup, LayersControl } from 'react-leaflet';
import L from 'leaflet';
import { Destination, Report, LocalProvider } from '../../types';
import { 
  ShieldAlert, Droplets, Trash2, Car, Trees, Home, 
  Compass, Eye, Navigation, CheckCircle2, AlertTriangle, 
  Gauge, Flame, AlertOctagon, Store, Info, Phone, ExternalLink
} from 'lucide-react';

// Fix leaflet default marker icons in bundlers
delete (L.Icon.Default.prototype as any)._getIconUrl;
L.Icon.Default.mergeOptions({
  iconRetinaUrl: 'https://unpkg.com/leaflet@1.9.4/dist/images/marker-icon-2x.png',
  iconUrl: 'https://unpkg.com/leaflet@1.9.4/dist/images/marker-icon.png',
  shadowUrl: 'https://unpkg.com/leaflet@1.9.4/dist/images/marker-shadow.png',
});

// Custom Destination DivIcon with Accessible Label & Status Icon
const createDestinationMarkerIcon = (score: number, status: string, name: string, isSelected: boolean) => {
  let bgColor = '#064e3b';
  let borderColor = '#10b981';
  let badgeText = 'LOW';
  let symbol = '✓';

  if (score >= 70 || status === 'CRITICAL') {
    bgColor = '#7f1d1d';
    borderColor = '#ef4444';
    badgeText = 'CRIT';
    symbol = '⚠️';
  } else if (score >= 50 || status === 'HIGH') {
    bgColor = '#7c2d12';
    borderColor = '#f97316';
    badgeText = 'HIGH';
    symbol = '⚡';
  } else if (score >= 30 || status === 'MODERATE') {
    bgColor = '#78350f';
    borderColor = '#f59e0b';
    badgeText = 'MOD';
    symbol = '●';
  }

  const size = isSelected ? 48 : 40;

  return L.divIcon({
    className: 'custom-destination-marker',
    html: `
      <div style="
        background: ${bgColor};
        border: 2px solid ${isSelected ? '#ffffff' : borderColor};
        width: ${size}px;
        height: ${size}px;
        border-radius: 50%;
        display: flex;
        flex-direction: column;
        align-items: center;
        justify-content: center;
        box-shadow: 0 0 ${isSelected ? '16px #fff' : '10px ' + borderColor};
        color: #ffffff;
        font-family: sans-serif;
        cursor: pointer;
        transition: transform 0.2s ease;
      ">
        <div style="font-size: 8px; font-weight: 800; color: ${borderColor}; line-height: 1;">${symbol} ${badgeText}</div>
        <div style="font-size: 11px; font-weight: 900; line-height: 1.1;">${Math.round(score)}</div>
      </div>
    `,
    iconSize: [size, size],
    iconAnchor: [size / 2, size / 2]
  });
};

// Custom Report Icon
const createReportIcon = (severity: number, category: string) => {
  const color = severity >= 4 ? '#ef4444' : severity === 3 ? '#f97316' : '#f59e0b';
  let iconChar = '!';
  if (category === 'WATER') iconChar = '💧';
  else if (category === 'WASTE') iconChar = '🗑️';
  else if (category === 'ROAD' || category === 'TRAFFIC') iconChar = '🚗';
  else if (category === 'ENVIRONMENT') iconChar = '🌲';

  return L.divIcon({
    className: 'custom-report-pin',
    html: `
      <div style="
        background-color: ${color};
        width: 32px;
        height: 32px;
        border-radius: 50%;
        display: flex;
        align-items: center;
        justify-content: center;
        border: 2px solid #ffffff;
        box-shadow: 0 0 10px ${color};
        color: #ffffff;
        font-size: 13px;
        font-weight: bold;
      ">
        ${iconChar}
      </div>
    `,
    iconSize: [32, 32],
    iconAnchor: [16, 16]
  });
};

// Custom Provider Icon
const createProviderIcon = (category: string) => {
  let iconChar = '🏠';
  if (category === 'LOCAL_GUIDE') iconChar = '🧭';
  else if (category === 'LOCAL_FOOD') iconChar = '🍲';
  else if (category === 'HANDICRAFTS') iconChar = '🧶';
  else if (category === 'RENTAL') iconChar = '🚲';

  return L.divIcon({
    className: 'custom-provider-pin',
    html: `
      <div style="
        background-color: #10b981;
        width: 30px;
        height: 30px;
        border-radius: 50%;
        display: flex;
        align-items: center;
        justify-content: center;
        border: 2px solid #ffffff;
        box-shadow: 0 0 8px #10b981;
        color: #ffffff;
        font-size: 13px;
      ">
        ${iconChar}
      </div>
    `,
    iconSize: [30, 30],
    iconAnchor: [15, 15]
  });
};

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
  const [showDestinations, setShowDestinations] = useState(true);
  const [showReports, setShowReports] = useState(true);
  const [showProviders, setShowProviders] = useState(true);
  const [showLegend, setShowLegend] = useState(true);

  // Center on Uttarakhand
  const center: [number, number] = [30.1500, 78.8500];

  return (
    <div style={{ position: 'relative', width: '100%', height: '100%', minHeight: '520px', borderRadius: '16px', overflow: 'hidden' }}>
      {/* Map Filter Controls Overlay */}
      <div style={{
        position: 'absolute', top: '14px', right: '14px', zIndex: 1000,
        background: 'rgba(10, 20, 15, 0.92)', backdropFilter: 'blur(12px)',
        padding: '10px 16px', borderRadius: '12px', border: '1px solid var(--border-subtle)',
        display: 'flex', gap: '14px', alignItems: 'center', fontSize: '0.8rem', flexWrap: 'wrap'
      }}>
        <label style={{ display: 'flex', alignItems: 'center', gap: '6px', cursor: 'pointer', color: '#f8fafc' }}>
          <input
            type="checkbox"
            checked={showDestinations}
            onChange={(e) => setShowDestinations(e.target.checked)}
            style={{ accentColor: '#10b981' }}
          />
          <span style={{ color: '#10b981', fontWeight: 700 }}>●</span> Destinations ({destinations.length})
        </label>

        <label style={{ display: 'flex', alignItems: 'center', gap: '6px', cursor: 'pointer', color: '#f8fafc' }}>
          <input
            type="checkbox"
            checked={showReports}
            onChange={(e) => setShowReports(e.target.checked)}
            style={{ accentColor: '#ef4444' }}
          />
          <span style={{ color: '#ef4444', fontWeight: 700 }}>●</span> Active Reports ({reports.length})
        </label>

        <label style={{ display: 'flex', alignItems: 'center', gap: '6px', cursor: 'pointer', color: '#f8fafc' }}>
          <input
            type="checkbox"
            checked={showProviders}
            onChange={(e) => setShowProviders(e.target.checked)}
            style={{ accentColor: '#14b8a6' }}
          />
          <span style={{ color: '#14b8a6', fontWeight: 700 }}>●</span> Homestays ({providers.length})
        </label>
      </div>

      {/* Floating Legend Overlay */}
      {showLegend && (
        <div style={{
          position: 'absolute', bottom: '20px', left: '16px', zIndex: 1000,
          background: 'rgba(10, 20, 15, 0.92)', backdropFilter: 'blur(12px)',
          padding: '12px 14px', borderRadius: '12px', border: '1px solid var(--border-subtle)',
          fontSize: '0.75rem', maxWidth: '230px'
        }}>
          <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '6px' }}>
            <span style={{ color: '#94a3b8', fontWeight: 800, textTransform: 'uppercase', letterSpacing: '0.05em' }}>
              Pressure Tiers
            </span>
            <button
              onClick={() => setShowLegend(false)}
              style={{ background: 'none', border: 'none', color: '#64748b', cursor: 'pointer', fontSize: '10px' }}
            >
              ✕
            </button>
          </div>
          <div style={{ display: 'flex', flexDirection: 'column', gap: '4px' }}>
            <div style={{ display: 'flex', alignItems: 'center', gap: '6px', color: '#10b981' }}>
              <span>●</span> <strong>0-30 LOW</strong> (Eco-Optimal)
            </div>
            <div style={{ display: 'flex', alignItems: 'center', gap: '6px', color: '#f59e0b' }}>
              <span>●</span> <strong>31-50 MODERATE</strong> (Steady)
            </div>
            <div style={{ display: 'flex', alignItems: 'center', gap: '6px', color: '#f97316' }}>
              <span>●</span> <strong>51-70 HIGH</strong> (High Stress)
            </div>
            <div style={{ display: 'flex', alignItems: 'center', gap: '6px', color: '#ef4444' }}>
              <span>●</span> <strong>71-100 CRITICAL</strong> (Bottleneck)
            </div>
          </div>
        </div>
      )}

      <MapContainer
        center={center}
        zoom={8}
        scrollWheelZoom={true}
        style={{ width: '100%', height: '100%', minHeight: '520px' }}
      >
        <TileLayer
          attribution='&copy; <a href="https://www.openstreetmap.org/copyright">OpenStreetMap</a> contributors'
          url="https://{s}.basemaps.cartocdn.com/rastertiles/voyager/{z}/{x}/{y}{r}.png"
        />

        {/* 1. Destination Markers */}
        {showDestinations && destinations.map((dest) => {
          const isSelected = dest.id === selectedDestinationId;
          const capLimit = dest.capacityDailyTourists || dest.capacity || 10000;
          const loadRatio = Math.round(((dest.currentVisitorsEst || 0) / capLimit) * 100);

          return (
            <Marker
              key={dest.id}
              position={[dest.latitude, dest.longitude]}
              icon={createDestinationMarkerIcon(dest.pressureScore, dest.status, dest.name, isSelected)}
            >
              <Popup>
                <div style={{ minWidth: '240px', padding: '4px' }}>
                  <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '8px' }}>
                    <h3 style={{ fontSize: '1.05rem', color: '#fff', margin: 0 }}>{dest.name}</h3>
                    <span className={`badge badge-${dest.status.toLowerCase()}`}>
                      {dest.status} ({dest.pressureScore.toFixed(1)})
                    </span>
                  </div>
                  <p style={{ fontSize: '0.75rem', color: '#94a3b8', marginBottom: '10px' }}>
                    {dest.district} District • Alt: {dest.altitudeMeters}m
                  </p>

                  <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: '6px', fontSize: '0.75rem', background: 'rgba(0,0,0,0.25)', padding: '8px', borderRadius: '8px', marginBottom: '10px' }}>
                    <div>👥 Tourism: <strong>{dest.subScores?.tourism || dest.tourismScore}%</strong></div>
                    <div>💧 Water: <strong>{dest.subScores?.water || dest.waterScore}%</strong></div>
                    <div>🗑️ Waste: <strong>{dest.subScores?.waste || dest.wasteScore}%</strong></div>
                    <div>🚗 Traffic: <strong>{dest.subScores?.traffic || dest.trafficScore}%</strong></div>
                  </div>

                  <div style={{ fontSize: '0.75rem', color: '#cbd5e1', marginBottom: '10px' }}>
                    Carrying Capacity Load: <strong style={{ color: loadRatio > 100 ? '#ef4444' : '#10b981' }}>{loadRatio}%</strong> ({dest.currentVisitorsEst?.toLocaleString()} active / {capLimit.toLocaleString()} cap)
                  </div>

                  {onSelectDestination && (
                    <button
                      onClick={() => onSelectDestination(dest)}
                      style={{
                        width: '100%',
                        background: 'linear-gradient(135deg, #10b981 0%, #059669 100%)',
                        border: 'none',
                        borderRadius: '8px',
                        padding: '8px',
                        color: '#fff',
                        fontWeight: 700,
                        fontSize: '0.8rem',
                        cursor: 'pointer',
                        display: 'flex',
                        alignItems: 'center',
                        justifyContent: 'center',
                        gap: '6px'
                      }}
                    >
                      <Eye size={14} /> Inspect Telemetry & ML Forecast
                    </button>
                  )}
                </div>
              </Popup>
            </Marker>
          );
        })}

        {/* 2. Citizen Report Markers */}
        {showReports && reports.map((rep) => (
          <Marker
            key={rep.id}
            position={[rep.latitude, rep.longitude]}
            icon={createReportIcon(rep.aiSeverity, rep.aiCategory)}
          >
            <Popup>
              <div style={{ minWidth: '220px', padding: '2px' }}>
                <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '6px' }}>
                  <span style={{ fontSize: '0.75rem', color: '#ef4444', fontWeight: 800 }}>
                    ⚠️ {rep.aiCategory} INCIDENT
                  </span>
                  <span style={{ fontSize: '0.7rem', background: 'rgba(239,68,68,0.2)', color: '#ef4444', padding: '2px 6px', borderRadius: '4px', fontWeight: 700 }}>
                    Severity: {rep.aiSeverity}/5
                  </span>
                </div>
                <p style={{ fontSize: '0.8rem', color: '#fff', margin: '0 0 8px 0', lineHeight: '1.4' }}>
                  "{rep.description}"
                </p>
                <div style={{ fontSize: '0.7rem', color: '#94a3b8' }}>
                  Location: <strong>{rep.destinationName}</strong> • Status: <strong>{rep.status}</strong>
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
            icon={createProviderIcon(prov.category)}
          >
            <Popup>
              <div style={{ minWidth: '220px', padding: '2px' }}>
                <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '4px' }}>
                  <span style={{ fontSize: '0.7rem', color: '#10b981', fontWeight: 700, textTransform: 'uppercase' }}>
                    {prov.category.replace('_', ' ')}
                  </span>
                  {prov.verified && (
                    <span style={{ fontSize: '0.7rem', color: '#10b981' }}>✓ Verified</span>
                  )}
                </div>
                <h4 style={{ fontSize: '0.9rem', color: '#fff', margin: '0 0 4px 0' }}>{prov.name}</h4>
                <p style={{ fontSize: '0.75rem', color: '#cbd5e1', margin: '0 0 6px 0' }}>{prov.description}</p>
                <div style={{ fontSize: '0.75rem', color: '#10b981', fontWeight: 700 }}>
                  Starting at ₹{prov.priceStartingINR} /{prov.pricingUnit || 'night'}
                </div>
              </div>
            </Popup>
          </Marker>
        ))}
      </MapContainer>
    </div>
  );
};
