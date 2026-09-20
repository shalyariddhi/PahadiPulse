import React, { useState, useEffect } from 'react';
import { AdminAnalytics, Destination } from '../types';
import { getAdminAnalytics } from '../services/api';
import { 
  BarChart, Bar, XAxis, YAxis, Tooltip, ResponsiveContainer, 
  CartesianGrid, PieChart, Pie, Cell, Legend, LineChart, Line, 
  AreaChart, Area, ScatterChart, Scatter, ZAxis, ComposedChart
} from 'recharts';
import { 
  BarChart3, PieChart as PieIcon, ShieldAlert, Activity, 
  TrendingUp, Calendar, Filter, Sparkles, Store, CheckCircle, 
  AlertTriangle, RefreshCw, Layers, Compass
} from 'lucide-react';

interface AnalyticsPageProps {
  analytics?: AdminAnalytics | null;
  destinations?: Destination[];
}

export const AnalyticsPage: React.FC<AnalyticsPageProps> = ({
  analytics: initialAnalytics,
  destinations = []
}) => {
  const [analyticsData, setAnalyticsData] = useState<AdminAnalytics | null>(initialAnalytics || null);
  const [loading, setLoading] = useState(false);

  // Filters
  const [days, setDays] = useState<number>(14);
  const [selectedDistrict, setSelectedDistrict] = useState<string>('ALL');
  const [selectedCategory, setSelectedCategory] = useState<string>('ALL');

  const districts = [
    'ALL', 'Dehradun', 'Tehri Garhwal', 'Nainital', 'Chamoli', 'Uttarkashi',
    'Rudraprayag', 'Pauri Garhwal', 'Almora', 'Pithoragarh',
    'Haridwar', 'Bageshwar', 'Champawat', 'Udham Singh Nagar'
  ];

  const categories = [
    'ALL', 'WATER', 'WASTE', 'ROAD', 'TRAFFIC', 'HEALTH',
    'CONNECTIVITY', 'TOURISM', 'ENVIRONMENT', 'OTHER'
  ];

  const fetchAnalytics = async () => {
    setLoading(true);
    try {
      const data = await getAdminAnalytics(days, selectedDistrict, selectedCategory);
      setAnalyticsData(data);
    } catch (err) {
      console.error('Failed to load analytics:', err);
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    fetchAnalytics();
  }, [days, selectedDistrict, selectedCategory]);

  const COLORS = ['#10b981', '#38bdf8', '#f59e0b', '#f97316', '#ef4444', '#8b5cf6', '#ec4899', '#14b8a6', '#64748b'];

  if (loading && !analyticsData) {
    return (
      <div className="glass-panel" style={{ padding: '48px', textAlign: 'center', color: '#94a3b8' }}>
        <RefreshCw size={28} className="spin" style={{ margin: '0 auto 12px auto', display: 'block' }} />
        Loading dynamic regional analytics from telemetry endpoints...
      </div>
    );
  }

  const data = analyticsData;
  if (!data) {
    return (
      <div className="glass-panel" style={{ padding: '48px', textAlign: 'center', color: '#94a3b8' }}>
        <AlertTriangle size={32} color="#f59e0b" style={{ margin: '0 auto 12px auto', display: 'block' }} />
        No telemetry records available for the selected filters.
      </div>
    );
  }

  // 1. Regional Pressure Trend
  const regionalTrendData = (data.regionalPressureTrend || []).map((pt) => ({
    date: pt.date.slice(5),
    avgPressure: pt.avgPressure,
    criticalCount: pt.criticalCount,
    highPressureCount: pt.highPressureCount
  }));

  // 2. Destination Pressure Comparison
  const destPressureData = (data.destinationPressureComparison || []).slice(0, 12).map((d) => ({
    name: d.name,
    pressure: d.pressureScore,
    status: d.status,
    load: d.loadPercentage
  }));

  // 3. Pressure Factor Comparison
  const factorData = (data.pressureFactorComparison || []).slice(0, 8).map((f) => ({
    name: f.name,
    Tourism: f.tourism,
    Water: f.water,
    Waste: f.waste,
    Traffic: f.traffic,
    Environment: f.environment
  }));

  // 4. Report Category Distribution
  const reportCategoryData = Object.entries(data.reportCategoryDistribution || data.categoryDistribution || {}).map(([key, val]) => ({
    name: key,
    value: val
  }));

  // 5. Report Severity Distribution
  const reportSeverityData = Object.entries(data.reportSeverityDistribution || {}).map(([key, val]) => ({
    name: key,
    value: val
  }));

  // 6. Report Resolution Status
  const reportStatusData = Object.entries(data.reportStatusDistribution || {}).map(([key, val]) => ({
    name: key.replace('_', ' '),
    value: val
  }));

  // 7. Provider Distribution
  const providerData = Object.entries(data.providerCategoryDistribution || {}).map(([key, val]) => ({
    name: key.replace('_', ' '),
    count: val
  }));

  // 8. Tourism-Pressure Trends
  const tourismPressureData = (data.tourismPressureTrends || []).map((d) => ({
    name: d.name,
    visitors: d.currentVisitors,
    capacity: d.capacity,
    loadPct: d.loadPercentage,
    pressure: d.pressureScore
  }));

  // 9. Prediction vs Current Pressure
  const predictionVsCurrentData = (data.predictionVsCurrent || []).map((p) => ({
    name: p.name,
    Current: p.currentPressure,
    Predicted: p.predictedPressure,
    Delta: p.delta,
    Risk: p.riskLevel
  }));

  return (
    <div style={{ display: 'flex', flexDirection: 'column', gap: '20px' }}>
      {/* Header & Interactive Filter Bar */}
      <div className="glass-panel" style={{ padding: '20px 24px', display: 'flex', justifyContent: 'space-between', alignItems: 'center', flexWrap: 'wrap', gap: '16px' }}>
        <div>
          <div style={{ display: 'flex', alignItems: 'center', gap: '10px', marginBottom: '4px' }}>
            <BarChart3 size={24} color="#10b981" />
            <h2 style={{ fontSize: '1.3rem', color: '#fff', margin: 0 }}>
              Regional Intelligence & Carrying Capacity Analytics
            </h2>
          </div>
          <p style={{ fontSize: '0.8rem', color: '#94a3b8', margin: 0 }}>
            Real-time multi-dimensional analytics derived directly from backend telemetry and sensor models
          </p>
        </div>

        {/* Filters */}
        <div style={{ display: 'flex', gap: '10px', flexWrap: 'wrap', alignItems: 'center' }}>
          {/* Date Horizon Filter */}
          <div style={{ display: 'flex', gap: '4px', background: 'rgba(0,0,0,0.3)', padding: '3px', borderRadius: '8px', border: '1px solid var(--border-subtle)' }}>
            {[7, 14, 30, 90].map((d) => (
              <button
                key={d}
                onClick={() => setDays(d)}
                style={{
                  padding: '5px 10px', borderRadius: '6px',
                  background: days === d ? 'rgba(16, 185, 129, 0.3)' : 'transparent',
                  color: days === d ? '#10b981' : '#94a3b8',
                  border: 'none', fontSize: '0.75rem', fontWeight: 600, cursor: 'pointer'
                }}
              >
                {d}D
              </button>
            ))}
          </div>

          {/* District Filter */}
          <select
            value={selectedDistrict}
            onChange={(e) => setSelectedDistrict(e.target.value)}
            style={{
              background: 'rgba(0,0,0,0.3)', border: '1px solid var(--border-subtle)',
              borderRadius: '8px', padding: '7px 12px', color: '#fff', fontSize: '0.8rem'
            }}
          >
            {districts.map((dist) => (
              <option key={dist} value={dist} style={{ background: '#12231b' }}>
                {dist === 'ALL' ? 'All Districts' : dist}
              </option>
            ))}
          </select>

          {/* Category Filter */}
          <select
            value={selectedCategory}
            onChange={(e) => setSelectedCategory(e.target.value)}
            style={{
              background: 'rgba(0,0,0,0.3)', border: '1px solid var(--border-subtle)',
              borderRadius: '8px', padding: '7px 12px', color: '#fff', fontSize: '0.8rem'
            }}
          >
            {categories.map((c) => (
              <option key={c} value={c} style={{ background: '#12231b' }}>
                {c === 'ALL' ? 'All Issue Categories' : c}
              </option>
            ))}
          </select>

          <button
            onClick={fetchAnalytics}
            title="Refresh Analytics"
            style={{
              padding: '7px 12px', background: 'rgba(16,185,129,0.15)',
              border: '1px solid rgba(16,185,129,0.3)', borderRadius: '8px',
              color: '#10b981', cursor: 'pointer', display: 'flex', alignItems: 'center', gap: '6px', fontSize: '0.8rem'
            }}
          >
            <RefreshCw size={14} className={loading ? 'spin' : ''} /> Refresh
          </button>
        </div>
      </div>

      {/* Analytics Grid: 9 Analytics Dimensions */}

      {/* Row 1: (1) Regional Pressure Trend & (2) Destination Pressure Comparison */}
      <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: '20px' }}>
        {/* Chart 1: Regional Pressure Trend */}
        <div className="glass-panel" style={{ padding: '20px' }}>
          <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '14px' }}>
            <h3 style={{ fontSize: '0.95rem', color: '#fff', margin: 0, display: 'flex', alignItems: 'center', gap: '8px' }}>
              <TrendingUp size={16} color="#10b981" /> 1. Regional Pressure Trend ({days}-Day Mean)
            </h3>
            <span style={{ fontSize: '0.75rem', color: '#94a3b8' }}>Uttarakhand Composite</span>
          </div>

          {regionalTrendData.length === 0 ? (
            <div style={{ padding: '36px', textAlign: 'center', color: '#64748b' }}>No trend records available.</div>
          ) : (
            <div style={{ height: '260px', width: '100%' }}>
              <ResponsiveContainer width="100%" height="100%">
                <AreaChart data={regionalTrendData}>
                  <defs>
                    <linearGradient id="regGrad" x1="0" y1="0" x2="0" y2="1">
                      <stop offset="5%" stopColor="#10b981" stopOpacity={0.6}/>
                      <stop offset="95%" stopColor="#10b981" stopOpacity={0.0}/>
                    </linearGradient>
                  </defs>
                  <CartesianGrid strokeDasharray="3 3" stroke="rgba(255,255,255,0.08)" />
                  <XAxis dataKey="date" stroke="#94a3b8" fontSize={11} />
                  <YAxis domain={[0, 100]} stroke="#94a3b8" fontSize={11} />
                  <Tooltip contentStyle={{ background: '#12231b', borderColor: '#2d5a43', borderRadius: '8px', color: '#fff' }} />
                  <Area type="monotone" dataKey="avgPressure" stroke="#10b981" strokeWidth={2.5} fillOpacity={1} fill="url(#regGrad)" name="Regional Avg Pressure" />
                </AreaChart>
              </ResponsiveContainer>
            </div>
          )}
        </div>

        {/* Chart 2: Destination Pressure Comparison */}
        <div className="glass-panel" style={{ padding: '20px' }}>
          <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '14px' }}>
            <h3 style={{ fontSize: '0.95rem', color: '#fff', margin: 0, display: 'flex', alignItems: 'center', gap: '8px' }}>
              <BarChart3 size={16} color="#38bdf8" /> 2. Destination Pressure Comparison
            </h3>
            <span style={{ fontSize: '0.75rem', color: '#94a3b8' }}>Ranked Hubs (0-100)</span>
          </div>

          {destPressureData.length === 0 ? (
            <div style={{ padding: '36px', textAlign: 'center', color: '#64748b' }}>No destination records found.</div>
          ) : (
            <div style={{ height: '260px', width: '100%' }}>
              <ResponsiveContainer width="100%" height="100%">
                <BarChart data={destPressureData}>
                  <CartesianGrid strokeDasharray="3 3" stroke="rgba(255,255,255,0.08)" />
                  <XAxis dataKey="name" stroke="#94a3b8" fontSize={10} angle={-25} textAnchor="end" height={50} />
                  <YAxis domain={[0, 100]} stroke="#94a3b8" fontSize={11} />
                  <Tooltip contentStyle={{ background: '#12231b', borderColor: '#2d5a43', borderRadius: '8px', color: '#fff' }} />
                  <Bar dataKey="pressure" name="Pressure Score" radius={[4, 4, 0, 0]}>
                    {destPressureData.map((entry, index) => (
                      <Cell
                        key={`cell-${index}`}
                        fill={entry.pressure >= 70 ? '#ef4444' : entry.pressure >= 50 ? '#f97316' : entry.pressure >= 30 ? '#f59e0b' : '#10b981'}
                      />
                    ))}
                  </Bar>
                </BarChart>
              </ResponsiveContainer>
            </div>
          )}
        </div>
      </div>

      {/* Row 2: (3) 5-Factor Breakdown & (8) Tourism-Pressure Trends */}
      <div style={{ display: 'grid', gridTemplateColumns: '1.4fr 1.6fr', gap: '20px' }}>
        {/* Chart 3: Pressure Factor Comparison */}
        <div className="glass-panel" style={{ padding: '20px' }}>
          <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '14px' }}>
            <h3 style={{ fontSize: '0.95rem', color: '#fff', margin: 0, display: 'flex', alignItems: 'center', gap: '8px' }}>
              <Layers size={16} color="#fbbf24" /> 3. 5-Factor Pressure Component Comparison
            </h3>
            <span style={{ fontSize: '0.75rem', color: '#94a3b8' }}>Multi-Factor Breakdown</span>
          </div>

          {factorData.length === 0 ? (
            <div style={{ padding: '36px', textAlign: 'center', color: '#64748b' }}>No factor data available.</div>
          ) : (
            <div style={{ height: '270px', width: '100%' }}>
              <ResponsiveContainer width="100%" height="100%">
                <BarChart data={factorData}>
                  <CartesianGrid strokeDasharray="3 3" stroke="rgba(255,255,255,0.08)" />
                  <XAxis dataKey="name" stroke="#94a3b8" fontSize={10} angle={-20} textAnchor="end" height={45} />
                  <YAxis domain={[0, 100]} stroke="#94a3b8" fontSize={11} />
                  <Tooltip contentStyle={{ background: '#12231b', borderColor: '#2d5a43', borderRadius: '8px', color: '#fff' }} />
                  <Legend wrapperStyle={{ fontSize: '0.75rem', color: '#cbd5e1' }} />
                  <Bar dataKey="Tourism" fill="#10b981" />
                  <Bar dataKey="Water" fill="#38bdf8" />
                  <Bar dataKey="Waste" fill="#fbbf24" />
                  <Bar dataKey="Traffic" fill="#f97316" />
                  <Bar dataKey="Environment" fill="#ef4444" />
                </BarChart>
              </ResponsiveContainer>
            </div>
          )}
        </div>

        {/* Chart 8: Tourism-Pressure Trends */}
        <div className="glass-panel" style={{ padding: '20px' }}>
          <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '14px' }}>
            <h3 style={{ fontSize: '0.95rem', color: '#fff', margin: 0, display: 'flex', alignItems: 'center', gap: '8px' }}>
              <Activity size={16} color="#c084fc" /> 8. Tourism Footfall vs Composite Pressure
            </h3>
            <span style={{ fontSize: '0.75rem', color: '#94a3b8' }}>Dual-Axis Correlation</span>
          </div>

          {tourismPressureData.length === 0 ? (
            <div style={{ padding: '36px', textAlign: 'center', color: '#64748b' }}>No footfall telemetry records.</div>
          ) : (
            <div style={{ height: '270px', width: '100%' }}>
              <ResponsiveContainer width="100%" height="100%">
                <ComposedChart data={tourismPressureData}>
                  <CartesianGrid strokeDasharray="3 3" stroke="rgba(255,255,255,0.08)" />
                  <XAxis dataKey="name" stroke="#94a3b8" fontSize={10} angle={-20} textAnchor="end" height={45} />
                  <YAxis yAxisId="left" domain={[0, 100]} stroke="#10b981" fontSize={11} />
                  <YAxis yAxisId="right" orientation="right" stroke="#38bdf8" fontSize={11} />
                  <Tooltip contentStyle={{ background: '#12231b', borderColor: '#2d5a43', borderRadius: '8px', color: '#fff' }} />
                  <Legend wrapperStyle={{ fontSize: '0.75rem', color: '#cbd5e1' }} />
                  <Bar yAxisId="right" dataKey="visitors" fill="#38bdf8" name="Active Footfall Est" radius={[4, 4, 0, 0]} />
                  <Line yAxisId="left" type="monotone" dataKey="pressure" stroke="#10b981" strokeWidth={2.5} name="Pressure Score" dot={{ r: 3 }} />
                </ComposedChart>
              </ResponsiveContainer>
            </div>
          )}
        </div>
      </div>

      {/* Row 3: (4) Category Distribution, (5) Severity Distribution, (6) Resolution Status */}
      <div style={{ display: 'grid', gridTemplateColumns: 'repeat(3, 1fr)', gap: '20px' }}>
        {/* Chart 4: Report Category Distribution */}
        <div className="glass-panel" style={{ padding: '20px' }}>
          <h3 style={{ fontSize: '0.95rem', color: '#fff', marginBottom: '12px', display: 'flex', alignItems: 'center', gap: '8px' }}>
            <PieIcon size={16} color="#14b8a6" /> 4. Report Categories
          </h3>
          {reportCategoryData.length === 0 ? (
            <div style={{ padding: '36px', textAlign: 'center', color: '#64748b' }}>No category data.</div>
          ) : (
            <div style={{ height: '220px', width: '100%' }}>
              <ResponsiveContainer width="100%" height="100%">
                <PieChart>
                  <Pie
                    data={reportCategoryData}
                    cx="50%" cy="50%"
                    innerRadius={45} outerRadius={75}
                    paddingAngle={4} dataKey="value"
                  >
                    {reportCategoryData.map((entry, index) => (
                      <Cell key={`cell-${index}`} fill={COLORS[index % COLORS.length]} />
                    ))}
                  </Pie>
                  <Tooltip contentStyle={{ background: '#12231b', borderColor: '#2d5a43', borderRadius: '8px', color: '#fff' }} />
                  <Legend wrapperStyle={{ fontSize: '0.7rem', color: '#cbd5e1' }} />
                </PieChart>
              </ResponsiveContainer>
            </div>
          )}
        </div>

        {/* Chart 5: Report Severity Distribution */}
        <div className="glass-panel" style={{ padding: '20px' }}>
          <h3 style={{ fontSize: '0.95rem', color: '#fff', marginBottom: '12px', display: 'flex', alignItems: 'center', gap: '8px' }}>
            <ShieldAlert size={16} color="#ef4444" /> 5. Report Severity
          </h3>
          {reportSeverityData.length === 0 ? (
            <div style={{ padding: '36px', textAlign: 'center', color: '#64748b' }}>No severity data.</div>
          ) : (
            <div style={{ height: '220px', width: '100%' }}>
              <ResponsiveContainer width="100%" height="100%">
                <BarChart data={reportSeverityData}>
                  <CartesianGrid strokeDasharray="3 3" stroke="rgba(255,255,255,0.08)" />
                  <XAxis dataKey="name" stroke="#94a3b8" fontSize={10} />
                  <YAxis stroke="#94a3b8" fontSize={11} />
                  <Tooltip contentStyle={{ background: '#12231b', borderColor: '#2d5a43', borderRadius: '8px', color: '#fff' }} />
                  <Bar dataKey="value" name="Reports Count" radius={[4, 4, 0, 0]}>
                    {reportSeverityData.map((entry, index) => (
                      <Cell
                        key={`cell-${index}`}
                        fill={entry.name === 'CRITICAL' ? '#ef4444' : entry.name === 'HIGH' ? '#f97316' : entry.name === 'MEDIUM' ? '#f59e0b' : '#10b981'}
                      />
                    ))}
                  </Bar>
                </BarChart>
              </ResponsiveContainer>
            </div>
          )}
        </div>

        {/* Chart 6: Report Resolution Status */}
        <div className="glass-panel" style={{ padding: '20px' }}>
          <h3 style={{ fontSize: '0.95rem', color: '#fff', marginBottom: '12px', display: 'flex', alignItems: 'center', gap: '8px' }}>
            <CheckCircle size={16} color="#10b981" /> 6. Workflow Resolution Status
          </h3>
          {reportStatusData.length === 0 ? (
            <div style={{ padding: '36px', textAlign: 'center', color: '#64748b' }}>No status data.</div>
          ) : (
            <div style={{ height: '220px', width: '100%' }}>
              <ResponsiveContainer width="100%" height="100%">
                <PieChart>
                  <Pie
                    data={reportStatusData}
                    cx="50%" cy="50%"
                    innerRadius={45} outerRadius={75}
                    paddingAngle={4} dataKey="value"
                  >
                    {reportStatusData.map((entry, index) => (
                      <Cell key={`cell-${index}`} fill={COLORS[index % COLORS.length]} />
                    ))}
                  </Pie>
                  <Tooltip contentStyle={{ background: '#12231b', borderColor: '#2d5a43', borderRadius: '8px', color: '#fff' }} />
                  <Legend wrapperStyle={{ fontSize: '0.7rem', color: '#cbd5e1' }} />
                </PieChart>
              </ResponsiveContainer>
            </div>
          )}
        </div>
      </div>

      {/* Row 4: (7) Provider Distribution & (9) Prediction vs Current Pressure */}
      <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: '20px' }}>
        {/* Chart 7: Provider Distribution */}
        <div className="glass-panel" style={{ padding: '20px' }}>
          <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '14px' }}>
            <h3 style={{ fontSize: '0.95rem', color: '#fff', margin: 0, display: 'flex', alignItems: 'center', gap: '8px' }}>
              <Store size={16} color="#10b981" /> 7. Local Provider Distribution by Category
            </h3>
            <span style={{ fontSize: '0.75rem', color: '#94a3b8' }}>Community Partners</span>
          </div>

          {providerData.length === 0 ? (
            <div style={{ padding: '36px', textAlign: 'center', color: '#64748b' }}>No providers found.</div>
          ) : (
            <div style={{ height: '260px', width: '100%' }}>
              <ResponsiveContainer width="100%" height="100%">
                <BarChart data={providerData}>
                  <CartesianGrid strokeDasharray="3 3" stroke="rgba(255,255,255,0.08)" />
                  <XAxis dataKey="name" stroke="#94a3b8" fontSize={10} angle={-20} textAnchor="end" height={45} />
                  <YAxis stroke="#94a3b8" fontSize={11} />
                  <Tooltip contentStyle={{ background: '#12231b', borderColor: '#2d5a43', borderRadius: '8px', color: '#fff' }} />
                  <Bar dataKey="count" fill="#10b981" radius={[4, 4, 0, 0]} name="Registered Providers" />
                </BarChart>
              </ResponsiveContainer>
            </div>
          )}
        </div>

        {/* Chart 9: Prediction vs Current Pressure */}
        <div className="glass-panel" style={{ padding: '20px' }}>
          <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '14px' }}>
            <h3 style={{ fontSize: '0.95rem', color: '#fff', margin: 0, display: 'flex', alignItems: 'center', gap: '8px' }}>
              <Sparkles size={16} color="#c084fc" /> 9. ML Predicted vs Current Pressure
            </h3>
            <span style={{ fontSize: '0.75rem', color: '#94a3b8' }}>7-Day Model Delta</span>
          </div>

          {predictionVsCurrentData.length === 0 ? (
            <div style={{ padding: '36px', textAlign: 'center', color: '#64748b' }}>No prediction comparison data.</div>
          ) : (
            <div style={{ height: '260px', width: '100%' }}>
              <ResponsiveContainer width="100%" height="100%">
                <BarChart data={predictionVsCurrentData}>
                  <CartesianGrid strokeDasharray="3 3" stroke="rgba(255,255,255,0.08)" />
                  <XAxis dataKey="name" stroke="#94a3b8" fontSize={10} angle={-20} textAnchor="end" height={45} />
                  <YAxis domain={[0, 100]} stroke="#94a3b8" fontSize={11} />
                  <Tooltip contentStyle={{ background: '#12231b', borderColor: '#2d5a43', borderRadius: '8px', color: '#fff' }} />
                  <Legend wrapperStyle={{ fontSize: '0.75rem', color: '#cbd5e1' }} />
                  <Bar dataKey="Current" fill="#10b981" radius={[4, 4, 0, 0]} />
                  <Bar dataKey="Predicted" fill="#c084fc" radius={[4, 4, 0, 0]} />
                </BarChart>
              </ResponsiveContainer>
            </div>
          )}
        </div>
      </div>
    </div>
  );
};
