import React from 'react';
import { useParams, Link } from 'react-router-dom';
import { motion } from 'framer-motion';
import { MapPin, Star, Wifi, Wind, Tv, ArrowLeft } from 'lucide-react';
import LoadingSpinner from '../components/LoadingSpinner';
import { useListing } from '../hooks/useListings';
import { useAuth } from '../hooks/useAuth';
import AvailabilityCalendar from '../components/AvailabilityCalendar';
import { getImageUrl } from '../lib/utils';

const StayDetailsPage: React.FC = () => {
  const { id } = useParams<{ id: string }>();
  const { listing: stay, loading, error } = useListing(id!);
  const { user } = useAuth();

  if (loading) return <LoadingSpinner />;
  if (error) return <div className="text-red-600 text-center py-8">Error: {error}</div>;
  if (!stay) return <div className="text-center py-8">Accommodation not found.</div>;

  const amenities = stay.amenities as string[] | null;

  const getAmenityIcon = (amenity: string) => {
    const lowerAmenity = amenity.toLowerCase();
    if (lowerAmenity.includes('wifi')) return <Wifi className="w-5 h-5 text-red-600" />;
    if (lowerAmenity.includes('air conditioning')) return <Wind className="w-5 h-5 text-red-600" />;
    if (lowerAmenity.includes('tv')) return <Tv className="w-5 h-5 text-red-600" />;
    return <div className="w-2 h-2 bg-red-600 rounded-full" />;
  };

  return (
    <div className="min-h-screen">
      {/* Hero Section */}
      <section className="relative h-96">
        <div
          className="absolute inset-0 bg-cover bg-center"
          style={{ backgroundImage: `url(${getImageUrl(stay.images, stay.id)})` }}
        />
        <div className="absolute inset-0 bg-black bg-opacity-40" />
        
        <div className="relative max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 h-full flex items-center">
          <motion.div
            initial={{ opacity: 0, y: 30 }}
            animate={{ opacity: 1, y: 0 }}
            className="text-white"
          >
            <Link
              to="/stays"
              className="inline-flex items-center space-x-2 text-white hover:text-red-300 mb-4"
            >
              <ArrowLeft className="w-5 h-5" />
              <span>Back to Stays</span>
            </Link>
            
            <h1 className="text-4xl md:text-5xl font-bold mb-4">{stay.title}</h1>
            
            <div className="flex flex-wrap items-center gap-6 text-lg">
              <div className="flex items-center space-x-2">
                <MapPin className="w-5 h-5" />
                <span>{stay.location}</span>
              </div>
              
              <div className="flex items-center space-x-2">
                <Star className="w-5 h-5 text-yellow-400 fill-current" />
                <span>{stay.rating}</span>
              </div>
              
              <div className="flex items-center space-x-2">
                <span className="text-3xl font-bold">KES {stay.price?.toLocaleString()}</span>
                <span className="text-lg opacity-80">/night</span>
              </div>
            </div>
          </motion.div>
        </div>
      </section>

      {/* Content Section */}
      <section className="py-12">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
          <div className="grid grid-cols-1 lg:grid-cols-3 gap-12">
            {/* Main Content */}
            <div className="lg:col-span-2 space-y-8">
              <motion.div initial={{ opacity: 0, y: 20 }} animate={{ opacity: 1, y: 0 }} transition={{ delay: 0.1 }}>
                <h2 className="text-2xl font-bold mb-4">About This Stay</h2>
                <p className="text-gray-600 leading-relaxed">{stay.description}</p>
              </motion.div>

              {stay.images && stay.images.length > 1 && (
                <motion.div initial={{ opacity: 0, y: 20 }} animate={{ opacity: 1, y: 0 }} transition={{ delay: 0.2 }}>
                  <h2 className="text-2xl font-bold mb-4">Gallery</h2>
                  <div className="grid grid-cols-2 md:grid-cols-3 gap-4">
                    {stay.images.map((imagePath, index) => (
                      <img 
                        key={index}
                        src={getImageUrl([imagePath], stay.id)} 
                        alt={`${stay.title} gallery image ${index + 1}`}
                        className="rounded-lg object-cover w-full h-40"
                      />
                    ))}
                  </div>
                </motion.div>
              )}

              {amenities && amenities.length > 0 && (
                <motion.div initial={{ opacity: 0, y: 20 }} animate={{ opacity: 1, y: 0 }} transition={{ delay: 0.3 }}>
                  <h2 className="text-2xl font-bold mb-4">Amenities</h2>
                  <div className="grid grid-cols-2 md:grid-cols-3 gap-4">
                    {amenities.map((amenity) => (
                      <div key={amenity} className="flex items-center space-x-3">
                        {getAmenityIcon(amenity)}
                        <span className="capitalize">{amenity}</span>
                      </div>
                    ))}
                  </div>
                </motion.div>
              )}
            </div>

            {/* Booking Sidebar */}
            <div className="lg:col-span-1">
              <motion.div
                initial={{ opacity: 0, x: 20 }}
                animate={{ opacity: 1, x: 0 }}
                transition={{ delay: 0.2 }}
                className="bg-white border border-gray-200 rounded-lg p-6 sticky top-24 space-y-6"
              >
                <div className="text-center">
                  <div className="text-3xl font-bold text-gray-900">KES {stay.price?.toLocaleString()}</div>
                  <div className="text-gray-600">per night</div>
                </div>

                <AvailabilityCalendar availability={stay.availability} />

                {user ? (
                  <Link
                    to={`/book/stay/${stay.id}`}
                    className="w-full bg-red-600 text-white py-3 px-4 rounded-lg font-semibold hover:bg-red-700 transition-colors text-center block"
                  >
                    Book This Stay
                  </Link>
                ) : (
                  <Link
                    to={`/signin?redirect=/stays/${stay.id}`}
                    className="w-full bg-red-600 text-white py-3 px-4 rounded-lg font-semibold hover:bg-red-700 transition-colors text-center block"
                  >
                    Sign In to Book
                  </Link>
                )}

                <p className="text-xs text-gray-500 text-center">
                  Free cancellation up to 48 hours before check-in
                </p>
              </motion.div>
            </div>
          </div>
        </div>
      </section>
    </div>
  );
};

export default StayDetailsPage;
