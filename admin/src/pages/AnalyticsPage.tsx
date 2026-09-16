import React from 'react';
import { AdminAnalytics } from '../types';
import { BarChart, Bar, XAxis, YAxis, Tooltip, ResponsiveContainer, CartesianGrid, PieChart, Pie, Cell } from 'recharts';
import { BarChart3, PieChart as PieIcon, ShieldAlert } from 'lucide-react';

interface AnalyticsPageProps {
  analytics: AdminAnalytics | null;
}

export const AnalyticsPage: React.FC<AnalyticsPageProps> = ({ analytics }) => {
  if (!analytics) {
    return (
      <div className="glass-panel" style={{ padding: '32px', textAlign: 'center', color: '#94a3b8' }}>
        Loading regional analytics data...
      </div>
    );
  }

  const districtData = analytics.districtSummaries || [];
  
  const categoryData = Object.entries(analytics.categoryDistribution || {}).map(([key, value]) => ({
    name: key,
    value: value
  }));

  const COLORS = ['#ef4444', '#f97316', '#f59e0b', '#10b981', '#06b6d4', '#8b5cf6', '#ec4899'];

  return (
    <div style={{ display: 'flex', flexDirection: 'column', gap: '20px' }}>
      {/* Header */}
      <div className="glass-panel" style={{ padding: '18px 24px' }}>
        <h2 style={{ fontSize: '1.25rem', color: '#fff', margin: '0 0 4px 0' }}>
          Regional Analytics & Carrying Capacity Intelligence
        </h2>
        <p style={{ fontSize: '0.8rem', color: '#94a3b8' }}>
          District-level aggregation, infrastructure pinch points, and civic issue distributions
        </p>
      </div>

      {/* Grid Charts */}
      <div style={{ display: 'grid', gridTemplateColumns: '1.4fr 1fr', gap: '20px' }}>
        {/* District Pressure Chart */}
        <div className="glass-panel" style={{ padding: '20px' }}>
          <h3 style={{ fontSize: '1rem', color: '#fff', marginBottom: '16px', display: 'flex', alignItems: 'center', gap: '8px' }}>
            <BarChart3 size={18} color="#10b981" /> District-Wise Mean Infrastructure Pressure Score
          </h3>
          <div style={{ height: '300px', width: '100%' }}>
            <ResponsiveContainer width="100%" height="100%">
              <BarChart data={districtData}>
                <CartesianGrid strokeDasharray="3 3" stroke="rgba(255,255,255,0.08)" />
                <XAxis dataKey="district" stroke="#94a3b8" fontSize={11} angle={-25} textAnchor="end" height={60} />
                <YAxis domain={[0, 100]} stroke="#94a3b8" fontSize={11} />
                <Tooltip contentStyle={{ background: '#12231b', borderColor: '#2d5a43', borderRadius: '8px', color: '#fff' }} />
                <Bar dataKey="avgPressure" fill="#10b981" radius={[6, 6, 0, 0]} name="Avg Pressure" />
              </BarChart>
            </ResponsiveContainer>
          </div>
        </div>

        {/* Category Distribution */}
        <div className="glass-panel" style={{ padding: '20px' }}>
          <h3 style={{ fontSize: '1rem', color: '#fff', marginBottom: '16px', display: 'flex', alignItems: 'center', gap: '8px' }}>
            <PieIcon size={18} color="#14b8a6" /> Incident Category Distribution
          </h3>
          <div style={{ height: '300px', width: '100%' }}>
            <ResponsiveContainer width="100%" height="100%">
              <PieChart>
                <Pie
                  data={categoryData}
                  cx="50%"
                  cy="50%"
                  innerRadius={60}
                  outerRadius={95}
                  paddingAngle={5}
                  dataKey="value"
                  label={({ name, percent }) => `${name} ${(percent * 100).toFixed(0)}%`}
                >
                  {categoryData.map((entry, index) => (
                    <Cell key={`cell-${index}`} fill={COLORS[index % COLORS.length]} />
                  ))}
                </Pie>
                <Tooltip contentStyle={{ background: '#12231b', borderColor: '#2d5a43', borderRadius: '8px', color: '#fff' }} />
              </PieChart>
            </ResponsiveContainer>
          </div>
        </div>
      </div>
    </div>
  );
};
