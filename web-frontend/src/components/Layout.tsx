import React from 'react';
import { useNavigate, useLocation, Link } from 'react-router-dom';
import { Wrench, Search, MessageSquare, LogOut, LayoutDashboard, Calendar, Menu, X } from 'lucide-react';
import { useAuth } from '../context/AuthContext';
import { ToastProvider } from '../context/ToastContext';
import { motion, AnimatePresence } from 'framer-motion';

const Layout: React.FC<{ children: React.ReactNode }> = ({ children }) => {
  const { user, logout } = useAuth();
  const navigate = useNavigate();
  const location = useLocation();
  const [isMenuOpen, setIsMenuOpen] = React.useState(false);

  const navItems = user?.role === 'helper'
    ? [
        { label: 'Dashboard', path: '/', icon: LayoutDashboard },
        { label: 'Messages', path: '/chat', icon: MessageSquare },
      ]
    : [
        { label: 'Discover', path: '/', icon: Search },
        { label: 'My Bookings', path: '/bookings', icon: Calendar },
      ];

  const handleLogout = () => {
    logout();
    navigate('/login');
  };

  return (
    <ToastProvider>
      <div className="page-container">
        <nav className="navbar">
          <div className="container flex items-center justify-between">
            <Link to="/" className="flex items-center gap-3 no-underline text-white">
              <div className="p-2 bg-gradient-to-br from-primary to-secondary rounded-xl shadow-lg shadow-primary/20">
                <Wrench className="w-6 h-6 text-white" />
              </div>
              <span className="text-xl font-bold font-heading tracking-tight">HouseHelper</span>
            </Link>

            {/* Desktop Nav */}
            <div className="hidden md:flex items-center gap-8">
              {navItems.map((item) => (
                <Link
                  key={item.path}
                  to={item.path}
                  className={`flex items-center gap-2 text-sm font-medium transition-colors hover:text-primary no-underline ${location.pathname === item.path ? 'text-primary' : 'text-text-muted'}`}
                >
                  <item.icon className="w-4 h-4" />
                  {item.label}
                </Link>
              ))}

              <div className="h-6 w-px bg-border mx-2" />

              <div className="flex items-center gap-4">
                <span className="text-sm font-semibold text-text-muted">{user?.username}</span>
                <button
                  onClick={handleLogout}
                  className="p-2 hover:bg-white/5 rounded-full transition-colors text-text-muted hover:text-error"
                  title="Logout"
                >
                  <LogOut className="w-5 h-5" />
                </button>
              </div>
            </div>

            {/* Mobile Toggle */}
            <button
              className="md:hidden p-2 text-white"
              onClick={() => setIsMenuOpen(!isMenuOpen)}
            >
              {isMenuOpen ? <X /> : <Menu />}
            </button>
          </div>
        </nav>

        {/* Mobile Menu */}
        <AnimatePresence>
          {isMenuOpen && (
            <motion.div
              initial={{ opacity: 0, height: 0 }}
              animate={{ opacity: 1, height: 'auto' }}
              exit={{ opacity: 0, height: 0 }}
              className="md:hidden bg-background border-b border-border overflow-hidden"
            >
              <div className="container py-6 flex flex-col gap-4">
                {navItems.map((item) => (
                  <Link
                    key={item.path}
                    to={item.path}
                    onClick={() => setIsMenuOpen(false)}
                    className={`flex items-center gap-4 p-4 rounded-xl no-underline ${location.pathname === item.path ? 'bg-primary/10 text-primary' : 'text-text-muted hover:bg-white/5'}`}
                  >
                    <item.icon className="w-5 h-5" />
                    <span className="font-semibold">{item.label}</span>
                  </Link>
                ))}
                <div className="h-px bg-border my-2" />
                <button
                  onClick={handleLogout}
                  className="flex items-center gap-4 p-4 text-error font-semibold hover:bg-error/5 rounded-xl transition-colors"
                >
                  <LogOut className="w-5 h-5" />
                  Logout
                </button>
              </div>
            </motion.div>
          )}
        </AnimatePresence>

        <main className="flex-1">
          <AnimatePresence mode="wait">
            <motion.div
              key={location.pathname}
              initial={{ opacity: 0, scale: 0.98 }}
              animate={{ opacity: 1, scale: 1 }}
              exit={{ opacity: 0, scale: 1.02 }}
              transition={{ duration: 0.3, ease: 'easeOut' }}
              className="py-10"
            >
              {children}
            </motion.div>
          </AnimatePresence>
        </main>

        <footer className="py-10 border-t border-border mt-auto">
          <div className="container flex flex-col md:flex-row justify-between items-center gap-6">
            <div className="flex items-center gap-3 text-text-muted opacity-50 grayscale">
              <Wrench className="w-5 h-5" />
              <span className="text-sm font-semibold tracking-widest uppercase">HouseHelper Platform</span>
            </div>
            <p className="text-xs text-text-muted">© 2026 HouseHelper. All rights reserved.</p>
          </div>
        </footer>
      </div>
    </ToastProvider>
  );
};

export default Layout;
