import React from 'react';
import { Destination, Report, AdminAnalytics, LocalProvider } from '../types';
import { RegionalLeafletMap } from '../components/maps/RegionalLeafletMap';
import { 
  AlertTriangle, Compass, CheckCircle2, Store, 
  TrendingUp, Users, ArrowUpRight, ShieldCheck 
} from 'lucide-react';

interface DashboardProps {
  analytics: AdminAnalytics | null;
  destinations: Destination[];
  reports: Report[];
  providers: LocalProvider[];
  onSelectDestination: (dest: Destination) => void;
  onNavigateTab: (tab: string) => void;
}

export const DashboardOverview: React.FC<DashboardProps> = ({
  analytics,
  destinations,
  reports,
  providers,
  onSelectDestination,
  onNavigateTab
}) => {
  const criticalReports = reports.filter((r) => r.aiSeverity >= 4 && r.status !== 'RESOLVED');
  const highPressureDests = destinations.filter((d) => d.pressureScore >= 51);

  return (
    <div style={{ display: 'flex', flexDirection: 'column', gap: '20px' }}>
      {/* Top Stat Cards */}
      <div style={{ display: 'grid', gridTemplateColumns: 'repeat(auto-fit, minmax(220px, 1fr))', gap: '16px' }}>
        <div className="glass-panel glass-panel-hover" style={{ padding: '20px' }}>
          <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '8px' }}>
            <span style={{ fontSize: '0.85rem', color: '#94a3b8' }}>Total Destinations Monitored</span>
            <Compass size={20} color="#10b981" />
          </div>
          <div style={{ fontSize: '2rem', fontWeight: 800, color: '#fff' }}>
            {destinations.length}
          </div>
          <div style={{ fontSize: '0.75rem', color: '#10b981', marginTop: '4px' }}>
            Across 13 Uttarakhand Districts
          </div>
        </div>

        <div className="glass-panel glass-panel-hover" style={{ padding: '20px' }}>
          <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '8px' }}>
            <span style={{ fontSize: '0.85rem', color: '#94a3b8' }}>High / Critical Stress Hubs</span>
            <AlertTriangle size={20} color="#ef4444" />
          </div>
          <div style={{ fontSize: '2rem', fontWeight: 800, color: '#ef4444' }}>
            {highPressureDests.length}
          </div>
          <div style={{ fontSize: '0.75rem', color: '#f87171', marginTop: '4px' }}>
            Mussoorie, Nainital, Rishikesh
          </div>
        </div>

        <div className="glass-panel glass-panel-hover" style={{ padding: '20px' }}>
          <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '8px' }}>
            <span style={{ fontSize: '0.85rem', color: '#94a3b8' }}>Open Citizen Reports</span>
            <ShieldCheck size={20} color="#f59e0b" />
          </div>
          <div style={{ fontSize: '2rem', fontWeight: 800, color: '#f59e0b' }}>
            {reports.filter((r) => r.status !== 'RESOLVED').length}
          </div>
          <div style={{ fontSize: '0.75rem', color: '#fbbf24', marginTop: '4px' }}>
            {criticalReports.length} flagged critical severity
          </div>
        </div>

        <div className="glass-panel glass-panel-hover" style={{ padding: '20px' }}>
          <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '8px' }}>
            <span style={{ fontSize: '0.85rem', color: '#94a3b8' }}>Verified Local Providers</span>
            <Store size={20} color="#14b8a6" />
          </div>
          <div style={{ fontSize: '2rem', fontWeight: 800, color: '#14b8a6' }}>
            {providers.length}
          </div>
          <div style={{ fontSize: '0.75rem', color: '#5eead4', marginTop: '4px' }}>
            Homestays, Guides & Cooperatives
          </div>
        </div>
      </div>

      {/* Main Grid: Map & Live Incident Triage Feed */}
      <div style={{ display: 'grid', gridTemplateColumns: '2fr 1.2fr', gap: '20px' }}>
        {/* Map Box */}
        <div className="glass-panel" style={{ padding: '16px', display: 'flex', flexDirection: 'column' }}>
          <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '12px' }}>
            <div>
              <h3 style={{ fontSize: '1.1rem', color: '#fff', margin: 0 }}>Regional Pressure Map</h3>
              <p style={{ fontSize: '0.75rem', color: '#94a3b8' }}>Click any destination circle to inspect real-time metrics</p>
            </div>
            <button onClick={() => onNavigateTab('map')} className="btn-secondary" style={{ padding: '6px 12px', fontSize: '0.8rem' }}>
              Expand Map <ArrowUpRight size={14} />
            </button>
          </div>
          <div style={{ flex: 1, minHeight: '440px' }}>
            <RegionalLeafletMap
              destinations={destinations}
              reports={reports}
              providers={providers}
              onSelectDestination={onSelectDestination}
            />
          </div>
        </div>

        {/* Live Critical Incidents & High-Pressure alerts */}
        <div style={{ display: 'flex', flexDirection: 'column', gap: '16px' }}>
          {/* Critical Triage Widget */}
          <div className="glass-panel" style={{ padding: '20px', flex: 1 }}>
            <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '14px' }}>
              <h3 style={{ fontSize: '1rem', color: '#fff', display: 'flex', alignItems: 'center', gap: '8px' }}>
                <AlertTriangle size={18} color="#ef4444" /> Critical Citizen Incidents
              </h3>
              <button onClick={() => onNavigateTab('reports')} className="btn-secondary" style={{ padding: '4px 8px', fontSize: '0.75rem' }}>
                Triage All
              </button>
            </div>

            <div style={{ display: 'flex', flexDirection: 'column', gap: '10px' }}>
              {criticalReports.length === 0 ? (
                <div style={{ textAlign: 'center', padding: '24px', color: '#94a3b8', fontSize: '0.85rem' }}>
                  No active critical emergencies.
                </div>
              ) : (
                criticalReports.slice(0, 4).map((rep) => (
                  <div
                    key={rep.id}
                    onClick={() => onNavigateTab('reports')}
                    style={{
                      background: 'rgba(239, 68, 68, 0.08)',
                      border: '1px solid rgba(239, 68, 68, 0.25)',
                      borderRadius: '10px',
                      padding: '12px',
                      cursor: 'pointer',
                      transition: 'all 0.2s ease'
                    }}
                  >
                    <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '4px' }}>
                      <span style={{ fontSize: '0.75rem', fontWeight: 700, color: '#ef4444' }}>
                        ⚠️ {rep.aiCategory} • Severity {rep.aiSeverity}/5
                      </span>
                      <span style={{ fontSize: '0.7rem', color: '#94a3b8' }}>
                        {rep.destinationName}
                      </span>
                    </div>
                    <p style={{ fontSize: '0.8rem', color: '#e2e8f0', margin: 0, lineClamp: 2, overflow: 'hidden' }}>
                      {rep.description}
                    </p>
                  </div>
                ))
              )}
            </div>
          </div>

          {/* High Pressure Regional Alerts */}
          <div className="glass-panel" style={{ padding: '20px' }}>
            <h3 style={{ fontSize: '1rem', color: '#fff', marginBottom: '12px', display: 'flex', alignItems: 'center', gap: '8px' }}>
              <TrendingUp size={18} color="#f59e0b" /> Carrying Capacity Overload
            </h3>
            <div style={{ display: 'flex', flexDirection: 'column', gap: '8px' }}>
              {highPressureDests.slice(0, 3).map((d) => (
                <div
                  key={d.id}
                  onClick={() => onSelectDestination(d)}
                  style={{
                    display: 'flex', justifyContent: 'space-between', alignItems: 'center',
                    padding: '10px 14px', background: 'rgba(255,255,255,0.03)', borderRadius: '8px',
                    border: '1px solid var(--border-subtle)', cursor: 'pointer'
                  }}
                >
                  <div>
                    <div style={{ fontSize: '0.85rem', fontWeight: 600, color: '#fff' }}>{d.name}</div>
                    <div style={{ fontSize: '0.7rem', color: '#94a3b8' }}>{d.currentVisitorsEst?.toLocaleString()} current est.</div>
                  </div>
                  <span className={`badge badge-${d.status.toLowerCase()}`}>
                    {d.pressureScore.toFixed(1)}
                  </span>
                </div>
              ))}
            </div>
          </div>
        </div>
      </div>
    </div>
  );
};
