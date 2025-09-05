import React from 'react';
import { Link } from 'react-router-dom';
import { MapPin, Star, DollarSign, Users } from 'lucide-react';
import { motion } from 'framer-motion';
import { Listing } from '../hooks/useListings';
import { getImageUrl } from '../lib/utils';

interface ListingCardProps {
  listing: Listing;
  index?: number;
}

const ListingCard: React.FC<ListingCardProps> = ({ listing, index = 0 }) => {
  const getCategoryPath = (category: string) => {
    switch (category) {
      case 'tour':
        return '/tours';
      case 'stay':
        return '/stays';
      case 'volunteer':
        return '/volunteer';
      default:
        return '/';
    }
  };

  const formatPrice = (price: number | null, category: string) => {
    if (category === 'volunteer' || price === null) {
      return 'Free';
    }
    return `$${price.toFixed(0)}`;
  };

  return (
    <motion.div
      initial={{ opacity: 0, y: 50 }}
      animate={{ opacity: 1, y: 0 }}
      transition={{ duration: 0.5, delay: index * 0.1 }}
      whileHover={{ y: -5 }}
      className="bg-white rounded-lg shadow-lg overflow-hidden hover:shadow-xl transition-all duration-300"
    >
      <div className="relative">
        <img
          src={getImageUrl(listing.images, listing.id)}
          alt={listing.title}
          className="w-full h-48 object-cover"
        />
        <div className="absolute top-4 left-4">
          <span className="bg-red-600 text-white px-3 py-1 rounded-full text-xs font-medium capitalize">
            {listing.category}
          </span>
        </div>
        {listing.category !== 'volunteer' && listing.rating && (
          <div className="absolute top-4 right-4 bg-white bg-opacity-90 rounded-lg px-2 py-1">
            <div className="flex items-center space-x-1">
              <Star className="w-4 h-4 text-yellow-400 fill-current" />
              <span className="text-sm font-medium">{listing.rating}</span>
            </div>
          </div>
        )}
      </div>

      <div className="p-6">
        <div className="flex items-start justify-between mb-2">
          <h3 className="text-lg font-semibold text-gray-900 line-clamp-2">
            {listing.title}
          </h3>
        </div>

        <div className="flex items-center text-gray-500 mb-3">
          <MapPin className="w-4 h-4 mr-1" />
          <span className="text-sm">{listing.location}</span>
        </div>

        <p className="text-gray-600 text-sm mb-4 line-clamp-3">
          {listing.description}
        </p>

        <div className="flex items-center justify-between">
          <div className="flex items-center space-x-2">
            {listing.category !== 'volunteer' && listing.price ? (
              <>
                <DollarSign className="w-4 h-4 text-green-600" />
                <span className="text-lg font-bold text-gray-900">
                  {formatPrice(listing.price, listing.category)}
                </span>
                <span className="text-sm text-gray-500">
                  {listing.category === 'stay' ? '/night' : '/person'}
                </span>
              </>
            ) : (
              <>
                <Users className="w-4 h-4 text-blue-600" />
                <span className="text-lg font-bold text-blue-600">
                  Volunteer
                </span>
              </>
            )}
          </div>

          <Link
            to={`${getCategoryPath(listing.category)}/${listing.id}`}
            className="bg-red-600 text-white px-4 py-2 rounded-md hover:bg-red-700 transition-colors text-sm font-medium"
          >
            {listing.category === 'volunteer' ? 'Apply Now' : 'View Details'}
          </Link>
        </div>
      </div>
    </motion.div>
  );
};

export default ListingCard;
