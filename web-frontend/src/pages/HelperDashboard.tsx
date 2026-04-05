import { useState, useEffect } from 'react';
import { LayoutDashboard, Calendar, MessageSquare, Star, DollarSign, Clock, CheckCircle, XCircle, ChevronRight, User, TrendingUp, AlertCircle, Zap } from 'lucide-react';
import { Skeleton } from '../components/Skeleton';
import { bookingApi } from '../api';
import { motion, AnimatePresence } from 'framer-motion';

const HelperDashboard = () => {
  const [bookings, setBookings] = useState<any[]>([]);
  const [loading, setLoading] = useState(true);
  const [activeTab, setActiveTab] = useState<'requests' | 'overview'>('requests');

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

  const handleStatusUpdate = async (id: number, status: string) => {
    try {
      await bookingApi.updateStatus(id, status);
      fetchBookings();
    } catch (e) {
      console.error(e);
    }
  };

  const stats = [
    { label: 'Active Requests', value: bookings.filter(b => b.status === 'pending').length, icon: Calendar, color: 'text-orange-400' },
    { label: 'Avg. Rating', value: '4.9', icon: Star, color: 'text-yellow-500' },
    { label: 'Job Completion', value: '98%', icon: CheckCircle, color: 'text-primary' },
    { label: 'Total Earnings', value: 'NPR 45.2K', icon: DollarSign, color: 'text-blue-500' },
  ];

  if (loading) return (
   <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6 p-4">
     {[...Array(4)].map((_, i) => (
       <div key={i} className="glass-card p-4 flex flex-col gap-4" style={{ minHeight: '150px' }}>
         <Skeleton type="rect" width="100%" height="1.5rem" className="mb-2" />
         <Skeleton type="rect" width="60%" height="1rem" className="mb-2" />
         <Skeleton type="rect" width="80%" height="1rem" />
       </div>
     ))}
   </div>
 );

  return (
    <div className="container flex flex-col gap-10">
      {/* Dashboard Header */}
      <div className="flex flex-col md:flex-row justify-between items-start md:items-end gap-6">
        <div>
           <div className="flex items-center gap-3 mb-2">
              <div className="w-2 h-2 rounded-full bg-primary animate-pulse" />
              <span className="text-xs font-bold text-primary uppercase tracking-widest">Live Platform Status: Operational</span>
           </div>
           <h1 className="text-4xl font-bold text-white font-heading tracking-tight">Professional Console</h1>
           <p className="text-text-muted mt-1">Manage your service pipeline and performance metrics.</p>
        </div>
        <div className="flex items-center gap-4 bg-white/5 border border-white/10 rounded-2xl p-6 shadow-xl">
           <TrendingUp className="w-8 h-8 text-primary opacity-50" />
           <div>
              <div className="text-[10px] font-bold text-text-muted uppercase">Platform Visibility</div>
              <div className="text-xl font-bold text-white">92nd Percentile</div>
           </div>
        </div>
      </div>

      {/* Stats Grid */}
      <div className="grid grid-cols-2 lg:grid-cols-4 gap-6">
        {stats.map((s, i) => (
          <motion.div 
            key={s.label}
            initial={{ opacity: 0, y: 20 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ delay: i * 0.1 }}
            className="glass-card flex flex-col gap-4 p-8 group overflow-hidden relative"
          >
            <div className={`absolute -right-4 -top-4 w-20 h-20 rounded-full opacity-5 group-hover:opacity-10 transition-opacity flex items-center justify-center ${s.color} bg-current`} />
            <div className={`p-3 rounded-xl w-fit ${s.color} bg-opacity-10`}>
               <s.icon className="w-6 h-6" />
            </div>
            <div>
               <div className="text-3xl font-bold text-white font-heading">{s.value}</div>
               <div className="text-xs font-bold text-text-muted uppercase tracking-wider mt-1">{s.label}</div>
            </div>
          </motion.div>
        ))}
      </div>

      <div className="grid grid-cols-1 lg:grid-cols-3 gap-10">
        {/* Main Feed */}
        <div className="lg:col-span-2 flex flex-col gap-6">
           <div className="flex items-center justify-between">
              <div className="flex gap-4">
                 <button 
                  onClick={() => setActiveTab('requests')}
                  className={`text-sm font-bold pb-2 transition-all border-b-2 ${activeTab === 'requests' ? 'border-primary text-white' : 'border-transparent text-text-muted hover:text-white'}`}
                 >
                   Service Pipeline
                 </button>
                 <button 
                  onClick={() => setActiveTab('overview')}
                  className={`text-sm font-bold pb-2 transition-all border-b-2 ${activeTab === 'overview' ? 'border-primary text-white' : 'border-transparent text-text-muted hover:text-white'}`}
                 >
                   Recent Activity
                 </button>
              </div>
              <button className="text-[10px] font-bold text-primary uppercase tracking-widest hover:underline">View All Records</button>
           </div>

           <AnimatePresence mode="wait">
             {activeTab === 'requests' ? (
               <motion.div 
                key="requests"
                initial={{ opacity: 0, x: -10 }}
                animate={{ opacity: 1, x: 0 }}
                exit={{ opacity: 0, x: 10 }}
                className="flex flex-col gap-4"
               >
                 {bookings.filter(b => b.status === 'pending').map((b) => (
                   <div key={b.id} className="glass-card flex flex-col md:flex-row items-center justify-between gap-6 group hover:bg-white/[0.04]">
                      <div className="flex items-center gap-6">
                        <div className="w-14 h-14 rounded-2xl bg-white/5 flex items-center justify-center group-hover:bg-primary/10 transition-colors">
                           <User className="text-text-muted group-hover:text-primary" />
                        </div>
                        <div>
                           <div className="text-xs font-bold text-primary uppercase tracking-tighter mb-0.5">Incoming Request</div>
                           <h4 className="text-xl font-bold text-white tracking-tight">{b.user.username}</h4>
                           <div className="flex items-center gap-4 mt-2">
                              <div className="flex items-center gap-1.5 text-xs text-text-muted font-semibold">
                                 <Clock className="w-3.5 h-3.5" />
                                 {new Date(b.date).toLocaleString([], { hour: '2-digit', minute: '2-digit' })}
                              </div>
                              <div className="flex items-center gap-1.5 text-xs text-text-muted font-semibold">
                                 <Calendar className="w-3.5 h-3.5" />
                                 {new Date(b.date).toLocaleDateString()}
                              </div>
                           </div>
                        </div>
                      </div>

                      <div className="flex items-center gap-3 w-full md:w-auto">
                        <button 
                          onClick={() => handleStatusUpdate(b.id, 'accepted')}
                          className="flex-1 md:flex-none p-3 bg-primary/10 border border-primary/20 text-primary rounded-xl hover:bg-primary hover:text-white transition-all shadow-lg shadow-primary/5"
                        >
                          <CheckCircle className="w-5 h-5" />
                        </button>
                        <button 
                          onClick={() => handleStatusUpdate(b.id, 'rejected')}
                          className="flex-1 md:flex-none p-3 bg-error/10 border border-error/20 text-error rounded-xl hover:bg-error hover:text-white transition-all shadow-lg shadow-error/5"
                        >
                          <XCircle className="w-5 h-5" />
                        </button>
                        <button className="flex-1 md:flex-none p-3 bg-white/5 border border-white/10 rounded-xl text-text-muted hover:text-white transition-all">
                          <MessageSquare className="w-5 h-5" />
                        </button>
                      </div>
                   </div>
                 ))}
                 
                 {bookings.filter(b => b.status === 'pending').length === 0 && (
                   <div className="flex flex-col items-center justify-center py-20 bg-white/5 border border-dashed border-white/10 rounded-[2rem]">
                      <AlertCircle className="w-10 h-10 text-text-dim mb-4" />
                      <h4 className="text-xl font-bold text-white/40">No Pending Requests</h4>
                      <p className="text-xs text-text-dim mt-2 tracking-tight uppercase font-bold">Your pipeline is currently clear</p>
                   </div>
                 )}
               </motion.div>
             ) : (
               <motion.div 
                key="overview"
                initial={{ opacity: 0, x: -10 }}
                animate={{ opacity: 1, x: 0 }}
                exit={{ opacity: 0, x: 10 }}
                className="flex flex-col gap-4"
               >
                 {bookings.filter(b => b.status !== 'pending').slice(0, 5).map((b) => (
                   <div key={b.id} className="flex items-center justify-between p-6 bg-white/5 rounded-2xl border border-white/5">
                      <div className="flex items-center gap-4">
                         <div className={`p-2 rounded-lg ${b.status === 'accepted' ? 'text-primary bg-primary/10' : 'text-text-muted bg-white/5'}`}>
                            {b.status === 'accepted' ? <CheckCircle className="w-4 h-4" /> : <Clock className="w-4 h-4" />}
                         </div>
                         <div>
                            <div className="text-sm font-bold text-white">{b.user.username}</div>
                            <div className="text-[10px] font-bold text-text-muted uppercase">{b.status} • {new Date(b.date).toLocaleDateString()}</div>
                         </div>
                      </div>
                      <ChevronRight className="w-4 h-4 text-text-dim" />
                   </div>
                 ))}
               </motion.div>
             )}
           </AnimatePresence>
        </div>

        {/* Sidebar Info */}
        <aside className="flex flex-col gap-8">
           <div className="glass-card bg-gradient-to-br from-secondary/10 to-transparent border-secondary/20 shadow-2xl shadow-secondary/5">
              <h4 className="text-lg font-bold text-white mb-4">Pro Success Tips</h4>
              <div className="flex flex-col gap-6">
                 {[
                   { title: 'Response Time', desc: 'Accept requests within 15 mins to boost visibility.', icon: Zap },
                   { title: 'Profile Completeness', desc: 'Add more services to appear in more searches.', icon: LayoutDashboard },
                 ].map(tip => (
                   <div key={tip.title} className="flex gap-4">
                      <div className="p-2 bg-secondary/10 rounded-lg h-fit">
                         <tip.icon className="w-4 h-4 text-secondary" />
                      </div>
                      <div>
                         <div className="text-sm font-bold text-white">{tip.title}</div>
                         <p className="text-xs text-text-muted mt-1 leading-relaxed">{tip.desc}</p>
                      </div>
                   </div>
                 ))}
              </div>
           </div>

           <div className="p-8 bg-primary/10 rounded-[2rem] border border-primary/20">
              <div className="text-xs font-bold text-primary uppercase tracking-widest mb-4">Verification Status</div>
              <div className="flex items-center gap-4">
                 <div className="w-12 h-12 rounded-full border-4 border-primary border-r-transparent flex items-center justify-center">
                    <CheckCircle className="w-6 h-6 text-primary" />
                 </div>
                 <div>
                    <div className="text-lg font-bold text-white">Full Verified</div>
                    <div className="text-xs font-bold text-primary/60 uppercase">Enterprise Protocol</div>
                 </div>
              </div>
           </div>
        </aside>
      </div>
    </div>
  );
};

export default HelperDashboard;
