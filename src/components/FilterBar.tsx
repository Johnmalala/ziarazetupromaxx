import React from 'react';
import { motion } from 'framer-motion';

interface FilterBarProps {
  categories: string[];
  selected: string;
  onSelect: (category: string) => void;
}

const FilterBar: React.FC<FilterBarProps> = ({ categories, selected, onSelect }) => {
  return (
    <div className="flex flex-wrap gap-2">
      {categories.map((category) => (
        <motion.button
          key={category}
          onClick={() => onSelect(category)}
          className={`px-4 py-2 rounded-full text-sm font-medium transition-colors ${
            selected === category
              ? 'bg-red-600 text-white'
              : 'bg-white text-gray-700 border border-gray-300 hover:bg-gray-100'
          }`}
          whileHover={{ scale: 1.05 }}
          whileTap={{ scale: 0.95 }}
        >
          {category}
        </motion.button>
      ))}
    </div>
  );
};

export default FilterBar;
