import React, { useState } from 'react';
import { motion } from 'framer-motion';
import { Search } from 'lucide-react';
import ListingCard from '../components/ListingCard';
import LoadingSpinner from '../components/LoadingSpinner';
import { useListings } from '../hooks/useListings';
import FilterBar from '../components/FilterBar';
import { useDebounce } from '../hooks/useDebounce';

const ToursPage: React.FC = () => {
  const [selectedSubCategory, setSelectedSubCategory] = useState('All');
  const [searchTerm, setSearchTerm] = useState('');
  const debouncedSearchTerm = useDebounce(searchTerm, 500);
  
  const { listings: tours, loading, error } = useListings('tour', debouncedSearchTerm);

  const tourSubCategories = ['All', 'Safari', 'Trekking', 'Cultural', 'City Walk'];

  const filteredTours = selectedSubCategory === 'All'
    ? tours
    : tours.filter(tour => tour.type?.toLowerCase() === selectedSubCategory.toLowerCase());

  return (
    <div className="min-h-screen pt-16">
      {/* Hero Section */}
      <section className="relative bg-gradient-to-r from-red-900 to-red-700 text-white">
        <div className="absolute inset-0 bg-black bg-opacity-40"></div>
        <div 
          className="absolute inset-0 bg-cover bg-center"
          style={{
            backgroundImage: 'url(https://images.unsplash.com/photo-1516026672322-bc52d61a55d5?w=1600)',
          }}
        ></div>
        
        <div className="relative max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-16">
          <motion.div
            initial={{ opacity: 0, y: 30 }}
            animate={{ opacity: 1, y: 0 }}
            className="text-center"
          >
            <h1 className="text-4xl md:text-5xl font-bold mb-4">
              East Africa Tours
            </h1>
            <p className="text-xl mb-8 max-w-2xl mx-auto opacity-90">
              Discover breathtaking safaris, mountain treks, and cultural experiences across Kenya, Tanzania, Uganda, and Rwanda.
            </p>
          </motion.div>
        </div>
      </section>

      {/* Search and Filter Section */}
      <section className="py-8 bg-gray-50">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 space-y-4">
          <div className="flex flex-col md:flex-row gap-4 items-center justify-between">
            <div className="relative flex-1 w-full md:w-auto md:max-w-md">
              <Search className="absolute left-3 top-1/2 transform -translate-y-1/2 text-gray-400 w-5 h-5" />
              <input
                type="text"
                placeholder="Search tours by title or description..."
                className="w-full pl-10 pr-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-red-500 focus:border-transparent"
                value={searchTerm}
                onChange={(e) => setSearchTerm(e.target.value)}
              />
            </div>
          </div>
          <FilterBar 
            categories={tourSubCategories}
            selected={selectedSubCategory}
            onSelect={setSelectedSubCategory}
          />
        </div>
      </section>

      {/* Tours Grid */}
      <section className="py-12">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
          <div className="mb-8">
            <h2 className="text-2xl font-bold text-gray-900 mb-2">
              {selectedSubCategory} Tours ({filteredTours.length})
            </h2>
            <p className="text-gray-600">
              Choose from our carefully curated selection of East African adventures.
            </p>
          </div>
          
          {loading && <div className="text-center py-12"><LoadingSpinner /></div>}
          {error && <div className="text-red-600 text-center py-8">Error: {error}</div>}
          
          {!loading && !error && filteredTours.length === 0 ? (
            <div className="text-center py-12">
              <p className="text-gray-500">No tours found. Try adjusting your search or filters.</p>
            </div>
          ) : (
            <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-8">
              {filteredTours.map((tour, index) => (
                <ListingCard key={tour.id} listing={tour} index={index} />
              ))}
            </div>
          )}
        </div>
      </section>
    </div>
  );
};

export default ToursPage;
