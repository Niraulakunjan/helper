import { useState } from 'react';
import { useNavigate, Link } from 'react-router-dom';
import { UserPlus, Mail, Lock, Phone, User, Loader, Wrench, Shield, CheckCircle } from 'lucide-react';
import { authApi } from '../api';
import { motion } from 'framer-motion';

const Register = () => {
  const [formData, setFormData] = useState({
    username: '',
    email: '',
    phone: '',
    password: '',
    role: 'user',
  });
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState('');
  
  const navigate = useNavigate();

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setLoading(true);
    setError('');
    try {
      await authApi.register(formData);
      navigate('/login');
    } catch (err: any) {
      setError(err.response?.data?.error || 'Registration failed');
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
        className="hidden md:flex md:w-5/12 bg-gradient-to-br from-[#0F2027] via-[#203A43] to-[#2C5364] p-12 flex-col justify-between"
      >
        <div>
          <Link to="/" className="flex items-center gap-3 no-underline">
            <div className="p-3 bg-white/10 backdrop-blur-xl rounded-2xl border border-white/10 shadow-2xl">
              <Wrench className="w-8 h-8 text-primary" />
            </div>
            <span className="text-2xl font-bold font-heading text-white tracking-tight">HouseHelper</span>
          </Link>
          
          <div className="mt-20">
            <h1 className="text-4xl font-bold font-heading text-white leading-tight">
              Join the <br />
              <span className="text-primary italic">Global Ecosystem.</span>
            </h1>
            <p className="mt-6 text-lg text-white/60 max-w-md font-light">
              Create an account to start hiring vetted professionals or offer your services to thousands of verified clients.
            </p>
          </div>
        </div>

        <div className="flex flex-col gap-6">
          {[
            'Professional Portfolio Management',
            'Secure Payment Infrastructure',
            'Real-time Communication Tools',
            'Advanced Dispute Resolution'
          ].map((text, i) => (
            <motion.div 
              key={text}
              initial={{ opacity: 0, x: -10 }}
              animate={{ opacity: 1, x: 0 }}
              transition={{ delay: 0.3 + i * 0.1 }}
              className="flex items-center gap-4 text-white/50 text-sm font-medium"
            >
              <div className="p-1 bg-primary/20 rounded-full">
                <CheckCircle className="w-4 h-4 text-primary" />
              </div>
              {text}
            </motion.div>
          ))}
        </div>
      </motion.div>

      {/* Auth Side */}
      <div className="flex-1 flex items-center justify-center p-6 md:p-12 relative overflow-y-auto">
        <div className="absolute top-0 right-0 w-full h-full opacity-5 pointer-events-none overflow-hidden">
          <div className="absolute -top-1/4 -right-1/4 w-[100vw] h-[100vw] bg-primary/20 rounded-full blur-[200px]" />
        </div>

        <motion.div 
          initial={{ opacity: 0, y: 20 }}
          animate={{ opacity: 1, y: 0 }}
          className="w-full max-w-lg"
        >
          <div className="mb-10 mt-10">
            <h2 className="text-3xl font-bold text-white font-heading">Onboarding Request</h2>
            <p className="text-text-muted mt-2">Initialize your unique service identifier.</p>
          </div>

          <form onSubmit={handleSubmit} className="flex flex-col gap-6">
            <div className="grid grid-cols-2 gap-4">
              <div className="flex flex-col gap-2">
                <label className="text-sm font-semibold text-text-muted ml-1">Account Identity</label>
                <div className="relative group">
                  <User className="absolute left-4 top-1/2 -translate-y-1/2 w-5 h-5 text-text-muted group-focus-within:text-primary transition-colors" />
                  <input 
                    type="text" 
                    className="modern-input pl-12"
                    placeholder="Global Username"
                    required
                    value={formData.username}
                    onChange={(e) => setFormData({...formData, username: e.target.value})}
                  />
                </div>
              </div>
              <div className="flex flex-col gap-2">
                <label className="text-sm font-semibold text-text-muted ml-1">Contact Reference</label>
                <div className="relative group">
                  <Phone className="absolute left-4 top-1/2 -translate-y-1/2 w-5 h-5 text-text-muted group-focus-within:text-primary transition-colors" />
                  <input 
                    type="text" 
                    className="modern-input pl-12"
                    placeholder="+977-9800000000"
                    required
                    value={formData.phone}
                    onChange={(e) => setFormData({...formData, phone: e.target.value})}
                  />
                </div>
              </div>
            </div>

            <div className="flex flex-col gap-2">
              <label className="text-sm font-semibold text-text-muted ml-1">Primary Email</label>
              <div className="relative group">
                <Mail className="absolute left-4 top-1/2 -translate-y-1/2 w-5 h-5 text-text-muted group-focus-within:text-primary transition-colors" />
                <input 
                  type="email" 
                  className="modern-input pl-12"
                  placeholder="name@organization.com"
                  required
                  value={formData.email}
                  onChange={(e) => setFormData({...formData, email: e.target.value})}
                />
              </div>
            </div>

            <div className="flex flex-col gap-2">
              <label className="text-sm font-semibold text-text-muted ml-1">Secure Credential</label>
              <div className="relative group">
                <Lock className="absolute left-4 top-1/2 -translate-y-1/2 w-5 h-5 text-text-muted group-focus-within:text-primary transition-colors" />
                <input 
                  type="password" 
                  className="modern-input pl-12"
                  placeholder="Min. 8 intricate characters"
                  required
                  value={formData.password}
                  onChange={(e) => setFormData({...formData, password: e.target.value})}
                />
              </div>
            </div>

            <div className="flex flex-col gap-4">
              <label className="text-sm font-semibold text-text-muted ml-1">Platform Role Assignment</label>
              <div className="grid grid-cols-2 gap-4">
                {[
                  { id: 'user', icon: User, title: 'Client', desc: 'Hire professional help' },
                  { id: 'helper', icon: Wrench, title: 'Professional', desc: 'Secure service requests' },
                ].map((item) => (
                  <button
                    key={item.id}
                    type="button"
                    onClick={() => setFormData({...formData, role: item.id})}
                    className={`p-4 rounded-xl border flex flex-col items-center gap-2 transition-all ${
                      formData.role === item.id 
                      ? 'bg-primary/10 border-primary text-primary shadow-[0_4px_20px_rgba(0,212,170,0.1)]' 
                      : 'bg-white/5 border-white/5 text-text-muted hover:bg-white/10'
                    }`}
                  >
                    <item.icon className="w-6 h-6 mb-1" />
                    <span className="font-bold text-sm uppercase tracking-tight">{item.title}</span>
                    <span className="text-[10px] opacity-60 text-center">{item.desc}</span>
                  </button>
                ))}
              </div>
            </div>

            {error && (
              <div className="p-4 bg-error/10 border border-error/20 text-error rounded-xl text-sm font-medium flex items-center gap-2">
                <Shield className="w-4 h-4" />
                {error}
              </div>
            )}

            <button 
              type="submit" 
              disabled={loading}
              className="btn-premium w-full mt-4 h-14"
            >
              {loading ? <Loader className="w-6 h-6 animate-spin text-white" /> : (
                <>
                   Initialize Onboarding
                  <UserPlus className="w-5 h-5" />
                </>
              )}
            </button>
          </form>

          <p className="mt-8 text-center text-text-muted text-sm pb-10">
            Already have an identifier? 
            <Link to="/login" className="text-primary hover:underline ml-2 font-bold transition-all">Authenticate Portal</Link>
          </p>
        </motion.div>
      </div>
    </div>
  );
};

export default Register;
