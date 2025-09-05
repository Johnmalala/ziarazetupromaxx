import { createClient } from '@supabase/supabase-js';

const supabaseUrl = import.meta.env.VITE_SUPABASE_URL;
const supabaseKey = import.meta.env.VITE_SUPABASE_ANON_KEY;

if (!supabaseUrl || !supabaseKey) {
  throw new Error('Missing Supabase environment variables. Please check your .env file.');
}

export const supabase = createClient<Database>(supabaseUrl, supabaseKey);

export type Database = {
  public: {
    Tables: {
      profiles: {
        Row: {
          id: string;
          full_name: string | null;
          email: string | null;
          role: string;
          created_at: string;
        };
        Insert: {
          id: string;
          full_name?: string | null;
          email?: string | null;
          role?: string;
          created_at?: string;
        };
        Update: {
          id?: string;
          full_name?: string | null;
          email?: string | null;
          role?: string;
          created_at?: string;
        };
      };
      listings: {
        Row: {
          id: string;
          title: string;
          description: string | null;
          category: 'tour' | 'stay' | 'volunteer';
          price: number | null;
          rating: number | null;
          location: string | null;
          type: string | null;
          availability: any;
          images: string[] | null; // Changed from image to images
          features: any;
          amenities: any;
          itinerary: any;
          created_at: string;
          status: 'published' | 'draft' | 'archived' | null;
        };
        Insert: {
          id?: string;
          title: string;
          description?: string | null;
          category: 'tour' | 'stay' | 'volunteer';
          price?: number | null;
          rating?: number | null;
          location?: string | null;
          type?: string | null;
          availability?: any;
          images?: string[] | null; // Changed from image to images
          features?: any;
          amenities?: any;
          itinerary?: any;
          created_at?: string;
          status?: 'published' | 'draft' | 'archived' | null;
        };
        Update: {
          id?: string;
          title?: string;
          description?: string | null;
          category?: 'tour' | 'stay' | 'volunteer';
          price?: number | null;
          rating?: number | null;
          location?: string | null;
          type?: string | null;
          availability?: any;
          images?: string[] | null; // Changed from image to images
          features?: any;
          amenities?: any;
          itinerary?: any;
          created_at?: string;
          status?: 'published' | 'draft' | 'archived' | null;
        };
      };
      bookings: {
        Row: {
          id: string;
          listing_id: string;
          user_id: string;
          total_amount: number;
          payment_status: 'pending' | 'paid' | 'partial';
          payment_plan: 'full' | 'deposit' | 'lipa_mdogo_mdogo';
          created_at: string;
          guests: number | null;
          check_in_date: string | null;
          check_out_date: string | null;
          paystack_ref: string | null;
        };
        Insert: {
          id?: string;
          listing_id: string;
          user_id: string;
          total_amount: number;
          payment_status?: 'pending' | 'paid' | 'partial';
          payment_plan?: 'full' | 'deposit' | 'lipa_mdogo_mdogo';
          created_at?: string;
          guests?: number | null;
          check_in_date?: string | null;
          check_out_date?: string | null;
          paystack_ref?: string | null;
        };
        Update: {
          id?: string;
          listing_id?: string;
          user_id?: string;
          total_amount?: number;
          payment_status?: 'pending' | 'paid' | 'partial';
          payment_plan?: 'full' | 'deposit' | 'lipa_mdogo_mdogo';
          created_at?: string;
          guests?: number | null;
          check_in_date?: string | null;
          check_out_date?: string | null;
          paystack_ref?: string | null;
        };
      };
      volunteer_applications: {
        Row: {
          id: string;
          opportunity_id: string;
          user_id: string;
          name: string;
          email: string;
          skills: string;
          motivation: string;
          availability: string;
          created_at: string;
        };
        Insert: {
          id?: string;
          opportunity_id: string;
          user_id: string;
          name: string;
          email: string;
          skills: string;
          motivation: string;
          availability: string;
          created_at?: string;
        };
        Update: {
          id?: string;
          opportunity_id?: string;
          user_id?: string;
          name?: string;
          email?: string;
          skills?: string;
          motivation?: string;
          availability?: string;
          created_at?: string;
        };
      };
      custom_requests: {
        Row: {
          id: string;
          user_id: string;
          trip_details: string;
          budget: number | null;
          created_at: string;
        };
        Insert: {
          id?: string;
          user_id: string;
          trip_details: string;
          budget?: number | null;
          created_at?: string;
        };
        Update: {
          id?: string;
          user_id?: string;
          trip_details?: string;
          budget?: number | null;
          created_at?: string;
        };
      };
    };
  };
};
