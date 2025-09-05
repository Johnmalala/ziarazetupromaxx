import React, { useState } from 'react';
import { useParams, Link } from 'react-router-dom';
import { motion } from 'framer-motion';
import { MapPin, Clock, Users, ArrowLeft, Send } from 'lucide-react';
import LoadingSpinner from '../components/LoadingSpinner';
import { useListing } from '../hooks/useListings';
import { useAuth } from '../hooks/useAuth';
import { supabase } from '../lib/supabase';
import { getImageUrl } from '../lib/utils';

const VolunteerDetailsPage: React.FC = () => {
  const { id } = useParams<{ id: string }>();
  const { listing: opportunity, loading, error } = useListing(id!);
  const { user } = useAuth();
  
  const [isApplying, setIsApplying] = useState(false);
  const [applicationData, setApplicationData] = useState({
    name: '',
    email: user?.email || '',
    skills: '',
    motivation: '',
    availability: ''
  });
  const [applicationStatus, setApplicationStatus] = useState<{ type: 'success' | 'error', message: string } | null>(null);

  if (loading) return <LoadingSpinner />;
  if (error) return <div className="text-red-600 text-center py-8">Error: {error}</div>;
  if (!opportunity) return <div className="text-center py-8">Volunteer opportunity not found.</div>;

  const handleApplicationSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    
    if (!user) {
      setApplicationStatus({ type: 'error', message: 'Please sign in to apply' });
      return;
    }

    setIsApplying(true);
    setApplicationStatus(null);

    try {
      const { error } = await supabase
        .from('volunteer_applications')
        .insert({
          opportunity_id: opportunity.id,
          user_id: user.id,
          name: applicationData.name,
          email: applicationData.email,
          skills: applicationData.skills,
          motivation: applicationData.motivation,
          availability: applicationData.availability
        });

      if (error) throw error;

      setApplicationStatus({ type: 'success', message: 'Application submitted successfully! We will contact you soon.' });
      setApplicationData({ name: '', email: user.email || '', skills: '', motivation: '', availability: '' });
    } catch (err) {
      setApplicationStatus({ 
        type: 'error', 
        message: err instanceof Error ? err.message : 'Failed to submit application' 
      });
    } finally {
      setIsApplying(false);
    }
  };

  return (
    <div className="min-h-screen pt-16">
      {/* Hero Section */}
      <section className="relative h-96">
        <div
          className="absolute inset-0 bg-cover bg-center"
          style={{ backgroundImage: `url(${getImageUrl(opportunity.images, opportunity.id)})` }}
        />
        <div className="absolute inset-0 bg-black bg-opacity-40" />
        
        <div className="relative max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 h-full flex items-center">
          <motion.div
            initial={{ opacity: 0, y: 30 }}
            animate={{ opacity: 1, y: 0 }}
            className="text-white"
          >
            <Link
              to="/volunteer"
              className="inline-flex items-center space-x-2 text-white hover:text-red-300 mb-4"
            >
              <ArrowLeft className="w-5 h-5" />
              <span>Back to Opportunities</span>
            </Link>
            
            <h1 className="text-4xl md:text-5xl font-bold mb-4">{opportunity.title}</h1>
            
            <div className="flex flex-wrap items-center gap-6 text-lg">
              <div className="flex items-center space-x-2">
                <MapPin className="w-5 h-5" />
                <span>{opportunity.location}</span>
              </div>
              
              <div className="flex items-center space-x-2">
                <Clock className="w-5 h-5" />
                <span>Flexible Schedule</span>
              </div>
              
              <div className="flex items-center space-x-2">
                <Users className="w-5 h-5" />
                <span>Community Impact</span>
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
              {/* Description */}
              <motion.div
                initial={{ opacity: 0, y: 20 }}
                animate={{ opacity: 1, y: 0 }}
                transition={{ delay: 0.1 }}
              >
                <h2 className="text-2xl font-bold mb-4">About This Opportunity</h2>
                <p className="text-gray-600 leading-relaxed">{opportunity.description}</p>
              </motion.div>

              {/* Requirements */}
              <motion.div
                initial={{ opacity: 0, y: 20 }}
                animate={{ opacity: 1, y: 0 }}
                transition={{ delay: 0.2 }}
              >
                <h2 className="text-2xl font-bold mb-4">What We're Looking For</h2>
                <div className="space-y-3">
                  <div className="flex items-start space-x-3">
                    <div className="w-2 h-2 bg-red-600 rounded-full mt-2" />
                    <span>Passionate about making a difference in communities</span>
                  </div>
                  <div className="flex items-start space-x-3">
                    <div className="w-2 h-2 bg-red-600 rounded-full mt-2" />
                    <span>Minimum commitment of 2 weeks</span>
                  </div>
                  <div className="flex items-start space-x-3">
                    <div className="w-2 h-2 bg-red-600 rounded-full mt-2" />
                    <span>Basic English communication skills</span>
                  </div>
                  <div className="flex items-start space-x-3">
                    <div className="w-2 h-2 bg-red-600 rounded-full mt-2" />
                    <span>Open mind and cultural sensitivity</span>
                  </div>
                </div>
              </motion.div>

              {/* What's Included */}
              <motion.div
                initial={{ opacity: 0, y: 20 }}
                animate={{ opacity: 1, y: 0 }}
                transition={{ delay: 0.3 }}
              >
                <h2 className="text-2xl font-bold mb-4">What's Included</h2>
                <div className="space-y-3">
                  <div className="flex items-start space-x-3">
                    <div className="w-2 h-2 bg-green-600 rounded-full mt-2" />
                    <span>Accommodation in volunteer housing</span>
                  </div>
                  <div className="flex items-start space-x-3">
                    <div className="w-2 h-2 bg-green-600 rounded-full mt-2" />
                    <span>Basic meals and local orientation</span>
                  </div>
                  <div className="flex items-start space-x-3">
                    <div className="w-2 h-2 bg-green-600 rounded-full mt-2" />
                    <span>Project supervision and support</span>
                  </div>
                  <div className="flex items-start space-x-3">
                    <div className="w-2 h-2 bg-green-600 rounded-full mt-2" />
                    <span>Certificate of completion</span>
                  </div>
                </div>
              </motion.div>
            </div>

            {/* Application Form */}
            <div className="lg:col-span-1">
              <motion.div
                initial={{ opacity: 0, x: 20 }}
                animate={{ opacity: 1, x: 0 }}
                transition={{ delay: 0.2 }}
                className="bg-white border border-gray-200 rounded-lg p-6 sticky top-24"
              >
                <h3 className="text-xl font-bold mb-6">Apply for This Opportunity</h3>

                {!user ? (
                  <div className="text-center">
                    <p className="text-gray-600 mb-4">Please sign in to apply for this volunteer opportunity.</p>
                    <Link
                      to="/auth"
                      className="w-full bg-red-600 text-white py-3 px-4 rounded-lg font-semibold hover:bg-red-700 transition-colors text-center block"
                    >
                      Sign In to Apply
                    </Link>
                  </div>
                ) : (
                  <form onSubmit={handleApplicationSubmit} className="space-y-4">
                    <div>
                      <label className="block text-sm font-medium text-gray-700 mb-2">
                        Full Name
                      </label>
                      <input
                        type="text"
                        required
                        value={applicationData.name}
                        onChange={(e) => setApplicationData(prev => ({ ...prev, name: e.target.value }))}
                        className="w-full border border-gray-300 rounded-md px-3 py-2 focus:ring-red-500 focus:border-red-500"
                        placeholder="Enter your full name"
                      />
                    </div>

                    <div>
                      <label className="block text-sm font-medium text-gray-700 mb-2">
                        Email Address
                      </label>
                      <input
                        type="email"
                        required
                        value={applicationData.email}
                        onChange={(e) => setApplicationData(prev => ({ ...prev, email: e.target.value }))}
                        className="w-full border border-gray-300 rounded-md px-3 py-2 focus:ring-red-500 focus:border-red-500"
                        placeholder="Enter your email"
                      />
                    </div>

                    <div>
                      <label className="block text-sm font-medium text-gray-700 mb-2">
                        Relevant Skills
                      </label>
                      <textarea
                        required
                        rows={3}
                        value={applicationData.skills}
                        onChange={(e) => setApplicationData(prev => ({ ...prev, skills: e.target.value }))}
                        className="w-full border border-gray-300 rounded-md px-3 py-2 focus:ring-red-500 focus:border-red-500"
                        placeholder="Describe your relevant skills and experience"
                      />
                    </div>

                    <div>
                      <label className="block text-sm font-medium text-gray-700 mb-2">
                        Motivation
                      </label>
                      <textarea
                        required
                        rows={3}
                        value={applicationData.motivation}
                        onChange={(e) => setApplicationData(prev => ({ ...prev, motivation: e.target.value }))}
                        className="w-full border border-gray-300 rounded-md px-3 py-2 focus:ring-red-500 focus:border-red-500"
                        placeholder="Why do you want to volunteer for this project?"
                      />
                    </div>

                    <div>
                      <label className="block text-sm font-medium text-gray-700 mb-2">
                        Availability
                      </label>
                      <input
                        type="text"
                        required
                        value={applicationData.availability}
                        onChange={(e) => setApplicationData(prev => ({ ...prev, availability: e.target.value }))}
                        className="w-full border border-gray-300 rounded-md px-3 py-2 focus:ring-red-500 focus:border-red-500"
                        placeholder="When are you available to volunteer?"
                      />
                    </div>

                    {applicationStatus && (
                      <div className={`p-3 rounded-md ${
                        applicationStatus.type === 'success' 
                          ? 'bg-green-50 text-green-700 border border-green-200' 
                          : 'bg-red-50 text-red-700 border border-red-200'
                      }`}>
                        <p className="text-sm">{applicationStatus.message}</p>
                      </div>
                    )}

                    <button
                      type="submit"
                      disabled={isApplying}
                      className="w-full bg-red-600 text-white py-3 px-4 rounded-lg font-semibold hover:bg-red-700 transition-colors flex items-center justify-center space-x-2 disabled:opacity-50 disabled:cursor-not-allowed"
                    >
                      <Send className="w-5 h-5" />
                      <span>{isApplying ? 'Submitting...' : 'Submit Application'}</span>
                    </button>
                  </form>
                )}
              </motion.div>
            </div>
          </div>
        </div>
      </section>
    </div>
  );
};

export default VolunteerDetailsPage;
