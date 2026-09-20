import React, { useState, useEffect } from 'react';
import { Destination, PressureHistoryResponse } from '../types';
import { getDestinationHistory } from '../services/api';
import { TrendingUp, Activity, Calendar, Sliders, ArrowUpRight, ShieldAlert } from 'lucide-react';
import { LineChart, Line, XAxis, YAxis, Tooltip, ResponsiveContainer, CartesianGrid, Legend } from 'recharts';

interface PressureTrendsPageProps {
  destinations: Destination[];
  onSelectDestination: (dest: Destination) => void;
}

export const PressureTrendsPage: React.FC<PressureTrendsPageProps> = ({
  destinations,
  onSelectDestination
}) => {
  const [selectedDestIds, setSelectedDestIds] = useState<string[]>(() => {
    return destinations.slice(0, 4).map((d) => d.id);
  });
  const [days, setDays] = useState(14);
  const [historyData, setHistoryData] = useState<Record<string, PressureHistoryResponse>>({});
  const [loading, setLoading] = useState(false);

  useEffect(() => {
    if (selectedDestIds.length > 0) {
      setLoading(true);
      Promise.allSettled(
        selectedDestIds.map((id) => getDestinationHistory(id, days))
      ).then((results) => {
        const map: Record<string, PressureHistoryResponse> = {};
        results.forEach((res) => {
          if (res.status === 'fulfilled') {
            map[res.value.destinationId] = res.value;
          }
        });
        setHistoryData(map);
      }).finally(() => setLoading(false));
    }
  }, [selectedDestIds, days]);

  const toggleDestination = (id: string) => {
    if (selectedDestIds.includes(id)) {
      if (selectedDestIds.length > 1) {
        setSelectedDestIds(selectedDestIds.filter((item) => item !== id));
      }
    } else {
      if (selectedDestIds.length < 5) {
        setSelectedDestIds([...selectedDestIds, id]);
      }
    }
  };

  // Build merged chart dataset by date
  const dateMap: Record<string, any> = {};
  Object.entries(historyData).forEach(([destId, hResp]) => {
    const destName = destinations.find((d) => d.id === destId)?.name || destId;
    hResp.history.forEach((pt) => {
      const dateKey = pt.date.slice(5);
      if (!dateMap[dateKey]) {
        dateMap[dateKey] = { date: dateKey };
      }
      dateMap[dateKey][destName] = pt.pressureScore;
    });
  });

  const chartData = Object.values(dateMap).sort((a, b) => a.date.localeCompare(b.date));

  const colors = ['#ef4444', '#f59e0b', '#10b981', '#38bdf8', '#c084fc'];

  return (
    <div style={{ display: 'flex', flexDirection: 'column', gap: '20px' }}>
      {/* Header */}
      <div className="glass-panel" style={{ padding: '20px 24px', display: 'flex', justifyContent: 'space-between', alignItems: 'center', flexWrap: 'wrap', gap: '16px' }}>
        <div>
          <div style={{ display: 'flex', alignItems: 'center', gap: '10px', marginBottom: '4px' }}>
            <Activity size={22} color="#10b981" />
            <h2 style={{ fontSize: '1.3rem', color: '#fff', margin: 0 }}>
              Historical Telemetry & Multi-Destination Pressure Trends
            </h2>
          </div>
          <p style={{ fontSize: '0.8rem', color: '#94a3b8', margin: 0 }}>
            Compare historical carrying capacity stress dynamics across key tourist hubs
          </p>
        </div>

        <div style={{ display: 'flex', gap: '10px', alignItems: 'center' }}>
          <span style={{ fontSize: '0.8rem', color: '#94a3b8' }}>Time Horizon:</span>
          {[7, 14, 30].map((d) => (
            <button
              key={d}
              onClick={() => setDays(d)}
              style={{
                padding: '6px 14px', borderRadius: '8px',
                background: days === d ? 'rgba(16, 185, 129, 0.25)' : 'rgba(0,0,0,0.3)',
                color: days === d ? '#10b981' : '#94a3b8',
                border: days === d ? '1px solid #10b981' : '1px solid var(--border-subtle)',
                fontSize: '0.8rem', fontWeight: 600, cursor: 'pointer'
              }}
            >
              {d} Days
            </button>
          ))}
        </div>
      </div>

      {/* Destination Selector Chips */}
      <div className="glass-panel" style={{ padding: '16px 20px' }}>
        <span style={{ fontSize: '0.75rem', color: '#94a3b8', fontWeight: 600, textTransform: 'uppercase', display: 'block', marginBottom: '10px' }}>
          Select Destinations to Compare (Max 5):
        </span>
        <div style={{ display: 'flex', flexWrap: 'wrap', gap: '8px' }}>
          {destinations.map((d) => {
            const isSelected = selectedDestIds.includes(d.id);
            return (
              <button
                key={d.id}
                onClick={() => toggleDestination(d.id)}
                style={{
                  padding: '6px 14px', borderRadius: '20px',
                  background: isSelected ? 'linear-gradient(135deg, rgba(16, 185, 129, 0.3) 0%, rgba(6, 78, 59, 0.5) 100%)' : 'rgba(0,0,0,0.3)',
                  color: isSelected ? '#fff' : '#94a3b8',
                  border: isSelected ? '1px solid #10b981' : '1px solid var(--border-subtle)',
                  fontSize: '0.8rem', fontWeight: isSelected ? 700 : 500, cursor: 'pointer',
                  display: 'flex', alignItems: 'center', gap: '6px'
                }}
              >
                <span>{d.name}</span>
                <span className={`badge badge-${d.status.toLowerCase()}`} style={{ fontSize: '0.65rem', padding: '1px 6px' }}>
                  {d.pressureScore.toFixed(0)}
                </span>
              </button>
            );
          })}
        </div>
      </div>

      {/* Multi-Line Trends Graph */}
      <div className="glass-panel" style={{ padding: '24px' }}>
        <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '16px' }}>
          <h3 style={{ fontSize: '1rem', color: '#fff', margin: 0, display: 'flex', alignItems: 'center', gap: '8px' }}>
            <TrendingUp size={18} color="#10b981" /> Comparative Pressure Trajectory ({days}-Day Retrospective)
          </h3>
          <span style={{ fontSize: '0.75rem', color: '#94a3b8' }}>Values represent 5-factor weighted pressure (0-100)</span>
        </div>

        <div style={{ height: '360px', width: '100%', background: 'rgba(0,0,0,0.25)', borderRadius: '12px', padding: '16px 16px 8px 0' }}>
          <ResponsiveContainer width="100%" height="100%">
            <LineChart data={chartData}>
              <CartesianGrid strokeDasharray="3 3" stroke="rgba(255,255,255,0.08)" />
              <XAxis dataKey="date" stroke="#94a3b8" fontSize={11} />
              <YAxis domain={[0, 100]} stroke="#94a3b8" fontSize={11} />
              <Tooltip contentStyle={{ background: '#12231b', borderColor: '#2d5a43', borderRadius: '8px', color: '#fff' }} />
              <Legend wrapperStyle={{ color: '#cbd5e1', fontSize: '0.8rem', paddingTop: '10px' }} />
              {selectedDestIds.map((id, idx) => {
                const dest = destinations.find((d) => d.id === id);
                const name = dest?.name || id;
                return (
                  <Line
                    key={id}
                    type="monotone"
                    dataKey={name}
                    stroke={colors[idx % colors.length]}
                    strokeWidth={2.5}
                    dot={{ r: 3 }}
                    activeDot={{ r: 6 }}
                  />
                );
              })}
            </LineChart>
          </ResponsiveContainer>
        </div>
      </div>
    </div>
  );
};
