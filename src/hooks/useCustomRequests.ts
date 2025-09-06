import { useState, useEffect, useCallback } from 'react';
import { supabase } from '../lib/supabase';
import { useAuth } from './useAuth';

export type CustomRequest = {
  id: string;
  created_at: string;
  trip_details: string;
  budget: number | null;
  status: string;
};

export function useCustomRequests() {
  const { user } = useAuth();
  const [requests, setRequests] = useState<CustomRequest[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  const fetchRequests = useCallback(async () => {
    if (!user) {
      setRequests([]);
      setLoading(false);
      return;
    }

    try {
      setLoading(true);
      const { data, error } = await supabase
        .from('custom_requests')
        .select('*')
        .eq('user_id', user.id)
        .order('created_at', { ascending: false });

      if (error) throw error;

      setRequests(data as CustomRequest[] || []);
    } catch (err) {
      setError(err instanceof Error ? err.message : 'Failed to fetch custom requests');
    } finally {
      setLoading(false);
    }
  }, [user]);

  useEffect(() => {
    if (user) {
      fetchRequests();

      const channel = supabase
        .channel(`public:custom_requests:user_id=${user.id}`)
        .on(
          'postgres_changes',
          {
            event: '*',
            schema: 'public',
            table: 'custom_requests',
            filter: `user_id=eq.${user.id}`,
          },
          (payload) => {
            console.log('Custom request change received!', payload);
            fetchRequests();
          }
        )
        .subscribe();

      return () => {
        supabase.removeChannel(channel);
      };
    }
  }, [user, fetchRequests]);

  return { requests, loading, error, refetch: fetchRequests };
}
