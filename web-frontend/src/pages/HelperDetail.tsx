import { useState, useEffect } from 'react';
import { useParams, useNavigate } from 'react-router-dom';
import { Star, MapPin, MessageSquare, Calendar, Loader, ArrowLeft, Shield, Clock, Zap, DollarSign, Award, CheckCircle } from 'lucide-react';
import { serviceApi } from '../api';

const HelperDetail = () => {
  const { id } = useParams();
  const [helper, setHelper] = useState<any>(null);
  const [loading, setLoading] = useState(true);
  const navigate = useNavigate();

  useEffect(() => {
    const fetchDetail = async () => {
      try {
        const res = await serviceApi.getHelperDetail(Number(id));
        setHelper(res.data);
      } catch (e) {
        console.error(e);
      } finally {
        setLoading(false);
      }
    };
    fetchDetail();
  }, [id]);

  if (loading) return (
    <div className="flex flex-col items-center justify-center py-40 gap-4">
      <Loader className="w-12 h-12 text-primary animate-spin" />
      <p className="text-text-muted font-heading font-semibold tracking-widest uppercase text-xs">Synchronizing Profile Data...</p>
    </div>
  );

  return (
    <div className="container">
      <button 
        onClick={() => navigate(-1)}
        className="flex items-center gap-2 text-text-muted hover:text-white transition-all mb-8 font-bold text-sm tracking-tight uppercase"
      >
        <ArrowLeft className="w-4 h-4" />
        Return to Platform Discovery
      </button>

      <div className="grid grid-cols-1 lg:grid-cols-3 gap-12">
        {/* Main Profile Info */}
        <div className="lg:col-span-2 flex flex-col gap-10">
          <section className="flex flex-col md:flex-row gap-8 items-center md:items-end p-10 glass-card bg-gradient-to-br from-white/[0.03] to-transparent relative overflow-hidden">
             <div className="absolute top-0 right-0 w-64 h-64 bg-primary/10 rounded-full blur-[100px] pointer-events-none" />
             
             <div className="relative">
                <div className="w-40 h-40 rounded-[2.5rem] bg-gradient-to-br from-primary to-secondary p-1 shadow-2xl">
                  <div className="w-full h-full bg-[#0B0E14] rounded-[2.25rem] flex items-center justify-center">
                    <span className="text-6xl font-bold font-heading text-primary">{helper.user.username[0].toUpperCase()}</span>
                  </div>
                </div>
                <div className="absolute -bottom-2 -right-2 p-3 bg-primary text-white rounded-2xl shadow-xl border-4 border-[#0B0E14]">
                   <Shield className="w-6 h-6" />
                </div>
             </div>

             <div className="flex-1 text-center md:text-left">
                <div className="flex flex-wrap items-center justify-center md:justify-start gap-3 mb-4">
                   <div className="px-4 py-1.5 bg-primary/20 border border-primary/30 rounded-full text-[10px] font-bold text-primary uppercase tracking-widest">
                     ID Verified Profile
                   </div>
                   <div className="flex items-center gap-1.5 px-4 py-1.5 bg-yellow-500/10 border border-yellow-500/30 rounded-full text-[10px] font-bold text-yellow-500 uppercase tracking-widest">
                     <Star className="w-3.5 h-3.5 fill-yellow-500" />
                     Top Rated Professional
                   </div>
                </div>
                <h1 className="text-5xl font-bold text-white font-heading mb-2 tracking-tight">{helper.user.username}</h1>
                <div className="flex items-center justify-center md:justify-start gap-4 text-text-muted">
                   <div className="flex items-center gap-2 font-semibold">
                      <Zap className="w-4 h-4 text-primary" />
                      {helper.service_name} Expert
                   </div>
                   <div className="w-1 h-1 rounded-full bg-white/20" />
                   <div className="flex items-center gap-2 font-semibold">
                      <MapPin className="w-4 h-4 text-primary" />
                      {helper.location}
                   </div>
                </div>
             </div>
          </section>

          {/* Detailed Info Sections */}
          <div className="grid grid-cols-1 md:grid-cols-2 gap-8">
             <div className="glass-card flex flex-col gap-4">
                <div className="flex items-center gap-3 text-white font-bold">
                   <Award className="w-5 h-5 text-primary" />
                   Professional Bio
                </div>
                <p className="text-text-muted leading-relaxed">
                  Dedicated {helper.service_name} specialist with extensive experience across premium residential projects. 
                  Committed to delivering high-fidelity craftsmanship, punctuality, and transparent communication.
                </p>
             </div>
             <div className="glass-card flex flex-col gap-4">
                <div className="flex items-center gap-3 text-white font-bold">
                   <Clock className="w-5 h-5 text-primary" />
                   Operational Standard
                </div>
                <div className="flex flex-col gap-3">
                   {[
                     'Immediate Response Times',
                     'Equipment Included in Service',
                     'Full Job Warranty Provided',
                     'Standard Safety Protocol Followed'
                   ].map(u => (
                     <div key={u} className="flex items-center gap-3 text-sm text-text-muted">
                        <CheckCircle className="w-4 h-4 text-primary/50" />
                        {u}
                     </div>
                   ))}
                </div>
             </div>
          </div>
        </div>

        {/* Action Sidebar */}
        <aside className="lg:sticky lg:top-32 h-fit">
           <div className="glass-card border-primary/20 bg-primary/[0.02] flex flex-col gap-8 shadow-2xl shadow-primary/5">
              <div className="flex justify-between items-center pb-6 border-b border-white/5">
                 <span className="text-text-muted font-bold tracking-tight">Service Rate</span>
                 <div className="flex items-baseline gap-1">
                    <span className="text-3xl font-bold text-white font-heading">NPR {helper.price.toLocaleString()}</span>
                    <span className="text-text-muted text-sm font-semibold">/hr</span>
                 </div>
              </div>

              <div className="flex flex-col gap-4">
                 <button 
                  onClick={() => navigate(`/book/${id}`)}
                  className="btn-premium py-5 text-lg group"
                 >
                   Establish Booking
                   <Calendar className="w-5 h-5 group-hover:rotate-12 transition-transform" />
                 </button>
                 <button 
                  onClick={() => navigate(`/chat/${helper.user.id}`)}
                  className="flex items-center justify-center gap-3 w-full py-4 bg-white/5 border border-white/10 rounded-2xl text-white font-bold hover:bg-white/10 transition-all text-sm"
                 >
                   <MessageSquare className="w-5 h-5 text-primary" />
                   Initiate Message
                 </button>
              </div>

              <div className="p-4 bg-[#0B0E14]/50 rounded-2xl border border-white/5">
                 <div className="flex items-center gap-3 text-xs font-bold text-yellow-500/80 mb-2">
                    <DollarSign className="w-4 h-4" />
                    TRANSACTIONAL SECURITY
                 </div>
                 <p className="text-[10px] text-text-muted leading-relaxed">
                   Payments are securely processed after service confirmation. Total amount may vary based on exact job duration.
                 </p>
              </div>
           </div>
        </aside>
      </div>
    </div>
  );
};

export default HelperDetail;
