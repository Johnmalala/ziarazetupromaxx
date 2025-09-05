import React from 'react';
import { Link } from 'react-router-dom';
import { useBookings } from '../hooks/useBookings';
import LoadingSpinner from '../components/LoadingSpinner';
import { format } from 'date-fns';
import { Tag, Calendar, DollarSign, ArrowRight } from 'lucide-react';
import { getImageUrl } from '../lib/utils';

const BookingsPage: React.FC = () => {
  const { bookings, loading, error } = useBookings();

  if (loading) return <LoadingSpinner />;
  if (error) return <div className="text-red-600 text-center py-8">Error: {error}</div>;

  const getStatusColor = (status: string) => {
    switch (status) {
      case 'paid': return 'bg-green-100 text-green-800';
      case 'partial': return 'bg-yellow-100 text-yellow-800';
      case 'pending': return 'bg-gray-100 text-gray-800';
      default: return 'bg-gray-100 text-gray-800';
    }
  };
  
  const getCategoryPath = (category: string, id: string) => {
    return `/${category}s/${id}`;
  };

  return (
    <div className="min-h-screen bg-gray-50">
      <section className="py-12">
        <div className="max-w-4xl mx-auto px-4 sm:px-6 lg:px-8">
          <h1 className="text-3xl font-bold text-center mb-8">My Bookings</h1>
          
          {bookings.length === 0 ? (
            <div className="text-center bg-white p-8 rounded-lg shadow-md">
              <h2 className="text-xl font-semibold mb-2">No Bookings Yet</h2>
              <p className="text-gray-600 mb-4">You haven't made any bookings. Start exploring!</p>
              <Link to="/" className="bg-red-600 text-white px-6 py-2 rounded-md font-semibold hover:bg-red-700">
                Browse Experiences
              </Link>
            </div>
          ) : (
            <div className="space-y-6">
              {bookings.map(booking => (
                <div key={booking.id} className="bg-white p-4 rounded-lg shadow-md flex flex-col sm:flex-row items-center space-y-4 sm:space-y-0 sm:space-x-6">
                  <img src={getImageUrl(booking.listings.images, booking.listing_id)} alt={booking.listings.title} className="w-full sm:w-32 h-32 rounded-lg object-cover" />
                  <div className="flex-grow">
                    <div className="flex justify-between items-start">
                      <h3 className="font-bold text-lg">{booking.listings.title}</h3>
                      <span className={`px-2 py-1 text-xs font-medium rounded-full ${getStatusColor(booking.payment_status)}`}>
                        {booking.payment_status}
                      </span>
                    </div>
                    <div className="text-sm text-gray-500 mt-2 space-y-1">
                      <div className="flex items-center space-x-2">
                        <Tag className="w-4 h-4" />
                        <span className="capitalize">{booking.listings.category}</span>
                      </div>
                      <div className="flex items-center space-x-2">
                        <Calendar className="w-4 h-4" />
                        <span>Booked on: {format(new Date(booking.created_at), 'MMMM d, yyyy')}</span>
                      </div>
                      <div className="flex items-center space-x-2">
                        <DollarSign className="w-4 h-4" />
                        <span>Total: KES {booking.total_amount.toFixed(2)}</span>
                      </div>
                    </div>
                  </div>
                  <Link to={getCategoryPath(booking.listings.category, booking.listing_id)} className="flex items-center space-x-2 text-red-600 font-semibold">
                    <span>View Details</span>
                    <ArrowRight className="w-4 h-4" />
                  </Link>
                </div>
              ))}
            </div>
          )}
        </div>
      </section>
    </div>
  );
};

export default BookingsPage;
