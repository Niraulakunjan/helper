import { useState, useEffect } from 'react';
import { Search, Star, MapPin, ChevronRight, Sliders } from 'lucide-react';
import { Skeleton } from './Skeleton';
import { serviceApi } from '../api';
import { useNavigate } from 'react-router-dom';
import { motion, AnimatePresence } from 'framer-motion';

interface Helper {
  id: number;
  user: { username: string };
  service_name: string;
  price: number;
  location: string;
  rating: number;
}

const Discover = () => {
  const [helpers, setHelpers] = useState<Helper[]>([]);
  const [loading, setLoading] = useState(true);
  const [searchQuery, setSearchQuery] = useState('');
  const [selectedCategory, setSelectedCategory] = useState<number | null>(null);
  const [categories, setCategories] = useState<{ id: number, name: string }[]>([]);

  const navigate = useNavigate();

  useEffect(() => {
    fetchData();
  }, []);

  const fetchData = async () => {
    setLoading(true);
    try {
      const [sRes, hRes] = await Promise.all([serviceApi.getServices(), serviceApi.getHelpers()]);
      setCategories(sRes.data);
      setHelpers(hRes.data);
    } catch (e) {
      console.error(e);
    } finally {
      setLoading(false);
    }
  };

  const filteredHelpers = helpers.filter(h => 
    (h.user.username.toLowerCase().includes(searchQuery.toLowerCase()) || 
     h.service_name.toLowerCase().includes(searchQuery.toLowerCase())) &&
    (!selectedCategory || categories.find(c => c.id === selectedCategory)?.name === h.service_name)
  );

  return (
    <div className="flex flex-col gap-8 pb-32">
      {/* Platform Controls */}
      <div className="flex flex-col md:flex-row gap-4 items-center">
        <div className="flex-1 w-full bg-white/5 border border-white/10 rounded-2xl p-4 flex items-center gap-4 group focus-within:border-primary/50 transition-all shadow-lg focus-within:shadow-primary/5">
          <Search className="text-text-muted group-focus-within:text-primary transition-colors" />
          <input 
            type="text" 
            placeholder="Search for 'Plumber', 'Electrician', or name..."
            className="bg-transparent border-none outline-none text-white w-full font-medium"
            value={searchQuery}
            onChange={(e) => setSearchQuery(e.target.value)}
          />
        </div>
        <button className="flex items-center gap-3 px-6 py-4 bg-white/5 border border-white/10 rounded-2xl text-text-muted hover:text-white transition-all font-semibold hover:border-white/30 shrink-0">
          <Sliders className="w-5 h-5" />
          More Filters
        </button>
      </div>

      {/* Category Chips - Quick Selection */}
      <div className="flex gap-3 overflow-x-auto pb-4 no-scrollbar">
        <button 
          onClick={() => setSelectedCategory(null)}
          className={`px-6 py-2 rounded-full border text-sm font-bold whitespace-nowrap transition-all ${
            selectedCategory === null ? 'bg-primary border-primary text-white shadow-lg' : 'bg-white/5 border-white/10 text-text-muted hover:text-white'
          }`}
        >
          All Pros
        </button>
        {categories.map(cat => (
          <button 
            key={cat.id}
            onClick={() => setSelectedCategory(cat.id)}
            className={`px-6 py-2 rounded-full border text-sm font-bold whitespace-nowrap transition-all ${
              selectedCategory === cat.id ? 'bg-primary border-primary text-white shadow-lg' : 'bg-white/5 border-white/10 text-text-muted hover:text-white'
            }`}
          >
            {cat.name}
          </button>
        ))}
      </div>

      {/* Professional Listing Grid */}
      {loading ? (
            <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6 p-4">
              {[...Array(6)].map((_, i) => (
                <div key={i} className="glass-card p-4 flex flex-col gap-4" style={{ minHeight: '150px' }}>
                  <Skeleton type="rect" width="100%" height="1.5rem" className="mb-2" />
                  <Skeleton type="rect" width="60%" height="1rem" className="mb-2" />
                  <Skeleton type="rect" width="80%" height="1rem" />
                </div>
              ))}
            </div>
          ) : (
        <div className="res-grid">
          <AnimatePresence>
            {filteredHelpers.map((h, i) => (
              <motion.div 
                key={h.id}
                initial={{ opacity: 0, y: 20 }}
                animate={{ opacity: 1, y: 0 }}
                transition={{ delay: i * 0.05 }}
                className="glass-card group flex flex-col gap-6"
                onClick={() => navigate(`/helper/${h.id}`)}
              >
                <div className="flex justify-between items-start">
                  <div className="w-16 h-16 rounded-2xl bg-gradient-to-br from-primary to-secondary p-0.5 shadow-lg group-hover:rotate-6 transition-transform">
                    <div className="w-full h-full bg-[#0B0E14] rounded-2xl flex items-center justify-center">
                      <span className="text-2xl font-bold font-heading text-primary">{h.user.username[0].toUpperCase()}</span>
                    </div>
                  </div>
                  <div className="flex flex-col items-end gap-1">
                    <span className="text-xs text-text-muted uppercase tracking-widest font-bold">Price Range</span>
                    <div className="text-xl font-bold font-heading text-white">NPR {h.price.toLocaleString()}</div>
                  </div>
                </div>

                <div className="flex flex-col gap-2">
                  <h3 className="text-xl font-bold text-white tracking-tight group-hover:text-primary transition-colors">{h.user.username}</h3>
                  <div className="flex items-center gap-2 text-primary font-bold text-sm tracking-tight uppercase">
                    <div className="w-1.5 h-1.5 rounded-full bg-primary" />
                    {h.service_name} Expert
                  </div>
                </div>

                <div className="flex items-center gap-6 mt-2 pt-6 border-t border-white/5">
                  <div className="flex items-center gap-2">
                    <MapPin className="w-4 h-4 text-text-muted" />
                    <span className="text-xs font-semibold text-text-muted">{h.location}</span>
                  </div>
                  <div className="flex items-center gap-2">
                    <Star className="w-4 h-4 text-yellow-500 fill-yellow-500" />
                    <span className="text-xs font-semibold text-text-muted">{h.rating || 'New'}</span>
                  </div>
                  <div className="ml-auto w-8 h-8 rounded-full bg-white/5 flex items-center justify-center group-hover:bg-primary/20 group-hover:text-primary transition-all">
                    <ChevronRight className="w-5 h-5" />
                  </div>
                </div>
              </motion.div>
            ))}
          </AnimatePresence>

          {filteredHelpers.length === 0 && (
            <div className="col-span-full py-20 text-center flex flex-col items-center gap-4">
               <div className="p-6 bg-white/5 rounded-full mb-4">
                  <Search className="w-12 h-12 text-text-dim" />
               </div>
               <h3 className="text-2xl font-bold text-white">No matches found</h3>
               <p className="text-text-muted max-w-xs mx-auto mb-6">Try adjusting your refine parameters or check our system categories again.</p>
               <button onClick={() => { setSearchQuery(''); setSelectedCategory(null); }} className="px-8 py-3 bg-white/5 border border-white/10 rounded-xl text-white font-bold hover:bg-white/10 transition-colors">Clear All Filters</button>
            </div>
          )}
        </div>
      )}
    </div>
  );
};

export default Discover;
