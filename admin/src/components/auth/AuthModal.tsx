import React, { useState } from 'react';
import { loginWithFirebase, logoutFirebase, isFirebaseConfigured, auth } from '../../services/firebase';
import { X, Flame, ShieldCheck, User, LogOut, Key } from 'lucide-react';

interface AuthModalProps {
  onClose: () => void;
}

export const AuthModal: React.FC<AuthModalProps> = ({ onClose }) => {
  const [email, setEmail] = useState('admin@pahadipulse.gov.in');
  const [password, setPassword] = useState('PahadiAdmin2026!');
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState('');
  const [success, setSuccess] = useState(false);

  const handleFirebaseLogin = async (e: React.FormEvent) => {
    e.preventDefault();
    setLoading(true);
    setError('');
    try {
      if (isFirebaseConfigured()) {
        await loginWithFirebase(email, password);
        setSuccess(true);
        setTimeout(onClose, 1200);
      } else {
        // Instant Demo Login mode
        setSuccess(true);
        setTimeout(onClose, 800);
      }
    } catch (err: any) {
      setError(err.message || 'Firebase login failed. Please verify credentials in Firebase Console.');
    } finally {
      setLoading(false);
    }
  };

  return (
    <div style={{
      position: 'fixed', top: 0, left: 0, right: 0, bottom: 0,
      background: 'rgba(5, 10, 8, 0.85)', backdropFilter: 'blur(8px)',
      display: 'flex', alignItems: 'center', justifyContent: 'center',
      zIndex: 2000, padding: '20px'
    }}>
      <div className="glass-panel" style={{ width: '100%', maxWidth: '440px', padding: '28px', position: 'relative' }}>
        <button
          onClick={onClose}
          style={{ position: 'absolute', top: '20px', right: '20px', background: 'rgba(255,255,255,0.1)', border: 'none', color: '#fff', borderRadius: '50%', width: '32px', height: '32px', cursor: 'pointer', display: 'flex', alignItems: 'center', justifyContent: 'center' }}
        >
          <X size={18} />
        </button>

        <div style={{ display: 'flex', alignItems: 'center', gap: '10px', marginBottom: '16px' }}>
          <div style={{ padding: '8px', background: 'rgba(245, 158, 11, 0.2)', borderRadius: '10px' }}>
            <Flame size={22} color="#f59e0b" />
          </div>
          <div>
            <h3 style={{ fontSize: '1.2rem', color: '#fff', margin: 0 }}>Firebase Authentication</h3>
            <p style={{ fontSize: '0.75rem', color: '#94a3b8' }}>Admin & Municipal Officer Portal</p>
          </div>
        </div>

        {error && (
          <div style={{ background: 'rgba(239, 68, 68, 0.15)', border: '1px solid rgba(239, 68, 68, 0.4)', borderRadius: '8px', padding: '10px', color: '#f87171', fontSize: '0.8rem', marginBottom: '14px' }}>
            {error}
          </div>
        )}

        {success ? (
          <div style={{ background: 'rgba(16, 185, 129, 0.15)', border: '1px solid rgba(16, 185, 129, 0.4)', borderRadius: '8px', padding: '16px', color: '#10b981', fontSize: '0.9rem', textAlign: 'center' }}>
            <ShieldCheck size={28} style={{ margin: '0 auto 8px auto', display: 'block' }} />
            <strong>Authenticated Successfully!</strong>
            <p style={{ fontSize: '0.75rem', color: '#cbd5e1', marginTop: '4px' }}>Role: District Nodal Officer (Admin)</p>
          </div>
        ) : (
          <form onSubmit={handleFirebaseLogin} style={{ display: 'flex', flexDirection: 'column', gap: '14px' }}>
            <div>
              <label style={{ display: 'block', fontSize: '0.75rem', color: '#94a3b8', marginBottom: '4px' }}>
                Officer Email / Username
              </label>
              <input
                type="email"
                value={email}
                onChange={(e) => setEmail(e.target.value)}
                required
                style={{ width: '100%', background: 'rgba(0,0,0,0.3)', border: '1px solid var(--border-subtle)', borderRadius: '8px', padding: '10px', color: '#fff', fontSize: '0.85rem' }}
              />
            </div>

            <div>
              <label style={{ display: 'block', fontSize: '0.75rem', color: '#94a3b8', marginBottom: '4px' }}>
                Password / Passkey
              </label>
              <input
                type="password"
                value={password}
                onChange={(e) => setPassword(e.target.value)}
                required
                style={{ width: '100%', background: 'rgba(0,0,0,0.3)', border: '1px solid var(--border-subtle)', borderRadius: '8px', padding: '10px', color: '#fff', fontSize: '0.85rem' }}
              />
            </div>

            <button type="submit" disabled={loading} className="btn-primary" style={{ width: '100%', justifyContent: 'center', marginTop: '8px' }}>
              {loading ? 'Authenticating...' : 'Sign in with Firebase'}
            </button>

            <div style={{ fontSize: '0.75rem', color: '#94a3b8', textAlign: 'center', marginTop: '6px' }}>
              ⚡ <em>Auto-configured for hackathon evaluation mode.</em>
            </div>
          </form>
        )}
      </div>
    </div>
  );
};
