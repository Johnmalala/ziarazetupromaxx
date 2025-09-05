import React, { useState } from 'react';
import { motion } from 'framer-motion';
import { Send, User, Calendar, DollarSign, Map, Users } from 'lucide-react';
import { supabase } from '../lib/supabase';
import { useAuth } from '../hooks/useAuth';
import { useNavigate } from 'react-router-dom';

const CustomPackagesPage: React.FC = () => {
  const { user } = useAuth();
  const navigate = useNavigate();
  const [formData, setFormData] = useState({
    trip_details: '',
    budget: '',
    destination: '',
    travel_dates: '',
    travelers: '1',
  });
  const [loading, setLoading] = useState(false);
  const [status, setStatus] = useState<{ type: 'success' | 'error', message: string } | null>(null);

  const handleInputChange = (e: React.ChangeEvent<HTMLInputElement | HTMLTextAreaElement | HTMLSelectElement>) => {
    setFormData(prev => ({ ...prev, [e.target.name]: e.target.value }));
  };

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!user) {
      navigate('/auth');
      return;
    }

    setLoading(true);
    setStatus(null);

    try {
      const { error } = await supabase.from('custom_requests').insert({
        user_id: user.id,
        trip_details: `
          Destination: ${formData.destination}
          Travel Dates: ${formData.travel_dates}
          Travelers: ${formData.travelers}
          Details: ${formData.trip_details}
        `,
        budget: parseFloat(formData.budget),
      });

      if (error) throw error;

      setStatus({ type: 'success', message: 'Your custom trip request has been sent! Our team will contact you shortly.' });
      setFormData({ trip_details: '', budget: '', destination: '', travel_dates: '', travelers: '1' });
    } catch (err) {
      setStatus({ type: 'error', message: err instanceof Error ? err.message : 'Failed to send request. Please try again.' });
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className="min-h-screen pt-16 bg-gray-50">
      <section className="py-16 text-center">
        <h1 className="text-4xl md:text-5xl font-bold mb-4">Design Your Dream Trip</h1>
        <p className="text-xl text-gray-600 max-w-3xl mx-auto">
          Tell us your travel dreams, and we'll craft a personalized East African adventure just for you.
        </p>
      </section>

      <section className="pb-16">
        <div className="max-w-3xl mx-auto px-4 sm:px-6 lg:px-8">
          <motion.div
            initial={{ opacity: 0, y: 50 }}
            animate={{ opacity: 1, y: 0 }}
            className="bg-white p-8 rounded-lg shadow-lg"
          >
            <form onSubmit={handleSubmit} className="space-y-6">
              <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-2">Destination(s)</label>
                  <div className="relative">
                    <Map className="absolute left-3 top-1/2 -translate-y-1/2 w-5 h-5 text-gray-400" />
                    <input type="text" name="destination" value={formData.destination} onChange={handleInputChange} required className="w-full pl-10 border-gray-300 rounded-md shadow-sm" placeholder="e.g., Serengeti, Zanzibar" />
                  </div>
                </div>
                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-2">Ideal Travel Dates</label>
                  <div className="relative">
                    <Calendar className="absolute left-3 top-1/2 -translate-y-1/2 w-5 h-5 text-gray-400" />
                    <input type="text" name="travel_dates" value={formData.travel_dates} onChange={handleInputChange} required className="w-full pl-10 border-gray-300 rounded-md shadow-sm" placeholder="e.g., June 2025" />
                  </div>
                </div>
              </div>
              <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-2">Number of Travelers</label>
                  <div className="relative">
                    <Users className="absolute left-3 top-1/2 -translate-y-1/2 w-5 h-5 text-gray-400" />
                    <select name="travelers" value={formData.travelers} onChange={handleInputChange} className="w-full pl-10 border-gray-300 rounded-md shadow-sm">
                      {[...Array(10)].map((_, i) => <option key={i + 1} value={i + 1}>{i + 1} Traveler{i > 0 && 's'}</option>)}
                      <option value="10+">10+ Travelers</option>
                    </select>
                  </div>
                </div>
                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-2">Budget per Person (USD)</label>
                  <div className="relative">
                    <DollarSign className="absolute left-3 top-1/2 -translate-y-1/2 w-5 h-5 text-gray-400" />
                    <input type="number" name="budget" value={formData.budget} onChange={handleInputChange} required className="w-full pl-10 border-gray-300 rounded-md shadow-sm" placeholder="e.g., 2000" />
                  </div>
                </div>
              </div>
              <div>
                <label className="block text-sm font-medium text-gray-700 mb-2">Trip Details & Interests</label>
                <textarea name="trip_details" rows={6} value={formData.trip_details} onChange={handleInputChange} required className="w-full border-gray-300 rounded-md shadow-sm" placeholder="Tell us what you'd like to see and do. e.g., wildlife safari, cultural tours, beach relaxation, specific activities..."></textarea>
              </div>
              {status && (
                <div className={`p-3 rounded-md text-sm ${status.type === 'success' ? 'bg-green-100 text-green-800' : 'bg-red-100 text-red-800'}`}>
                  {status.message}
                </div>
              )}
              <div>
                <button type="submit" disabled={loading} className="w-full flex justify-center items-center space-x-2 bg-red-600 text-white px-6 py-3 rounded-md hover:bg-red-700 transition-colors disabled:opacity-50">
                  <Send className="w-5 h-5" />
                  <span>{loading ? 'Sending Request...' : 'Request My Custom Package'}</span>
                </button>
              </div>
              {!user && <p className="text-center text-sm text-gray-500 mt-4">You will be asked to sign in or create an account.</p>}
            </form>
          </motion.div>
        </div>
      </section>
    </div>
  );
};

export default CustomPackagesPage;
