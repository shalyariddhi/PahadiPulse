import React, { useState } from 'react';
import { generateItinerary, classifyReportAI } from '../services/api';
import { ItineraryResponse, ReportCategory } from '../types';
import { Sparkles, Calendar, Users, Wallet, Compass, Send, CheckCircle2, ShieldAlert } from 'lucide-react';

export const TripPlannerDemo: React.FC = () => {
  // Itinerary Planner State
  const [days, setDays] = useState(4);
  const [travellers, setTravellers] = useState(3);
  const [budget, setBudget] = useState(10000);
  const [selectedInterests, setSelectedInterests] = useState<string[]>(['Nature', 'Adventure']);
  const [loadingItin, setLoadingItin] = useState(false);
  const [itinerary, setItinerary] = useState<ItineraryResponse | null>(null);

  // AI Report Classifier State
  const [reportText, setReportText] = useState('Heavy plastic trash accumulation and blocked mountain water drain near Kempty bypass');
  const [aiResult, setAiResult] = useState<any>(null);
  const [loadingAI, setLoadingAI] = useState(false);

  const availableInterests = ['Nature', 'Adventure', 'Food', 'Culture', 'Photography', 'Spiritual', 'Relaxation'];

  const toggleInterest = (interest: string) => {
    if (selectedInterests.includes(interest)) {
      setSelectedInterests(selectedInterests.filter((i) => i !== interest));
    } else {
      setSelectedInterests([...selectedInterests, interest]);
    }
  };

  const handleGenerateItinerary = async () => {
    setLoadingItin(true);
    try {
      const res = await generateItinerary({
        daysCount: days,
        travellersCount: travellers,
        budgetPerPersonINR: budget,
        interests: selectedInterests,
        startingRegion: 'Dehradun / Rishikesh'
      });
      setItinerary(res);
    } catch (err) {
      console.error(err);
      alert('Failed to generate itinerary');
    } finally {
      setLoadingItin(false);
    }
  };

  const handleClassifyAI = async () => {
    setLoadingAI(true);
    try {
      const res = await classifyReportAI(reportText);
      setAiResult(res);
    } catch (err) {
      console.error(err);
      alert('Failed to classify text');
    } finally {
      setLoadingAI(false);
    }
  };

  return (
    <div style={{ display: 'flex', flexDirection: 'column', gap: '24px' }}>
      {/* Header */}
      <div className="glass-panel" style={{ padding: '20px 24px' }}>
        <h2 style={{ fontSize: '1.3rem', color: '#fff', margin: '0 0 4px 0', display: 'flex', alignItems: 'center', gap: '8px' }}>
          <Sparkles size={22} color="#10b981" /> Live AI Engine Simulator & Evaluation Workbench
        </h2>
        <p style={{ fontSize: '0.85rem', color: '#94a3b8' }}>
          Interactive simulator for IBM Hackathon judges to test the <strong>Pressure-Aware Itinerary Optimizer</strong> and <strong>AI Citizen Report Classifier</strong> in real-time.
        </p>
      </div>

      {/* Grid: Left = Trip Optimizer, Right = AI Report Classifier */}
      <div style={{ display: 'grid', gridTemplateColumns: '1.2fr 1fr', gap: '24px' }}>
        {/* Section 1: AI Trip Planner */}
        <div className="glass-panel" style={{ padding: '24px', display: 'flex', flexDirection: 'column', gap: '16px' }}>
          <h3 style={{ fontSize: '1.1rem', color: '#10b981', display: 'flex', alignItems: 'center', gap: '8px' }}>
            <Compass size={20} /> 1. Smart Itinerary Optimization Engine
          </h3>
          <p style={{ fontSize: '0.8rem', color: '#94a3b8' }}>
            Multi-objective Pareto optimizer: balances budget, group size, and interests while actively penalizing congested hotspots (Mussoorie/Nainital).
          </p>

          <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr 1fr', gap: '12px' }}>
            <div>
              <label style={{ display: 'block', fontSize: '0.75rem', color: '#94a3b8', marginBottom: '4px' }}>
                Trip Duration
              </label>
              <input
                type="number"
                min="1"
                max="10"
                value={days}
                onChange={(e) => setDays(Number(e.target.value))}
                style={{ width: '100%', background: 'rgba(0,0,0,0.3)', border: '1px solid var(--border-subtle)', borderRadius: '8px', padding: '8px', color: '#fff' }}
              />
            </div>
            <div>
              <label style={{ display: 'block', fontSize: '0.75rem', color: '#94a3b8', marginBottom: '4px' }}>
                Travellers
              </label>
              <input
                type="number"
                min="1"
                max="15"
                value={travellers}
                onChange={(e) => setTravellers(Number(e.target.value))}
                style={{ width: '100%', background: 'rgba(0,0,0,0.3)', border: '1px solid var(--border-subtle)', borderRadius: '8px', padding: '8px', color: '#fff' }}
              />
            </div>
            <div>
              <label style={{ display: 'block', fontSize: '0.75rem', color: '#94a3b8', marginBottom: '4px' }}>
                Budget / Person (₹)
              </label>
              <input
                type="number"
                step="1000"
                value={budget}
                onChange={(e) => setBudget(Number(e.target.value))}
                style={{ width: '100%', background: 'rgba(0,0,0,0.3)', border: '1px solid var(--border-subtle)', borderRadius: '8px', padding: '8px', color: '#fff' }}
              />
            </div>
          </div>

          {/* Interests Pills */}
          <div>
            <label style={{ display: 'block', fontSize: '0.75rem', color: '#94a3b8', marginBottom: '6px' }}>
              Traveler Interests
            </label>
            <div style={{ display: 'flex', gap: '6px', flexWrap: 'wrap' }}>
              {availableInterests.map((interest) => {
                const isSelected = selectedInterests.includes(interest);
                return (
                  <button
                    key={interest}
                    onClick={() => toggleInterest(interest)}
                    style={{
                      padding: '4px 10px', borderRadius: '16px', fontSize: '0.75rem',
                      border: isSelected ? '1px solid #10b981' : '1px solid var(--border-subtle)',
                      background: isSelected ? 'rgba(16, 185, 129, 0.2)' : 'rgba(255,255,255,0.04)',
                      color: isSelected ? '#10b981' : '#cbd5e1', cursor: 'pointer'
                    }}
                  >
                    {interest}
                  </button>
                );
              })}
            </div>
          </div>

          <button onClick={handleGenerateItinerary} disabled={loadingItin} className="btn-primary" style={{ width: '100%', justifyContent: 'center' }}>
            {loadingItin ? 'Optimizing Regional Route...' : '🚀 Generate Pressure-Aware Itinerary'}
          </button>

          {/* Generated Result Output */}
          {itinerary && (
            <div style={{ background: 'rgba(0,0,0,0.35)', border: '1px solid var(--border-active)', borderRadius: '12px', padding: '16px' }}>
              <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '8px' }}>
                <h4 style={{ fontSize: '1rem', color: '#10b981', margin: 0 }}>{itinerary.title}</h4>
                <span style={{ fontSize: '0.75rem', background: 'rgba(16, 185, 129, 0.2)', color: '#10b981', padding: '3px 8px', borderRadius: '8px', fontWeight: 700 }}>
                  -{itinerary.pressureMitigationScore}% Regional Strain
                </span>
              </div>
              <p style={{ fontSize: '0.8rem', color: '#cbd5e1', marginBottom: '12px', fontStyle: 'italic' }}>
                "{itinerary.rationale}"
              </p>

              <div style={{ display: 'flex', flexDirection: 'column', gap: '8px' }}>
                {itinerary.days.map((d) => (
                  <div key={d.dayNumber} style={{ background: 'rgba(255,255,255,0.03)', padding: '10px', borderRadius: '8px', border: '1px solid var(--border-subtle)' }}>
                    <div style={{ display: 'flex', justifyContent: 'space-between', fontSize: '0.85rem', fontWeight: 600, color: '#fff', marginBottom: '4px' }}>
                      <span>Day {d.dayNumber}: {d.destinationName} ({d.district})</span>
                      <span className={`badge badge-${d.pressureLevel.toLowerCase()}`}>
                        {d.pressureScore} Pressure
                      </span>
                    </div>
                    <div style={{ fontSize: '0.75rem', color: '#94a3b8' }}>
                      🏡 Stay: <strong style={{ color: '#10b981' }}>{d.stayRecommendation.name}</strong> (₹{d.stayRecommendation.costPerNightINR}/night)
                    </div>
                  </div>
                ))}
              </div>
            </div>
          )}
        </div>

        {/* Section 2: AI Citizen Report Classifier */}
        <div className="glass-panel" style={{ padding: '24px', display: 'flex', flexDirection: 'column', gap: '16px' }}>
          <h3 style={{ fontSize: '1.1rem', color: '#f59e0b', display: 'flex', alignItems: 'center', gap: '8px' }}>
            <ShieldAlert size={20} /> 2. AI Citizen Report Classifier
          </h3>
          <p style={{ fontSize: '0.8rem', color: '#94a3b8' }}>
            Real-time NLP pipeline that extracts category, evaluates severity (1–5), and suggests administrative actions.
          </p>

          <div>
            <label style={{ display: 'block', fontSize: '0.75rem', color: '#94a3b8', marginBottom: '4px' }}>
              Test Incident Description:
            </label>
            <textarea
              rows={4}
              value={reportText}
              onChange={(e) => setReportText(e.target.value)}
              style={{
                width: '100%', background: 'rgba(0,0,0,0.3)', border: '1px solid var(--border-subtle)',
                borderRadius: '8px', padding: '10px', color: '#fff', fontSize: '0.85rem'
              }}
            />
          </div>

          <button onClick={handleClassifyAI} disabled={loadingAI} className="btn-primary" style={{ width: '100%', justifyContent: 'center', background: 'linear-gradient(135deg, #f59e0b 0%, #d97706 100%)' }}>
            {loadingAI ? 'Analyzing NLP Pipeline...' : '🤖 Run AI Classifier'}
          </button>

          {aiResult && (
            <div style={{ background: 'rgba(0,0,0,0.35)', border: '1px solid rgba(245, 158, 11, 0.4)', borderRadius: '12px', padding: '16px' }}>
              <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '8px' }}>
                <span style={{ fontSize: '0.85rem', fontWeight: 700, color: '#f59e0b' }}>
                  Category: {aiResult.aiCategory}
                </span>
                <span style={{ fontSize: '0.75rem', background: 'rgba(245, 158, 11, 0.2)', color: '#f59e0b', padding: '3px 8px', borderRadius: '8px', fontWeight: 700 }}>
                  Severity: {aiResult.aiSeverity} / 5
                </span>
              </div>
              <div style={{ fontSize: '0.75rem', color: '#94a3b8', marginBottom: '8px' }}>
                Confidence Score: <strong style={{ color: '#10b981' }}>{(aiResult.aiConfidence * 100).toFixed(0)}%</strong>
              </div>
              <p style={{ fontSize: '0.8rem', color: '#cbd5e1', marginBottom: '10px' }}>
                {aiResult.aiExplanation}
              </p>
              <div style={{ fontSize: '0.75rem', color: '#10b981', background: 'rgba(16, 185, 129, 0.1)', padding: '8px', borderRadius: '6px' }}>
                <strong>Recommended Dispatch:</strong> {aiResult.recommendedAction}
              </div>
            </div>
          )}
        </div>
      </div>
    </div>
  );
};
