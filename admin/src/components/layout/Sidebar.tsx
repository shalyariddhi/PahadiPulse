import { 
  LayoutDashboard, Map, Flame, Compass, Activity, 
  Sparkles, AlertTriangle, Store, BarChart3, Settings, Plane, Bell
} from 'lucide-react';

interface SidebarProps {
  currentTab: string;
  onTabChange: (tab: string) => void;
  openIssuesCount?: number;
  unreadNotifsCount?: number;
}

export const Sidebar: React.FC<SidebarProps> = ({ currentTab, onTabChange, openIssuesCount = 0, unreadNotifsCount = 0 }) => {
  const navItems = [
    { id: 'overview', label: 'Overview Dashboard', icon: LayoutDashboard },
    { id: 'map', label: 'Regional Map', icon: Map },
    { id: 'heatmap', label: 'Pressure Heatmap', icon: Flame },
    { id: 'destinations', label: 'Destinations & Capacity', icon: Compass },
    { id: 'trends', label: 'Pressure Trends', icon: Activity },
    { id: 'predictions', label: 'Pressure Predictions', icon: Sparkles },
    { id: 'reports', label: 'Citizen Reports & Triage', icon: AlertTriangle, badge: openIssuesCount },
    { id: 'providers', label: 'Local Providers', icon: Store },
    { id: 'analytics', label: 'Regional Analytics', icon: BarChart3 },
    { id: 'settings', label: 'Settings & Weights', icon: Settings },
    { id: 'planner_demo', label: 'Itinerary Simulator', icon: Plane },
    { id: 'notifications', label: 'Tactical Alerts', icon: Bell, badge: unreadNotifsCount }
  ];

  return (
    <aside className="glass-panel" style={{ width: '270px', padding: '18px 12px', display: 'flex', flexDirection: 'column', gap: '6px', minHeight: 'calc(100vh - 120px)' }}>
      <div style={{ padding: '6px 12px 10px 12px', fontSize: '0.75rem', fontWeight: 700, color: '#64748b', textTransform: 'uppercase', letterSpacing: '0.08em' }}>
        Control Center
      </div>

      {navItems.map((item) => {
        const Icon = item.icon;
        const isActive = currentTab === item.id;
        return (
          <button
            key={item.id}
            onClick={() => onTabChange(item.id)}
            style={{
              display: 'flex',
              alignItems: 'center',
              justifyContent: 'space-between',
              padding: '10px 14px',
              borderRadius: '10px',
              border: isActive ? '1px solid var(--border-active)' : '1px solid transparent',
              background: isActive ? 'linear-gradient(135deg, rgba(16, 185, 129, 0.2) 0%, rgba(6, 78, 59, 0.4) 100%)' : 'transparent',
              color: isActive ? '#10b981' : '#94a3b8',
              fontFamily: 'var(--font-heading)',
              fontWeight: isActive ? 700 : 500,
              fontSize: '0.85rem',
              cursor: 'pointer',
              textAlign: 'left',
              transition: 'all 0.2s ease',
              width: '100%'
            }}
          >
            <div style={{ display: 'flex', alignItems: 'center', gap: '10px' }}>
              <Icon size={17} color={isActive ? '#10b981' : '#94a3b8'} />
              <span>{item.label}</span>
            </div>
            {item.badge && item.badge > 0 ? (
              <span style={{ 
                background: '#ef4444', color: '#fff', fontSize: '0.7rem', 
                fontWeight: 700, padding: '2px 7px', borderRadius: '10px' 
              }}>
                {item.badge}
              </span>
            ) : null}
          </button>
        );
      })}
    </aside>
  );
};
