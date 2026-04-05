import { useState } from 'react';
import { useNavigate, Link } from 'react-router-dom';
import { Wrench, Mail, Lock, Loader, ArrowRight, Shield, Zap, Star } from 'lucide-react';
import { useAuth } from '../context/AuthContext';
import { motion } from 'framer-motion';

const Login = () => {
  const [formData, setFormData] = useState({ username: '', password: '' });
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState('');
  
  const { login } = useAuth();
  const navigate = useNavigate();

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setLoading(true);
    setError('');
    try {
      await login(formData);
      navigate('/');
    } catch (err: any) {
      setError(err.response?.data?.error || 'Login failed');
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className="min-h-screen flex flex-col md:flex-row bg-[#0B0E14]">
      {/* Branding Side - Hidden on Mobile */}
      <motion.div 
        initial={{ opacity: 0, x: -20 }}
        animate={{ opacity: 1, x: 0 }}
        className="hidden md:flex md:w-1/2 bg-gradient-to-br from-[#0F2027] via-[#203A43] to-[#2C5364] p-12 flex-col justify-between relative overflow-hidden"
      >
        <div className="absolute top-0 right-0 w-full h-full opacity-10 pointer-events-none">
          <svg className="w-full h-full" viewBox="0 0 100 100" preserveAspectRatio="none">
            <path d="M0 100 L100 0 L100 100 Z" fill="white" />
          </svg>
        </div>

        <div className="relative z-10">
          <Link to="/" className="flex items-center gap-3 no-underline">
            <div className="p-3 bg-white/10 backdrop-blur-xl rounded-2xl border border-white/10 shadow-2xl">
              <Wrench className="w-8 h-8 text-primary" />
            </div>
            <span className="text-2xl font-bold font-heading text-white tracking-tight">HouseHelper</span>
          </Link>
          
          <div className="mt-20">
            <h1 className="text-5xl font-bold font-heading text-white leading-tight">
              Elevate Your <br />
              <span className="text-primary italic">Service Standards.</span>
            </h1>
            <p className="mt-6 text-xl text-white/60 max-w-md font-light leading-relaxed">
              The premier platform connecting elite service professionals with discerning clients. 
              Efficiency, transparency, and trust, all in one place.
            </p>
          </div>
        </div>

        <div className="grid grid-cols-2 gap-6 relative z-10">
          {[
            { icon: Shield, title: 'Verified Pros', text: 'Vetted background checks' },
            { icon: Zap, title: 'Instant Booking', text: 'Real-time scheduling' },
            { icon: Star, title: 'Elite Quality', text: 'Top-rated performance' },
            { icon: Mail, title: 'Direct Chat', text: 'Secure communication' },
          ].map((item, i) => (
            <motion.div 
              key={item.title}
              initial={{ opacity: 0, y: 10 }}
              animate={{ opacity: 1, y: 0 }}
              transition={{ delay: 0.2 + i * 0.1 }}
              className="p-4 rounded-2xl bg-white/5 border border-white/5 backdrop-blur-sm"
            >
              <item.icon className="w-6 h-6 text-primary mb-2" />
              <h3 className="text-white text-sm font-bold">{item.title}</h3>
              <p className="text-white/40 text-xs mt-1">{item.text}</p>
            </motion.div>
          ))}
        </div>
      </motion.div>

      {/* Auth Side */}
      <div className="flex-1 flex items-center justify-center p-6 md:p-12 relative">
        {/* Subtle Background Elements */}
        <div className="absolute top-1/4 -right-20 w-80 h-80 bg-primary/10 rounded-full blur-[100px] pointer-events-none" />
        <div className="absolute bottom-1/4 -left-20 w-60 h-60 bg-secondary/10 rounded-full blur-[80px] pointer-events-none" />

        <motion.div 
          initial={{ opacity: 0, y: 20 }}
          animate={{ opacity: 1, y: 0 }}
          className="w-full max-w-md"
        >
          <div className="md:hidden flex items-center gap-3 mb-10 no-underline">
            <Wrench className="w-8 h-8 text-primary" />
            <span className="text-2xl font-bold font-heading text-white tracking-tight">HouseHelper</span>
          </div>

          <div className="mb-10">
            <h2 className="text-3xl font-bold text-white font-heading">Welcome Back</h2>
            <p className="text-text-muted mt-2">Enterprise-grade service management portal.</p>
          </div>

          <form onSubmit={handleSubmit} className="flex flex-col gap-6">
            <div className="flex flex-col gap-2">
              <label className="text-sm font-semibold text-text-muted ml-1">Username / Identifier</label>
              <div className="relative group">
                <Mail className="absolute left-4 top-1/2 -translate-y-1/2 w-5 h-5 text-text-muted group-focus-within:text-primary transition-colors" />
                <input 
                  type="text" 
                  name="username"
                  className="modern-input pl-12"
                  placeholder="name@company.com"
                  required
                  value={formData.username}
                  onChange={(e) => setFormData({...formData, username: e.target.value})}
                />
              </div>
            </div>

            <div className="flex flex-col gap-2">
              <div className="flex justify-between items-center ml-1">
                <label className="text-sm font-semibold text-text-muted">Security Credential</label>
                <Link to="/forgot" className="text-xs text-primary hover:underline font-medium">Reset Access?</Link>
              </div>
              <div className="relative group">
                <Lock className="absolute left-4 top-1/2 -translate-y-1/2 w-5 h-5 text-text-muted group-focus-within:text-primary transition-colors" />
                <input 
                  type="password" 
                  name="password"
                  className="modern-input pl-12"
                  placeholder="••••••••"
                  required
                  value={formData.password}
                  onChange={(e) => setFormData({...formData, password: e.target.value})}
                />
              </div>
            </div>

            {error && (
              <motion.div 
                initial={{ opacity: 0, scale: 0.95 }}
                animate={{ opacity: 1, scale: 1 }}
                className="p-4 bg-error/10 border border-error/20 text-error rounded-xl text-sm font-medium flex items-center gap-2"
              >
                <Shield className="w-4 h-4" />
                {error}
              </motion.div>
            )}

            <button 
              type="submit" 
              disabled={loading}
              className="btn-premium w-full mt-4 h-14"
            >
              {loading ? <Loader className="w-6 h-6 animate-spin text-white" /> : (
                <>
                  Authenticate Access
                  <ArrowRight className="w-5 h-5" />
                </>
              )}
            </button>
          </form>

          <p className="mt-10 text-center text-text-muted text-sm">
            Don't have an enterprise account? 
            <Link to="/register" className="text-primary hover:underline ml-2 font-bold transition-all">Request Onboarding</Link>
          </p>
        </motion.div>
      </div>
    </div>
  );
};

export default Login;
