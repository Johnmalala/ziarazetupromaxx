import React, { useState, useEffect } from 'react';
import { useAuth } from '../hooks/useAuth';
import { supabase } from '../lib/supabase';
import LoadingSpinner from '../components/LoadingSpinner';
import { User, Mail, Save, List, ClipboardCheck } from 'lucide-react';
import { useBookings } from '../hooks/useBookings';
import { useCustomRequests } from '../hooks/useCustomRequests';
import { format } from 'date-fns';

type ProfileData = {
  full_name: string | null;
  email: string | null;
};

const ProfilePage: React.FC = () => {
  const { user } = useAuth();
  const [profile, setProfile] = useState<ProfileData | null>(null);
  const [loading, setLoading] = useState(true);
  const [updating, setUpdating] = useState(false);
  const [status, setStatus] = useState<{ type: 'success' | 'error', message: string } | null>(null);
  const [activeTab, setActiveTab] = useState('profile');

  const { bookings, loading: bookingsLoading } = useBookings();
  const { requests, loading: requestsLoading } = useCustomRequests();

  useEffect(() => {
    const fetchProfile = async () => {
      if (!user) return;
      try {
        setLoading(true);
        const { data, error } = await supabase
          .from('profiles')
          .select('full_name, email')
          .eq('id', user.id)
          .single();
        
        if (error) throw error;
        setProfile(data);
      } catch (err) {
        setStatus({ type: 'error', message: err instanceof Error ? err.message : 'Failed to fetch profile' });
      } finally {
        setLoading(false);
      }
    };
    fetchProfile();
  }, [user]);

  const handleUpdateProfile = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!user || !profile) return;
    
    setUpdating(true);
    setStatus(null);

    try {
      const { error } = await supabase
        .from('profiles')
        .update({ full_name: profile.full_name })
        .eq('id', user.id);
      
      if (error) throw error;
      setStatus({ type: 'success', message: 'Profile updated successfully!' });
    } catch (err) {
      setStatus({ type: 'error', message: err instanceof Error ? err.message : 'Failed to update profile' });
    } finally {
      setUpdating(false);
    }
  };

  const getStatusColor = (status: string) => {
    switch (status.toLowerCase()) {
      case 'quoted':
      case 'in progress':
        return 'bg-blue-100 text-blue-800';
      case 'booked':
        return 'bg-green-100 text-green-800';
      case 'pending':
      default:
        return 'bg-yellow-100 text-yellow-800';
    }
  };

  if (loading) return <LoadingSpinner />;

  return (
    <div className="min-h-screen pt-16 bg-gray-50">
      <section className="py-12">
        <div className="max-w-4xl mx-auto px-4 sm:px-6 lg:px-8">
          <h1 className="text-3xl font-bold text-center mb-8">My Dashboard</h1>
          
          <div className="mb-8 border-b border-gray-200">
            <nav className="-mb-px flex space-x-8" aria-label="Tabs">
              <button
                onClick={() => setActiveTab('profile')}
                className={`whitespace-nowrap py-4 px-1 border-b-2 font-medium text-sm ${
                  activeTab === 'profile'
                    ? 'border-red-500 text-red-600'
                    : 'border-transparent text-gray-500 hover:text-gray-700 hover:border-gray-300'
                }`}
              >
                Profile
              </button>
              <button
                onClick={() => setActiveTab('bookings')}
                className={`whitespace-nowrap py-4 px-1 border-b-2 font-medium text-sm ${
                  activeTab === 'bookings'
                    ? 'border-red-500 text-red-600'
                    : 'border-transparent text-gray-500 hover:text-gray-700 hover:border-gray-300'
                }`}
              >
                My Bookings
              </button>
              <button
                onClick={() => setActiveTab('requests')}
                className={`whitespace-nowrap py-4 px-1 border-b-2 font-medium text-sm ${
                  activeTab === 'requests'
                    ? 'border-red-500 text-red-600'
                    : 'border-transparent text-gray-500 hover:text-gray-700 hover:border-gray-300'
                }`}
              >
                My Custom Requests
              </button>
            </nav>
          </div>

          <div className="bg-white p-8 rounded-lg shadow-md">
            {activeTab === 'profile' && (
              <form onSubmit={handleUpdateProfile} className="space-y-6">
                <h2 className="text-xl font-semibold">My Information</h2>
                <div>
                  <label className="block text-sm font-medium text-gray-700">Full Name</label>
                  <div className="mt-1 relative">
                    <User className="absolute left-3 top-1/2 -translate-y-1/2 w-5 h-5 text-gray-400" />
                    <input 
                      type="text" 
                      value={profile?.full_name || ''}
                      onChange={(e) => setProfile(p => p ? { ...p, full_name: e.target.value } : null)}
                      className="w-full pl-10 border-gray-300 rounded-md shadow-sm focus:ring-red-500 focus:border-red-500"
                    />
                  </div>
                </div>
                <div>
                  <label className="block text-sm font-medium text-gray-700">Email Address</label>
                  <div className="mt-1 relative">
                    <Mail className="absolute left-3 top-1/2 -translate-y-1/2 w-5 h-5 text-gray-400" />
                    <input 
                      type="email" 
                      value={profile?.email || ''}
                      disabled 
                      className="w-full pl-10 border-gray-300 rounded-md shadow-sm bg-gray-100 cursor-not-allowed"
                    />
                  </div>
                </div>
                {status && (
                  <div className={`p-3 rounded-md text-sm ${status.type === 'success' ? 'bg-green-100 text-green-800' : 'bg-red-100 text-red-800'}`}>
                    {status.message}
                  </div>
                )}
                <div className="text-right">
                  <button type="submit" disabled={updating} className="flex items-center space-x-2 bg-red-600 text-white px-6 py-2 rounded-md hover:bg-red-700 disabled:opacity-50">
                    <Save className="w-5 h-5" />
                    <span>{updating ? 'Saving...' : 'Save Changes'}</span>
                  </button>
                </div>
              </form>
            )}

            {activeTab === 'bookings' && (
              <div>
                <h2 className="text-xl font-semibold mb-4">My Bookings</h2>
                {bookingsLoading ? <LoadingSpinner /> : bookings.length > 0 ? (
                  <div className="space-y-4">
                    {bookings.map(booking => (
                      <div key={booking.id} className="border p-4 rounded-md">
                        <p className="font-bold">{booking.listings.title}</p>
                        <p className="text-sm text-gray-500">Booked on: {format(new Date(booking.created_at), 'PPP')}</p>
                      </div>
                    ))}
                  </div>
                ) : <p className="text-gray-500">You have no active bookings.</p>}
              </div>
            )}

            {activeTab === 'requests' && (
              <div>
                <h2 className="text-xl font-semibold mb-4">My Custom Requests</h2>
                {requestsLoading ? <LoadingSpinner /> : requests.length > 0 ? (
                  <div className="space-y-4">
                    {requests.map(request => (
                      <div key={request.id} className="border p-4 rounded-md">
                        <div className="flex justify-between items-start">
                          <p className="font-bold truncate pr-4">Request from {format(new Date(request.created_at), 'PPP')}</p>
                          <span className={`px-2 py-1 text-xs font-medium rounded-full ${getStatusColor(request.status)}`}>
                            {request.status}
                          </span>
                        </div>
                        <p className="text-sm text-gray-600 mt-2 line-clamp-2">{request.trip_details}</p>
                      </div>
                    ))}
                  </div>
                ) : <p className="text-gray-500">You have not made any custom trip requests.</p>}
              </div>
            )}
          </div>
        </div>
      </section>
    </div>
  );
};

export default ProfilePage;
