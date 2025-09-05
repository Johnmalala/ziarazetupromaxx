import React from 'react';
import { useParams, Link } from 'react-router-dom';
import { motion } from 'framer-motion';
import { MapPin, Star, Clock, Users, ArrowLeft } from 'lucide-react';
import LoadingSpinner from '../components/LoadingSpinner';
import { useListing } from '../hooks/useListings';
import { useAuth } from '../hooks/useAuth';
import AvailabilityCalendar from '../components/AvailabilityCalendar';
import ImageGallery from '../components/ImageGallery'; // Import the new component

const TourDetailsPage: React.FC = () => {
  const { id } = useParams<{ id: string }>();
  const { listing: tour, loading, error } = useListing(id!);
  const { user } = useAuth();

  if (loading) return <LoadingSpinner />;
  if (error) return <div className="text-red-600 text-center py-8">Error: {error}</div>;
  if (!tour) return <div className="text-center py-8">Tour not found.</div>;

  const features = tour.features as { duration?: string; group_size?: string; [key: string]: any } | null;
  const itinerary = tour.itinerary as { [key: string]: string } | null;

  return (
    <div className="min-h-screen">
      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
        <motion.div
          initial={{ opacity: 0, y: 20 }}
          animate={{ opacity: 1, y: 0 }}
          className="mb-6"
        >
          <h1 className="text-4xl md:text-5xl font-bold mb-2">{tour.title}</h1>
          <div className="flex flex-wrap items-center gap-x-6 gap-y-2 text-gray-600">
            <div className="flex items-center space-x-2">
              <Star className="w-5 h-5 text-yellow-400 fill-current" />
              <span>{tour.rating}</span>
            </div>
            <div className="flex items-center space-x-2">
              <MapPin className="w-5 h-5" />
              <span>{tour.location}</span>
            </div>
          </div>
        </motion.div>

        <ImageGallery images={tour.images} listingTitle={tour.title} />

        {/* Content Section */}
        <section className="py-12">
          <div className="grid grid-cols-1 lg:grid-cols-3 gap-12">
            {/* Main Content */}
            <div className="lg:col-span-2 space-y-8">
              <motion.div initial={{ opacity: 0, y: 20 }} animate={{ opacity: 1, y: 0 }} transition={{ delay: 0.1 }}>
                <h2 className="text-2xl font-bold mb-4">About This Tour</h2>
                <p className="text-gray-600 leading-relaxed">{tour.description}</p>
              </motion.div>

              {itinerary && (
                <motion.div initial={{ opacity: 0, y: 20 }} animate={{ opacity: 1, y: 0 }} transition={{ delay: 0.3 }}>
                  <h2 className="text-2xl font-bold mb-4">Itinerary</h2>
                  <div className="space-y-4">
                    {Object.entries(itinerary).map(([day, activities]) => (
                      <div key={day} className="border-l-4 border-red-600 pl-4">
                        <h3 className="font-semibold capitalize mb-2">{day.replace('_', ' ')}</h3>
                        <p className="text-gray-600">{activities}</p>
                      </div>
                    ))}
                  </div>
                </motion.div>
              )}
            </div>

            {/* Sidebar */}
            <div className="lg:col-span-1">
              <motion.div
                initial={{ opacity: 0, x: 20 }}
                animate={{ opacity: 1, x: 0 }}
                transition={{ delay: 0.2 }}
                className="bg-white border border-gray-200 rounded-lg p-6 sticky top-24 space-y-6"
              >
                <div className="text-center">
                  <div className="text-3xl font-bold text-gray-900">KES {tour.price?.toLocaleString()}</div>
                  <div className="text-gray-600">per person</div>
                </div>

                <div className="space-y-4">
                  {features?.duration && (
                    <div className="flex items-center justify-between">
                      <div className="flex items-center space-x-2">
                        <Clock className="w-5 h-5 text-gray-400" />
                        <span className="text-sm">Duration</span>
                      </div>
                      <span className="text-sm font-medium">{features.duration}</span>
                    </div>
                  )}
                  {features?.group_size && (
                    <div className="flex items-center justify-between">
                      <div className="flex items-center space-x-2">
                        <Users className="w-5 h-5 text-gray-400" />
                        <span className="text-sm">Group Size</span>
                      </div>
                      <span className="text-sm font-medium">{features.group_size}</span>
                    </div>
                  )}
                </div>

                <AvailabilityCalendar availability={tour.availability} />

                {user ? (
                  <Link
                    to={`/book/tour/${tour.id}`}
                    className="w-full bg-red-600 text-white py-3 px-4 rounded-lg font-semibold hover:bg-red-700 transition-colors text-center block"
                  >
                    Book This Tour
                  </Link>
                ) : (
                  <Link
                    to={`/signin?redirect=/tours/${tour.id}`}
                    className="w-full bg-red-600 text-white py-3 px-4 rounded-lg font-semibold hover:bg-red-700 transition-colors text-center block"
                  >
                    Sign In to Book
                  </Link>
                )}

                <p className="text-xs text-gray-500 text-center">
                  Free cancellation up to 24 hours before the tour
                </p>
              </motion.div>
            </div>
          </div>
        </section>
      </div>
    </div>
  );
};

export default TourDetailsPage;
