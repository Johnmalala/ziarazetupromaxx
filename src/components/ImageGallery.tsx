import React from 'react';
import { motion } from 'framer-motion';
import { getImageUrl } from '../lib/utils';
import { Image } from 'lucide-react';

interface ImageGalleryProps {
  images: string[] | null | undefined;
  listingTitle: string;
}

const ImageGallery: React.FC<ImageGalleryProps> = ({ images, listingTitle }) => {
  if (!images || images.length === 0) {
    return (
      <div className="aspect-video bg-gray-200 rounded-lg flex items-center justify-center">
        <Image className="w-16 h-16 text-gray-400" />
      </div>
    );
  }

  const mainImage = images[0];
  const otherImages = images.slice(1, 5);

  return (
    <motion.div 
      initial={{ opacity: 0 }}
      animate={{ opacity: 1 }}
      className="grid grid-cols-1 md:grid-cols-2 md:grid-rows-2 gap-2 rounded-2xl overflow-hidden h-[50vh] max-h-[550px]"
    >
      {/* Main Image */}
      <div className="md:col-span-1 md:row-span-2 h-full">
        <img
          src={getImageUrl([mainImage])}
          alt={listingTitle}
          className="w-full h-full object-cover cursor-pointer hover:opacity-90 transition-opacity"
        />
      </div>

      {/* Other Images */}
      {otherImages.map((imagePath, index) => (
        <div key={index} className="hidden md:block h-full">
          <img
            src={getImageUrl([imagePath])}
            alt={`${listingTitle} - image ${index + 2}`}
            className="w-full h-full object-cover cursor-pointer hover:opacity-90 transition-opacity"
          />
        </div>
      ))}
       {/* Fill empty grid cells if less than 5 images */}
       {Array.from({ length: 4 - otherImages.length }).map((_, index) => (
        <div key={`placeholder-${index}`} className="hidden md:block bg-gray-200 h-full"></div>
      ))}
    </motion.div>
  );
};

export default ImageGallery;
