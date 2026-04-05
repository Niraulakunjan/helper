import React, { createContext, useContext, useState, useEffect } from 'react';
import { authApi } from '../api';

interface User {
  id: number;
  username: string;
  email: string;
  phone: string;
  role: string;
  hasHelperProfile: boolean;
}

interface AuthContextType {
  user: User | null;
  loading: boolean;
  login: (credentials: any) => Promise<void>;
  register: (userData: any) => Promise<void>;
  logout: () => void;
  refreshProfile: () => Promise<void>;
  isLoggedIn: boolean;
}

const AuthContext = createContext<AuthContextType | undefined>(undefined);

export const AuthProvider: React.FC<{ children: React.ReactNode }> = ({ children }) => {
  const [user, setUser] = useState<User | null>(null);
  const [loading, setLoading] = useState(true);

  const mapUser = (data: any): User => ({
    id: data.id,
    username: data.username,
    email: data.email,
    phone: data.phone,
    role: data.role,
    hasHelperProfile: data.has_helper_profile,
  });

  const refreshProfile = async () => {
    const token = localStorage.getItem('token');
    if (token) {
      try {
        const response = await authApi.getProfile();
        setUser(mapUser(response.data));
      } catch (error) {
        localStorage.removeItem('token');
        setUser(null);
      }
    }
  };

  useEffect(() => {
    const tryAutoLogin = async () => {
      await refreshProfile();
      setLoading(false);
    };
    tryAutoLogin();
  }, []);

  const login = async (credentials: any) => {
    setLoading(true);
    try {
      const response = await authApi.login(credentials);
      const { access, user } = response.data;
      localStorage.setItem('token', access);
      setUser(mapUser(user));
    } finally {
      setLoading(false);
    }
  };

  const register = async (userData: any) => {
    setLoading(true);
    try {
      await authApi.register(userData);
    } finally {
      setLoading(false);
    }
  };

  const logout = () => {
    localStorage.removeItem('token');
    setUser(null);
  };

  return (
    <AuthContext.Provider value={{ user, loading, login, register, logout, refreshProfile, isLoggedIn: !!user }}>
      {children}
    </AuthContext.Provider>
  );
};

export const useAuth = () => {
  const context = useContext(AuthContext);
  if (context === undefined) {
    throw new Error('useAuth must be used within an AuthProvider');
  }
  return context;
};
