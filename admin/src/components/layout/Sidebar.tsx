import React from 'react';
import { 
  LayoutDashboard, Map, Compass, AlertTriangle, 
  Store, BarChart3, Sparkles, Sliders
} from 'lucide-react';

interface SidebarProps {
  currentTab: string;
  onTabChange: (tab: string) => void;
  openIssuesCount?: number;
}

export const Sidebar: React.FC<SidebarProps> = ({ currentTab, onTabChange, openIssuesCount = 0 }) => {
  const navItems = [
    { id: 'overview', label: 'Overview', icon: LayoutDashboard },
    { id: 'map', label: 'Regional Map & Heatmap', icon: Map },
    { id: 'destinations', label: 'Destinations & Capacity', icon: Compass },
    { id: 'reports', label: 'Citizen Reports (AI Triage)', icon: AlertTriangle, badge: openIssuesCount },
    { id: 'providers', label: 'Local Providers & Homestays', icon: Store },
    { id: 'analytics', label: 'Regional Analytics', icon: BarChart3 },
    { id: 'planner_demo', label: 'AI Trip Simulator (Judge Demo)', icon: Sparkles }
  ];

  return (
    <aside className="glass-panel" style={{ width: '260px', padding: '20px 12px', display: 'flex', flexDirection: 'column', gap: '8px', minHeight: 'calc(100vh - 120px)' }}>
      <div style={{ padding: '8px 12px', fontSize: '0.75rem', fontWeight: 700, color: '#64748b', textTransform: 'uppercase', letterSpacing: '0.08em' }}>
        Control Modules
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
              padding: '12px 16px',
              borderRadius: '12px',
              border: isActive ? '1px solid var(--border-active)' : '1px solid transparent',
              background: isActive ? 'linear-gradient(135deg, rgba(16, 185, 129, 0.2) 0%, rgba(6, 78, 59, 0.4) 100%)' : 'transparent',
              color: isActive ? '#10b981' : '#94a3b8',
              fontFamily: 'var(--font-heading)',
              fontWeight: isActive ? 600 : 500,
              fontSize: '0.9rem',
              cursor: 'pointer',
              textAlign: 'left',
              transition: 'all 0.2s ease',
              width: '100%'
            }}
          >
            <div style={{ display: 'flex', alignItems: 'center', gap: '12px' }}>
              <Icon size={18} color={isActive ? '#10b981' : '#94a3b8'} />
              <span>{item.label}</span>
            </div>
            {item.badge && item.badge > 0 ? (
              <span style={{ 
                background: '#ef4444', color: '#fff', fontSize: '0.7rem', 
                fontWeight: 700, padding: '2px 8px', borderRadius: '10px' 
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
