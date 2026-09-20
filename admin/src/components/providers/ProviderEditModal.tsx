import React, { useState } from 'react';
import { LocalProvider, LocalProviderCreate, LocalProviderUpdate, ProviderCategory, Destination } from '../../types';
import { createProvider, updateProvider, deleteProvider } from '../../services/api';
import { X, Save, Trash2, Store, Plus } from 'lucide-react';

interface ProviderEditModalProps {
  provider?: LocalProvider | null;
  destinations: Destination[];
  onClose: () => void;
  onSaved: (p: LocalProvider) => void;
  onDeleted?: (id: string) => void;
}

export const ProviderEditModal: React.FC<ProviderEditModalProps> = ({
  provider,
  destinations,
  onClose,
  onSaved,
  onDeleted
}) => {
  const isEditing = !!provider;

  const [name, setName] = useState(provider?.name || '');
  const [category, setCategory] = useState<ProviderCategory>(provider?.category || 'HOMESTAY');
  const [destinationId, setDestinationId] = useState(provider?.destinationId || (destinations[0]?.id || 'nainital'));
  const [description, setDescription] = useState(provider?.description || '');
  const [ownerName, setOwnerName] = useState(provider?.ownerName || '');
  const [contactPhone, setContactPhone] = useState(provider?.contactPhone || '+91 98765 43210');
  const [contactEmail, setContactEmail] = useState(provider?.contactEmail || '');
  const [locationAddress, setLocationAddress] = useState(provider?.locationAddress || '');
  const [latitude, setLatitude] = useState(provider?.latitude || 29.3919);
  const [longitude, setLongitude] = useState(provider?.longitude || 79.4542);
  const [priceStartingINR, setPriceStartingINR] = useState(provider?.priceStartingINR || 1500);
  const [pricingUnit, setPricingUnit] = useState(provider?.pricingUnit || 'night');
  const [verified, setVerified] = useState(provider?.verified ?? true);
  const [externalBookingUrl, setExternalBookingUrl] = useState(provider?.externalBookingUrl || '');

  const [saving, setSaving] = useState(false);
  const [deleting, setDeleting] = useState(false);
  const [error, setError] = useState('');

  const categories: ProviderCategory[] = [
    'HOMESTAY', 'LOCAL_GUIDE', 'LOCAL_FOOD', 'HANDICRAFTS',
    'LOCAL_PRODUCTS', 'CULTURAL_EXPERIENCE', 'RENTAL'
  ];

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setSaving(true);
    setError('');

    try {
      const selectedDest = destinations.find((d) => d.id === destinationId);
      const destinationName = selectedDest?.name || 'Uttarakhand';

      if (isEditing && provider) {
        const updates: LocalProviderUpdate = {
          name,
          category,
          description,
          ownerName,
          contactPhone,
          contactEmail: contactEmail || undefined,
          locationAddress,
          latitude,
          longitude,
          priceStartingINR,
          pricingUnit,
          verified,
          externalBookingUrl: externalBookingUrl || undefined
        };
        const res = await updateProvider(provider.id, updates);
        onSaved(res);
      } else {
        const payload: LocalProviderCreate = {
          name,
          category,
          description,
          destinationId,
          destinationName,
          ownerName: ownerName || 'Local Host',
          contactPhone,
          contactEmail: contactEmail || undefined,
          locationAddress: locationAddress || `${destinationName}, Uttarakhand`,
          latitude,
          longitude,
          priceStartingINR,
          pricingUnit,
          verified,
          externalBookingUrl: externalBookingUrl || undefined
        };
        const res = await createProvider(payload);
        onSaved(res);
      }
      onClose();
    } catch (err: any) {
      setError(err?.response?.data?.detail || err.message || 'Failed to save provider');
    } finally {
      setSaving(false);
    }
  };

  const handleDelete = async () => {
    if (!provider || !window.confirm(`Are you sure you want to remove ${provider.name}?`)) return;
    setDeleting(true);
    try {
      await deleteProvider(provider.id);
      if (onDeleted) onDeleted(provider.id);
      onClose();
    } catch (err: any) {
      setError(err?.response?.data?.detail || err.message || 'Failed to delete provider');
    } finally {
      setDeleting(false);
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
        width: '100%', maxWidth: '680px', maxHeight: '92vh',
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

        <div style={{ display: 'flex', alignItems: 'center', gap: '10px', marginBottom: '16px' }}>
          <Store size={22} color="#10b981" />
          <div>
            <h3 style={{ fontSize: '1.25rem', color: '#fff', margin: 0 }}>
              {isEditing ? `Edit Provider: ${provider.name}` : 'Register Local Community Provider'}
            </h3>
            <p style={{ fontSize: '0.75rem', color: '#94a3b8', margin: 0 }}>
              Homestay hosts, trekking guides, handicraft artisans & local cooperatives
            </p>
          </div>
        </div>

        {error && (
          <div style={{ background: 'rgba(239, 68, 68, 0.15)', border: '1px solid rgba(239, 68, 68, 0.4)', borderRadius: '8px', padding: '10px', color: '#f87171', fontSize: '0.85rem', marginBottom: '14px' }}>
            {error}
          </div>
        )}

        <form onSubmit={handleSubmit} style={{ display: 'flex', flexDirection: 'column', gap: '14px' }}>
          {/* Row 1: Name & Category */}
          <div style={{ display: 'grid', gridTemplateColumns: '1.4fr 1fr', gap: '12px' }}>
            <div>
              <label style={{ display: 'block', fontSize: '0.75rem', color: '#94a3b8', marginBottom: '4px', fontWeight: 600 }}>
                Provider / Homestay Name
              </label>
              <input
                type="text"
                value={name}
                onChange={(e) => setName(e.target.value)}
                required
                style={{ width: '100%', background: 'rgba(0,0,0,0.3)', border: '1px solid var(--border-subtle)', borderRadius: '8px', padding: '9px 12px', color: '#fff', fontSize: '0.85rem' }}
              />
            </div>

            <div>
              <label style={{ display: 'block', fontSize: '0.75rem', color: '#94a3b8', marginBottom: '4px', fontWeight: 600 }}>
                Category
              </label>
              <select
                value={category}
                onChange={(e) => setCategory(e.target.value as ProviderCategory)}
                style={{ width: '100%', background: 'rgba(0,0,0,0.3)', border: '1px solid var(--border-subtle)', borderRadius: '8px', padding: '9px 12px', color: '#fff', fontSize: '0.85rem' }}
              >
                {categories.map((c) => (
                  <option key={c} value={c} style={{ background: '#12231b' }}>{c.replace('_', ' ')}</option>
                ))}
              </select>
            </div>
          </div>

          {/* Row 2: Destination & Owner Name */}
          <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: '12px' }}>
            <div>
              <label style={{ display: 'block', fontSize: '0.75rem', color: '#94a3b8', marginBottom: '4px', fontWeight: 600 }}>
                Associated Destination Hub
              </label>
              <select
                value={destinationId}
                onChange={(e) => setDestinationId(e.target.value)}
                style={{ width: '100%', background: 'rgba(0,0,0,0.3)', border: '1px solid var(--border-subtle)', borderRadius: '8px', padding: '9px 12px', color: '#fff', fontSize: '0.85rem' }}
              >
                {destinations.map((d) => (
                  <option key={d.id} value={d.id} style={{ background: '#12231b' }}>{d.name} ({d.district})</option>
                ))}
              </select>
            </div>

            <div>
              <label style={{ display: 'block', fontSize: '0.75rem', color: '#94a3b8', marginBottom: '4px', fontWeight: 600 }}>
                Owner / Local Host Name
              </label>
              <input
                type="text"
                value={ownerName}
                onChange={(e) => setOwnerName(e.target.value)}
                required
                style={{ width: '100%', background: 'rgba(0,0,0,0.3)', border: '1px solid var(--border-subtle)', borderRadius: '8px', padding: '9px 12px', color: '#fff', fontSize: '0.85rem' }}
              />
            </div>
          </div>

          {/* Row 3: Contact Phone & Email */}
          <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: '12px' }}>
            <div>
              <label style={{ display: 'block', fontSize: '0.75rem', color: '#94a3b8', marginBottom: '4px', fontWeight: 600 }}>
                Contact Phone
              </label>
              <input
                type="text"
                value={contactPhone}
                onChange={(e) => setContactPhone(e.target.value)}
                required
                style={{ width: '100%', background: 'rgba(0,0,0,0.3)', border: '1px solid var(--border-subtle)', borderRadius: '8px', padding: '9px 12px', color: '#fff', fontSize: '0.85rem' }}
              />
            </div>

            <div>
              <label style={{ display: 'block', fontSize: '0.75rem', color: '#94a3b8', marginBottom: '4px', fontWeight: 600 }}>
                Contact Email (Optional)
              </label>
              <input
                type="email"
                value={contactEmail}
                onChange={(e) => setContactEmail(e.target.value)}
                style={{ width: '100%', background: 'rgba(0,0,0,0.3)', border: '1px solid var(--border-subtle)', borderRadius: '8px', padding: '9px 12px', color: '#fff', fontSize: '0.85rem' }}
              />
            </div>
          </div>

          {/* Row 4: Pricing & Unit */}
          <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: '12px' }}>
            <div>
              <label style={{ display: 'block', fontSize: '0.75rem', color: '#94a3b8', marginBottom: '4px', fontWeight: 600 }}>
                Price Starting (INR)
              </label>
              <input
                type="number"
                value={priceStartingINR}
                onChange={(e) => setPriceStartingINR(parseFloat(e.target.value))}
                required
                style={{ width: '100%', background: 'rgba(0,0,0,0.3)', border: '1px solid var(--border-subtle)', borderRadius: '8px', padding: '9px 12px', color: '#fff', fontSize: '0.85rem' }}
              />
            </div>

            <div>
              <label style={{ display: 'block', fontSize: '0.75rem', color: '#94a3b8', marginBottom: '4px', fontWeight: 600 }}>
                Pricing Unit
              </label>
              <input
                type="text"
                value={pricingUnit}
                onChange={(e) => setPricingUnit(e.target.value)}
                placeholder="e.g. night, trek, person, kg"
                style={{ width: '100%', background: 'rgba(0,0,0,0.3)', border: '1px solid var(--border-subtle)', borderRadius: '8px', padding: '9px 12px', color: '#fff', fontSize: '0.85rem' }}
              />
            </div>
          </div>

          {/* Address & External Booking URL */}
          <div>
            <label style={{ display: 'block', fontSize: '0.75rem', color: '#94a3b8', marginBottom: '4px', fontWeight: 600 }}>
              Physical Village / Street Address
            </label>
            <input
              type="text"
              value={locationAddress}
              onChange={(e) => setLocationAddress(e.target.value)}
              required
              style={{ width: '100%', background: 'rgba(0,0,0,0.3)', border: '1px solid var(--border-subtle)', borderRadius: '8px', padding: '9px 12px', color: '#fff', fontSize: '0.85rem' }}
            />
          </div>

          <div>
            <label style={{ display: 'block', fontSize: '0.75rem', color: '#94a3b8', marginBottom: '4px', fontWeight: 600 }}>
              External Booking / Website / WhatsApp URL
            </label>
            <input
              type="url"
              value={externalBookingUrl}
              onChange={(e) => setExternalBookingUrl(e.target.value)}
              placeholder="https://wa.me/919876543210 or https://airbnb.com/..."
              style={{ width: '100%', background: 'rgba(0,0,0,0.3)', border: '1px solid var(--border-subtle)', borderRadius: '8px', padding: '9px 12px', color: '#fff', fontSize: '0.85rem' }}
            />
          </div>

          {/* Verified Toggle */}
          <div style={{ display: 'flex', alignItems: 'center', gap: '8px', padding: '8px 0' }}>
            <input
              type="checkbox"
              id="verifiedCheck"
              checked={verified}
              onChange={(e) => setVerified(e.target.checked)}
              style={{ accentColor: '#10b981', width: '16px', height: '16px' }}
            />
            <label htmlFor="verifiedCheck" style={{ fontSize: '0.85rem', color: '#fff', cursor: 'pointer' }}>
              Mark as Verified Community Partner (PahadiPulse Endorsed)
            </label>
          </div>

          {/* Description */}
          <div>
            <label style={{ display: 'block', fontSize: '0.75rem', color: '#94a3b8', marginBottom: '4px', fontWeight: 600 }}>
              Provider Description
            </label>
            <textarea
              value={description}
              onChange={(e) => setDescription(e.target.value)}
              rows={3}
              required
              style={{ width: '100%', background: 'rgba(0,0,0,0.3)', border: '1px solid var(--border-subtle)', borderRadius: '8px', padding: '10px', color: '#fff', fontSize: '0.85rem' }}
            />
          </div>

          <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginTop: '8px' }}>
            {isEditing ? (
              <button
                type="button"
                onClick={handleDelete}
                disabled={deleting}
                style={{
                  background: 'rgba(239, 68, 68, 0.15)', border: '1px solid rgba(239, 68, 68, 0.4)',
                  color: '#ef4444', borderRadius: '8px', padding: '8px 14px', fontSize: '0.8rem',
                  fontWeight: 600, cursor: 'pointer', display: 'flex', alignItems: 'center', gap: '6px'
                }}
              >
                <Trash2 size={14} />
                {deleting ? 'Deleting...' : 'Delete Provider'}
              </button>
            ) : <div />}

            <div style={{ display: 'flex', gap: '10px' }}>
              <button type="button" onClick={onClose} className="btn-secondary">
                Cancel
              </button>
              <button type="submit" disabled={saving} className="btn-primary">
                <Save size={16} />
                {saving ? 'Saving...' : isEditing ? 'Update Provider' : 'Register Provider'}
              </button>
            </div>
          </div>
        </form>
      </div>
    </div>
  );
};
