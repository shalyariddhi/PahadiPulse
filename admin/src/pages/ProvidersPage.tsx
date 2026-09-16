import React, { useState } from 'react';
import { LocalProvider } from '../types';
import { Store, CheckCircle, Phone, MapPin, Star, Filter } from 'lucide-react';

interface ProvidersPageProps {
  providers: LocalProvider[];
}

export const ProvidersPage: React.FC<ProvidersPageProps> = ({ providers }) => {
  const [categoryFilter, setCategoryFilter] = useState('ALL');

  const categories = ['ALL', 'HOMESTAY', 'LOCAL_GUIDE', 'LOCAL_FOOD', 'HANDICRAFTS', 'LOCAL_PRODUCTS', 'CULTURAL_EXPERIENCE'];

  const filtered = providers.filter((p) => {
    return categoryFilter === 'ALL' || p.category === categoryFilter;
  });

  return (
    <div style={{ display: 'flex', flexDirection: 'column', gap: '16px' }}>
      {/* Header & Filter */}
      <div className="glass-panel" style={{ padding: '18px 24px', display: 'flex', justifyContent: 'space-between', alignItems: 'center', flexWrap: 'wrap', gap: '16px' }}>
        <div>
          <h2 style={{ fontSize: '1.25rem', color: '#fff', margin: 0 }}>
            Local Livelihoods, Homestays & Community Guides
          </h2>
          <p style={{ fontSize: '0.8rem', color: '#94a3b8' }}>
            Empowering regional communities and promoting economic distribution across Uttarakhand
          </p>
        </div>

        <select
          value={categoryFilter}
          onChange={(e) => setCategoryFilter(e.target.value)}
          style={{
            background: 'rgba(0,0,0,0.3)', border: '1px solid var(--border-subtle)',
            borderRadius: '8px', padding: '8px 14px', color: '#fff', fontSize: '0.85rem'
          }}
        >
          {categories.map((c) => (
            <option key={c} value={c} style={{ background: '#12231b' }}>
              {c === 'ALL' ? 'All Provider Categories' : c.replace('_', ' ')}
            </option>
          ))}
        </select>
      </div>

      {/* Grid of Providers */}
      <div style={{ display: 'grid', gridTemplateColumns: 'repeat(auto-fill, minmax(320px, 1fr))', gap: '16px' }}>
        {filtered.map((p) => (
          <div
            key={p.id}
            className="glass-panel glass-panel-hover"
            style={{ padding: '20px', display: 'flex', flexDirection: 'column', justifyContent: 'space-between' }}
          >
            <div>
              <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'flex-start', marginBottom: '8px' }}>
                <span style={{ fontSize: '0.75rem', background: 'rgba(16, 185, 129, 0.15)', color: '#10b981', padding: '3px 8px', borderRadius: '6px', fontWeight: 600 }}>
                  {p.category.replace('_', ' ')}
                </span>
                <div style={{ display: 'flex', alignItems: 'center', gap: '4px', color: '#f59e0b', fontSize: '0.85rem' }}>
                  <Star size={14} fill="#f59e0b" />
                  <strong>{p.rating}</strong>
                </div>
              </div>

              <h3 style={{ fontSize: '1.15rem', color: '#fff', margin: '0 0 6px 0' }}>{p.name}</h3>
              <p style={{ fontSize: '0.8rem', color: '#cbd5e1', marginBottom: '12px' }}>{p.description}</p>
              
              <div style={{ display: 'flex', flexDirection: 'column', gap: '6px', fontSize: '0.8rem', color: '#94a3b8', marginBottom: '14px' }}>
                <div style={{ display: 'flex', alignItems: 'center', gap: '6px' }}>
                  <MapPin size={14} color="#10b981" /> {p.locationAddress} ({p.destinationName})
                </div>
                <div style={{ display: 'flex', alignItems: 'center', gap: '6px' }}>
                  <Phone size={14} color="#10b981" /> {p.contactPhone}
                </div>
              </div>
            </div>

            <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', paddingTop: '12px', borderTop: '1px solid var(--border-subtle)' }}>
              <div>
                <span style={{ fontSize: '0.75rem', color: '#94a3b8' }}>Tariff: </span>
                <strong style={{ color: '#10b981', fontSize: '1rem' }}>₹{p.priceStartingINR}</strong>
                <span style={{ fontSize: '0.7rem', color: '#94a3b8' }}> /{p.pricingUnit}</span>
              </div>
              <div style={{ display: 'flex', alignItems: 'center', gap: '4px', color: '#10b981', fontSize: '0.75rem', fontWeight: 600 }}>
                <CheckCircle size={14} /> Verified Provider
              </div>
            </div>
          </div>
        ))}
      </div>
    </div>
  );
};
