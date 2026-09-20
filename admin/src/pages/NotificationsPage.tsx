import React, { useState, useEffect } from 'react';
import { 
  Bell, AlertTriangle, Flame, Sparkles, CheckCircle2, 
  RefreshCw, CheckCheck, Filter, ShieldAlert, ArrowRight, 
  MapPin, Send, MessageSquare, Info, AlertOctagon, Compass, Bookmark
} from 'lucide-react';
import { NotificationItem, NotificationType } from '../types';
import { getNotifications, getUnreadNotificationCount, markNotificationRead, markAllNotificationsRead, createNotification } from '../services/api';

interface NotificationsPageProps {
  onInspectDestination?: (id: string) => void;
  onInspectReport?: (id: string) => void;
}

export const NotificationsPage: React.FC<NotificationsPageProps> = ({ 
  onInspectDestination, 
  onInspectReport 
}) => {
  const [notifications, setNotifications] = useState<NotificationItem[]>([]);
  const [loading, setLoading] = useState(true);
  const [unreadCount, setUnreadCount] = useState(0);
  
  // Filters
  const [activeTab, setActiveTab] = useState<'ALL' | 'UNREAD' | 'CRITICAL_REPORT' | 'PRESSURE_SPIKE' | 'PREDICTION_WARNING' | 'TOURIST'>('ALL');
  const [roleFilter, setRoleFilter] = useState<'admin' | 'tourist' | 'ALL'>('admin');
  const [searchQuery, setSearchQuery] = useState('');

  // Create Custom Notification Modal / State
  const [showCreateModal, setShowCreateModal] = useState(false);
  const [newTitle, setNewTitle] = useState('');
  const [newMessage, setNewMessage] = useState('');
  const [newType, setNewType] = useState<NotificationType>('CRITICAL_REPORT');
  const [newRole, setNewRole] = useState<'admin' | 'tourist'>('admin');
  const [newEntityId, setNewEntityId] = useState('');
  const [isSubmitting, setIsSubmitting] = useState(false);

  const fetchNotifs = async () => {
    setLoading(true);
    try {
      const roleParam = roleFilter === 'ALL' ? undefined : roleFilter;
      const typeParam = (activeTab === 'ALL' || activeTab === 'UNREAD' || activeTab === 'TOURIST') ? undefined : activeTab;
      const unreadParam = activeTab === 'UNREAD';

      const [list, countData] = await Promise.all([
        getNotifications(roleParam, typeParam, unreadParam),
        getUnreadNotificationCount(roleParam)
      ]);

      setNotifications(list);
      setUnreadCount(countData.unreadCount);
    } catch (err) {
      console.error('Failed to load notifications:', err);
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    fetchNotifs();
  }, [activeTab, roleFilter]);

  const handleMarkRead = async (id: string, e?: React.MouseEvent) => {
    if (e) e.stopPropagation();
    try {
      await markNotificationRead(id);
      setNotifications(prev => prev.map(n => n.id === id ? { ...n, read: true } : n));
      setUnreadCount(prev => Math.max(0, prev - 1));
    } catch (err) {
      console.error('Failed to mark read:', err);
    }
  };

  const handleMarkAllRead = async () => {
    try {
      const roleParam = roleFilter === 'ALL' ? undefined : roleFilter;
      await markAllNotificationsRead(roleParam);
      setNotifications(prev => prev.map(n => ({ ...n, read: true })));
      setUnreadCount(0);
    } catch (err) {
      console.error('Failed to mark all read:', err);
    }
  };

  const handleCreateNotification = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!newTitle.trim() || !newMessage.trim()) return;

    setIsSubmitting(true);
    try {
      await createNotification({
        title: newTitle,
        message: newMessage,
        type: newType,
        targetRole: newRole,
        relatedEntityId: newEntityId.trim() || undefined,
        relatedEntityType: newEntityId ? 'entity' : undefined
      });
      setShowCreateModal(false);
      setNewTitle('');
      setNewMessage('');
      setNewEntityId('');
      await fetchNotifs();
    } catch (err) {
      console.error('Failed to create notification:', err);
    } finally {
      setIsSubmitting(false);
    }
  };

  // Filter list by client search
  const filteredNotifs = notifications.filter(n => {
    if (searchQuery.trim()) {
      const q = searchQuery.toLowerCase();
      const matchTitle = n.title.toLowerCase().includes(q);
      const matchMsg = n.message.toLowerCase().includes(q);
      const matchEntity = n.relatedEntityId?.toLowerCase().includes(q);
      if (!matchTitle && !matchMsg && !matchEntity) return false;
    }
    return true;
  });

  const getTypeMetadata = (type: NotificationType) => {
    switch (type) {
      case 'CRITICAL_REPORT':
        return {
          icon: ShieldAlert,
          color: '#ef4444',
          bg: 'rgba(239,68,68,0.12)',
          border: 'rgba(239,68,68,0.3)',
          label: 'CRITICAL REPORT'
        };
      case 'HIGH_SEVERITY_ISSUE':
        return {
          icon: AlertTriangle,
          color: '#f97316',
          bg: 'rgba(249,115,22,0.12)',
          border: 'rgba(249,115,22,0.3)',
          label: 'HIGH SEVERITY'
        };
      case 'PRESSURE_SPIKE':
      case 'HIGH_PRESSURE_ALERT':
        return {
          icon: Flame,
          color: '#f59e0b',
          bg: 'rgba(245,158,11,0.12)',
          border: 'rgba(245,158,11,0.3)',
          label: 'PRESSURE SURGE'
        };
      case 'PREDICTION_WARNING':
        return {
          icon: Sparkles,
          color: '#a855f7',
          bg: 'rgba(168,85,247,0.12)',
          border: 'rgba(168,85,247,0.3)',
          label: 'ML PREDICTION'
        };
      case 'ITINERARY_UPDATE':
        return {
          icon: Compass,
          color: '#06b6d4',
          bg: 'rgba(6,182,212,0.12)',
          border: 'rgba(6,182,212,0.3)',
          label: 'ITINERARY'
        };
      case 'SAVED_DESTINATION_ALERT':
        return {
          icon: Bookmark,
          color: '#10b981',
          bg: 'rgba(16,185,129,0.12)',
          border: 'rgba(16,185,129,0.3)',
          label: 'SAVED DEST'
        };
      default:
        return {
          icon: Info,
          color: '#94a3b8',
          bg: 'rgba(148,163,184,0.12)',
          border: 'rgba(148,163,184,0.3)',
          label: 'ADVISORY'
        };
    }
  };

  const formatRelativeTime = (iso: string) => {
    try {
      const d = new Date(iso);
      const diffSec = Math.floor((Date.now() - d.getTime()) / 1000);
      if (diffSec < 60) return 'Just now';
      if (diffSec < 3600) return `${Math.floor(diffSec / 60)} min ago`;
      if (diffSec < 86400) return `${Math.floor(diffSec / 3600)}h ago`;
      return d.toLocaleDateString('en-IN', { month: 'short', day: 'numeric', hour: '2-digit', minute: '2-digit' });
    } catch {
      return iso;
    }
  };

  return (
    <div style={{ display: 'flex', flexDirection: 'column', gap: '20px' }}>
      {/* Header Banner */}
      <div className="glass-panel" style={{ padding: '24px', display: 'flex', justifyContent: 'space-between', alignItems: 'center', flexWrap: 'wrap', gap: '16px' }}>
        <div style={{ display: 'flex', alignItems: 'center', gap: '16px' }}>
          <div style={{
            width: '52px', height: '52px', borderRadius: '14px',
            background: 'linear-gradient(135deg, rgba(239,68,68,0.2) 0%, rgba(245,158,11,0.2) 100%)',
            display: 'flex', alignItems: 'center', justifyContent: 'center',
            border: '1px solid rgba(239,68,68,0.3)',
            boxShadow: '0 4px 14px rgba(239,68,68,0.2)'
          }}>
            <Bell size={28} color="#f87171" />
          </div>
          <div>
            <div style={{ display: 'flex', alignItems: 'center', gap: '10px' }}>
              <h2 style={{ fontSize: '1.4rem', fontWeight: 800, color: '#fff', margin: 0 }}>
                Tactical Alerts & In-App Notifications
              </h2>
              {unreadCount > 0 && (
                <span style={{
                  background: '#ef4444', color: '#fff',
                  fontSize: '0.75rem', fontWeight: 700,
                  padding: '2px 8px', borderRadius: '12px'
                }}>
                  {unreadCount} Unread
                </span>
              )}
            </div>
            <p style={{ fontSize: '0.85rem', color: '#94a3b8', margin: '4px 0 0 0' }}>
              Real-time regional hazard notifications, pressure spikes, ML forecasting warnings, and tourist advisories.
            </p>
          </div>
        </div>

        <div style={{ display: 'flex', alignItems: 'center', gap: '10px', flexWrap: 'wrap' }}>
          <button
            onClick={() => setShowCreateModal(true)}
            style={{
              display: 'flex', alignItems: 'center', gap: '6px',
              padding: '8px 14px', borderRadius: '8px',
              background: 'rgba(16,185,129,0.15)', border: '1px solid rgba(16,185,129,0.4)',
              color: '#10b981', fontWeight: 600, fontSize: '0.85rem', cursor: 'pointer'
            }}
          >
            <Send size={15} /> Dispatch Alert
          </button>

          {unreadCount > 0 && (
            <button
              onClick={handleMarkAllRead}
              style={{
                display: 'flex', alignItems: 'center', gap: '6px',
                padding: '8px 14px', borderRadius: '8px',
                background: 'rgba(59,130,246,0.15)', border: '1px solid rgba(59,130,246,0.4)',
                color: '#60a5fa', fontWeight: 600, fontSize: '0.85rem', cursor: 'pointer'
              }}
            >
              <CheckCheck size={16} /> Mark All as Read
            </button>
          )}

          <button
            onClick={fetchNotifs}
            disabled={loading}
            style={{
              display: 'flex', alignItems: 'center', gap: '6px',
              padding: '8px 14px', borderRadius: '8px',
              background: 'rgba(255,255,255,0.06)', border: '1px solid var(--border-subtle)',
              color: '#94a3b8', fontWeight: 600, fontSize: '0.85rem', cursor: 'pointer'
            }}
          >
            <RefreshCw size={15} className={loading ? 'spin' : ''} /> Refresh
          </button>
        </div>
      </div>

      {/* Filter Tabs & Search */}
      <div className="glass-panel" style={{ padding: '16px 20px', display: 'flex', justifyContent: 'space-between', alignItems: 'center', flexWrap: 'wrap', gap: '12px' }}>
        <div style={{ display: 'flex', alignItems: 'center', gap: '8px', flexWrap: 'wrap' }}>
          {[
            { id: 'ALL', label: 'All Alerts' },
            { id: 'UNREAD', label: `Unread (${unreadCount})` },
            { id: 'CRITICAL_REPORT', label: 'Critical Reports' },
            { id: 'PRESSURE_SPIKE', label: 'Pressure Surges' },
            { id: 'PREDICTION_WARNING', label: 'ML Predictions' }
          ].map(tab => {
            const active = activeTab === tab.id;
            return (
              <button
                key={tab.id}
                onClick={() => setActiveTab(tab.id as any)}
                style={{
                  padding: '6px 14px', borderRadius: '8px',
                  border: active ? '1px solid #10b981' : '1px solid transparent',
                  background: active ? 'rgba(16,185,129,0.2)' : 'rgba(255,255,255,0.05)',
                  color: active ? '#10b981' : '#94a3b8',
                  fontWeight: active ? 700 : 500, fontSize: '0.82rem',
                  cursor: 'pointer', transition: 'all 0.2s'
                }}
              >
                {tab.label}
              </button>
            );
          })}
        </div>

        <div style={{ display: 'flex', alignItems: 'center', gap: '10px' }}>
          {/* Role selector */}
          <select
            value={roleFilter}
            onChange={(e) => setRoleFilter(e.target.value as any)}
            style={{
              padding: '6px 12px', borderRadius: '8px',
              background: 'rgba(15,23,42,0.8)', border: '1px solid var(--border-subtle)',
              color: '#fff', fontSize: '0.82rem'
            }}
          >
            <option value="admin">Admin Operations</option>
            <option value="tourist">Tourist Advisories</option>
            <option value="ALL">All Personas</option>
          </select>

          {/* Search box */}
          <input
            type="text"
            placeholder="Search alerts..."
            value={searchQuery}
            onChange={(e) => setSearchQuery(e.target.value)}
            style={{
              padding: '6px 12px', borderRadius: '8px',
              background: 'rgba(15,23,42,0.8)', border: '1px solid var(--border-subtle)',
              color: '#fff', fontSize: '0.82rem', width: '180px'
            }}
          />
        </div>
      </div>

      {/* Notifications List */}
      {loading ? (
        <div className="glass-panel" style={{ padding: '60px', textAlign: 'center', color: '#94a3b8' }}>
          <RefreshCw size={32} className="spin" style={{ margin: '0 auto 12px auto', display: 'block', color: '#10b981' }} />
          Loading in-app alert streams...
        </div>
      ) : filteredNotifs.length === 0 ? (
        <div className="glass-panel" style={{ padding: '60px 24px', textAlign: 'center' }}>
          <div style={{
            width: '56px', height: '56px', borderRadius: '50%',
            background: 'rgba(16,185,129,0.1)', border: '1px solid rgba(16,185,129,0.3)',
            display: 'flex', alignItems: 'center', justifyContent: 'center',
            margin: '0 auto 16px auto'
          }}>
            <CheckCircle2 size={30} color="#10b981" />
          </div>
          <h3 style={{ fontSize: '1.1rem', fontWeight: 700, color: '#fff', margin: 0 }}>
            No Notifications Found
          </h3>
          <p style={{ fontSize: '0.85rem', color: '#94a3b8', margin: '6px auto 0 auto', maxWidth: '420px' }}>
            {activeTab === 'UNREAD' 
              ? 'All in-app alerts have been read. Telemetry systems operating nominally.' 
              : 'Zero active notifications match your current filter parameters.'}
          </p>
        </div>
      ) : (
        <div style={{ display: 'flex', flexDirection: 'column', gap: '12px' }}>
          {filteredNotifs.map((item) => {
            const meta = getTypeMetadata(item.type);
            const Icon = meta.icon;

            return (
              <div
                key={item.id}
                className="glass-panel"
                style={{
                  padding: '16px 20px',
                  display: 'flex',
                  alignItems: 'flex-start',
                  gap: '16px',
                  borderRadius: '12px',
                  border: !item.read ? `1px solid ${meta.color}66` : '1px solid var(--border-subtle)',
                  background: !item.read ? 'rgba(30, 41, 59, 0.75)' : 'rgba(15, 23, 42, 0.6)',
                  position: 'relative',
                  transition: 'all 0.2s ease'
                }}
              >
                {/* Unread Accent Dot */}
                {!item.read && (
                  <div style={{
                    position: 'absolute', top: '16px', left: '8px',
                    width: '6px', height: '6px', borderRadius: '50%',
                    background: meta.color,
                    boxShadow: `0 0 8px ${meta.color}`
                  }} />
                )}

                {/* Type Icon Badge */}
                <div style={{
                  width: '44px', height: '44px', borderRadius: '12px',
                  background: meta.bg, border: `1px solid ${meta.border}`,
                  display: 'flex', alignItems: 'center', justifyContent: 'center',
                  flexShrink: 0, marginTop: '2px'
                }}>
                  <Icon size={22} color={meta.color} />
                </div>

                {/* Notification Content */}
                <div style={{ flex: 1, minWidth: 0 }}>
                  <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between', gap: '10px', flexWrap: 'wrap' }}>
                    <div style={{ display: 'flex', alignItems: 'center', gap: '8px', flexWrap: 'wrap' }}>
                      <span style={{
                        fontSize: '0.7rem', fontWeight: 700,
                        color: meta.color, background: meta.bg,
                        padding: '2px 8px', borderRadius: '4px',
                        border: `1px solid ${meta.border}`
                      }}>
                        {meta.label}
                      </span>
                      {item.targetRole && (
                        <span style={{
                          fontSize: '0.68rem', fontWeight: 600,
                          color: '#94a3b8', background: 'rgba(255,255,255,0.06)',
                          padding: '2px 6px', borderRadius: '4px'
                        }}>
                          {item.targetRole.toUpperCase()}
                        </span>
                      )}
                      <h4 style={{
                        fontSize: '0.95rem', fontWeight: 700,
                        color: !item.read ? '#fff' : '#cbd5e1',
                        margin: 0
                      }}>
                        {item.title}
                      </h4>
                    </div>

                    <div style={{ display: 'flex', alignItems: 'center', gap: '8px' }}>
                      <span style={{ fontSize: '0.75rem', color: '#64748b' }}>
                        {formatRelativeTime(item.createdAt)}
                      </span>
                      {!item.read && (
                        <button
                          onClick={(e) => handleMarkRead(item.id, e)}
                          title="Mark as Read"
                          style={{
                            padding: '3px 8px', borderRadius: '6px',
                            background: 'rgba(255,255,255,0.08)',
                            border: '1px solid var(--border-subtle)',
                            color: '#94a3b8', fontSize: '0.72rem',
                            cursor: 'pointer', display: 'flex', alignItems: 'center', gap: '4px'
                          }}
                        >
                          <CheckCircle2 size={12} color="#10b981" /> Read
                        </button>
                      )}
                    </div>
                  </div>

                  <p style={{
                    fontSize: '0.85rem', color: !item.read ? '#e2e8f0' : '#94a3b8',
                    margin: '6px 0 10px 0', lineHeight: 1.5
                  }}>
                    {item.message}
                  </p>

                  {/* Metadata & Actions */}
                  <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between', flexWrap: 'wrap', gap: '8px' }}>
                    <div style={{ display: 'flex', alignItems: 'center', gap: '10px', flexWrap: 'wrap' }}>
                      {item.relatedEntityId && (
                        <span style={{
                          fontSize: '0.72rem', color: '#64748b',
                          background: 'rgba(0,0,0,0.3)', padding: '2px 6px', borderRadius: '4px'
                        }}>
                          Entity: <strong>{item.relatedEntityId}</strong>
                        </span>
                      )}
                      {item.metadata?.severity && (
                        <span style={{
                          fontSize: '0.72rem', color: '#ef4444',
                          background: 'rgba(239,68,68,0.1)', padding: '2px 6px', borderRadius: '4px'
                        }}>
                          Severity: {item.metadata.severity}
                        </span>
                      )}
                      {item.metadata?.pressureScore && (
                        <span style={{
                          fontSize: '0.72rem', color: '#f59e0b',
                          background: 'rgba(245,158,11,0.1)', padding: '2px 6px', borderRadius: '4px'
                        }}>
                          Pressure: {item.metadata.pressureScore}/100
                        </span>
                      )}
                    </div>

                    {/* Interactive Action Deep-Link */}
                    {item.relatedEntityId && (
                      <div style={{ display: 'flex', alignItems: 'center', gap: '8px' }}>
                        {item.type === 'CRITICAL_REPORT' || item.type === 'HIGH_SEVERITY_ISSUE' ? (
                          <button
                            onClick={() => onInspectReport && onInspectReport(item.relatedEntityId!)}
                            style={{
                              display: 'flex', alignItems: 'center', gap: '4px',
                              padding: '4px 10px', borderRadius: '6px',
                              background: 'rgba(239,68,68,0.15)', border: '1px solid rgba(239,68,68,0.3)',
                              color: '#f87171', fontSize: '0.75rem', fontWeight: 600, cursor: 'pointer'
                            }}
                          >
                            Inspect Report <ArrowRight size={13} />
                          </button>
                        ) : (
                          <button
                            onClick={() => onInspectDestination && onInspectDestination(item.relatedEntityId!)}
                            style={{
                              display: 'flex', alignItems: 'center', gap: '4px',
                              padding: '4px 10px', borderRadius: '6px',
                              background: 'rgba(16,185,129,0.15)', border: '1px solid rgba(16,185,129,0.3)',
                              color: '#10b981', fontSize: '0.75rem', fontWeight: 600, cursor: 'pointer'
                            }}
                          >
                            View Telemetry <ArrowRight size={13} />
                          </button>
                        )}
                      </div>
                    )}
                  </div>
                </div>
              </div>
            );
          })}
        </div>
      )}

      {/* Create Alert Modal */}
      {showCreateModal && (
        <div style={{
          position: 'fixed', inset: 0,
          background: 'rgba(0,0,0,0.7)', backdropFilter: 'blur(6px)',
          display: 'flex', alignItems: 'center', justifyContent: 'center',
          zIndex: 9999, padding: '20px'
        }}>
          <div className="glass-panel" style={{ width: '100%', maxWidth: '520px', padding: '24px', borderRadius: '16px' }}>
            <h3 style={{ fontSize: '1.2rem', fontWeight: 700, color: '#fff', margin: '0 0 16px 0', display: 'flex', alignItems: 'center', gap: '8px' }}>
              <Send size={20} color="#10b981" /> Dispatch In-App Notification
            </h3>

            <form onSubmit={handleCreateNotification} style={{ display: 'flex', flexDirection: 'column', gap: '14px' }}>
              <div>
                <label style={{ fontSize: '0.8rem', color: '#94a3b8', display: 'block', marginBottom: '4px' }}>Alert Title</label>
                <input
                  type="text"
                  required
                  placeholder="e.g. Flash Flood Alert in Alaknanda Valley"
                  value={newTitle}
                  onChange={(e) => setNewTitle(e.target.value)}
                  style={{ width: '100%', padding: '8px 12px', borderRadius: '8px', background: 'rgba(15,23,42,0.8)', border: '1px solid var(--border-subtle)', color: '#fff' }}
                />
              </div>

              <div>
                <label style={{ fontSize: '0.8rem', color: '#94a3b8', display: 'block', marginBottom: '4px' }}>Alert Message</label>
                <textarea
                  required
                  rows={3}
                  placeholder="Detailed situational description and recommended actions..."
                  value={newMessage}
                  onChange={(e) => setNewMessage(e.target.value)}
                  style={{ width: '100%', padding: '8px 12px', borderRadius: '8px', background: 'rgba(15,23,42,0.8)', border: '1px solid var(--border-subtle)', color: '#fff', resize: 'none' }}
                />
              </div>

              <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: '12px' }}>
                <div>
                  <label style={{ fontSize: '0.8rem', color: '#94a3b8', display: 'block', marginBottom: '4px' }}>Alert Type</label>
                  <select
                    value={newType}
                    onChange={(e) => setNewType(e.target.value as any)}
                    style={{ width: '100%', padding: '8px 12px', borderRadius: '8px', background: 'rgba(15,23,42,0.8)', border: '1px solid var(--border-subtle)', color: '#fff' }}
                  >
                    <option value="CRITICAL_REPORT">Critical Hazard Report</option>
                    <option value="HIGH_SEVERITY_ISSUE">High Severity Issue</option>
                    <option value="PRESSURE_SPIKE">Pressure Surge</option>
                    <option value="PREDICTION_WARNING">ML Prediction Warning</option>
                    <option value="HIGH_PRESSURE_ALERT">Tourist High Pressure Alert</option>
                    <option value="ITINERARY_UPDATE">Itinerary Update</option>
                    <option value="SAVED_DESTINATION_ALERT">Saved Destination Alert</option>
                    <option value="GENERAL_ANNOUNCEMENT">General Announcement</option>
                  </select>
                </div>

                <div>
                  <label style={{ fontSize: '0.8rem', color: '#94a3b8', display: 'block', marginBottom: '4px' }}>Target Audience</label>
                  <select
                    value={newRole}
                    onChange={(e) => setNewRole(e.target.value as any)}
                    style={{ width: '100%', padding: '8px 12px', borderRadius: '8px', background: 'rgba(15,23,42,0.8)', border: '1px solid var(--border-subtle)', color: '#fff' }}
                  >
                    <option value="admin">Admin Operations</option>
                    <option value="tourist">Tourist App</option>
                  </select>
                </div>
              </div>

              <div>
                <label style={{ fontSize: '0.8rem', color: '#94a3b8', display: 'block', marginBottom: '4px' }}>Related Entity ID (Optional)</label>
                <input
                  type="text"
                  placeholder="e.g. mussoorie, rep_123, chopta"
                  value={newEntityId}
                  onChange={(e) => setNewEntityId(e.target.value)}
                  style={{ width: '100%', padding: '8px 12px', borderRadius: '8px', background: 'rgba(15,23,42,0.8)', border: '1px solid var(--border-subtle)', color: '#fff' }}
                />
              </div>

              <div style={{ display: 'flex', justifyContent: 'flex-end', gap: '10px', marginTop: '10px' }}>
                <button
                  type="button"
                  onClick={() => setShowCreateModal(false)}
                  style={{ padding: '8px 16px', borderRadius: '8px', background: 'rgba(255,255,255,0.08)', border: '1px solid var(--border-subtle)', color: '#94a3b8', cursor: 'pointer' }}
                >
                  Cancel
                </button>
                <button
                  type="submit"
                  disabled={isSubmitting}
                  style={{ padding: '8px 18px', borderRadius: '8px', background: '#10b981', border: 'none', color: '#0f172a', fontWeight: 700, cursor: 'pointer' }}
                >
                  {isSubmitting ? 'Dispatching...' : 'Dispatch Alert'}
                </button>
              </div>
            </form>
          </div>
        </div>
      )}
    </div>
  );
};
