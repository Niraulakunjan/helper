import { useState, useEffect } from 'react';
import { Calendar, Clock, CheckCircle, XCircle, Loader, MessageSquare, ChevronRight, MapPin, DollarSign } from 'lucide-react';
import { bookingApi } from '../api';
import { useNavigate } from 'react-router-dom';
import { motion, AnimatePresence } from 'framer-motion';

interface Booking {
  id: number;
  helper: { 
    id: number;
    user: { username: string };
    service_name: string;
    price: number;
    location: string;
  };
  date: string;
  status: string;
}

const MyBookings = () => {
  const [bookings, setBookings] = useState<Booking[]>([]);
  const [loading, setLoading] = useState(true);
  const navigate = useNavigate();

  useEffect(() => {
    fetchBookings();
  }, []);

  const fetchBookings = async () => {
    try {
      const res = await bookingApi.getMyBookings();
      setBookings(res.data);
    } catch (e) {
      console.error(e);
    } finally {
      setLoading(false);
    }
  };

  const getStatusColor = (status: string) => {
    switch (status) {
      case 'pending': return 'text-orange-400 bg-orange-400/10 border-orange-400/20';
      case 'accepted': return 'text-primary bg-primary/10 border-primary/20 shadow-[0_0_15px_rgba(0,212,170,0.1)]';
      case 'completed': return 'text-blue-400 bg-blue-400/10 border-blue-400/20';
      case 'rejected': return 'text-error bg-error/10 border-error/20';
      default: return 'text-text-muted bg-white/5 border-white/10';
    }
  };

  if (loading) return (
    <div className="flex flex-col items-center justify-center py-20 gap-4">
      <Loader className="w-10 h-10 text-primary animate-spin" />
      <p className="text-text-muted font-heading font-semibold tracking-widest uppercase text-xs">Accessing Booking Vault...</p>
    </div>
  );

  return (
    <div className="flex flex-col gap-10">
      <div className="flex flex-col md:flex-row justify-between items-end gap-4">
        <div>
          <h2 className="text-3xl font-bold text-white font-heading tracking-tight">Booking History</h2>
          <p className="text-text-muted text-sm mt-1">Manage all your requested and confirmed services.</p>
        </div>
        <div className="flex items-center gap-4 bg-white/5 border border-white/10 rounded-xl p-1 shrink-0">
           {['All', 'Active', 'Past'].map((t) => (
             <button key={t} className={`px-4 py-1.5 rounded-lg text-xs font-bold transition-all ${t === 'All' ? 'bg-primary text-white shadow-lg' : 'text-text-muted hover:text-white'}`}>
               {t}
             </button>
           ))}
        </div>
      </div>

      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-1 gap-6">
        <AnimatePresence>
          {bookings.map((b, i) => (
            <motion.div 
              key={b.id}
              initial={{ opacity: 0, x: -20 }}
              animate={{ opacity: 1, x: 0 }}
              transition={{ delay: i * 0.05 }}
              className="glass-card flex flex-col lg:flex-row items-stretch lg:items-center gap-8 group"
            >
              <div className="flex items-center gap-6 lg:border-r border-white/5 lg:pr-10">
                <div className="w-20 h-20 rounded-2xl bg-[#0B0E14] border border-white/5 flex flex-col items-center justify-center gap-1 shadow-inner group-hover:border-primary/50 transition-colors">
                  <span className="text-xs font-bold text-text-muted uppercase tracking-tighter">{new Date(b.date).toLocaleString('default', { month: 'short' })}</span>
                  <span className="text-3xl font-bold text-primary font-heading leading-none">{new Date(b.date).getDate()}</span>
                </div>
                <div className="flex flex-col">
                  <div className={`px-3 py-1 rounded-full text-[10px] font-bold uppercase border w-fit mb-3 ${getStatusColor(b.status)}`}>
                    {b.status}
                  </div>
                  <h3 className="text-xl font-bold text-white tracking-tight">{b.helper.user.username}</h3>
                  <p className="text-primary text-sm font-bold tracking-tight uppercase mt-0.5">{b.helper.service_name}</p>
                </div>
              </div>

              <div className="flex-1 grid grid-cols-2 md:grid-cols-3 gap-6">
                 <div className="flex flex-col gap-1">
                    <span className="text-[10px] text-text-muted font-bold uppercase tracking-widest">TimeSlot</span>
                    <div className="flex items-center gap-2 text-white font-medium">
                       <Clock className="w-4 h-4 text-primary" />
                       {new Date(b.date).toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' })}
                    </div>
                 </div>
                 <div className="flex flex-col gap-1">
                    <span className="text-[10px] text-text-muted font-bold uppercase tracking-widest">Financials</span>
                    <div className="flex items-center gap-2 text-white font-medium">
                       <DollarSign className="w-4 h-4 text-primary" />
                       NPR {b.helper.price.toLocaleString()}
                    </div>
                 </div>
                 <div className="hidden md:flex flex-col gap-1">
                    <span className="text-[10px] text-text-muted font-bold uppercase tracking-widest">Region</span>
                    <div className="flex items-center gap-2 text-white font-medium">
                       <MapPin className="w-4 h-4 text-primary" />
                       {b.helper.location}
                    </div>
                 </div>
              </div>

              <div className="flex items-center gap-3 lg:border-l border-white/5 lg:pl-10">
                <button 
                  onClick={() => navigate(`/chat/${b.helper.id}`)}
                  className="flex-1 lg:flex-none px-6 py-3 bg-white/5 border border-white/10 rounded-xl text-white hover:bg-white/10 transition-all flex items-center justify-center gap-3 font-semibold text-sm"
                >
                  <MessageSquare className="w-4 h-4 text-primary" />
                  Connect
                </button>
                <button className="flex-1 lg:flex-none p-3 bg-white/5 border border-white/10 rounded-xl text-text-muted hover:text-white transition-all">
                  <ChevronRight className="w-5 h-5" />
                </button>
              </div>
            </motion.div>
          ))}
        </AnimatePresence>

        {bookings.length === 0 && (
          <div className="py-20 text-center flex flex-col items-center gap-6 glass-card bg-opacity-30">
             <div className="p-6 bg-white/5 rounded-full">
                <Calendar className="w-12 h-12 text-text-dim" />
             </div>
             <div>
               <h3 className="text-2xl font-bold text-white">No active bookings</h3>
               <p className="text-text-muted max-w-xs mx-auto mt-2">Browse professionals to get started with your first service request.</p>
             </div>
             <button onClick={() => window.location.reload()} className="btn-premium px-10">Discover Pros Now</button>
          </div>
        )}
      </div>
    </div>
  );
};

export default MyBookings;
