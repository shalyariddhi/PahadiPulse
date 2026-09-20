import React, { useState } from 'react';
import { LocalProvider, ProviderCategory, Destination } from '../types';
import { Store, CheckCircle, Phone, MapPin, Star, Filter, Plus, Edit3, Eye, AlertCircle, ExternalLink } from 'lucide-react';

interface ProvidersPageProps {
  providers: LocalProvider[];
  destinations: Destination[];
  onSelectProvider: (p: LocalProvider) => void;
  onAddProvider?: () => void;
  onEditProvider?: (p: LocalProvider) => void;
}

export const ProvidersPage: React.FC<ProvidersPageProps> = ({
  providers,
  destinations,
  onSelectProvider,
  onAddProvider,
  onEditProvider
}) => {
  const [categoryFilter, setCategoryFilter] = useState('ALL');
  const [destinationFilter, setDestinationFilter] = useState('ALL');
  const [verifiedFilter, setVerifiedFilter] = useState<'ALL' | 'VERIFIED' | 'UNVERIFIED'>('ALL');
  const [maxPrice, setMaxPrice] = useState<number>(10000);
  const [search, setSearch] = useState('');

  const categories: string[] = ['ALL', 'HOMESTAY', 'LOCAL_GUIDE', 'LOCAL_FOOD', 'HANDICRAFTS', 'LOCAL_PRODUCTS', 'CULTURAL_EXPERIENCE', 'RENTAL'];

  const destinationNames = ['ALL', ...Array.from(new Set(providers.map((p) => p.destinationName).filter(Boolean)))];

  const filtered = providers.filter((p) => {
    const matchCat = categoryFilter === 'ALL' || p.category === categoryFilter;
    const matchDest = destinationFilter === 'ALL' || p.destinationName === destinationFilter || p.destinationId === destinationFilter;
    const matchVer = verifiedFilter === 'ALL' || (verifiedFilter === 'VERIFIED' && p.verified) || (verifiedFilter === 'UNVERIFIED' && !p.verified);
    const matchPrice = !p.priceStartingINR || p.priceStartingINR <= maxPrice;
    const matchSearch = p.name.toLowerCase().includes(search.toLowerCase()) || p.description.toLowerCase().includes(search.toLowerCase()) || p.locationAddress.toLowerCase().includes(search.toLowerCase());
    return matchCat && matchDest && matchVer && matchPrice && matchSearch;
  });

  return (
    <div style={{ display: 'flex', flexDirection: 'column', gap: '16px' }}>
      {/* Header & Filters */}
      <div className="glass-panel" style={{ padding: '18px 24px', display: 'flex', justifyContent: 'space-between', alignItems: 'center', flexWrap: 'wrap', gap: '16px' }}>
        <div>
          <div style={{ display: 'flex', alignItems: 'center', gap: '10px', marginBottom: '4px' }}>
            <Store size={22} color="#10b981" />
            <h2 style={{ fontSize: '1.25rem', color: '#fff', margin: 0 }}>
              Local Livelihoods & Community Provider Management
            </h2>
          </div>
          <p style={{ fontSize: '0.8rem', color: '#94a3b8', margin: 0 }}>
            Empowering regional mountain hosts, artisans & cooperatives ({providers.length} registered)
          </p>
        </div>

        <div style={{ display: 'flex', gap: '10px', flexWrap: 'wrap', alignItems: 'center' }}>
          <input
            type="text"
            placeholder="Search provider..."
            value={search}
            onChange={(e) => setSearch(e.target.value)}
            style={{
              background: 'rgba(0,0,0,0.3)', border: '1px solid var(--border-subtle)',
              borderRadius: '8px', padding: '8px 12px', color: '#fff', fontSize: '0.85rem'
            }}
          />

          <select
            value={categoryFilter}
            onChange={(e) => setCategoryFilter(e.target.value)}
            style={{
              background: 'rgba(0,0,0,0.3)', border: '1px solid var(--border-subtle)',
              borderRadius: '8px', padding: '8px 12px', color: '#fff', fontSize: '0.85rem'
            }}
          >
            {categories.map((c) => (
              <option key={c} value={c} style={{ background: '#12231b' }}>
                {c === 'ALL' ? 'All Categories' : c.replace('_', ' ')}
              </option>
            ))}
          </select>

          <select
            value={destinationFilter}
            onChange={(e) => setDestinationFilter(e.target.value)}
            style={{
              background: 'rgba(0,0,0,0.3)', border: '1px solid var(--border-subtle)',
              borderRadius: '8px', padding: '8px 12px', color: '#fff', fontSize: '0.85rem'
            }}
          >
            {destinationNames.map((d) => (
              <option key={d} value={d} style={{ background: '#12231b' }}>
                {d === 'ALL' ? 'All Destinations' : d}
              </option>
            ))}
          </select>

          <select
            value={verifiedFilter}
            onChange={(e) => setVerifiedFilter(e.target.value as any)}
            style={{
              background: 'rgba(0,0,0,0.3)', border: '1px solid var(--border-subtle)',
              borderRadius: '8px', padding: '8px 12px', color: '#fff', fontSize: '0.85rem'
            }}
          >
            <option value="ALL" style={{ background: '#12231b' }}>All Verification</option>
            <option value="VERIFIED" style={{ background: '#12231b' }}>✓ Verified Only</option>
            <option value="UNVERIFIED" style={{ background: '#12231b' }}>Pending Review</option>
          </select>

          {onAddProvider && (
            <button onClick={onAddProvider} className="btn-primary" style={{ padding: '8px 16px', fontSize: '0.85rem' }}>
              <Plus size={16} /> Add Provider
            </button>
          )}
        </div>
      </div>

      {/* Demo Data Notice */}
      <div style={{
        background: 'rgba(245, 158, 11, 0.08)',
        border: '1px solid rgba(245, 158, 11, 0.3)',
        borderRadius: '12px',
        padding: '12px 18px',
        display: 'flex',
        alignItems: 'center',
        gap: '12px'
      }}>
        <AlertCircle size={18} color="#f59e0b" />
        <span style={{ fontSize: '0.8rem', color: '#cbd5e1' }}>
          <strong>DEMO DATA DISCLAIMER:</strong> All provider records are clearly labelled prototype entries for hackathon evaluation. Direct community booking links redirect safely without embedded payment collection.
        </span>
      </div>

      {/* Grid of Providers */}
      <div style={{ display: 'grid', gridTemplateColumns: 'repeat(auto-fill, minmax(330px, 1fr))', gap: '16px' }}>
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
                  <strong>{p.rating?.toFixed(1) || '4.8'}</strong>
                </div>
              </div>

              <h3 style={{ fontSize: '1.2rem', color: '#fff', margin: '0 0 6px 0' }}>{p.name}</h3>
              <p style={{ fontSize: '0.8rem', color: '#cbd5e1', marginBottom: '12px', lineClamp: 2, display: '-webkit-box', WebkitLineClamp: 2, WebkitBoxOrient: 'vertical', overflow: 'hidden' }}>
                {p.description}
              </p>
              
              <div style={{ display: 'flex', flexDirection: 'column', gap: '6px', fontSize: '0.8rem', color: '#94a3b8', marginBottom: '14px' }}>
                <div style={{ display: 'flex', alignItems: 'center', gap: '6px' }}>
                  <MapPin size={14} color="#10b981" /> {p.locationAddress} ({p.destinationName})
                </div>
                <div style={{ display: 'flex', alignItems: 'center', gap: '6px' }}>
                  <Phone size={14} color="#10b981" /> {p.contactPhone}
                </div>
              </div>
            </div>

            <div>
              <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', paddingBottom: '10px', borderBottom: '1px solid var(--border-subtle)', marginBottom: '10px' }}>
                <div>
                  <span style={{ fontSize: '0.75rem', color: '#94a3b8' }}>Tariff: </span>
                  <strong style={{ color: '#10b981', fontSize: '1rem' }}>₹{p.priceStartingINR?.toLocaleString()}</strong>
                  <span style={{ fontSize: '0.7rem', color: '#94a3b8' }}> /{p.pricingUnit || 'night'}</span>
                </div>
                {p.verified ? (
                  <div style={{ display: 'flex', alignItems: 'center', gap: '4px', color: '#10b981', fontSize: '0.75rem', fontWeight: 600 }}>
                    <CheckCircle size={13} /> Verified
                  </div>
                ) : (
                  <span style={{ color: '#f59e0b', fontSize: '0.75rem' }}>Review Pending</span>
                )}
              </div>

              <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
                {onEditProvider && (
                  <button
                    onClick={() => onEditProvider(p)}
                    className="btn-secondary"
                    style={{ padding: '6px 12px', fontSize: '0.75rem' }}
                  >
                    <Edit3 size={13} /> Edit
                  </button>
                )}

                <button
                  onClick={() => onSelectProvider(p)}
                  className="btn-primary"
                  style={{ padding: '6px 14px', fontSize: '0.8rem' }}
                >
                  <Eye size={14} /> Full Profile
                </button>
              </div>
            </div>
          </div>
        ))}
      </div>
    </div>
  );
};
