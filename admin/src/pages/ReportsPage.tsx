import React, { useState } from 'react';
import { Report, ReportStatus } from '../types';
import { TriageModal } from '../components/reports/TriageModal';
import { AlertTriangle, CheckCircle, Clock, ShieldAlert, Sparkles, Filter } from 'lucide-react';

interface ReportsPageProps {
  reports: Report[];
  onReportUpdated: (updated: Report) => void;
}

export const ReportsPage: React.FC<ReportsPageProps> = ({ reports, onReportUpdated }) => {
  const [selectedReport, setSelectedReport] = useState<Report | null>(null);
  const [statusFilter, setStatusFilter] = useState('ALL');
  const [categoryFilter, setCategoryFilter] = useState('ALL');

  const categories = ['ALL', 'WATER', 'WASTE', 'ROAD', 'TRAFFIC', 'HEALTH', 'CONNECTIVITY', 'TOURISM', 'ENVIRONMENT'];

  const filtered = reports.filter((r) => {
    const matchStatus = statusFilter === 'ALL' || r.status === statusFilter;
    const matchCat = categoryFilter === 'ALL' || r.aiCategory === categoryFilter || r.category === categoryFilter;
    return matchStatus && matchCat;
  });

  const getStatusBadge = (status: ReportStatus) => {
    switch (status) {
      case 'SUBMITTED':
        return <span style={{ background: 'rgba(148, 163, 184, 0.2)', color: '#94a3b8', padding: '3px 8px', borderRadius: '6px', fontSize: '0.75rem', fontWeight: 600 }}>SUBMITTED</span>;
      case 'AI_CLASSIFIED':
        return <span style={{ background: 'rgba(59, 130, 246, 0.2)', color: '#60a5fa', padding: '3px 8px', borderRadius: '6px', fontSize: '0.75rem', fontWeight: 600 }}>🤖 AI CLASSIFIED</span>;
      case 'VERIFIED':
        return <span style={{ background: 'rgba(245, 158, 11, 0.2)', color: '#fbbf24', padding: '3px 8px', borderRadius: '6px', fontSize: '0.75rem', fontWeight: 600 }}>VERIFIED</span>;
      case 'ASSIGNED':
        return <span style={{ background: 'rgba(168, 85, 247, 0.2)', color: '#c084fc', padding: '3px 8px', borderRadius: '6px', fontSize: '0.75rem', fontWeight: 600 }}>ASSIGNED</span>;
      case 'RESOLVED':
        return <span style={{ background: 'rgba(16, 185, 129, 0.2)', color: '#10b981', padding: '3px 8px', borderRadius: '6px', fontSize: '0.75rem', fontWeight: 600 }}>RESOLVED</span>;
    }
  };

  return (
    <div style={{ display: 'flex', flexDirection: 'column', gap: '16px' }}>
      {/* Header & Filter Bar */}
      <div className="glass-panel" style={{ padding: '18px 24px', display: 'flex', justifyContent: 'space-between', alignItems: 'center', flexWrap: 'wrap', gap: '16px' }}>
        <div>
          <h2 style={{ fontSize: '1.25rem', color: '#fff', margin: 0 }}>
            Citizen Infrastructure Reports & AI Triage
          </h2>
          <p style={{ fontSize: '0.8rem', color: '#94a3b8' }}>
            Multi-stage workflow: Submitted ➔ AI Classified ➔ Verified ➔ Assigned ➔ Resolved
          </p>
        </div>

        <div style={{ display: 'flex', gap: '12px' }}>
          <select
            value={statusFilter}
            onChange={(e) => setStatusFilter(e.target.value)}
            style={{
              background: 'rgba(0,0,0,0.3)', border: '1px solid var(--border-subtle)',
              borderRadius: '8px', padding: '8px 14px', color: '#fff', fontSize: '0.85rem'
            }}
          >
            <option value="ALL" style={{ background: '#12231b' }}>All Workflow Statuses</option>
            <option value="SUBMITTED" style={{ background: '#12231b' }}>Submitted</option>
            <option value="AI_CLASSIFIED" style={{ background: '#12231b' }}>AI Classified</option>
            <option value="VERIFIED" style={{ background: '#12231b' }}>Verified</option>
            <option value="ASSIGNED" style={{ background: '#12231b' }}>Assigned</option>
            <option value="RESOLVED" style={{ background: '#12231b' }}>Resolved</option>
          </select>

          <select
            value={categoryFilter}
            onChange={(e) => setCategoryFilter(e.target.value)}
            style={{
              background: 'rgba(0,0,0,0.3)', border: '1px solid var(--border-subtle)',
              borderRadius: '8px', padding: '8px 14px', color: '#fff', fontSize: '0.85rem'
            }}
          >
            {categories.map((cat) => (
              <option key={cat} value={cat} style={{ background: '#12231b' }}>
                {cat === 'ALL' ? 'All Categories' : cat}
              </option>
            ))}
          </select>
        </div>
      </div>

      {/* Reports Table / Card Feed */}
      <div style={{ display: 'flex', flexDirection: 'column', gap: '12px' }}>
        {filtered.map((rep) => (
          <div
            key={rep.id}
            className="glass-panel glass-panel-hover"
            style={{ padding: '18px 24px', display: 'flex', justifyContent: 'space-between', alignItems: 'center', gap: '16px' }}
          >
            <div style={{ flex: 1 }}>
              <div style={{ display: 'flex', alignItems: 'center', gap: '10px', marginBottom: '8px' }}>
                <span style={{ fontSize: '0.8rem', fontWeight: 700, color: '#ef4444' }}>
                  ⚠️ {rep.aiCategory}
                </span>
                <span style={{ fontSize: '0.75rem', background: rep.aiSeverity >= 4 ? 'rgba(239,68,68,0.2)' : 'rgba(245,158,11,0.2)', color: rep.aiSeverity >= 4 ? '#ef4444' : '#f59e0b', padding: '2px 8px', borderRadius: '12px', fontWeight: 600 }}>
                  Severity: {rep.aiSeverity}/5
                </span>
                {getStatusBadge(rep.status)}
                <span style={{ fontSize: '0.75rem', color: '#94a3b8' }}>
                  Location: <strong>{rep.destinationName}</strong>
                </span>
              </div>

              <p style={{ fontSize: '0.9rem', color: '#f8fafc', margin: '0 0 6px 0' }}>
                {rep.description}
              </p>

              <div style={{ display: 'flex', gap: '16px', fontSize: '0.75rem', color: '#94a3b8' }}>
                <span>Reported by: <strong style={{ color: '#cbd5e1' }}>{rep.userName}</strong></span>
                <span>AI Confidence: <strong style={{ color: '#10b981' }}>{(rep.aiConfidence * 100).toFixed(0)}%</strong></span>
                {rep.adminNotes && (
                  <span style={{ color: '#fbbf24' }}>Note: {rep.adminNotes}</span>
                )}
              </div>
            </div>

            <button
              onClick={() => setSelectedReport(rep)}
              className="btn-primary"
              style={{ padding: '8px 18px', fontSize: '0.85rem' }}
            >
              Triage & Action
            </button>
          </div>
        ))}
      </div>

      {selectedReport && (
        <TriageModal
          report={selectedReport}
          onClose={() => setSelectedReport(null)}
          onUpdated={(updated) => {
            onReportUpdated(updated);
            setSelectedReport(null);
          }}
        />
      )}
    </div>
  );
};
