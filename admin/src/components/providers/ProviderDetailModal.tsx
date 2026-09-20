import React from 'react';
import { LocalProvider } from '../../types';
import { X, Store, CheckCircle, AlertCircle, Phone, Mail, MapPin, Star, ExternalLink, ShieldCheck, Edit3 } from 'lucide-react';

interface ProviderDetailModalProps {
  provider: LocalProvider | null;
  onClose: () => void;
  onEdit?: (p: LocalProvider) => void;
}

export const ProviderDetailModal: React.FC<ProviderDetailModalProps> = ({
  provider,
  onClose,
  onEdit
}) => {
  if (!provider) return null;

  const categoryLabels: Record<string, string> = {
    HOMESTAY: '🏡 Traditional Homestay',
    LOCAL_GUIDE: '🧭 Certified Mountain Guide',
    LOCAL_FOOD: '🍲 Pahadi Cuisine & Cafe',
    HANDICRAFTS: '🧶 Aipan & Woolen Crafts',
    LOCAL_PRODUCTS: '🍯 Organic Pahadi Produce',
    CULTURAL_EXPERIENCE: '🥁 Folk & Heritage Immersion',
    RENTAL: '🚲 Eco-Bikes & Trek Gear'
  };

  const handleOpenBooking = () => {
    if (provider.externalBookingUrl) {
      window.open(provider.externalBookingUrl, '_blank', 'noopener,noreferrer');
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
        width: '100%', maxWidth: '640px', maxHeight: '92vh',
        overflowY: 'auto', padding: '28px', position: 'relative'
      }}>
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

        <div style={{ display: 'flex', alignItems: 'center', gap: '8px', marginBottom: '12px' }}>
          <span style={{ fontSize: '0.75rem', background: 'rgba(16, 185, 129, 0.2)', color: '#10b981', padding: '4px 10px', borderRadius: '8px', fontWeight: 700 }}>
            {categoryLabels[provider.category] || provider.category}
          </span>
          {provider.verified ? (
            <span style={{ fontSize: '0.75rem', background: 'rgba(16, 185, 129, 0.2)', color: '#10b981', padding: '4px 10px', borderRadius: '8px', fontWeight: 600, display: 'flex', alignItems: 'center', gap: '4px' }}>
              <CheckCircle size={13} /> Verified Community Partner
            </span>
          ) : (
            <span style={{ fontSize: '0.75rem', background: 'rgba(245, 158, 11, 0.2)', color: '#fbbf24', padding: '4px 10px', borderRadius: '8px', fontWeight: 600 }}>
              Verification Pending
            </span>
          )}
        </div>

        <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'flex-start', marginBottom: '14px' }}>
          <div>
            <h2 style={{ fontSize: '1.4rem', color: '#fff', margin: '0 0 4px 0' }}>
              {provider.name}
            </h2>
            <p style={{ fontSize: '0.85rem', color: '#94a3b8', margin: 0 }}>
              Managed by: <strong style={{ color: '#cbd5e1' }}>{provider.ownerName || 'Local Host'}</strong> • In <strong style={{ color: '#10b981' }}>{provider.destinationName}</strong>
            </p>
          </div>

          <div style={{ display: 'flex', alignItems: 'center', gap: '4px', background: 'rgba(245, 158, 11, 0.15)', padding: '6px 12px', borderRadius: '10px', color: '#fbbf24', fontWeight: 700 }}>
            <Star size={16} fill="#fbbf24" />
            <span>{provider.rating?.toFixed(1) || '4.8'}</span>
          </div>
        </div>

        {/* Description */}
        <div style={{ background: 'rgba(255,255,255,0.03)', border: '1px solid var(--border-subtle)', borderRadius: '10px', padding: '14px', marginBottom: '16px', color: '#e2e8f0', fontSize: '0.9rem', lineHeight: '1.5' }}>
          {provider.description}
        </div>

        {/* Info Grid */}
        <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: '12px', marginBottom: '18px' }}>
          <div style={{ background: 'rgba(0,0,0,0.25)', padding: '12px', borderRadius: '8px' }}>
            <span style={{ fontSize: '0.75rem', color: '#94a3b8', display: 'block', marginBottom: '4px' }}>Direct Contact</span>
            <div style={{ display: 'flex', alignItems: 'center', gap: '6px', fontSize: '0.85rem', color: '#fff', marginBottom: '4px' }}>
              <Phone size={14} color="#10b981" /> {provider.contactPhone}
            </div>
            {provider.contactEmail && (
              <div style={{ display: 'flex', alignItems: 'center', gap: '6px', fontSize: '0.8rem', color: '#94a3b8' }}>
                <Mail size={14} color="#10b981" /> {provider.contactEmail}
              </div>
            )}
          </div>

          <div style={{ background: 'rgba(0,0,0,0.25)', padding: '12px', borderRadius: '8px' }}>
            <span style={{ fontSize: '0.75rem', color: '#94a3b8', display: 'block', marginBottom: '4px' }}>Tariff / Pricing</span>
            <div style={{ fontSize: '1.2rem', fontWeight: 700, color: '#10b981' }}>
              ₹{provider.priceStartingINR?.toLocaleString()}
              <span style={{ fontSize: '0.75rem', color: '#94a3b8', fontWeight: 400 }}> /{provider.pricingUnit || 'night'}</span>
            </div>
            <span style={{ fontSize: '0.7rem', color: '#64748b' }}>100% Direct Community Benefit</span>
          </div>
        </div>

        <div style={{ background: 'rgba(0,0,0,0.25)', padding: '12px', borderRadius: '8px', marginBottom: '16px' }}>
          <span style={{ fontSize: '0.75rem', color: '#94a3b8', display: 'block', marginBottom: '4px' }}>Physical Location & Coordinates</span>
          <div style={{ display: 'flex', alignItems: 'center', gap: '6px', fontSize: '0.85rem', color: '#e2e8f0', marginBottom: '4px' }}>
            <MapPin size={14} color="#10b981" /> {provider.locationAddress}
          </div>
          <div style={{ fontSize: '0.75rem', color: '#64748b' }}>
            Coordinates: {provider.latitude?.toFixed(4)}, {provider.longitude?.toFixed(4)}
          </div>
        </div>

        {/* Demo Provider Disclaimer */}
        <div style={{
          background: 'rgba(245, 158, 11, 0.08)',
          border: '1px solid rgba(245, 158, 11, 0.3)',
          borderRadius: '10px',
          padding: '12px',
          marginBottom: '20px',
          display: 'flex',
          gap: '10px',
          alignItems: 'center'
        }}>
          <AlertCircle size={20} color="#f59e0b" style={{ flexShrink: 0 }} />
          <div style={{ fontSize: '0.75rem', color: '#cbd5e1' }}>
            <strong>DEMO / HACKATHON PROVIDER:</strong> Seeded prototype profile illustrating community empowerment. No payments processed on platform; external redirects only.
          </div>
        </div>

        {/* Footer Actions */}
        <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', paddingTop: '12px', borderTop: '1px solid var(--border-subtle)' }}>
          {provider.externalBookingUrl ? (
            <button
              onClick={handleOpenBooking}
              className="btn-secondary"
              style={{ fontSize: '0.8rem', padding: '8px 14px' }}
            >
              <ExternalLink size={14} /> Test External URL
            </button>
          ) : <div />}

          <div style={{ display: 'flex', gap: '10px' }}>
            {onEdit && (
              <button
                onClick={() => {
                  onClose();
                  onEdit(provider);
                }}
                className="btn-secondary"
                style={{ fontSize: '0.8rem', padding: '8px 14px' }}
              >
                <Edit3 size={14} /> Edit Provider
              </button>
            )}
            <button onClick={onClose} className="btn-primary" style={{ fontSize: '0.8rem', padding: '8px 16px' }}>
              Close
            </button>
          </div>
        </div>
      </div>
    </div>
  );
};
