import { useState, useEffect } from 'react';
import { useParams, useNavigate } from 'react-router-dom';
import { ArrowLeft, Calendar, CheckCircle, Loader, Info } from 'lucide-react';
import { serviceApi, bookingApi } from '../api';

interface Helper {
  id: number;
  user: { username: string };
  service_name: string;
  price: number;
}

const BookingForm = () => {
  const { id } = useParams<{ id: string }>();
  const [helper, setHelper] = useState<Helper | null>(null);
  const [date, setDate] = useState('');
  const [loading, setLoading] = useState(true);
  const [submitting, setSubmitting] = useState(false);
  const [success, setSuccess] = useState(false);
  const [error, setError] = useState('');
  
  const navigate = useNavigate();

  useEffect(() => {
    const fetchHelper = async () => {
      try {
        const res = await serviceApi.getHelperDetail(Number(id));
        setHelper(res.data);
      } catch (e) {
        console.error(e);
      } finally {
        setLoading(false);
      }
    };
    fetchHelper();
  }, [id]);

  const handleBook = async () => {
    if (!date) { setError('Please select a date'); return; }
    setSubmitting(true);
    setError('');
    try {
      await bookingApi.createBooking({
        helper_id: Number(id),
        date: new Date(date).toISOString()
      });
      setSuccess(true);
    } catch (e: any) {
      setError(e.response?.data?.detail || 'Booking failed');
    } finally {
      setSubmitting(false);
    }
  };

  if (loading) return (
    <div className="app-container justify-center items-center">
      <Loader className="w-10 h-10 text-primary animate-spin" />
    </div>
  );

  if (!helper) return (
    <div className="app-container p-6 text-center">
      <p>Helper not found</p>
      <button onClick={() => navigate(-1)} className="btn-primary mt-4">Go Back</button>
    </div>
  );

  return (
    <div className="app-container">
      <header className="p-4 flex items-center gap-4">
        <button onClick={() => navigate(-1)} className="text-white hover:text-primary">
          <ArrowLeft className="w-6 h-6" />
        </button>
        <h1 className="text-xl font-bold">Book Service</h1>
      </header>

      <main className="p-6">
        {success ? (
          <div className="flex flex-col items-center justify-center py-10 text-center gap-6">
            <CheckCircle className="w-20 h-20 text-primary" />
            <h2 className="text-2xl font-bold">Booking Confirmed!</h2>
            <p className="text-muted text-sm px-4">
              Your booking with {helper.user.username} is pending confirmation.
            </p>
            <button onClick={() => navigate('/')} className="btn-primary px-10">Done</button>
          </div>
        ) : (
          <div className="flex flex-col gap-8">
            <div className="card flex items-center gap-4">
              <div className="w-12 h-12 rounded-full bg-primary/20 flex items-center justify-center text-primary font-bold">
                {helper.user.username[0].toUpperCase()}
              </div>
              <div className="flex-1">
                <h3 className="font-bold">{helper.user.username}</h3>
                <p className="text-primary text-xs">{helper.service_name}</p>
                <p className="text-muted text-xs">NPR {helper.price} / visit</p>
              </div>
            </div>

            <div className="flex flex-col gap-4">
              <h4 className="text-sm font-semibold text-white/70">Select Date</h4>
              <div className="relative">
                <Calendar className="absolute left-4 top-1/2 -translate-y-1/2 w-5 h-5 text-primary" />
                <input 
                  type="date"
                  className="input-field pl-12"
                  value={date}
                  onChange={(e) => { setDate(e.target.value); setError(''); }}
                  min={new Date().toISOString().split('T')[0]}
                />
              </div>
              {error && (
                <div className="flex items-center gap-2 text-red-500 text-xs mt-1">
                  <Info className="w-4 h-4" />
                  {error}
                </div>
              )}
            </div>

            <button 
              onClick={handleBook}
              disabled={submitting}
              className="btn-primary mt-4"
            >
              {submitting ? <Loader className="w-5 h-5 animate-spin" /> : 'Confirm Booking'}
            </button>
          </div>
        )}
      </main>
    </div>
  );
};

export default BookingForm;
