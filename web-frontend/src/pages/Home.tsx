import { useState } from 'react';
import { Search, MapPin, Star, Shield, Zap, ArrowRight, Wrench, Calendar, MessageCircle, Play } from 'lucide-react';
import Discover from '../components/Discover';
import MyBookings from '../components/MyBookings';
import { motion, AnimatePresence } from 'framer-motion';

const Home = () => {
  const [activeTab, setActiveTab] = useState<'discover' | 'bookings'>('discover');

  return (
    <div className="container">
      {/* Header Info Section - Premium Landing Feel */}
      <AnimatePresence mode="wait">
        {activeTab === 'discover' && (
          <motion.section 
            initial={{ opacity: 0, y: -20 }}
            animate={{ opacity: 1, y: 0 }}
            exit={{ opacity: 0, scale: 0.95 }}
            className="mb-16"
          >
            <div className="flex flex-col md:flex-row gap-12 items-center">
              <div className="flex-1">
                <div className="inline-flex items-center gap-2 px-4 py-2 bg-primary/10 rounded-full border border-primary/20 text-primary text-xs font-bold uppercase tracking-widest mb-6 translate-y-0 hover:translate-y-[-2px] transition-all cursor-default">
                  <Zap className="w-3 h-3 fill-primary" />
                  Marketplace for Elite Professionals
                </div>
                <h1 className="text-5xl md:text-6xl font-bold font-heading text-white leading-[1.1] mb-6">
                  Expert help, <br />
                  <span className="text-transparent bg-clip-text bg-gradient-to-r from-primary to-secondary">Reimagined for You.</span>
                </h1>
                <p className="text-xl text-text-muted max-w-lg mb-8 font-light">
                  Join thousands of homeowners who trust HouseHelper for vetted, background-checked professionals in plumbing, electrical, and beyond.
                </p>
                <div className="flex flex-wrap gap-4">
                  <div className="flex items-center gap-2 px-6 py-4 bg-white/5 border border-white/10 rounded-2xl">
                    <Shield className="w-5 h-5 text-primary" />
                    <span className="text-sm font-semibold">100% Verified</span>
                  </div>
                  <div className="flex items-center gap-2 px-6 py-4 bg-white/5 border border-white/10 rounded-2xl">
                    <Star className="w-5 h-5 text-yellow-500 fill-yellow-500" />
                    <span className="text-sm font-semibold">4.9/5 Avg. Rating</span>
                  </div>
                </div>
              </div>

              <div className="flex-1 relative">
                <div className="absolute top-1/2 left-1/2 -translate-x-1/2 -translate-y-1/2 w-72 h-72 bg-primary/20 rounded-full blur-[100px] pointer-events-none" />
                <div className="grid grid-cols-2 gap-4">
                  {[
                    { icon: Wrench, label: 'Plumbing', color: 'bg-blue-500' },
                    { icon: Zap, label: 'Electrical', color: 'bg-yellow-500' },
                    { icon: Shield, label: 'Cleaning', color: 'bg-green-500' },
                    { icon: Star, label: 'Carpentry', color: 'bg-orange-500' },
                  ].map((cat, i) => (
                    <motion.div 
                      key={cat.label}
                      initial={{ opacity: 0, scale: 0.9 }}
                      animate={{ opacity: 1, scale: 1 }}
                      transition={{ delay: 0.2 + i * 0.1 }}
                      className="glass-card flex flex-col items-center justify-center gap-4 p-8 group cursor-pointer"
                    >
                      <div className={`p-4 rounded-2xl ${cat.color} bg-opacity-10 text-white group-hover:scale-110 transition-transform shadow-xl`}>
                        <cat.icon className="w-8 h-8" />
                      </div>
                      <span className="font-bold tracking-tight text-white/80 group-hover:text-primary transition-colors">{cat.label}</span>
                    </motion.div>
                  ))}
                </div>
              </div>
            </div>
          </motion.section>
        )}
      </AnimatePresence>

      {/* Main Action Tabs */}
      <div className="flex items-center justify-center gap-2 mb-10 p-1.5 bg-white/5 border border-white/10 rounded-2xl w-fit mx-auto">
        <button
          onClick={() => setActiveTab('discover')}
          className={`flex items-center gap-2 px-8 py-3 rounded-xl font-bold transition-all ${
            activeTab === 'discover' ? 'bg-primary text-white shadow-xl shadow-primary/20' : 'text-text-muted hover:text-white'
          }`}
        >
          <Search className="w-4 h-4" />
          Discover Service
        </button>
        <button
          onClick={() => setActiveTab('bookings')}
          className={`flex items-center gap-2 px-8 py-3 rounded-xl font-bold transition-all ${
            activeTab === 'bookings' ? 'bg-primary text-white shadow-xl shadow-primary/20' : 'text-text-muted hover:text-white'
          }`}
        >
          <Calendar className="w-4 h-4" />
          My Bookings
        </button>
      </div>

      {/* Dynamic Content */}
      <AnimatePresence mode="wait">
        {activeTab === 'discover' ? (
          <motion.div 
            key="discover" 
            initial={{ opacity: 0, y: 10 }}
            animate={{ opacity: 1, y: 0 }}
            exit={{ opacity: 0, y: -10 }}
          >
            <Discover />
          </motion.div>
        ) : (
          <motion.div 
            key="bookings"
            initial={{ opacity: 0, y: 10 }}
            animate={{ opacity: 1, y: 0 }}
            exit={{ opacity: 0, y: -10 }}
          >
            <MyBookings />
          </motion.div>
        )}
      </AnimatePresence>
    </div>
  );
};

export default Home;
