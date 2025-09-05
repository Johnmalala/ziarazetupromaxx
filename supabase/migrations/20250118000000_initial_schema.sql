/*
# Ziarazetu Initial Database Schema
Complete database setup for the Ziarazetu travel platform including user profiles, listings, bookings, volunteer applications, and custom trip requests.

## Query Description: 
This migration creates the foundational database structure for a travel booking platform. It establishes user profiles linked to Supabase Auth, content listings for tours/stays/volunteer opportunities, a booking system with multiple payment options, volunteer applications, and custom trip requests. Includes comprehensive RLS policies for data security and automatic profile creation via database triggers.

## Metadata:
- Schema-Category: "Structural"
- Impact-Level: "High"
- Requires-Backup: false
- Reversible: true

## Structure Details:
- profiles: User profile data linked to auth.users
- listings: Tours, stays, and volunteer opportunities
- bookings: Reservation system with payment tracking
- volunteer_applications: Applications for volunteer positions
- custom_requests: Custom trip planning requests

## Security Implications:
- RLS Status: Enabled on all public tables
- Policy Changes: Yes - comprehensive row-level security
- Auth Requirements: Users can only access their own data

## Performance Impact:
- Indexes: Added on foreign keys and frequently queried columns
- Triggers: Profile auto-creation on user signup
- Estimated Impact: Minimal - optimized for read/write operations
*/

-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Profiles table
CREATE TABLE public.profiles (
  id UUID REFERENCES auth.users ON DELETE CASCADE,
  full_name TEXT,
  email TEXT,
  role TEXT DEFAULT 'user' CHECK (role IN ('user', 'admin')),
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  PRIMARY KEY (id)
);

-- Listings table
CREATE TABLE public.listings (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  title TEXT NOT NULL,
  description TEXT,
  category TEXT NOT NULL CHECK (category IN ('tour', 'stay', 'volunteer')),
  price NUMERIC DEFAULT 0,
  rating NUMERIC CHECK (rating >= 0 AND rating <= 5),
  location TEXT,
  type TEXT,
  availability JSONB DEFAULT '{}',
  image TEXT,
  images JSONB DEFAULT '[]',
  amenities JSONB DEFAULT '[]',
  itinerary JSONB DEFAULT '[]',
  duration TEXT,
  max_guests INTEGER,
  featured BOOLEAN DEFAULT FALSE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Bookings table
CREATE TABLE public.bookings (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  listing_id UUID REFERENCES public.listings(id) ON DELETE CASCADE,
  user_id UUID REFERENCES public.profiles(id) ON DELETE CASCADE,
  total_amount NUMERIC NOT NULL CHECK (total_amount >= 0),
  amount_paid NUMERIC DEFAULT 0 CHECK (amount_paid >= 0),
  payment_status TEXT DEFAULT 'pending' CHECK (payment_status IN ('pending', 'paid', 'partial', 'cancelled')),
  payment_plan TEXT DEFAULT 'full' CHECK (payment_plan IN ('full', 'deposit', 'lipa_mdogo_mdogo')),
  check_in_date DATE,
  check_out_date DATE,
  guests INTEGER DEFAULT 1,
  special_requests TEXT,
  paystack_reference TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Volunteer applications table
CREATE TABLE public.volunteer_applications (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  opportunity_id UUID REFERENCES public.listings(id) ON DELETE CASCADE,
  user_id UUID REFERENCES public.profiles(id) ON DELETE CASCADE,
  name TEXT NOT NULL,
  email TEXT NOT NULL,
  phone TEXT,
  skills TEXT,
  motivation TEXT,
  availability TEXT,
  experience TEXT,
  status TEXT DEFAULT 'pending' CHECK (status IN ('pending', 'approved', 'rejected')),
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Custom trip requests table
CREATE TABLE public.custom_requests (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID REFERENCES public.profiles(id) ON DELETE CASCADE,
  trip_details TEXT NOT NULL,
  budget NUMERIC,
  preferred_dates TEXT,
  group_size INTEGER DEFAULT 1,
  contact_phone TEXT,
  status TEXT DEFAULT 'pending' CHECK (status IN ('pending', 'in_progress', 'quoted', 'completed')),
  admin_notes TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Payment installments table (for lipa mdogo mdogo)
CREATE TABLE public.payment_installments (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  booking_id UUID REFERENCES public.bookings(id) ON DELETE CASCADE,
  amount NUMERIC NOT NULL CHECK (amount > 0),
  due_date DATE NOT NULL,
  paid_date DATE,
  status TEXT DEFAULT 'pending' CHECK (status IN ('pending', 'paid', 'overdue')),
  paystack_reference TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create indexes for better performance
CREATE INDEX idx_listings_category ON public.listings(category);
CREATE INDEX idx_listings_featured ON public.listings(featured);
CREATE INDEX idx_bookings_user_id ON public.bookings(user_id);
CREATE INDEX idx_bookings_listing_id ON public.bookings(listing_id);
CREATE INDEX idx_bookings_status ON public.bookings(payment_status);
CREATE INDEX idx_volunteer_applications_user_id ON public.volunteer_applications(user_id);
CREATE INDEX idx_volunteer_applications_opportunity_id ON public.volunteer_applications(opportunity_id);
CREATE INDEX idx_custom_requests_user_id ON public.custom_requests(user_id);
CREATE INDEX idx_payment_installments_booking_id ON public.payment_installments(booking_id);

-- Enable Row Level Security
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.listings ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.bookings ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.volunteer_applications ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.custom_requests ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.payment_installments ENABLE ROW LEVEL SECURITY;

-- RLS Policies for profiles
CREATE POLICY "Public profiles are viewable by everyone" ON public.profiles
  FOR SELECT USING (true);

CREATE POLICY "Users can insert their own profile" ON public.profiles
  FOR INSERT WITH CHECK (auth.uid() = id);

CREATE POLICY "Users can update their own profile" ON public.profiles
  FOR UPDATE USING (auth.uid() = id);

-- RLS Policies for listings
CREATE POLICY "Listings are viewable by everyone" ON public.listings
  FOR SELECT USING (true);

CREATE POLICY "Only admins can insert listings" ON public.listings
  FOR INSERT WITH CHECK (
    EXISTS (
      SELECT 1 FROM public.profiles 
      WHERE id = auth.uid() AND role = 'admin'
    )
  );

CREATE POLICY "Only admins can update listings" ON public.listings
  FOR UPDATE USING (
    EXISTS (
      SELECT 1 FROM public.profiles 
      WHERE id = auth.uid() AND role = 'admin'
    )
  );

CREATE POLICY "Only admins can delete listings" ON public.listings
  FOR DELETE USING (
    EXISTS (
      SELECT 1 FROM public.profiles 
      WHERE id = auth.uid() AND role = 'admin'
    )
  );

-- RLS Policies for bookings
CREATE POLICY "Users can view their own bookings" ON public.bookings
  FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can insert their own bookings" ON public.bookings
  FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update their own bookings" ON public.bookings
  FOR UPDATE USING (auth.uid() = user_id);

CREATE POLICY "Admins can view all bookings" ON public.bookings
  FOR SELECT USING (
    EXISTS (
      SELECT 1 FROM public.profiles 
      WHERE id = auth.uid() AND role = 'admin'
    )
  );

-- RLS Policies for volunteer applications
CREATE POLICY "Users can view their own applications" ON public.volunteer_applications
  FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can insert their own applications" ON public.volunteer_applications
  FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update their own applications" ON public.volunteer_applications
  FOR UPDATE USING (auth.uid() = user_id);

CREATE POLICY "Admins can view all applications" ON public.volunteer_applications
  FOR SELECT USING (
    EXISTS (
      SELECT 1 FROM public.profiles 
      WHERE id = auth.uid() AND role = 'admin'
    )
  );

-- RLS Policies for custom requests
CREATE POLICY "Users can view their own requests" ON public.custom_requests
  FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can insert their own requests" ON public.custom_requests
  FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update their own requests" ON public.custom_requests
  FOR UPDATE USING (auth.uid() = user_id);

CREATE POLICY "Admins can view all requests" ON public.custom_requests
  FOR SELECT USING (
    EXISTS (
      SELECT 1 FROM public.profiles 
      WHERE id = auth.uid() AND role = 'admin'
    )
  );

-- RLS Policies for payment installments
CREATE POLICY "Users can view their own installments" ON public.payment_installments
  FOR SELECT USING (
    EXISTS (
      SELECT 1 FROM public.bookings 
      WHERE id = booking_id AND user_id = auth.uid()
    )
  );

CREATE POLICY "Users can update their own installments" ON public.payment_installments
  FOR UPDATE USING (
    EXISTS (
      SELECT 1 FROM public.bookings 
      WHERE id = booking_id AND user_id = auth.uid()
    )
  );

-- Function to handle updated_at timestamp
CREATE OR REPLACE FUNCTION public.handle_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Triggers for updated_at
CREATE TRIGGER handle_profiles_updated_at
  BEFORE UPDATE ON public.profiles
  FOR EACH ROW EXECUTE FUNCTION public.handle_updated_at();

CREATE TRIGGER handle_listings_updated_at
  BEFORE UPDATE ON public.listings
  FOR EACH ROW EXECUTE FUNCTION public.handle_updated_at();

CREATE TRIGGER handle_bookings_updated_at
  BEFORE UPDATE ON public.bookings
  FOR EACH ROW EXECUTE FUNCTION public.handle_updated_at();

CREATE TRIGGER handle_volunteer_applications_updated_at
  BEFORE UPDATE ON public.volunteer_applications
  FOR EACH ROW EXECUTE FUNCTION public.handle_updated_at();

CREATE TRIGGER handle_custom_requests_updated_at
  BEFORE UPDATE ON public.custom_requests
  FOR EACH ROW EXECUTE FUNCTION public.handle_updated_at();

CREATE TRIGGER handle_payment_installments_updated_at
  BEFORE UPDATE ON public.payment_installments
  FOR EACH ROW EXECUTE FUNCTION public.handle_updated_at();

-- Function to automatically create profile for new users
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO public.profiles (id, full_name, email)
  VALUES (
    NEW.id,
    NEW.raw_user_meta_data->>'full_name',
    NEW.email
  );
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Trigger to create profile when user signs up
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();

-- Insert sample data for development
INSERT INTO public.listings (title, description, category, price, rating, location, type, image, featured) VALUES
('Serengeti Safari Adventure', 'Experience the great migration with our 5-day Serengeti safari. Witness millions of wildebeest and zebra crossing the plains.', 'tour', 1200, 4.8, 'Serengeti, Tanzania', 'Safari', 'https://images.unsplash.com/photo-1516026672322-bc52d61a55d5?w=800', true),
('Mount Kilimanjaro Trek', 'Conquer Africa''s highest peak with our guided 7-day Machame route trek. Professional guides and full support.', 'tour', 2500, 4.9, 'Kilimanjaro, Tanzania', 'Trekking', 'https://images.unsplash.com/photo-1609198092458-38a293c7ac4b?w=800', true),
('Zanzibar Cultural Tour', 'Explore the spice island''s rich history, stone town architecture, and pristine beaches.', 'tour', 800, 4.7, 'Zanzibar, Tanzania', 'Cultural', 'https://images.unsplash.com/photo-1544735716-392fe2489ffa?w=800', true),
('Safari Lodge Serengeti', 'Luxury tented camp overlooking the Serengeti plains. All-inclusive with game drives.', 'stay', 450, 4.9, 'Serengeti, Tanzania', 'Lodge', 'https://images.unsplash.com/photo-1564501049412-61c2a3083791?w=800', true),
('Zanzibar Beach Resort', 'Beachfront resort with private beach access, spa, and water sports activities.', 'stay', 280, 4.6, 'Zanzibar, Tanzania', 'Resort', 'https://images.unsplash.com/photo-1520637836862-4d197d17c5a0?w=800', true),
('Nairobi City Hotel', 'Modern hotel in the heart of Nairobi with easy access to national parks and city attractions.', 'stay', 120, 4.4, 'Nairobi, Kenya', 'Hotel', 'https://images.unsplash.com/photo-1566073771259-6a8506099945?w=800', false),
('Wildlife Conservation Project', 'Help protect endangered species in Kenya''s national parks. Research and conservation work.', 'volunteer', 0, 4.8, 'Maasai Mara, Kenya', 'Conservation', 'https://images.unsplash.com/photo-1547036967-23d11aacaee0?w=800', true),
('Community Education Program', 'Teach English and basic skills to children in rural communities. Make a lasting impact.', 'volunteer', 0, 4.9, 'Arusha, Tanzania', 'Education', 'https://images.unsplash.com/photo-1488521787991-ed7bbaae773c?w=800', true),
('Healthcare Support Initiative', 'Support local healthcare facilities and help provide medical care to underserved communities.', 'volunteer', 0, 4.7, 'Kampala, Uganda', 'Healthcare', 'https://images.unsplash.com/photo-1576091160399-112ba8d25d1f?w=800', false);
