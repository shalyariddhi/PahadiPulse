import React, { useState, useEffect, useRef } from 'react';
import { 
  Mountain, ShieldCheck, Activity, Flame, LogOut, 
  Bell, Check, ArrowRight, ShieldAlert, Sparkles, CheckCheck
} from 'lucide-react';
import { useAuth } from '../../context/AuthContext';
import { isFirebaseConfigured } from '../../services/firebase';
import { getNotifications, getUnreadNotificationCount, markNotificationRead, markAllNotificationsRead } from '../../services/api';
import { NotificationItem } from '../../types';

interface NavbarProps {
  activeTab: string;
  onNavigateTab?: (tab: string) => void;
}

export const Navbar: React.FC<NavbarProps> = ({ activeTab, onNavigateTab }) => {
  const { profile, role, logout } = useAuth();
  const [unreadCount, setUnreadCount] = useState(0);
  const [recentNotifs, setRecentNotifs] = useState<NotificationItem[]>([]);
  const [dropdownOpen, setDropdownOpen] = useState(false);
  const dropdownRef = useRef<HTMLDivElement>(null);

  const fetchNotificationState = async () => {
    try {
      const [countData, list] = await Promise.all([
        getUnreadNotificationCount('admin'),
        getNotifications('admin', undefined, false, 5)
      ]);
      setUnreadCount(countData.unreadCount);
      setRecentNotifs(list);
    } catch (err) {
      // Non-blocking
    }
  };

  useEffect(() => {
    fetchNotificationState();
    const interval = setInterval(fetchNotificationState, 15000); // 15s poll
    return () => clearInterval(interval);
  }, []);

  // Close dropdown on click outside
  useEffect(() => {
    const handleClickOutside = (event: MouseEvent) => {
      if (dropdownRef.current && !dropdownRef.current.contains(event.target as Node)) {
        setDropdownOpen(false);
      }
    };
    document.addEventListener('mousedown', handleClickOutside);
    return () => document.removeEventListener('mousedown', handleClickOutside);
  }, []);

  const handleQuickRead = async (id: string, e: React.MouseEvent) => {
    e.stopPropagation();
    try {
      await markNotificationRead(id);
      setRecentNotifs(prev => prev.map(n => n.id === id ? { ...n, read: true } : n));
      setUnreadCount(prev => Math.max(0, prev - 1));
    } catch (err) {
      console.error(err);
    }
  };

  const handleMarkAll = async () => {
    try {
      await markAllNotificationsRead('admin');
      setRecentNotifs(prev => prev.map(n => ({ ...n, read: true })));
      setUnreadCount(0);
    } catch (err) {
      console.error(err);
    }
  };

  return (
    <header className="glass-panel" style={{ margin: '16px 24px 0 24px', padding: '14px 24px', display: 'flex', justifyContent: 'space-between', alignItems: 'center', flexWrap: 'wrap', gap: '12px' }}>
      <div style={{ display: 'flex', alignItems: 'center', gap: '14px' }}>
        <div style={{ 
          width: '42px', height: '42px', borderRadius: '12px', 
          background: 'linear-gradient(135deg, #10b981 0%, #064e3b 100%)',
          display: 'flex', alignItems: 'center', justifyContent: 'center',
          boxShadow: '0 4px 12px rgba(16, 185, 129, 0.4)'
        }}>
          <Mountain size={24} color="#fff" />
        </div>
        <div>
          <h1 style={{ fontSize: '1.25rem', fontWeight: 700, color: '#fff', display: 'flex', alignItems: 'center', gap: '8px', margin: 0 }}>
            PahadiPulse <span style={{ fontSize: '0.75rem', fontWeight: 600, color: '#10b981', background: 'rgba(16,185,129,0.15)', padding: '2px 8px', borderRadius: '12px', border: '1px solid rgba(16,185,129,0.3)' }}>ADMIN v1.0</span>
          </h1>
          <p style={{ fontSize: '0.8rem', color: '#94a3b8', margin: '2px 0 0 0' }}>
            Regional Tourism Intelligence & Sustainable Carrying Capacity Portal | Uttarakhand
          </p>
        </div>
      </div>

      <div style={{ display: 'flex', alignItems: 'center', gap: '12px', flexWrap: 'wrap' }}>
        {/* Firebase Connection Badge */}
        <div style={{ display: 'flex', alignItems: 'center', gap: '6px', padding: '6px 12px', background: 'rgba(245,158,11,0.12)', borderRadius: '20px', border: '1px solid rgba(245,158,11,0.3)' }}>
          <Flame size={15} color="#f59e0b" />
          <span style={{ fontSize: '0.8rem', color: '#fbbf24' }}>
            Firebase: <strong>{isFirebaseConfigured() ? 'Cloud Live' : 'Active (Demo)'}</strong>
          </span>
        </div>

        {/* ML Engine Badge */}
        <div style={{ display: 'flex', alignItems: 'center', gap: '6px', padding: '6px 12px', background: 'rgba(16,185,129,0.12)', borderRadius: '20px', border: '1px solid rgba(16,185,129,0.3)' }}>
          <Activity size={15} color="#10b981" />
          <span style={{ fontSize: '0.8rem', color: '#6ee7b7' }}>ML Engine: <strong>Active (RandomForest)</strong></span>
        </div>

        {/* Notification Bell with Badge & Dropdown */}
        <div style={{ position: 'relative' }} ref={dropdownRef}>
          <button
            onClick={() => setDropdownOpen(prev => !prev)}
            title="Tactical Alerts"
            style={{
              display: 'flex', alignItems: 'center', justifyContent: 'center',
              width: '38px', height: '38px', borderRadius: '50%',
              background: unreadCount > 0 ? 'rgba(239,68,68,0.15)' : 'rgba(255,255,255,0.06)',
              border: unreadCount > 0 ? '1px solid rgba(239,68,68,0.4)' : '1px solid var(--border-subtle)',
              color: unreadCount > 0 ? '#f87171' : '#94a3b8',
              cursor: 'pointer', position: 'relative', transition: 'all 0.2s'
            }}
          >
            <Bell size={18} />
            {unreadCount > 0 && (
              <span style={{
                position: 'absolute', top: '-2px', right: '-2px',
                background: '#ef4444', color: '#fff',
                fontSize: '0.65rem', fontWeight: 800,
                width: '18px', height: '18px', borderRadius: '50%',
                display: 'flex', alignItems: 'center', justifyContent: 'center',
                boxShadow: '0 0 8px rgba(239,68,68,0.8)'
              }}>
                {unreadCount > 9 ? '9+' : unreadCount}
              </span>
            )}
          </button>

          {/* Quick Dropdown Panel */}
          {dropdownOpen && (
            <div style={{
              position: 'absolute', top: '48px', right: 0,
              width: '360px', borderRadius: '14px',
              background: 'rgba(15, 23, 42, 0.95)',
              backdropFilter: 'blur(16px)',
              border: '1px solid var(--border-active)',
              boxShadow: '0 12px 32px rgba(0,0,0,0.5)',
              zIndex: 9999, overflow: 'hidden'
            }}>
              <div style={{ padding: '12px 16px', borderBottom: '1px solid var(--border-subtle)', display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
                <div style={{ display: 'flex', alignItems: 'center', gap: '8px' }}>
                  <Bell size={16} color="#10b981" />
                  <span style={{ fontSize: '0.85rem', fontWeight: 700, color: '#fff' }}>Tactical Alerts</span>
                  {unreadCount > 0 && (
                    <span style={{ background: 'rgba(239,68,68,0.2)', color: '#f87171', fontSize: '0.7rem', padding: '1px 6px', borderRadius: '8px', fontWeight: 700 }}>
                      {unreadCount} new
                    </span>
                  )}
                </div>
                {unreadCount > 0 && (
                  <button
                    onClick={handleMarkAll}
                    style={{ background: 'none', border: 'none', color: '#60a5fa', fontSize: '0.72rem', cursor: 'pointer', display: 'flex', alignItems: 'center', gap: '4px' }}
                  >
                    <CheckCheck size={13} /> Mark all read
                  </button>
                )}
              </div>

              <div style={{ maxHeight: '280px', overflowY: 'auto' }}>
                {recentNotifs.length === 0 ? (
                  <div style={{ padding: '24px', textAlign: 'center', color: '#64748b', fontSize: '0.8rem' }}>
                    No alerts in queue
                  </div>
                ) : (
                  recentNotifs.map(item => (
                    <div
                      key={item.id}
                      onClick={() => {
                        setDropdownOpen(false);
                        if (onNavigateTab) onNavigateTab('notifications');
                      }}
                      style={{
                        padding: '10px 14px',
                        borderBottom: '1px solid rgba(255,255,255,0.04)',
                        background: !item.read ? 'rgba(30, 41, 59, 0.5)' : 'transparent',
                        display: 'flex', alignItems: 'flex-start', gap: '10px',
                        cursor: 'pointer', transition: 'background 0.2s'
                      }}
                    >
                      <div style={{
                        width: '8px', height: '8px', borderRadius: '50%',
                        background: !item.read ? '#ef4444' : 'transparent',
                        marginTop: '6px', flexShrink: 0
                      }} />
                      <div style={{ flex: 1, minWidth: 0 }}>
                        <h5 style={{ fontSize: '0.82rem', fontWeight: !item.read ? 700 : 500, color: !item.read ? '#fff' : '#94a3b8', margin: 0, whiteSpace: 'nowrap', overflow: 'hidden', textOverflow: 'ellipsis' }}>
                          {item.title}
                        </h5>
                        <p style={{ fontSize: '0.75rem', color: '#64748b', margin: '2px 0 0 0', display: '-webkit-box', WebkitLineClamp: 2, WebkitBoxOrient: 'vertical', overflow: 'hidden', lineHeight: 1.3 }}>
                          {item.message}
                        </p>
                      </div>
                      {!item.read && (
                        <button
                          onClick={(e) => handleQuickRead(item.id, e)}
                          title="Mark Read"
                          style={{
                            background: 'rgba(255,255,255,0.08)', border: 'none',
                            borderRadius: '4px', padding: '3px 6px',
                            color: '#10b981', cursor: 'pointer', fontSize: '0.7rem'
                          }}
                        >
                          <Check size={12} />
                        </button>
                      )}
                    </div>
                  ))
                )}
              </div>

              <div
                onClick={() => {
                  setDropdownOpen(false);
                  if (onNavigateTab) onNavigateTab('notifications');
                }}
                style={{
                  padding: '10px 14px', textAlign: 'center',
                  background: 'rgba(16, 185, 129, 0.1)',
                  color: '#10b981', fontSize: '0.8rem', fontWeight: 600,
                  cursor: 'pointer', display: 'flex', alignItems: 'center', justifyContent: 'center', gap: '6px'
                }}
              >
                View Full Alert Hub <ArrowRight size={14} />
              </div>
            </div>
          )}
        </div>

        {/* Officer Profile Badge */}
        <div
          onClick={() => onNavigateTab && onNavigateTab('settings')}
          style={{
            display: 'flex', alignItems: 'center', gap: '8px',
            padding: '6px 14px', background: 'rgba(255,255,255,0.06)',
            borderRadius: '20px', border: '1px solid var(--border-subtle)',
            color: '#fff', cursor: 'pointer', fontSize: '0.8rem', fontWeight: 600
          }}
        >
          <ShieldCheck size={16} color="#10b981" />
          <span>{profile?.displayName || 'Officer'}</span>
          <span style={{ fontSize: '0.7rem', color: '#10b981', background: 'rgba(16,185,129,0.2)', padding: '1px 6px', borderRadius: '4px' }}>
            {role.toUpperCase()}
          </span>
        </div>

        {/* Logout Button */}
        <button
          onClick={logout}
          title="Sign Out"
          style={{
            display: 'flex', alignItems: 'center', justifyContent: 'center',
            width: '36px', height: '36px', background: 'rgba(239,68,68,0.15)',
            borderRadius: '50%', border: '1px solid rgba(239,68,68,0.3)',
            color: '#f87171', cursor: 'pointer', transition: 'all 0.2s ease'
          }}
        >
          <LogOut size={16} />
        </button>
      </div>
    </header>
  );
};

