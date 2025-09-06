import React, { useState, useEffect } from 'react';
import { motion } from 'framer-motion';
import { Send, Map, Calendar, DollarSign, Users, Sparkles, User, Mail, Phone, MessageCircle } from 'lucide-react';
import { supabase } from '../lib/supabase';
import { useAuth } from '../hooks/useAuth';
import { useNavigate } from 'react-router-dom';
import toast from 'react-hot-toast';

const CustomPackagesPage: React.FC = () => {
  const { user } = useAuth();
  const navigate = useNavigate();
  const [formData, setFormData] = useState({
    full_name: '',
    email: '',
    phone: '',
    whatsapp_number: '',
    trip_details: '',
    budget: '',
    destination: '',
    travel_dates: '',
    travelers: '1',
  });
  const [loading, setLoading] = useState(false);

  useEffect(() => {
    if (user) {
      setFormData(prev => ({
        ...prev,
        email: user.email || '',
      }));
      // Fetch profile to get full name if available
      supabase.from('profiles').select('full_name').eq('id', user.id).single().then(({ data }) => {
        if (data?.full_name) {
          setFormData(prev => ({ ...prev, full_name: data.full_name! }));
        }
      });
    }
  }, [user]);

  const handleInputChange = (e: React.ChangeEvent<HTMLInputElement | HTMLTextAreaElement | HTMLSelectElement>) => {
    setFormData(prev => ({ ...prev, [e.target.name]: e.target.value }));
  };

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!user) {
      toast.error("Please sign in to request a custom package.");
      navigate('/signin?redirect=/custom-packages');
      return;
    }

    setLoading(true);
    const toastId = toast.loading('Sending your request...');

    try {
      const { error } = await supabase.from('custom_requests').insert({
        user_id: user.id,
        full_name: formData.full_name,
        email: formData.email,
        phone: formData.phone,
        whatsapp_number: formData.whatsapp_number,
        trip_details: `
          Destination: ${formData.destination}
          Travel Dates: ${formData.travel_dates}
          Travelers: ${formData.travelers}
          Details: ${formData.trip_details}
        `,
        budget: parseFloat(formData.budget),
        status: 'Pending',
      });

      if (error) throw error;

      toast.success('Request sent! We will contact you shortly.', { id: toastId });
      setFormData({
        ...formData,
        trip_details: '',
        budget: '',
        destination: '',
        travel_dates: '',
        travelers: '1',
      });
      navigate('/profile'); // Navigate to profile to see the request
    } catch (err) {
      toast.error(err instanceof Error ? err.message : 'Failed to send request.', { id: toastId });
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className="min-h-screen bg-gray-50">
      <section className="relative bg-gradient-to-t from-red-900 via-red-800 to-red-700 text-white py-20">
        <div 
          className="absolute inset-0 bg-cover bg-center opacity-20"
          style={{ backgroundImage: 'url(https://images.unsplash.com/photo-1523906834658-6e24ef2386f9?w=1600)' }}
        />
        <div className="relative max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 text-center">
          <motion.h1 
            initial={{ opacity: 0, y: 20 }}
            animate={{ opacity: 1, y: 0 }}
            className="text-4xl md:text-5xl font-bold mb-4"
          >
            Craft Your Perfect East African Adventure
          </motion.h1>
          <motion.p 
            initial={{ opacity: 0, y: 20 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ delay: 0.1 }}
            className="text-xl max-w-3xl mx-auto text-red-100"
          >
            Your dream itinerary, our expert planning. Tell us what you envision, and we'll make it a reality.
          </motion.p>
        </div>
      </section>

      <section className="py-16">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
          <div className="grid grid-cols-1 lg:grid-cols-5 gap-12">
            <motion.div 
              initial={{ opacity: 0, x: -50 }}
              animate={{ opacity: 1, x: 0 }}
              className="lg:col-span-3 bg-white p-8 rounded-2xl shadow-lg"
            >
              <h2 className="text-2xl font-bold mb-6 text-gray-900">Tell Us Your Travel Vision</h2>
              <form onSubmit={handleSubmit} className="space-y-6">
                <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
                  <div>
                    <label className="block text-sm font-medium text-gray-700 mb-2">Full Name *</label>
                    <div className="relative">
                      <User className="absolute left-3 top-1/2 -translate-y-1/2 w-5 h-5 text-gray-400" />
                      <input type="text" name="full_name" value={formData.full_name} onChange={handleInputChange} required className="w-full pl-10 pr-4 py-3 border border-gray-300 rounded-xl focus:ring-2 focus:ring-red-500 focus:border-transparent" placeholder="Your full name" />
                    </div>
                  </div>
                  <div>
                    <label className="block text-sm font-medium text-gray-700 mb-2">Email Address *</label>
                    <div className="relative">
                      <Mail className="absolute left-3 top-1/2 -translate-y-1/2 w-5 h-5 text-gray-400" />
                      <input type="email" name="email" value={formData.email} onChange={handleInputChange} required className="w-full pl-10 pr-4 py-3 border border-gray-300 rounded-xl focus:ring-2 focus:ring-red-500 focus:border-transparent" placeholder="Your email address" />
                    </div>
                  </div>
                </div>
                <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
                  <div>
                    <label className="block text-sm font-medium text-gray-700 mb-2">Phone Number *</label>
                    <div className="relative">
                      <Phone className="absolute left-3 top-1/2 -translate-y-1/2 w-5 h-5 text-gray-400" />
                      <input type="tel" name="phone" value={formData.phone} onChange={handleInputChange} required className="w-full pl-10 pr-4 py-3 border border-gray-300 rounded-xl focus:ring-2 focus:ring-red-500 focus:border-transparent" placeholder="e.g., +254 712 345 678" />
                    </div>
                  </div>
                  <div>
                    <label className="block text-sm font-medium text-gray-700 mb-2">WhatsApp Number (Optional)</label>
                    <div className="relative">
                      <MessageCircle className="absolute left-3 top-1/2 -translate-y-1/2 w-5 h-5 text-gray-400" />
                      <input type="tel" name="whatsapp_number" value={formData.whatsapp_number} onChange={handleInputChange} className="w-full pl-10 pr-4 py-3 border border-gray-300 rounded-xl focus:ring-2 focus:ring-red-500 focus:border-transparent" placeholder="If different from phone" />
                    </div>
                  </div>
                </div>
                <hr/>
                <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
                  <div>
                    <label className="block text-sm font-medium text-gray-700 mb-2">Destination(s) *</label>
                    <div className="relative">
                      <Map className="absolute left-3 top-1/2 -translate-y-1/2 w-5 h-5 text-gray-400" />
                      <input type="text" name="destination" value={formData.destination} onChange={handleInputChange} required className="w-full pl-10 pr-4 py-3 border border-gray-300 rounded-xl focus:ring-2 focus:ring-red-500 focus:border-transparent" placeholder="e.g., Serengeti, Zanzibar" />
                    </div>
                  </div>
                  <div>
                    <label className="block text-sm font-medium text-gray-700 mb-2">Ideal Travel Dates *</label>
                    <div className="relative">
                      <Calendar className="absolute left-3 top-1/2 -translate-y-1/2 w-5 h-5 text-gray-400" />
                      <input type="text" name="travel_dates" value={formData.travel_dates} onChange={handleInputChange} required className="w-full pl-10 pr-4 py-3 border border-gray-300 rounded-xl focus:ring-2 focus:ring-red-500 focus:border-transparent" placeholder="e.g., June 2025" />
                    </div>
                  </div>
                </div>
                <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
                  <div>
                    <label className="block text-sm font-medium text-gray-700 mb-2">Number of Travelers *</label>
                    <div className="relative">
                      <Users className="absolute left-3 top-1/2 -translate-y-1/2 w-5 h-5 text-gray-400" />
                      <select name="travelers" value={formData.travelers} onChange={handleInputChange} className="w-full pl-10 pr-4 py-3 border border-gray-300 rounded-xl focus:ring-2 focus:ring-red-500 focus:border-transparent">
                        {[...Array(10)].map((_, i) => <option key={i + 1} value={i + 1}>{i + 1} Traveler{i > 0 && 's'}</option>)}
                        <option value="10+">10+ Travelers</option>
                      </select>
                    </div>
                  </div>
                  <div>
                    <label className="block text-sm font-medium text-gray-700 mb-2">Budget per Person (USD) *</label>
                    <div className="relative">
                      <DollarSign className="absolute left-3 top-1/2 -translate-y-1/2 w-5 h-5 text-gray-400" />
                      <input type="number" name="budget" value={formData.budget} onChange={handleInputChange} required className="w-full pl-10 pr-4 py-3 border border-gray-300 rounded-xl focus:ring-2 focus:ring-red-500 focus:border-transparent" placeholder="e.g., 2000" />
                    </div>
                  </div>
                </div>
                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-2">Trip Details & Interests *</label>
                  <textarea name="trip_details" rows={6} value={formData.trip_details} onChange={handleInputChange} required className="w-full px-4 py-3 border border-gray-300 rounded-xl focus:ring-2 focus:ring-red-500 focus:border-transparent" placeholder="Tell us what you'd like to see and do. e.g., wildlife safari, cultural tours, beach relaxation, specific activities..."></textarea>
                </div>
                <div>
                  <button type="submit" disabled={loading} className="w-full flex justify-center items-center space-x-2 bg-red-600 text-white px-6 py-4 rounded-xl font-bold text-lg hover:bg-red-700 transition-colors disabled:opacity-50">
                    <Send className="w-5 h-5" />
                    <span>{loading ? 'Sending Request...' : 'Request My Custom Package'}</span>
                  </button>
                </div>
              </form>
            </motion.div>

            <motion.div 
              initial={{ opacity: 0, x: 50 }}
              animate={{ opacity: 1, x: 0 }}
              className="lg:col-span-2 space-y-8"
            >
              <div className="bg-white p-8 rounded-2xl shadow-lg">
                <h3 className="text-xl font-bold mb-4 text-gray-900">How It Works</h3>
                <ol className="space-y-4">
                  <li className="flex items-start space-x-4">
                    <div className="flex-shrink-0 w-8 h-8 bg-red-100 text-red-600 rounded-full flex items-center justify-center font-bold">1</div>
                    <div>
                      <h4 className="font-semibold">Tell Us Your Dream</h4>
                      <p className="text-gray-600 text-sm">Fill out the form with your travel preferences, interests, and budget.</p>
                    </div>
                  </li>
                  <li className="flex items-start space-x-4">
                    <div className="flex-shrink-0 w-8 h-8 bg-red-100 text-red-600 rounded-full flex items-center justify-center font-bold">2</div>
                    <div>
                      <h4 className="font-semibold">Get a Custom Plan</h4>
                      <p className="text-gray-600 text-sm">Our experts will design a personalized itinerary and quote just for you.</p>
                    </div>
                  </li>
                  <li className="flex items-start space-x-4">
                    <div className="flex-shrink-0 w-8 h-8 bg-red-100 text-red-600 rounded-full flex items-center justify-center font-bold">3</div>
                    <div>
                      <h4 className="font-semibold">Book Your Adventure</h4>
                      <p className="text-gray-600 text-sm">Review, refine, and book your perfect trip with one-on-one support.</p>
                    </div>
                  </li>
                </ol>
              </div>
              
              <div className="bg-white p-8 rounded-2xl shadow-lg">
                <h3 className="text-xl font-bold mb-4 text-gray-900">Inspiration For Your Trip</h3>
                <ul className="space-y-3">
                  {[
                    "Private Wildlife Safaris",
                    "Gorilla Trekking in Uganda/Rwanda",
                    "Luxury Beach Getaways in Zanzibar",
                    "Mount Kilimanjaro Climbs",
                    "Authentic Cultural Immersions",
                    "Hot Air Balloon Rides Over the Mara"
                  ].map(item => (
                    <li key={item} className="flex items-center space-x-3">
                      <Sparkles className="w-5 h-5 text-yellow-500" />
                      <span className="text-gray-700">{item}</span>
                    </li>
                  ))}
                </ul>
              </div>
            </motion.div>

          </div>
        </div>
      </section>
    </div>
  );
};

export default CustomPackagesPage;
