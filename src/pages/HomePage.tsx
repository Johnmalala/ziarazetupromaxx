import React from 'react';
import { Link } from 'react-router-dom';
import { Camera, MapPin, Calendar, Star, ArrowRight, HeartHandshake } from 'lucide-react';
import { motion } from 'framer-motion';
import { useListings } from '../hooks/useListings';
import LoadingSpinner from '../components/LoadingSpinner';
import { getImageUrl } from '../lib/utils';

const HomePage: React.FC = () => {
  const { listings: featuredTours, loading: toursLoading } = useListings('tour');
  const { listings: featuredStays, loading: staysLoading } = useListings('stay');

  return (
    <div className="min-h-screen">
      {/* Hero Section */}
      <motion.section 
        initial={{ opacity: 0 }}
        animate={{ opacity: 1 }}
        className="relative h-screen bg-gradient-to-r from-red-600 to-red-800 flex items-center justify-center text-white"
      >
        <div 
          className="absolute inset-0 bg-black bg-opacity-40"
          style={{
            backgroundImage: "url('https://images.unsplash.com/photo-1516026672322-bc52d61a55d5?w=1920&h=1080&fit=crop')",
            backgroundSize: 'cover',
            backgroundPosition: 'center',
          }}
        />
        <div className="relative z-10 text-center max-w-4xl mx-auto px-4">
          <motion.h1 
            initial={{ y: 30, opacity: 0 }}
            animate={{ y: 0, opacity: 1 }}
            transition={{ delay: 0.2 }}
            className="text-5xl md:text-7xl font-bold mb-6"
          >
            Explore East Africa with Ziarazetu
          </motion.h1>
          <motion.p 
            initial={{ y: 30, opacity: 0 }}
            animate={{ y: 0, opacity: 1 }}
            transition={{ delay: 0.4 }}
            className="text-xl md:text-2xl mb-8 text-gray-200"
          >
            Safari Tours • City Walks • Stays • Custom Adventures
          </motion.p>
          <motion.div 
            initial={{ y: 30, opacity: 0 }}
            animate={{ y: 0, opacity: 1 }}
            transition={{ delay: 0.6 }}
            className="flex flex-col sm:flex-row gap-4 justify-center"
          >
            <Link
              to="/tours"
              className="bg-white text-red-600 px-8 py-4 rounded-xl font-bold text-lg hover:bg-gray-100 transition-colors"
            >
              Browse Tours
            </Link>
            <Link
              to="/stays"
              className="bg-transparent border-2 border-white text-white px-8 py-4 rounded-xl font-bold text-lg hover:bg-white hover:text-red-600 transition-colors"
            >
              Find Stays
            </Link>
          </motion.div>
        </div>
      </motion.section>

      {/* Quick Links */}
      <section className="py-16 bg-white">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
          <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-8">
            <motion.div 
              initial={{ y: 50, opacity: 0 }}
              whileInView={{ y: 0, opacity: 1 }}
              viewport={{ once: true }}
              className="text-center p-8 bg-red-50 rounded-2xl hover:bg-red-100 transition-colors"
            >
              <Camera className="h-16 w-16 text-red-600 mx-auto mb-4" />
              <h3 className="text-2xl font-bold text-gray-900 mb-4">Safari & Tours</h3>
              <p className="text-gray-600 mb-6">Experience wildlife safaris, cultural tours, and multi-day adventures across East Africa</p>
              <Link to="/tours" className="text-red-600 font-semibold hover:text-red-700 inline-flex items-center">
                Explore Tours <ArrowRight className="w-4 h-4 ml-2" />
              </Link>
            </motion.div>

            <motion.div 
              initial={{ y: 50, opacity: 0 }}
              whileInView={{ y: 0, opacity: 1 }}
              viewport={{ once: true }}
              transition={{ delay: 0.1 }}
              className="text-center p-8 bg-red-50 rounded-2xl hover:bg-red-100 transition-colors"
            >
              <MapPin className="h-16 w-16 text-red-600 mx-auto mb-4" />
              <h3 className="text-2xl font-bold text-gray-900 mb-4">Stays & Hotels</h3>
              <p className="text-gray-600 mb-6">From luxury hotels to cozy Airbnbs across Mombasa, Nairobi, Zanzibar and more</p>
              <Link to="/stays" className="text-red-600 font-semibold hover:text-red-700 inline-flex items-center">
                Find Stays <ArrowRight className="w-4 h-4 ml-2" />
              </Link>
            </motion.div>

            <motion.div 
              initial={{ y: 50, opacity: 0 }}
              whileInView={{ y: 0, opacity: 1 }}
              viewport={{ once: true }}
              transition={{ delay: 0.2 }}
              className="text-center p-8 bg-red-50 rounded-2xl hover:bg-red-100 transition-colors"
            >
              <HeartHandshake className="h-16 w-16 text-red-600 mx-auto mb-4" />
              <h3 className="text-2xl font-bold text-gray-900 mb-4">Volunteer & Give Back</h3>
              <p className="text-gray-600 mb-6">Make a meaningful impact in local communities through our verified volunteer programs.</p>
              <Link to="/volunteer" className="text-red-600 font-semibold hover:text-red-700 inline-flex items-center">
                Find Opportunities <ArrowRight className="w-4 h-4 ml-2" />
              </Link>
            </motion.div>

            <motion.div 
              initial={{ y: 50, opacity: 0 }}
              whileInView={{ y: 0, opacity: 1 }}
              viewport={{ once: true }}
              transition={{ delay: 0.3 }}
              className="text-center p-8 bg-red-50 rounded-2xl hover:bg-red-100 transition-colors"
            >
              <Calendar className="h-16 w-16 text-red-600 mx-auto mb-4" />
              <h3 className="text-2xl font-bold text-gray-900 mb-4">Custom Packages</h3>
              <p className="text-gray-600 mb-6">Tailored tour and accommodation packages designed just for your East Africa adventure</p>
              <Link to="/custom-packages" className="text-red-600 font-semibold hover:text-red-700 inline-flex items-center">
                Plan Custom Trip <ArrowRight className="w-4 h-4 ml-2" />
              </Link>
            </motion.div>
          </div>
        </div>
      </section>

      {/* Featured Tours */}
      <section className="py-16 bg-gray-50">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
          <div className="text-center mb-12">
            <h2 className="text-4xl font-bold text-gray-900 mb-4">Featured Tours</h2>
            <p className="text-xl text-gray-600">Discover the best of East Africa</p>
          </div>
          {toursLoading ? <LoadingSpinner /> : (
            <div className="grid grid-cols-1 md:grid-cols-3 gap-8">
              {featuredTours.slice(0, 3).map((tour, index) => (
                <motion.div
                  key={tour.id}
                  initial={{ y: 50, opacity: 0 }}
                  whileInView={{ y: 0, opacity: 1 }}
                  viewport={{ once: true }}
                  transition={{ delay: index * 0.1 }}
                  className="bg-white rounded-2xl shadow-lg overflow-hidden hover:shadow-xl transition-shadow"
                >
                  <img src={getImageUrl(tour.images, tour.id)} alt={tour.title} className="w-full h-64 object-cover" />
                  <div className="p-6">
                    <div className="flex items-center mb-2">
                      <Star className="h-5 w-5 text-yellow-400 fill-current" />
                      <span className="ml-1 text-sm text-gray-600">{tour.rating}</span>
                    </div>
                    <h3 className="text-xl font-bold text-gray-900 mb-2">{tour.title}</h3>
                    <p className="text-gray-600 mb-4 line-clamp-2">{tour.description}</p>
                    <div className="flex justify-between items-center">
                      <span className="text-2xl font-bold text-red-600">KES {(tour.price || 0).toLocaleString()}</span>
                      <Link
                        to={`/tours/${tour.id}`}
                        className="bg-red-600 text-white px-6 py-2 rounded-xl hover:bg-red-700 transition-colors"
                      >
                        View Details
                      </Link>
                    </div>
                  </div>
                </motion.div>
              ))}
            </div>
          )}
        </div>
      </section>

      {/* Featured Stays */}
      <section className="py-16 bg-white">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
          <div className="text-center mb-12">
            <h2 className="text-4xl font-bold text-gray-900 mb-4">Featured Stays</h2>
            <p className="text-xl text-gray-600">Comfortable accommodations across East Africa</p>
          </div>
          {staysLoading ? <LoadingSpinner /> : (
            <div className="grid grid-cols-1 md:grid-cols-3 gap-8">
              {featuredStays.slice(0, 3).map((stay, index) => (
                <motion.div
                  key={stay.id}
                  initial={{ y: 50, opacity: 0 }}
                  whileInView={{ y: 0, opacity: 1 }}
                  viewport={{ once: true }}
                  transition={{ delay: index * 0.1 }}
                  className="bg-white rounded-2xl shadow-lg overflow-hidden hover:shadow-xl transition-shadow"
                >
                  <img src={getImageUrl(stay.images, stay.id)} alt={stay.title} className="w-full h-64 object-cover" />
                  <div className="p-6">
                    <div className="flex items-center justify-between mb-2">
                      <span className="bg-red-100 text-red-600 px-3 py-1 rounded-full text-sm font-medium capitalize">
                        {stay.type || 'Stay'}
                      </span>
                      <div className="flex items-center">
                        <Star className="h-5 w-5 text-yellow-400 fill-current" />
                        <span className="ml-1 text-sm text-gray-600">{stay.rating}</span>
                      </div>
                    </div>
                    <h3 className="text-xl font-bold text-gray-900 mb-2">{stay.title}</h3>
                    <p className="text-gray-600 mb-4">{stay.location}</p>
                    <div className="flex justify-between items-center">
                      <span className="text-2xl font-bold text-red-600">KES {(stay.price || 0).toLocaleString()}</span>
                      <Link
                        to={`/stays/${stay.id}`}
                        className="bg-red-600 text-white px-6 py-2 rounded-xl hover:bg-red-700 transition-colors"
                      >
                        View Details
                      </Link>
                    </div>
                  </div>
                </motion.div>
              ))}
            </div>
          )}
        </div>
      </section>
    </div>
  );
};

export default HomePage;
