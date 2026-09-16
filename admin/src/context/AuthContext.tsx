import React, { createContext, useContext, useState, useEffect, ReactNode } from 'react';
import { auth, loginWithFirebase, logoutFirebase, isFirebaseConfigured } from '../services/firebase';
import { onAuthStateChanged, User as FirebaseUser } from 'firebase/auth';
import axios from 'axios';

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
  logout: () => Promise<void>;
}

const AuthContext = createContext<AuthContextType | undefined>(undefined);

export const AuthProvider: React.FC<{ children: ReactNode }> = ({ children }) => {
  const [user, setUser] = useState<FirebaseUser | null>(null);
  const [profile, setProfile] = useState<UserProfile | null>(null);
  const [token, setToken] = useState<string | null>(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    const unsubscribe = onAuthStateChanged(auth, async (firebaseUser) => {
      setLoading(true);
      setError(null);

      if (firebaseUser) {
        setUser(firebaseUser);
        try {
          const idToken = await firebaseUser.getIdToken();
          setToken(idToken);

          // Sync user with backend API
          const syncRes = await axios.post(
            'http://localhost:8000/api/auth/sync-user',
            {
              uid: firebaseUser.uid,
              email: firebaseUser.email,
              displayName: firebaseUser.displayName || 'Pahadi Officer',
              role: 'admin' // Initial admin officer persona for Admin portal
            },
            {
              headers: { Authorization: `Bearer ${idToken}` }
            }
          );
          setProfile(syncRes.data);
        } catch (err: any) {
          console.warn('Backend profile sync note:', err.message);
          // Fallback profile if backend sync offline
          setProfile({
            uid: firebaseUser.uid,
            email: firebaseUser.email || '',
            displayName: firebaseUser.displayName || 'Officer',
            role: 'admin'
          });
        }
      } else {
        setUser(null);
        setProfile(null);
        setToken(null);
      }
      setLoading(false);
    });

    return () => unsubscribe();
  }, []);

  const login = async (email: string, pass: string) => {
    setLoading(true);
    setError(null);
    try {
      if (isFirebaseConfigured()) {
        await loginWithFirebase(email, pass);
      } else {
        // Simulated admin login when demo mode is active
        const demoProfile: UserProfile = {
          uid: 'admin_officer_demo',
          email,
          displayName: 'District Nodal Officer',
          role: 'admin'
        };
        setProfile(demoProfile);
        setToken('admin_secret_pahadi');
      }
    } catch (err: any) {
      setError(err.message || 'Authentication failed. Please verify credentials.');
      throw err;
    } finally {
      setLoading(false);
    }
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
    } finally {
      setLoading(false);
    }
  };

  const role: UserRole = profile?.role || 'tourist';
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
