import React, { useState, useEffect } from 'react';
import { useAuth } from '../hooks/useAuth';
import { supabase } from '../lib/supabase';
import LoadingSpinner from '../components/LoadingSpinner';
import { User, Mail, Save } from 'lucide-react';
import { Link } from 'react-router-dom';

type Profile = {
  full_name: string | null;
  email: string | null;
};

const ProfilePage: React.FC = () => {
  const { user } = useAuth();
  const [profile, setProfile] = useState<Profile | null>(null);
  const [loading, setLoading] = useState(true);
  const [updating, setUpdating] = useState(false);
  const [status, setStatus] = useState<{ type: 'success' | 'error', message: string } | null>(null);

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

  if (loading) return <LoadingSpinner />;

  return (
    <div className="min-h-screen pt-16 bg-gray-50">
      <section className="py-12">
        <div className="max-w-2xl mx-auto px-4 sm:px-6 lg:px-8">
          <h1 className="text-3xl font-bold text-center mb-8">My Profile</h1>
          <div className="bg-white p-8 rounded-lg shadow-md">
            <form onSubmit={handleUpdateProfile} className="space-y-6">
              <div>
                <label className="block text-sm font-medium text-gray-700">Full Name</label>
                <div className="mt-1 relative">
                  <User className="absolute left-3 top-1/2 -translate-y-1/2 w-5 h-5 text-gray-400" />
                  <input 
                    type="text" 
                    value={profile?.full_name || ''}
                    onChange={(e) => setProfile(p => p ? { ...p, full_name: e.target.value } : null)}
                    className="w-full pl-10 border-gray-300 rounded-md shadow-sm"
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
                    className="w-full pl-10 border-gray-300 rounded-md shadow-sm bg-gray-100"
                  />
                </div>
              </div>

              {status && (
                <div className={`p-3 rounded-md text-sm ${status.type === 'success' ? 'bg-green-100 text-green-800' : 'bg-red-100 text-red-800'}`}>
                  {status.message}
                </div>
              )}

              <div className="flex justify-between items-center">
                <Link to="/bookings" className="text-red-600 hover:underline font-medium">
                  View My Bookings
                </Link>
                <button type="submit" disabled={updating} className="flex items-center space-x-2 bg-red-600 text-white px-6 py-2 rounded-md hover:bg-red-700 disabled:opacity-50">
                  <Save className="w-5 h-5" />
                  <span>{updating ? 'Saving...' : 'Save Changes'}</span>
                </button>
              </div>
            </form>
          </div>
        </div>
      </section>
    </div>
  );
};

export default ProfilePage;
