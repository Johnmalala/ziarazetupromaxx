import React, { useState, useEffect } from 'react';
import { useParams, useNavigate } from 'react-router-dom';
import { useListing } from '../hooks/useListings';
import { useAuth } from '../hooks/useAuth';
import LoadingSpinner from '../components/LoadingSpinner';
import { Shield, Check } from 'lucide-react';
import { motion } from 'framer-motion';
import { supabase } from '../lib/supabase';
import toast from 'react-hot-toast';
import { getImageUrl } from '../lib/utils';

const BookingPage: React.FC = () => {
  const { type, id } = useParams<{ type: string; id: string }>();
  const { listing, loading, error } = useListing(id!);
  const { user } = useAuth();
  const navigate = useNavigate();

  const [bookingData, setBookingData] = useState({
    travelers: 1,
    checkIn: '',
    checkOut: ''
  });
  const [isSubmitting, setIsSubmitting] = useState(false);

  useEffect(() => {
    if (!loading && !user) {
      toast.error('Please sign in to continue booking.');
      navigate(`/signin?redirect=/book/${type}/${id}`);
    }
  }, [user, loading, navigate, id, type]);

  const pricePerItem = listing?.price || 0;
  const totalAmount = pricePerItem * bookingData.travelers;

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!user || !listing) {
      toast.error('You must be signed in to book.');
      return;
    }

    setIsSubmitting(true);
    const toastId = toast.loading('Confirming your booking...');

    try {
      const { error: insertError } = await supabase
        .from('bookings')
        .insert({
          listing_id: listing.id,
          user_id: user.id,
          total_amount: totalAmount,
          payment_plan: 'pay_on_arrival',
          payment_status: 'pending',
          guests: bookingData.travelers,
          check_in_date: bookingData.checkIn || null,
          check_out_date: listing.category === 'stay' ? bookingData.checkOut : null,
        });

      if (insertError) {
        // Throw the specific database error
        throw insertError;
      }
      
      toast.success('Booking confirmed! Your reservation is now visible on your dashboard.', { id: toastId, duration: 5000 });
      navigate('/bookings');

    } catch (err) {
      // Display the specific error message from the database
      const errorMessage = err instanceof Error ? err.message : 'An unexpected error occurred.';
      toast.error(`Booking Failed: ${errorMessage}`, { id: toastId, duration: 8000 });
    } finally {
      setIsSubmitting(false);
    }
  };

  if (loading) return <LoadingSpinner />;
  if (error) return <div className="text-red-600 text-center py-8">Error: {error}</div>;
  if (!listing) return <div className="text-center py-8">Listing not found.</div>;

  return (
    <div className="min-h-screen bg-gray-50 py-8">
      <div className="max-w-6xl mx-auto px-4 sm:px-6 lg:px-8">
        <div className="grid grid-cols-1 lg:grid-cols-2 gap-12">
          <motion.div 
            initial={{ x: -50, opacity: 0 }}
            animate={{ x: 0, opacity: 1 }}
            className="space-y-6"
          >
            <div className="bg-white rounded-2xl shadow-lg overflow-hidden">
              <img src={getImageUrl(listing.images, listing.id)} alt={listing.title} className="w-full h-64 object-cover" />
              <div className="p-6">
                <h1 className="text-3xl font-bold text-gray-900 mb-4">{listing.title}</h1>
                <p className="text-gray-600 mb-6 line-clamp-3">{listing.description}</p>
              </div>
            </div>

            <div className="bg-white rounded-2xl shadow-lg p-6">
              <h2 className="text-2xl font-bold text-gray-900 mb-6">Payment Options</h2>
              <div className="space-y-4">
                {/* Pay on Arrival */}
                <div
                  className={`relative border-2 rounded-xl p-4 cursor-pointer transition-colors border-red-600 bg-red-50`}
                >
                  <div className="flex items-center">
                    <div className={`w-5 h-5 rounded-full border-2 mr-3 flex items-center justify-center border-red-600 bg-red-600`}>
                      <Check className="h-3 w-3 text-white" />
                    </div>
                    <div className="flex-1">
                      <h3 className="font-bold text-gray-900">Pay on Arrival</h3>
                      <p className="text-sm text-gray-600">Confirm your booking now and pay when you arrive.</p>
                    </div>
                  </div>
                </div>
                
                {/* Other payment options */}
                {['Card', 'M-Pesa'].map(method => (
                  <div key={method} className="relative border-2 rounded-xl p-4 opacity-50 cursor-not-allowed">
                     <span className="absolute top-2 right-2 bg-gray-500 text-white px-2 py-1 rounded-full text-xs">Coming Soon</span>
                     <div className="flex items-center">
                       <div className="w-5 h-5 rounded-full border-2 border-gray-300 mr-3"></div>
                       <div className="flex-1">
                         <h3 className="font-bold text-gray-900">Pay with {method}</h3>
                         <p className="text-sm text-gray-600">Online payments will be available soon.</p>
                       </div>
                     </div>
                  </div>
                ))}
              </div>
            </div>
          </motion.div>

          <motion.div 
            initial={{ x: 50, opacity: 0 }}
            animate={{ x: 0, opacity: 1 }}
            className="bg-white rounded-2xl shadow-lg p-8"
          >
            <h2 className="text-2xl font-bold text-gray-900 mb-6">Confirm Your Booking</h2>
            <form onSubmit={handleSubmit} className="space-y-6">
              <div>
                <label className="block text-sm font-medium text-gray-700 mb-2">Number of {listing.category === 'tour' ? 'Travelers' : 'Guests'} *</label>
                <select value={bookingData.travelers} onChange={(e) => setBookingData(prev => ({ ...prev, travelers: parseInt(e.target.value) }))} className="w-full px-4 py-3 border border-gray-300 rounded-xl focus:ring-2 focus:ring-red-500 focus:border-transparent">
                  {[...Array(8)].map((_, i) => (<option key={i + 1} value={i + 1}>{i + 1} {i + 1 === 1 ? 'person' : 'people'}</option>))}
                </select>
              </div>

              <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-2">{listing.category === 'tour' ? 'Tour Date' : 'Check-in'} *</label>
                  <input type="date" required value={bookingData.checkIn} onChange={(e) => setBookingData(prev => ({ ...prev, checkIn: e.target.value }))} className="w-full px-4 py-3 border border-gray-300 rounded-xl focus:ring-2 focus:ring-red-500 focus:border-transparent" />
                </div>
                {listing.category === 'stay' && (
                  <div>
                    <label className="block text-sm font-medium text-gray-700 mb-2">Check-out *</label>
                    <input type="date" required value={bookingData.checkOut} onChange={(e) => setBookingData(prev => ({ ...prev, checkOut: e.target.value }))} className="w-full px-4 py-3 border border-gray-300 rounded-xl focus:ring-2 focus:ring-red-500 focus:border-transparent" />
                  </div>
                )}
              </div>

              <div className="bg-gray-50 rounded-xl p-6 space-y-3">
                <h3 className="font-bold text-gray-900">Booking Summary</h3>
                <div className="flex justify-between font-bold text-lg border-t pt-3">
                  <span>Total Amount Due on Arrival</span>
                  <span className="text-red-600">KES {totalAmount.toLocaleString(undefined, { minimumFractionDigits: 2, maximumFractionDigits: 2 })}</span>
                </div>
              </div>

              <button type="submit" disabled={isSubmitting} className="w-full bg-red-600 text-white py-4 rounded-xl font-bold text-lg hover:bg-red-700 transition-colors flex items-center justify-center disabled:opacity-50">
                <Check className="h-5 w-5 mr-2" />
                {isSubmitting ? 'Confirming...' : 'Confirm Booking'}
              </button>
              <div className="text-center mt-2 text-sm text-gray-500 flex items-center justify-center space-x-2">
                <Shield className="w-4 h-4" />
                <span>You will not be charged now.</span>
              </div>
            </form>
          </motion.div>
        </div>
      </div>
    </div>
  );
};

export default BookingPage;
