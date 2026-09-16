import React, { useState } from 'react';
import { Report, ReportStatus } from '../../types';
import { updateReportStatus } from '../../services/api';
import { X, CheckCircle, ShieldAlert, AlertTriangle, ArrowRight } from 'lucide-react';

interface TriageModalProps {
  report: Report | null;
  onClose: () => void;
  onUpdated: (updated: Report) => void;
}

export const TriageModal: React.FC<TriageModalProps> = ({ report, onClose, onUpdated }) => {
  const [status, setStatus] = useState<ReportStatus>(report?.status || 'SUBMITTED');
  const [adminNotes, setAdminNotes] = useState(report?.adminNotes || '');
  const [saving, setSaving] = useState(false);

  if (!report) return null;

  const handleSave = async () => {
    setSaving(true);
    try {
      const res = await updateReportStatus(report.id, status, adminNotes);
      onUpdated(res);
      onClose();
    } catch (err) {
      console.error(err);
      alert('Failed to update report status');
    } finally {
      setSaving(false);
    }
  };

  const workflowSteps: ReportStatus[] = ['SUBMITTED', 'AI_CLASSIFIED', 'VERIFIED', 'ASSIGNED', 'RESOLVED'];

  return (
    <div style={{
      position: 'fixed', top: 0, left: 0, right: 0, bottom: 0,
      background: 'rgba(5, 10, 8, 0.85)', backdropFilter: 'blur(8px)',
      display: 'flex', alignItems: 'center', justifyContent: 'center',
      zIndex: 2000, padding: '20px'
    }}>
      <div className="glass-panel" style={{ width: '100%', maxWidth: '640px', padding: '28px', position: 'relative' }}>
        <button
          onClick={onClose}
          style={{ position: 'absolute', top: '20px', right: '20px', background: 'rgba(255,255,255,0.1)', border: 'none', color: '#fff', borderRadius: '50%', width: '32px', height: '32px', cursor: 'pointer', display: 'flex', alignItems: 'center', justifyContent: 'center' }}
        >
          <X size={18} />
        </button>

        <div style={{ display: 'flex', alignItems: 'center', gap: '10px', marginBottom: '14px' }}>
          <span style={{ fontSize: '0.75rem', background: 'rgba(239, 68, 68, 0.2)', color: '#ef4444', padding: '4px 10px', borderRadius: '8px', fontWeight: 700 }}>
            {report.aiCategory} REPORT
          </span>
          <span style={{ fontSize: '0.75rem', color: '#94a3b8' }}>ID: {report.id}</span>
        </div>

        <h3 style={{ fontSize: '1.2rem', color: '#fff', marginBottom: '8px' }}>
          {report.destinationName} • Infrastructure Incident
        </h3>
        
        <p style={{ fontSize: '0.9rem', color: '#cbd5e1', background: 'rgba(0,0,0,0.25)', padding: '12px', borderRadius: '8px', marginBottom: '16px' }}>
          "{report.description}"
        </p>

        {/* AI Insight Box */}
        <div style={{ background: 'rgba(16, 185, 129, 0.08)', border: '1px solid rgba(16, 185, 129, 0.3)', borderRadius: '10px', padding: '14px', marginBottom: '20px' }}>
          <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '6px' }}>
            <span style={{ fontSize: '0.8rem', fontWeight: 700, color: '#10b981' }}>🤖 AI Triage Inference</span>
            <span style={{ fontSize: '0.75rem', color: '#94a3b8' }}>Confidence: {(report.aiConfidence * 100).toFixed(0)}%</span>
          </div>
          <p style={{ fontSize: '0.85rem', color: '#e2e8f0', margin: '0 0 6px 0' }}>
            {report.aiExplanation}
          </p>
          <div style={{ fontSize: '0.8rem', color: '#f59e0b' }}>
            Estimated Severity: <strong>{report.aiSeverity} / 5</strong>
          </div>
        </div>

        {/* Workflow State Selector */}
        <div style={{ marginBottom: '16px' }}>
          <label style={{ display: 'block', fontSize: '0.8rem', color: '#94a3b8', marginBottom: '8px', fontWeight: 600 }}>
            INCIDENT RESOLUTION WORKFLOW
          </label>
          <div style={{ display: 'flex', gap: '8px', flexWrap: 'wrap' }}>
            {workflowSteps.map((step) => {
              const isSelected = status === step;
              return (
                <button
                  key={step}
                  onClick={() => setStatus(step)}
                  style={{
                    padding: '8px 14px', borderRadius: '8px',
                    border: isSelected ? '1px solid #10b981' : '1px solid var(--border-subtle)',
                    background: isSelected ? 'rgba(16, 185, 129, 0.25)' : 'rgba(255,255,255,0.04)',
                    color: isSelected ? '#10b981' : '#94a3b8',
                    fontSize: '0.8rem', fontWeight: isSelected ? 700 : 500, cursor: 'pointer'
                  }}
                >
                  {step}
                </button>
              );
            })}
          </div>
        </div>

        {/* Admin Notes */}
        <div style={{ marginBottom: '20px' }}>
          <label style={{ display: 'block', fontSize: '0.8rem', color: '#94a3b8', marginBottom: '6px', fontWeight: 600 }}>
            ADMINISTRATIVE DISPATCH & NOTES
          </label>
          <textarea
            value={adminNotes}
            onChange={(e) => setAdminNotes(e.target.value)}
            rows={3}
            style={{
              width: '100%', background: 'rgba(0,0,0,0.3)', border: '1px solid var(--border-subtle)',
              borderRadius: '8px', padding: '10px', color: '#fff', fontSize: '0.85rem', fontFamily: 'inherit'
            }}
            placeholder="e.g. Dispatched PWD road clearing bulldozer to Kempty bypass..."
          />
        </div>

        <div style={{ display: 'flex', justifyContent: 'flex-end', gap: '12px' }}>
          <button onClick={onClose} className="btn-secondary">
            Cancel
          </button>
          <button onClick={handleSave} disabled={saving} className="btn-primary">
            {saving ? 'Saving...' : 'Update Incident Status'}
          </button>
        </div>
      </div>
    </div>
  );
};
