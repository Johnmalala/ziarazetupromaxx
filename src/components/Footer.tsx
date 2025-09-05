import React from 'react';
import { Link } from 'react-router-dom';
import { Phone, Mail, MapPin, Facebook, Twitter, Instagram, Youtube } from 'lucide-react';

const Footer: React.FC = () => {
  return (
    <footer className="bg-gray-900 text-white">
      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-12">
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-8">
          {/* Company Info */}
          <div className="space-y-4">
            <div className="flex items-center space-x-2">
              <div className="w-10 h-10 bg-red-600 rounded-lg flex items-center justify-center">
                <span className="text-white font-bold text-xl">Z</span>
              </div>
              <span className="text-2xl font-bold">Ziarazetu</span>
            </div>
            <p className="text-gray-300 text-sm">
              Discover the beauty of East Africa with our carefully curated tours, comfortable stays, and meaningful volunteer opportunities.
            </p>
            <div className="flex space-x-4">
              <a href="#" className="text-gray-300 hover:text-red-400 transition-colors">
                <Facebook className="w-5 h-5" />
              </a>
              <a href="#" className="text-gray-300 hover:text-red-400 transition-colors">
                <Twitter className="w-5 h-5" />
              </a>
              <a href="#" className="text-gray-300 hover:text-red-400 transition-colors">
                <Instagram className="w-5 h-5" />
              </a>
              <a href="#" className="text-gray-300 hover:text-red-400 transition-colors">
                <Youtube className="w-5 h-5" />
              </a>
            </div>
          </div>

          {/* Quick Links */}
          <div className="space-y-4">
            <h3 className="text-lg font-semibold">Quick Links</h3>
            <div className="space-y-2">
              <Link to="/tours" className="block text-gray-300 hover:text-red-400 transition-colors text-sm">
                Tours
              </Link>
              <Link to="/stays" className="block text-gray-300 hover:text-red-400 transition-colors text-sm">
                Stays
              </Link>
              <Link to="/volunteer" className="block text-gray-300 hover:text-red-400 transition-colors text-sm">
                Volunteer
              </Link>
              <Link to="/custom-packages" className="block text-gray-300 hover:text-red-400 transition-colors text-sm">
                Custom Packages
              </Link>
            </div>
          </div>

          {/* Services */}
          <div className="space-y-4">
            <h3 className="text-lg font-semibold">Services</h3>
            <div className="space-y-2">
              <span className="block text-gray-300 text-sm">Safari Tours</span>
              <span className="block text-gray-300 text-sm">Mountain Trekking</span>
              <span className="block text-gray-300 text-sm">Cultural Experiences</span>
              <span className="block text-gray-300 text-sm">Luxury Lodges</span>
              <span className="block text-gray-300 text-sm">Beach Resorts</span>
              <span className="block text-gray-300 text-sm">Volunteer Programs</span>
            </div>
          </div>

          {/* Contact Info */}
          <div className="space-y-4">
            <h3 className="text-lg font-semibold">Contact Us</h3>
            <div className="space-y-3">
              <div className="flex items-center space-x-3">
                <Phone className="w-5 h-5 text-red-400" />
                <span className="text-gray-300 text-sm">+254 700 123 456</span>
              </div>
              <div className="flex items-center space-x-3">
                <Mail className="w-5 h-5 text-red-400" />
                <span className="text-gray-300 text-sm">info@ziarazetu.com</span>
              </div>
              <div className="flex items-start space-x-3">
                <MapPin className="w-5 h-5 text-red-400 mt-0.5" />
                <span className="text-gray-300 text-sm">
                  Nairobi, Kenya<br />
                  Covering Kenya, Tanzania, Uganda & Rwanda
                </span>
              </div>
            </div>
          </div>
        </div>

        {/* Bottom Bar */}
        <div className="border-t border-gray-800 mt-8 pt-8 flex flex-col md:flex-row justify-between items-center">
          <p className="text-gray-300 text-sm">
            © 2025 Ziarazetu. All rights reserved.
          </p>
          <div className="flex space-x-6 mt-4 md:mt-0">
            <Link to="/privacy" className="text-gray-300 hover:text-red-400 transition-colors text-sm">
              Privacy Policy
            </Link>
            <Link to="/terms" className="text-gray-300 hover:text-red-400 transition-colors text-sm">
              Terms of Service
            </Link>
          </div>
        </div>
      </div>
    </footer>
  );
};

export default Footer;
