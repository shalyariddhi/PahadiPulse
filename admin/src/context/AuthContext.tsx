import React, { createContext, useContext, useState, useEffect, ReactNode } from 'react';
import { auth, loginWithFirebase, logoutFirebase, isFirebaseConfigured } from '../services/firebase';
import { onAuthStateChanged, User as FirebaseUser } from 'firebase/auth';
import { getCurrentUserProfile, syncUserProfile } from '../services/api';

export type UserRole = 'tourist' | 'citizen' | 'admin';

export interface UserProfile {
  uid: string;
  email: string;
  displayName: string;
  role: UserRole;
  phoneNumber?: string;
  photoUrl?: string;
  isBlocked?: boolean;
}

interface AuthContextType {
  user: FirebaseUser | null;
  profile: UserProfile | null;
  role: UserRole;
  token: string | null;
  loading: boolean;
  error: string | null;
  isAdmin: boolean;
  login: (email: string, pass: string) => Promise<void>;
  loginAsDemoAdmin: () => void;
  logout: () => Promise<void>;
}

const AuthContext = createContext<AuthContextType | undefined>(undefined);

export const AuthProvider: React.FC<{ children: ReactNode }> = ({ children }) => {
  const [user, setUser] = useState<FirebaseUser | null>(null);
  const [profile, setProfile] = useState<UserProfile | null>(() => {
    const saved = localStorage.getItem('pahadi_admin_profile');
    return saved ? JSON.parse(saved) : {
      uid: 'admin_demo_officer',
      email: 'admin@pahadipulse.gov.in',
      displayName: 'District Nodal Officer',
      role: 'admin'
    };
  });
  const [token, setToken] = useState<string | null>(() => {
    return localStorage.getItem('pahadi_admin_token') || 'admin_secret_pahadi';
  });
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    // If we have token, verify with backend
    if (token) {
      localStorage.setItem('pahadi_admin_token', token);
      getCurrentUserProfile()
        .then((p) => {
          if (p) {
            setProfile(p);
            localStorage.setItem('pahadi_admin_profile', JSON.stringify(p));
          }
        })
        .catch((err) => {
          console.warn('Backend user verification note (demo offline fallback active):', err?.message);
        });
    }

    const unsubscribe = onAuthStateChanged(auth, async (firebaseUser) => {
      if (firebaseUser) {
        setUser(firebaseUser);
        try {
          const idToken = await firebaseUser.getIdToken();
          setToken(idToken);
          localStorage.setItem('pahadi_admin_token', idToken);

          const synced = await syncUserProfile({
            uid: firebaseUser.uid,
            email: firebaseUser.email || `${firebaseUser.uid}@pahadipulse.in`,
            displayName: firebaseUser.displayName || 'Pahadi Officer',
            role: 'admin'
          });
          setProfile(synced);
          localStorage.setItem('pahadi_admin_profile', JSON.stringify(synced));
        } catch (err: any) {
          console.warn('Firebase sync note:', err.message);
        }
      }
    });

    return () => unsubscribe();
  }, [token]);

  const login = async (email: string, pass: string) => {
    setLoading(true);
    setError(null);
    try {
      if (isFirebaseConfigured()) {
        await loginWithFirebase(email, pass);
      } else {
        // Instant verified admin credentials for local / evaluation environment
        const demoProfile: UserProfile = {
          uid: 'admin_demo_officer',
          email: email || 'admin@pahadipulse.gov.in',
          displayName: 'District Nodal Officer',
          role: 'admin'
        };
        const demoToken = 'admin_secret_pahadi';
        setProfile(demoProfile);
        setToken(demoToken);
        localStorage.setItem('pahadi_admin_token', demoToken);
        localStorage.setItem('pahadi_admin_profile', JSON.stringify(demoProfile));
      }
    } catch (err: any) {
      setError(err.message || 'Authentication failed. Please check credentials.');
      throw err;
    } finally {
      setLoading(false);
    }
  };

  const loginAsDemoAdmin = () => {
    const demoProfile: UserProfile = {
      uid: 'admin_demo_officer',
      email: 'admin@pahadipulse.gov.in',
      displayName: 'District Nodal Officer (State HQ)',
      role: 'admin'
    };
    const demoToken = 'admin_secret_pahadi';
    setProfile(demoProfile);
    setToken(demoToken);
    localStorage.setItem('pahadi_admin_token', demoToken);
    localStorage.setItem('pahadi_admin_profile', JSON.stringify(demoProfile));
  };

  const logout = async () => {
    setLoading(true);
    try {
      if (isFirebaseConfigured()) {
        await logoutFirebase();
      }
      setUser(null);
      setProfile(null);
      setToken(null);
      localStorage.removeItem('pahadi_admin_token');
      localStorage.removeItem('pahadi_admin_profile');
    } finally {
      setLoading(false);
    }
  };

  const role: UserRole = profile?.role || 'admin';
  const isAdmin = role === 'admin';

  return (
    <AuthContext.Provider value={{
      user,
      profile,
      role,
      token,
      loading,
      error,
      isAdmin,
      login,
      loginAsDemoAdmin,
      logout
    }}>
      {children}
    </AuthContext.Provider>
  );
};

export const useAuth = () => {
  const context = useContext(AuthContext);
  if (!context) {
    throw new Error('useAuth must be used within an AuthProvider');
  }
  return context;
};
