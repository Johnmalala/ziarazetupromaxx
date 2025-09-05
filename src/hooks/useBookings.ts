import { useState, useEffect, useCallback } from 'react';
import { supabase } from '../lib/supabase';
import { useAuth } from './useAuth';

export type Booking = {
  id: string;
  created_at: string;
  listing_id: string;
  payment_status: 'pending' | 'paid' | 'partial';
  payment_plan: 'full' | 'deposit' | 'lipa_mdogo_mdogo';
  total_amount: number;
  guests: number | null;
  check_in_date: string | null;
  listings: {
    title: string;
    images: string[] | null;
    category: string;
  };
};

export function useBookings() {
  const { user } = useAuth();
  const [bookings, setBookings] = useState<Booking[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  const fetchBookings = useCallback(async () => {
    if (!user) {
      setBookings([]);
      setLoading(false);
      return;
    }

    try {
      setLoading(true);
      const { data, error } = await supabase
        .from('bookings')
        .select(`
          id,
          created_at,
          listing_id,
          payment_status,
          payment_plan,
          total_amount,
          guests,
          check_in_date,
          listings (
            title,
            images,
            category
          )
        `)
        .eq('user_id', user.id)
        .order('created_at', { ascending: false });

      if (error) throw error;

      setBookings(data as Booking[] || []);
    } catch (err) {
      setError(err instanceof Error ? err.message : 'Failed to fetch bookings');
    } finally {
      setLoading(false);
    }
  }, [user]);

  useEffect(() => {
    if (user) {
      fetchBookings();

      const channel = supabase
        .channel(`public:bookings:user_id=${user.id}`)
        .on(
          'postgres_changes',
          {
            event: '*',
            schema: 'public',
            table: 'bookings',
            filter: `user_id=eq.${user.id}`,
          },
          (payload) => {
            console.log('Booking change received!', payload);
            fetchBookings();
          }
        )
        .subscribe();

      return () => {
        supabase.removeChannel(channel);
      };
    }
  }, [user, fetchBookings]);

  return { bookings, loading, error, refetch: fetchBookings };
}
