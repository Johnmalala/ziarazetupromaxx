import { useState, useEffect, useCallback } from 'react';
import { supabase } from '../lib/supabase';
import { RealtimeChannel } from '@supabase/supabase-js';

export type Listing = {
  id: string;
  title: string;
  description: string | null;
  category: 'tour' | 'stay' | 'volunteer';
  price: number | null;
  rating: number | null;
  location: string | null;
  type: string | null;
  availability: any;
  images: string[] | null;
  features: any;
  amenities: any;
  itinerary: any;
  created_at: string;
  status: 'published' | 'draft' | 'archived' | null;
};

export function useListings(category?: 'tour' | 'stay' | 'volunteer', searchTerm: string = '') {
  const [listings, setListings] = useState<Listing[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  const fetchListings = useCallback(async () => {
    try {
      setLoading(true);
      let query = supabase
        .from('listings')
        .select('*')
        .filter('status', 'ilike', 'published'); // Case-insensitive filter
      
      if (category) {
        query = query.filter('category', 'ilike', category); // Case-insensitive filter
      }

      if (searchTerm) {
        query = query.or(`title.ilike.%${searchTerm}%,description.ilike.%${searchTerm}%`);
      }
      
      const { data, error } = await query.order('created_at', { ascending: false });
      
      if (error) throw error;
      
      setListings(data || []);
    } catch (err) {
      setError(err instanceof Error ? err.message : 'Failed to fetch listings');
      console.error('Error fetching listings:', err);
    } finally {
      setLoading(false);
    }
  }, [category, searchTerm]);

  useEffect(() => {
    fetchListings();

    const channel = supabase
      .channel(`public:listings:${category || 'all'}:${searchTerm || 'all'}`)
      .on(
        'postgres_changes',
        { event: '*', schema: 'public', table: 'listings' },
        (payload) => {
          console.log('Change received!', payload);
          fetchListings();
        }
      )
      .subscribe();

    return () => {
      supabase.removeChannel(channel);
    };
  }, [category, searchTerm, fetchListings]);

  return { listings, loading, error, refetch: fetchListings };
}

export function useListing(id: string) {
  const [listing, setListing] = useState<Listing | null>(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  const fetchListing = useCallback(async () => {
    try {
      setLoading(true);
      const { data, error } = await supabase
        .from('listings')
        .select('*')
        .eq('id', id)
        .filter('status', 'ilike', 'published') // Case-insensitive filter
        .single();
      
      if (error) throw error;
      
      setListing(data);
    } catch (err) {
      setError(err instanceof Error ? err.message : 'Failed to fetch listing');
      console.error('Error fetching listing:', err);
    } finally {
      setLoading(false);
    }
  }, [id]);

  useEffect(() => {
    if (id) {
      fetchListing();

      const channel = supabase
        .channel(`public:listings:id=${id}`)
        .on(
          'postgres_changes',
          {
            event: '*',
            schema: 'public',
            table: 'listings',
            filter: `id=eq.${id}`,
          },
          (payload) => {
            console.log(`Change on listing ${id}`, payload);
            fetchListing();
          }
        )
        .subscribe();

      return () => {
        supabase.removeChannel(channel);
      };
    }
  }, [id, fetchListing]);

  return { listing, loading, error };
}
