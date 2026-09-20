import React, { useState } from 'react';
import { useAuth } from '../../context/AuthContext';
import { Mountain, Shield, ShieldCheck, Key, Flame, AlertCircle, ArrowRight, CheckCircle2 } from 'lucide-react';
import { isFirebaseConfigured } from '../../services/firebase';

interface LoginPageProps {
  onSuccess?: () => void;
}

export const LoginPage: React.FC<LoginPageProps> = ({ onSuccess }) => {
  const { login, loginAsDemoAdmin, error, loading } = useAuth();
  const [email, setEmail] = useState('admin@pahadipulse.gov.in');
  const [password, setPassword] = useState('PahadiAdmin2026!');
  const [localError, setLocalError] = useState('');

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setLocalError('');
    try {
      await login(email, password);
      if (onSuccess) onSuccess();
    } catch (err: any) {
      setLocalError(err.message || 'Login failed. Please verify credentials.');
    }
  };

  const handleDemoQuickLogin = () => {
    loginAsDemoAdmin();
    if (onSuccess) onSuccess();
  };

  return (
    <div style={{
      minHeight: '100vh',
      display: 'flex',
      alignItems: 'center',
      justifyContent: 'center',
      padding: '24px',
      position: 'relative'
    }}>
      <div className="glass-panel" style={{
        width: '100%',
        maxWidth: '460px',
        padding: '36px',
        borderRadius: '20px',
        boxShadow: '0 20px 50px rgba(0,0,0,0.6)',
        border: '1px solid var(--border-active)'
      }}>
        {/* Brand Header */}
        <div style={{ display: 'flex', flexDirection: 'column', alignItems: 'center', textAlign: 'center', marginBottom: '28px' }}>
          <div style={{
            width: '56px', height: '56px', borderRadius: '16px',
            background: 'linear-gradient(135deg, #10b981 0%, #064e3b 100%)',
            display: 'flex', alignItems: 'center', justifyContent: 'center',
            boxShadow: '0 8px 24px rgba(16, 185, 129, 0.4)',
            marginBottom: '16px'
          }}>
            <Mountain size={32} color="#fff" />
          </div>
          
          <h1 style={{ fontSize: '1.6rem', color: '#fff', margin: '0 0 6px 0', letterSpacing: '-0.02em' }}>
            PahadiPulse <span style={{ color: '#10b981' }}>Admin</span>
          </h1>
          <p style={{ fontSize: '0.85rem', color: '#94a3b8', margin: 0 }}>
            Uttarakhand Regional Tourism & Carrying Capacity Command Portal
          </p>
        </div>

        {(error || localError) && (
          <div style={{
            background: 'rgba(239, 68, 68, 0.15)',
            border: '1px solid rgba(239, 68, 68, 0.4)',
            borderRadius: '10px',
            padding: '12px 14px',
            color: '#f87171',
            fontSize: '0.85rem',
            marginBottom: '18px',
            display: 'flex',
            alignItems: 'center',
            gap: '8px'
          }}>
            <AlertCircle size={18} />
            <span>{error || localError}</span>
          </div>
        )}

        <form onSubmit={handleSubmit} style={{ display: 'flex', flexDirection: 'column', gap: '16px' }}>
          <div>
            <label style={{ display: 'block', fontSize: '0.8rem', color: '#cbd5e1', marginBottom: '6px', fontWeight: 600 }}>
              Officer Official Email
            </label>
            <input
              type="email"
              value={email}
              onChange={(e) => setEmail(e.target.value)}
              required
              placeholder="officer@pahadipulse.gov.in"
              style={{
                width: '100%',
                background: 'rgba(0,0,0,0.4)',
                border: '1px solid var(--border-subtle)',
                borderRadius: '10px',
                padding: '12px 14px',
                color: '#fff',
                fontSize: '0.9rem'
              }}
            />
          </div>

          <div>
            <label style={{ display: 'block', fontSize: '0.8rem', color: '#cbd5e1', marginBottom: '6px', fontWeight: 600 }}>
              Secure Password / Passkey
            </label>
            <input
              type="password"
              value={password}
              onChange={(e) => setPassword(e.target.value)}
              required
              placeholder="••••••••••••"
              style={{
                width: '100%',
                background: 'rgba(0,0,0,0.4)',
                border: '1px solid var(--border-subtle)',
                borderRadius: '10px',
                padding: '12px 14px',
                color: '#fff',
                fontSize: '0.9rem'
              }}
            />
          </div>

          <button
            type="submit"
            disabled={loading}
            className="btn-primary"
            style={{ width: '100%', justifyContent: 'center', padding: '12px', fontSize: '0.95rem', marginTop: '8px' }}
          >
            {loading ? 'Authenticating...' : 'Sign In as Designated Officer'}
            <ArrowRight size={16} />
          </button>
        </form>

        <div style={{ margin: '20px 0', display: 'flex', alignItems: 'center', gap: '10px' }}>
          <div style={{ flex: 1, height: '1px', background: 'var(--border-subtle)' }} />
          <span style={{ fontSize: '0.75rem', color: '#64748b', textTransform: 'uppercase' }}>or quick evaluate</span>
          <div style={{ flex: 1, height: '1px', background: 'var(--border-subtle)' }} />
        </div>

        {/* Quick Demo Button */}
        <button
          onClick={handleDemoQuickLogin}
          type="button"
          style={{
            width: '100%',
            background: 'rgba(16, 185, 129, 0.12)',
            border: '1px solid rgba(16, 185, 129, 0.35)',
            borderRadius: '10px',
            padding: '10px 14px',
            color: '#10b981',
            fontWeight: 600,
            fontSize: '0.85rem',
            cursor: 'pointer',
            display: 'flex',
            alignItems: 'center',
            justifyContent: 'center',
            gap: '8px',
            transition: 'all 0.2s ease'
          }}
        >
          <ShieldCheck size={16} />
          ⚡ Launch Instant Demo Admin Session
        </button>

        <div style={{ marginTop: '24px', padding: '12px', background: 'rgba(255,255,255,0.03)', borderRadius: '10px', border: '1px solid var(--border-subtle)' }}>
          <div style={{ display: 'flex', alignItems: 'center', gap: '8px', fontSize: '0.75rem', color: '#94a3b8' }}>
            <Shield size={14} color="#10b981" />
            <span>Role-Based Access Control enforced on all backend API endpoints.</span>
          </div>
        </div>
      </div>
    </div>
  );
};
