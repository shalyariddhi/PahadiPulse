import React, { useState } from 'react';
import { Report, ReportStatus, ReportCategory, ReportSeverity } from '../../types';
import { reviewReportClassification, updateReportStatus } from '../../services/api';
import { X, CheckCircle, ShieldAlert, AlertTriangle, ArrowRight, Sparkles, Edit3, MapPin, User, Calendar, Image as ImageIcon, Send } from 'lucide-react';

interface ReportDetailModalProps {
  report: Report | null;
  onClose: () => void;
  onUpdated: (updated: Report) => void;
}

export const ReportDetailModal: React.FC<ReportDetailModalProps> = ({
  report,
  onClose,
  onUpdated
}) => {
  if (!report) return null;

  const [status, setStatus] = useState<ReportStatus>(report.status);
  const [category, setCategory] = useState<ReportCategory>(report.category || report.aiCategory || 'OTHER');
  const [severity, setSeverity] = useState<ReportSeverity>(
    report.severity || (report.aiSeverity >= 5 ? 'CRITICAL' : report.aiSeverity === 4 ? 'HIGH' : report.aiSeverity === 3 ? 'MEDIUM' : 'LOW')
  );
  const [adminNotes, setAdminNotes] = useState(report.adminNotes || '');
  const [saving, setSaving] = useState(false);
  const [actionSuccess, setActionSuccess] = useState('');

  const categories: ReportCategory[] = [
    'WATER', 'WASTE', 'ROAD', 'TRAFFIC', 'HEALTH',
    'CONNECTIVITY', 'TOURISM', 'ENVIRONMENT', 'OTHER'
  ];

  const severities: ReportSeverity[] = ['LOW', 'MEDIUM', 'HIGH', 'CRITICAL'];

  // Quick Action Buttons
  const handleQuickStatus = async (newStatus: ReportStatus) => {
    setSaving(true);
    setActionSuccess('');
    try {
      const res = await updateReportStatus(report.id, newStatus, adminNotes);
      setStatus(newStatus);
      onUpdated(res);
      setActionSuccess(`Status successfully progressed to ${newStatus}`);
    } catch (err: any) {
      alert('Failed to update status: ' + (err?.response?.data?.detail || err.message));
    } finally {
      setSaving(false);
    }
  };

  // Full Review & Classification Correction
  const handleSaveReview = async () => {
    setSaving(true);
    setActionSuccess('');
    try {
      const res = await reviewReportClassification(report.id, {
        category,
        severity,
        status,
        adminNotes
      });
      onUpdated(res);
      setActionSuccess('Review and AI correction saved successfully');
      setTimeout(onClose, 800);
    } catch (err: any) {
      alert('Failed to save review: ' + (err?.response?.data?.detail || err.message));
    } finally {
      setSaving(false);
    }
  };

  return (
    <div style={{
      position: 'fixed', top: 0, left: 0, right: 0, bottom: 0,
      background: 'rgba(5, 10, 8, 0.85)', backdropFilter: 'blur(8px)',
      display: 'flex', alignItems: 'center', justifyContent: 'center',
      zIndex: 2000, padding: '20px'
    }}>
      <div className="glass-panel" style={{
        width: '100%', maxWidth: '760px', maxHeight: '92vh',
        overflowY: 'auto', padding: '28px', position: 'relative'
      }}>
        {/* Close Button */}
        <button
          onClick={onClose}
          style={{
            position: 'absolute', top: '20px', right: '20px',
            background: 'rgba(255,255,255,0.1)', border: 'none', color: '#fff',
            borderRadius: '50%', width: '32px', height: '32px', cursor: 'pointer',
            display: 'flex', alignItems: 'center', justifyContent: 'center'
          }}
        >
          <X size={18} />
        </button>

        {/* Top Badges */}
        <div style={{ display: 'flex', alignItems: 'center', gap: '8px', flexWrap: 'wrap', marginBottom: '14px' }}>
          <span style={{ fontSize: '0.75rem', background: 'rgba(239, 68, 68, 0.2)', color: '#ef4444', padding: '4px 10px', borderRadius: '8px', fontWeight: 700 }}>
            ⚠️ {report.aiCategory} (AI Category)
          </span>
          <span style={{ fontSize: '0.75rem', background: 'rgba(245, 158, 11, 0.2)', color: '#fbbf24', padding: '4px 10px', borderRadius: '8px', fontWeight: 700 }}>
            Severity: {report.aiSeverity}/5 ({report.severity || severity})
          </span>
          <span className={`badge badge-${status === 'RESOLVED' ? 'low' : status === 'ASSIGNED' ? 'high' : 'moderate'}`}>
            Status: {status}
          </span>
          {report.adminReviewed && (
            <span style={{ fontSize: '0.75rem', background: 'rgba(16, 185, 129, 0.2)', color: '#10b981', padding: '4px 10px', borderRadius: '8px', fontWeight: 700 }}>
              ✓ Officer Reviewed
            </span>
          )}
          <span style={{ fontSize: '0.75rem', color: '#64748b' }}>ID: {report.id}</span>
        </div>

        <h2 style={{ fontSize: '1.3rem', color: '#fff', margin: '0 0 8px 0' }}>
          {report.destinationName} • Infrastructure Issue Triage
        </h2>

        {actionSuccess && (
          <div style={{ background: 'rgba(16, 185, 129, 0.15)', border: '1px solid rgba(16, 185, 129, 0.4)', borderRadius: '8px', padding: '10px', color: '#10b981', fontSize: '0.85rem', marginBottom: '14px' }}>
            ✓ {actionSuccess}
          </div>
        )}

        {/* Metadata Strip */}
        <div style={{ display: 'flex', gap: '16px', flexWrap: 'wrap', fontSize: '0.8rem', color: '#94a3b8', marginBottom: '16px', background: 'rgba(0,0,0,0.2)', padding: '10px 14px', borderRadius: '8px' }}>
          <span style={{ display: 'flex', alignItems: 'center', gap: '5px' }}>
            <User size={14} color="#10b981" /> Reported by: <strong style={{ color: '#fff' }}>{report.userName || 'Verified Citizen'}</strong>
          </span>
          <span style={{ display: 'flex', alignItems: 'center', gap: '5px' }}>
            <MapPin size={14} color="#10b981" /> Coordinates: <strong style={{ color: '#fff' }}>{report.latitude.toFixed(4)}, {report.longitude.toFixed(4)}</strong>
          </span>
          <span style={{ display: 'flex', alignItems: 'center', gap: '5px' }}>
            <Calendar size={14} color="#10b981" /> Time: <strong style={{ color: '#fff' }}>{report.createdAt ? new Date(report.createdAt).toLocaleString() : 'Recent'}</strong>
          </span>
        </div>

        {/* Citizen Description */}
        <div style={{ marginBottom: '16px' }}>
          <label style={{ display: 'block', fontSize: '0.75rem', color: '#94a3b8', marginBottom: '4px', fontWeight: 600 }}>
            CITIZEN REPORT DESCRIPTION
          </label>
          <div style={{ background: 'rgba(255,255,255,0.03)', border: '1px solid var(--border-subtle)', borderRadius: '8px', padding: '12px', color: '#e2e8f0', fontSize: '0.9rem', lineHeight: '1.5' }}>
            "{report.description}"
          </div>
        </div>

        {/* Photo Preview if attached */}
        {report.imageUrl && (
          <div style={{ marginBottom: '16px' }}>
            <label style={{ display: 'block', fontSize: '0.75rem', color: '#94a3b8', marginBottom: '4px', fontWeight: 600 }}>
              ATTACHED FIELD PHOTO
            </label>
            <div style={{ borderRadius: '10px', overflow: 'hidden', border: '1px solid var(--border-subtle)', maxHeight: '200px' }}>
              <img
                src={report.imageUrl}
                alt="Report attachment"
                style={{ width: '100%', height: '200px', objectFit: 'cover' }}
              />
            </div>
          </div>
        )}

        {/* AI Classification Breakdown Card */}
        <div style={{
          background: 'rgba(16, 185, 129, 0.08)',
          border: '1px solid rgba(16, 185, 129, 0.3)',
          borderRadius: '10px',
          padding: '14px',
          marginBottom: '18px'
        }}>
          <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '6px' }}>
            <span style={{ fontSize: '0.85rem', fontWeight: 700, color: '#10b981', display: 'flex', alignItems: 'center', gap: '6px' }}>
              <Sparkles size={16} /> AI Classification & Severity Reasoning
            </span>
            <span style={{ fontSize: '0.75rem', color: '#94a3b8' }}>
              Confidence: <strong>{(report.aiConfidence * 100).toFixed(0)}%</strong>
            </span>
          </div>
          <p style={{ fontSize: '0.85rem', color: '#e2e8f0', margin: '0 0 8px 0' }}>
            {report.aiExplanation}
          </p>
          <div style={{ fontSize: '0.75rem', color: '#64748b', fontStyle: 'italic' }}>
            ⚡ ML NLP model trained for Uttarakhand civic infra triage. Designated officers can review and override below.
          </div>
        </div>

        {/* Admin Quick Action Workflow Strip */}
        <div style={{ marginBottom: '18px' }}>
          <label style={{ display: 'block', fontSize: '0.75rem', color: '#94a3b8', marginBottom: '6px', fontWeight: 600 }}>
            DISPATCH WORKFLOW ACTIONS
          </label>
          <div style={{ display: 'flex', gap: '10px', flexWrap: 'wrap' }}>
            <button
              onClick={() => handleQuickStatus('VERIFIED')}
              disabled={saving || status === 'VERIFIED'}
              style={{
                padding: '8px 14px', borderRadius: '8px', border: '1px solid #f59e0b',
                background: status === 'VERIFIED' ? 'rgba(245, 158, 11, 0.3)' : 'rgba(245, 158, 11, 0.1)',
                color: '#fbbf24', fontSize: '0.8rem', fontWeight: 600, cursor: 'pointer',
                display: 'flex', alignItems: 'center', gap: '6px'
              }}
            >
              <CheckCircle size={14} /> 1. Verify Incident
            </button>

            <button
              onClick={() => handleQuickStatus('ASSIGNED')}
              disabled={saving || status === 'ASSIGNED'}
              style={{
                padding: '8px 14px', borderRadius: '8px', border: '1px solid #8b5cf6',
                background: status === 'ASSIGNED' ? 'rgba(139, 92, 246, 0.3)' : 'rgba(139, 92, 246, 0.1)',
                color: '#c084fc', fontSize: '0.8rem', fontWeight: 600, cursor: 'pointer',
                display: 'flex', alignItems: 'center', gap: '6px'
              }}
            >
              <Send size={14} /> 2. Assign to Department
            </button>

            <button
              onClick={() => handleQuickStatus('RESOLVED')}
              disabled={saving || status === 'RESOLVED'}
              style={{
                padding: '8px 14px', borderRadius: '8px', border: '1px solid #10b981',
                background: status === 'RESOLVED' ? 'rgba(16, 185, 129, 0.3)' : 'rgba(16, 185, 129, 0.1)',
                color: '#10b981', fontSize: '0.8rem', fontWeight: 600, cursor: 'pointer',
                display: 'flex', alignItems: 'center', gap: '6px'
              }}
            >
              <CheckCircle size={14} /> 3. Mark Resolved
            </button>
          </div>
        </div>

        {/* Admin Classification Override & Notes */}
        <div style={{ background: 'rgba(255,255,255,0.03)', border: '1px solid var(--border-subtle)', borderRadius: '10px', padding: '16px', marginBottom: '20px' }}>
          <div style={{ display: 'flex', alignItems: 'center', gap: '6px', marginBottom: '12px' }}>
            <Edit3 size={15} color="#fbbf24" />
            <span style={{ fontSize: '0.85rem', fontWeight: 700, color: '#fbbf24' }}>
              Override AI Classification & Severity
            </span>
          </div>

          <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: '14px', marginBottom: '14px' }}>
            <div>
              <label style={{ display: 'block', fontSize: '0.75rem', color: '#94a3b8', marginBottom: '4px', fontWeight: 600 }}>
                CORRECT CATEGORY
              </label>
              <select
                value={category}
                onChange={(e) => setCategory(e.target.value as ReportCategory)}
                style={{ width: '100%', background: 'rgba(0,0,0,0.3)', border: '1px solid var(--border-subtle)', borderRadius: '8px', padding: '8px 12px', color: '#fff', fontSize: '0.85rem' }}
              >
                {categories.map((c) => (
                  <option key={c} value={c} style={{ background: '#12231b' }}>{c}</option>
                ))}
              </select>
            </div>

            <div>
              <label style={{ display: 'block', fontSize: '0.75rem', color: '#94a3b8', marginBottom: '4px', fontWeight: 600 }}>
                CORRECT SEVERITY
              </label>
              <select
                value={severity}
                onChange={(e) => setSeverity(e.target.value as ReportSeverity)}
                style={{ width: '100%', background: 'rgba(0,0,0,0.3)', border: '1px solid var(--border-subtle)', borderRadius: '8px', padding: '8px 12px', color: '#fff', fontSize: '0.85rem' }}
              >
                {severities.map((s) => (
                  <option key={s} value={s} style={{ background: '#12231b' }}>{s}</option>
                ))}
              </select>
            </div>
          </div>

          <div>
            <label style={{ display: 'block', fontSize: '0.75rem', color: '#94a3b8', marginBottom: '4px', fontWeight: 600 }}>
              ADMIN DISPATCH DIRECTIVE & LOG NOTES
            </label>
            <textarea
              value={adminNotes}
              onChange={(e) => setAdminNotes(e.target.value)}
              rows={3}
              placeholder="e.g., Escalated to Municipal Board Nainital; clearing truck routed."
              style={{ width: '100%', background: 'rgba(0,0,0,0.3)', border: '1px solid var(--border-subtle)', borderRadius: '8px', padding: '10px', color: '#fff', fontSize: '0.85rem' }}
            />
          </div>
        </div>

        {/* Footer */}
        <div style={{ display: 'flex', justifyContent: 'flex-end', gap: '12px' }}>
          <button onClick={onClose} className="btn-secondary">
            Close
          </button>
          <button onClick={handleSaveReview} disabled={saving} className="btn-primary">
            {saving ? 'Saving...' : 'Save AI Override & Update'}
          </button>
        </div>
      </div>
    </div>
  );
};
