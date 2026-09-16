import React, { useState, useEffect } from 'react';
import { Mountain, ShieldCheck, Activity, Flame, LogIn } from 'lucide-react';
import { auth, isFirebaseConfigured } from '../../services/firebase';
import { onAuthStateChanged, User } from 'firebase/auth';
import { AuthModal } from '../auth/AuthModal';

interface NavbarProps {
  activeTab: string;
}

export const Navbar: React.FC<NavbarProps> = ({ activeTab }) => {
  const [showAuthModal, setShowAuthModal] = useState(false);
  const [currentUser, setCurrentUser] = useState<User | null>(null);

  useEffect(() => {
    const unsubscribe = onAuthStateChanged(auth, (user) => {
      setCurrentUser(user);
    });
    return () => unsubscribe();
  }, []);

  return (
    <>
      <header className="glass-panel" style={{ margin: '16px 24px 0 24px', padding: '14px 24px', display: 'flex', justifyContent: 'space-between', alignItems: 'center', flexWrap: 'wrap', gap: '12px' }}>
        <div style={{ display: 'flex', alignItems: 'center', gap: '14px' }}>
          <div style={{ 
            width: '42px', height: '42px', borderRadius: '12px', 
            background: 'linear-gradient(135deg, #10b981 0%, #064e3b 100%)',
            display: 'flex', alignItems: 'center', justifyContent: 'center',
            boxShadow: '0 4px 12px rgba(16, 185, 129, 0.4)'
          }}>
            <Mountain size={24} color="#fff" />
          </div>
          <div>
            <h1 style={{ fontSize: '1.25rem', fontWeight: 700, color: '#fff', display: 'flex', alignItems: 'center', gap: '8px', margin: 0 }}>
              PahadiPulse <span style={{ fontSize: '0.75rem', fontWeight: 600, color: '#10b981', background: 'rgba(16,185,129,0.15)', padding: '2px 8px', borderRadius: '12px', border: '1px solid rgba(16,185,129,0.3)' }}>ADMIN v1.0</span>
            </h1>
            <p style={{ fontSize: '0.8rem', color: '#94a3b8', margin: '2px 0 0 0' }}>
              Regional Intelligence & Sustainable Tourism Command Center | Uttarakhand
            </p>
          </div>
        </div>

        <div style={{ display: 'flex', alignItems: 'center', gap: '12px', flexWrap: 'wrap' }}>
          {/* Firebase Connection Badge */}
          <div style={{ display: 'flex', alignItems: 'center', gap: '6px', padding: '6px 12px', background: 'rgba(245,158,11,0.12)', borderRadius: '20px', border: '1px solid rgba(245,158,11,0.3)' }}>
            <Flame size={15} color="#f59e0b" />
            <span style={{ fontSize: '0.8rem', color: '#fbbf24' }}>
              Firebase: <strong>{isFirebaseConfigured() ? 'Cloud Live' : 'Ready / Active'}</strong>
            </span>
          </div>

          <div style={{ display: 'flex', alignItems: 'center', gap: '6px', padding: '6px 12px', background: 'rgba(255,255,255,0.05)', borderRadius: '20px', border: '1px solid rgba(255,255,255,0.1)' }}>
            <Activity size={15} color="#10b981" />
            <span style={{ fontSize: '0.8rem', color: '#e2e8f0' }}>ML Engine: <strong>Active</strong></span>
          </div>

          <button
            onClick={() => setShowAuthModal(true)}
            style={{ display: 'flex', alignItems: 'center', gap: '6px', padding: '6px 14px', background: 'rgba(16,185,129,0.12)', borderRadius: '20px', border: '1px solid rgba(16,185,129,0.3)', color: '#10b981', cursor: 'pointer', fontFamily: 'inherit', fontWeight: 600, fontSize: '0.8rem' }}
          >
            <ShieldCheck size={16} />
            <span>{currentUser ? currentUser.email?.split('@')[0] : 'Admin Auth'}</span>
          </button>
        </div>
      </header>

      {showAuthModal && (
        <AuthModal onClose={() => setShowAuthModal(false)} />
      )}
    </>
  );
};
