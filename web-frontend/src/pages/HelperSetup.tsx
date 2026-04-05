import { useState, useEffect } from 'react';
import { Wrench, CheckCircle, ArrowRight, MapPin, Loader, Info } from 'lucide-react';
import { serviceApi } from '../api';
import { useAuth } from '../context/AuthContext';

interface Service { id: number; name: string; }

const HelperSetup = () => {
  const [step, setStep] = useState(0);
  const [services, setServices] = useState<Service[]>([]);
  const [selectedService, setSelectedService] = useState<Service | null>(null);
  const [price, setPrice] = useState('');
  const [location, setLocation] = useState('');
  const [loading, setLoading] = useState(true);
  const [submitting, setSubmitting] = useState(false);
  const [error, setError] = useState('');

  useEffect(() => {
    const fetchServices = async () => {
      try {
        const res = await serviceApi.getServices();
        setServices(res.data);
      } catch (e) {
        console.error(e);
      } finally {
        setLoading(false);
      }
    };
    fetchServices();
  }, []);

  const handleNext = () => {
    if (step === 0 && !selectedService) { setError('Please select a service'); return; }
    if (step === 1 && (!price || Number(price) <= 0)) { setError('Please enter a valid price'); return; }
    setError('');
    setStep(step + 1);
  };

  const { refreshProfile } = useAuth();

  const handleSubmit = async () => {
    if (!location) { setError('Please enter your location'); return; }
    setSubmitting(true);
    try {
      await serviceApi.createHelperProfile({
        service_id: selectedService?.id,
        price: Number(price),
        location: location
      });
      await refreshProfile();
    } catch (e: any) {
      setError(e.response?.data?.detail || 'Setup failed');
    } finally {
      setSubmitting(false);
    }
  };

  if (loading) return (
    <div className="app-container justify-center items-center">
      <Loader className="w-10 h-10 text-primary animate-spin" />
    </div>
  );

  return (
    <div className="app-container bg-[#0A1628]">
      <header className="p-6 bg-[#0F2040]">
        <div className="flex items-center gap-3 mb-4">
          <div className="p-2 bg-gradient-to-br from-[#7B61FF] to-[#00D4AA] rounded-xl">
            <Wrench className="w-5 h-5 text-white" />
          </div>
          <h1 className="text-xl font-bold">Helper Setup</h1>
          <span className="ml-auto text-xs text-white/30">{step + 1}/3</span>
        </div>
        
        <div className="flex gap-2">
          {[0, 1, 2].map((i) => (
            <div 
              key={i} 
              className={`h-1 flex-1 rounded-full transition-all ${
                i < step ? 'bg-[#00D4AA]' : i === step ? 'bg-[#7B61FF]' : 'bg-white/10'
              }`}
            />
          ))}
        </div>
        <p className="mt-4 text-sm text-white/70">
          {step === 0 ? 'What service do you offer?' : step === 1 ? 'Set your hourly rate' : 'Where do you work?'}
        </p>
      </header>

      <main className="flex-1 p-6 overflow-y-auto">
        {error && (
          <div className="mb-4 p-3 bg-red-500/10 border border-red-500/20 text-red-500 rounded-xl text-xs flex items-center gap-2">
            <Info className="w-4 h-4" />
            {error}
          </div>
        )}

        {step === 0 && (
          <div className="grid grid-cols-2 gap-4">
            {services.map((s) => (
              <button
                key={s.id}
                onClick={() => { setSelectedService(s); setError(''); }}
                className={`flex flex-col items-center justify-center p-6 rounded-2xl border transition-all ${
                  selectedService?.id === s.id 
                  ? 'bg-[#00D4AA]/10 border-[#00D4AA] text-[#00D4AA]' 
                  : 'bg-white/5 border-white/5 text-white/40'
                }`}
              >
                <div className={`w-12 h-12 rounded-full flex items-center justify-center mb-3 ${
                  selectedService?.id === s.id ? 'bg-[#00D4AA]/20' : 'bg-white/5'
                }`}>
                  <Wrench className="w-6 h-6" />
                </div>
                <span className="text-xs font-bold text-center">{s.name}</span>
                {selectedService?.id === s.id && <CheckCircle className="w-4 h-4 mt-2" />}
              </button>
            ))}
          </div>
        )}

        {step === 1 && (
          <div className="flex flex-col gap-6">
            <div className="flex items-center gap-2 px-4 py-2 bg-[#00D4AA]/10 border border-[#00D4AA]/20 rounded-full w-fit">
              <Wrench className="w-4 h-4 text-[#00D4AA]" />
              <span className="text-xs font-bold text-[#00D4AA]">{selectedService?.name}</span>
            </div>
            
            <div className="flex items-center bg-[#0F2040] border border-[#7B61FF]/30 rounded-2xl overflow-hidden">
              <div className="bg-[#7B61FF]/10 text-[#7B61FF] font-bold px-4 py-4 border-r border-[#7B61FF]/20">NPR</div>
              <input 
                type="number"
                className="flex-1 bg-transparent border-none text-2xl font-bold text-white px-4 outline-none"
                placeholder="0.00"
                value={price}
                onChange={(e) => { setPrice(e.target.value); setError(''); }}
              />
              <span className="pr-4 text-white/20 text-sm">/hr</span>
            </div>

            <div className="flex flex-wrap gap-2">
              {[500, 800, 1000, 1500].map(v => (
                <button 
                  key={v}
                  onClick={() => { setPrice(v.toString()); setError(''); }}
                  className="px-4 py-2 bg-white/5 border border-white/10 rounded-full text-xs text-white/60 hover:text-white"
                >
                  NPR {v}
                </button>
              ))}
            </div>
          </div>
        )}

        {step === 2 && (
          <div className="flex flex-col gap-6">
             <div className="flex gap-2">
                <div className="flex items-center gap-2 px-3 py-1.5 bg-[#00D4AA]/10 border border-[#00D4AA]/20 rounded-full text-[10px] font-bold text-[#00D4AA]">
                  {selectedService?.name}
                </div>
                <div className="flex items-center gap-2 px-3 py-1.5 bg-[#7B61FF]/10 border border-[#7B61FF]/20 rounded-full text-[10px] font-bold text-[#7B61FF]">
                  NPR {price}/hr
                </div>
             </div>

             <div className="flex items-center bg-[#0F2040] border border-[#00D4AA]/30 rounded-2xl overflow-hidden px-4">
                <MapPin className="text-[#00D4AA] w-5 h-5" />
                <input 
                  className="flex-1 bg-transparent border-none py-4 px-3 text-white text-sm outline-none"
                  placeholder="e.g. Kathmandu, Baneshwor"
                  value={location}
                  onChange={(e) => { setLocation(e.target.value); setError(''); }}
                />
             </div>

             <div className="flex flex-wrap gap-2">
              {['Kathmandu', 'Lalitpur', 'Bhaktapur', 'Pokhara'].map(loc => (
                <button 
                  key={loc}
                  onClick={() => { setLocation(loc); setError(''); }}
                  className="px-4 py-2 bg-white/5 border border-white/10 rounded-full text-xs text-white/60 flex items-center gap-2"
                >
                  <MapPin className="w-3 h-3" />
                  {loc}
                </button>
              ))}
            </div>
          </div>
        )}
      </main>

      <footer className="p-6 bg-[#0F2040] shadow-[0_-10px_20px_rgba(0,0,0,0.3)]">
        <button 
          onClick={step < 2 ? handleNext : handleSubmit}
          disabled={submitting}
          className={`btn-primary flex items-center justify-center gap-2 transition-all ${
            step < 2 ? 'bg-[#7B61FF]' : 'bg-[#00D4AA]'
          }`}
        >
          {submitting ? <Loader className="w-5 h-5 animate-spin" /> : (
            <>
              {step < 2 ? 'Continue' : 'Complete Setup'}
              {step < 2 ? <ArrowRight className="w-5 h-5" /> : <CheckCircle className="w-5 h-5" />}
            </>
          )}
        </button>
      </footer>
    </div>
  );
};

export default HelperSetup;
