/*
# Ziarazetu Database Schema Setup (Fixed Version)
This migration safely sets up all required tables and policies for the Ziarazetu platform.

## Query Description:
This operation creates the complete database structure for tours, stays, volunteer opportunities, and booking management. It includes comprehensive security policies and sample data. All operations are designed to be safe and handle existing structures properly.

## Metadata:
- Schema-Category: "Structural"
- Impact-Level: "Medium" 
- Requires-Backup: false
- Reversible: true

## Structure Details:
- Creates/updates: listings, bookings, volunteer_applications, custom_requests, payment_installments tables
- Adds missing columns to existing profiles table
- Creates comprehensive RLS policies for data security
- Adds performance indexes and triggers

## Security Implications:
- RLS Status: Enabled on all tables
- Policy Changes: Yes - comprehensive user data isolation
- Auth Requirements: Users can only access their own data

## Performance Impact:
- Indexes: Added on foreign keys and frequently queried columns
- Triggers: Added for automatic timestamps and profile creation
- Estimated Impact: Improved query performance, minimal overhead
*/

-- Enable required extensions
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Add role column to profiles if it doesn't exist
DO $$ 
BEGIN 
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='profiles' AND column_name='role') THEN
        ALTER TABLE profiles ADD COLUMN role text DEFAULT 'user';
    END IF;
END $$;

-- Create listings table
CREATE TABLE IF NOT EXISTS listings (
    id uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
    title text NOT NULL,
    description text,
    category text CHECK (category IN ('tour', 'stay', 'volunteer')) NOT NULL,
    price numeric DEFAULT 0,
    rating numeric DEFAULT 0 CHECK (rating >= 0 AND rating <= 5),
    location text,
    type text,
    availability jsonb DEFAULT '{}',
    image text,
    features text[],
    amenities text[],
    itinerary jsonb,
    max_guests integer DEFAULT 1,
    duration text,
    difficulty_level text,
    created_at timestamp with time zone DEFAULT now(),
    updated_at timestamp with time zone DEFAULT now()
);

-- Create bookings table
CREATE TABLE IF NOT EXISTS bookings (
    id uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
    listing_id uuid REFERENCES listings(id) ON DELETE CASCADE,
    user_id uuid REFERENCES profiles(id) ON DELETE CASCADE,
    total_amount numeric NOT NULL,
    payment_status text CHECK (payment_status IN ('pending', 'paid', 'partial', 'cancelled')) DEFAULT 'pending',
    payment_plan text CHECK (payment_plan IN ('full', 'deposit', 'lipa_mdogo_mdogo')) DEFAULT 'full',
    paystack_reference text,
    check_in_date date,
    check_out_date date,
    guests integer DEFAULT 1,
    special_requests text,
    status text CHECK (status IN ('pending', 'confirmed', 'cancelled', 'completed')) DEFAULT 'pending',
    created_at timestamp with time zone DEFAULT now(),
    updated_at timestamp with time zone DEFAULT now()
);

-- Create volunteer applications table
CREATE TABLE IF NOT EXISTS volunteer_applications (
    id uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
    opportunity_id uuid REFERENCES listings(id) ON DELETE CASCADE,
    user_id uuid REFERENCES profiles(id) ON DELETE CASCADE,
    name text NOT NULL,
    email text NOT NULL,
    phone text,
    skills text,
    motivation text,
    availability text,
    experience text,
    emergency_contact text,
    status text CHECK (status IN ('pending', 'approved', 'rejected', 'withdrawn')) DEFAULT 'pending',
    created_at timestamp with time zone DEFAULT now(),
    updated_at timestamp with time zone DEFAULT now()
);

-- Create custom requests table
CREATE TABLE IF NOT EXISTS custom_requests (
    id uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id uuid REFERENCES profiles(id) ON DELETE CASCADE,
    trip_details text NOT NULL,
    budget numeric,
    preferred_dates text,
    group_size integer DEFAULT 1,
    contact_email text,
    contact_phone text,
    status text CHECK (status IN ('pending', 'in_progress', 'quoted', 'accepted', 'rejected')) DEFAULT 'pending',
    admin_notes text,
    quoted_amount numeric,
    created_at timestamp with time zone DEFAULT now(),
    updated_at timestamp with time zone DEFAULT now()
);

-- Create payment installments table
CREATE TABLE IF NOT EXISTS payment_installments (
    id uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
    booking_id uuid REFERENCES bookings(id) ON DELETE CASCADE,
    installment_number integer NOT NULL,
    amount numeric NOT NULL,
    due_date date NOT NULL,
    payment_status text CHECK (payment_status IN ('pending', 'paid', 'overdue')) DEFAULT 'pending',
    paystack_reference text,
    paid_at timestamp with time zone,
    created_at timestamp with time zone DEFAULT now(),
    updated_at timestamp with time zone DEFAULT now()
);

-- Create indexes for better performance
CREATE INDEX IF NOT EXISTS idx_listings_category ON listings(category);
CREATE INDEX IF NOT EXISTS idx_listings_location ON listings(location);
CREATE INDEX IF NOT EXISTS idx_bookings_user_id ON bookings(user_id);
CREATE INDEX IF NOT EXISTS idx_bookings_listing_id ON bookings(listing_id);
CREATE INDEX IF NOT EXISTS idx_bookings_status ON bookings(status);
CREATE INDEX IF NOT EXISTS idx_volunteer_applications_user_id ON volunteer_applications(user_id);
CREATE INDEX IF NOT EXISTS idx_volunteer_applications_opportunity_id ON volunteer_applications(opportunity_id);
CREATE INDEX IF NOT EXISTS idx_custom_requests_user_id ON custom_requests(user_id);
CREATE INDEX IF NOT EXISTS idx_payment_installments_booking_id ON payment_installments(booking_id);

-- Create or replace function to update timestamps
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = now();
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Create triggers for automatic timestamp updates
DO $$ 
BEGIN
    -- Drop existing triggers if they exist
    DROP TRIGGER IF EXISTS update_listings_updated_at ON listings;
    DROP TRIGGER IF EXISTS update_bookings_updated_at ON bookings;
    DROP TRIGGER IF EXISTS update_volunteer_applications_updated_at ON volunteer_applications;
    DROP TRIGGER IF EXISTS update_custom_requests_updated_at ON custom_requests;
    DROP TRIGGER IF EXISTS update_payment_installments_updated_at ON payment_installments;
    
    -- Create new triggers
    CREATE TRIGGER update_listings_updated_at BEFORE UPDATE ON listings
        FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
    CREATE TRIGGER update_bookings_updated_at BEFORE UPDATE ON bookings
        FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
    CREATE TRIGGER update_volunteer_applications_updated_at BEFORE UPDATE ON volunteer_applications
        FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
    CREATE TRIGGER update_custom_requests_updated_at BEFORE UPDATE ON custom_requests
        FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
    CREATE TRIGGER update_payment_installments_updated_at BEFORE UPDATE ON payment_installments
        FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
END $$;

-- Enable Row Level Security
ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE listings ENABLE ROW LEVEL SECURITY;
ALTER TABLE bookings ENABLE ROW LEVEL SECURITY;
ALTER TABLE volunteer_applications ENABLE ROW LEVEL SECURITY;
ALTER TABLE custom_requests ENABLE ROW LEVEL SECURITY;
ALTER TABLE payment_installments ENABLE ROW LEVEL SECURITY;

-- Drop existing policies and recreate them
DO $$ 
BEGIN
    -- Profiles policies
    DROP POLICY IF EXISTS "Users can view own profile" ON profiles;
    DROP POLICY IF EXISTS "Users can update own profile" ON profiles;
    DROP POLICY IF EXISTS "Admins can view all profiles" ON profiles;
    
    -- Listings policies
    DROP POLICY IF EXISTS "Anyone can view listings" ON listings;
    DROP POLICY IF EXISTS "Admins can manage listings" ON listings;
    
    -- Bookings policies
    DROP POLICY IF EXISTS "Users can view own bookings" ON bookings;
    DROP POLICY IF EXISTS "Users can create bookings" ON bookings;
    DROP POLICY IF EXISTS "Users can update own bookings" ON bookings;
    DROP POLICY IF EXISTS "Admins can view all bookings" ON bookings;
    
    -- Volunteer applications policies
    DROP POLICY IF EXISTS "Users can view own applications" ON volunteer_applications;
    DROP POLICY IF EXISTS "Users can create applications" ON volunteer_applications;
    DROP POLICY IF EXISTS "Users can update own applications" ON volunteer_applications;
    DROP POLICY IF EXISTS "Admins can view all applications" ON volunteer_applications;
    
    -- Custom requests policies
    DROP POLICY IF EXISTS "Users can view own requests" ON custom_requests;
    DROP POLICY IF EXISTS "Users can create requests" ON custom_requests;
    DROP POLICY IF EXISTS "Users can update own requests" ON custom_requests;
    DROP POLICY IF EXISTS "Admins can view all requests" ON custom_requests;
    
    -- Payment installments policies
    DROP POLICY IF EXISTS "Users can view own installments" ON payment_installments;
    DROP POLICY IF EXISTS "Admins can view all installments" ON payment_installments;
END $$;

-- Create policies for profiles
CREATE POLICY "Users can view own profile" ON profiles
    FOR SELECT USING (auth.uid() = id);

CREATE POLICY "Users can update own profile" ON profiles
    FOR UPDATE USING (auth.uid() = id);

CREATE POLICY "Admins can view all profiles" ON profiles
    FOR ALL USING (
        EXISTS (
            SELECT 1 FROM profiles 
            WHERE id = auth.uid() AND role = 'admin'
        )
    );

-- Create policies for listings
CREATE POLICY "Anyone can view listings" ON listings
    FOR SELECT USING (true);

CREATE POLICY "Admins can manage listings" ON listings
    FOR ALL USING (
        EXISTS (
            SELECT 1 FROM profiles 
            WHERE id = auth.uid() AND role = 'admin'
        )
    );

-- Create policies for bookings
CREATE POLICY "Users can view own bookings" ON bookings
    FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can create bookings" ON bookings
    FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own bookings" ON bookings
    FOR UPDATE USING (auth.uid() = user_id);

CREATE POLICY "Admins can view all bookings" ON bookings
    FOR ALL USING (
        EXISTS (
            SELECT 1 FROM profiles 
            WHERE id = auth.uid() AND role = 'admin'
        )
    );

-- Create policies for volunteer applications
CREATE POLICY "Users can view own applications" ON volunteer_applications
    FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can create applications" ON volunteer_applications
    FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own applications" ON volunteer_applications
    FOR UPDATE USING (auth.uid() = user_id);

CREATE POLICY "Admins can view all applications" ON volunteer_applications
    FOR ALL USING (
        EXISTS (
            SELECT 1 FROM profiles 
            WHERE id = auth.uid() AND role = 'admin'
        )
    );

-- Create policies for custom requests
CREATE POLICY "Users can view own requests" ON custom_requests
    FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can create requests" ON custom_requests
    FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own requests" ON custom_requests
    FOR UPDATE USING (auth.uid() = user_id);

CREATE POLICY "Admins can view all requests" ON custom_requests
    FOR ALL USING (
        EXISTS (
            SELECT 1 FROM profiles 
            WHERE id = auth.uid() AND role = 'admin'
        )
    );

-- Create policies for payment installments
CREATE POLICY "Users can view own installments" ON payment_installments
    FOR SELECT USING (
        EXISTS (
            SELECT 1 FROM bookings 
            WHERE bookings.id = payment_installments.booking_id 
            AND bookings.user_id = auth.uid()
        )
    );

CREATE POLICY "Admins can view all installments" ON payment_installments
    FOR ALL USING (
        EXISTS (
            SELECT 1 FROM profiles 
            WHERE id = auth.uid() AND role = 'admin'
        )
    );

-- Create function to automatically create profile
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS trigger AS $$
BEGIN
    INSERT INTO public.profiles (id, full_name, email, role)
    VALUES (
        new.id,
        new.raw_user_meta_data->>'full_name',
        new.email,
        'user'
    );
    RETURN new;
END;
$$ language plpgsql security definer;

-- Create trigger for automatic profile creation
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE TRIGGER on_auth_user_created
    AFTER INSERT ON auth.users
    FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();

-- Insert sample data only if tables are empty
DO $$
BEGIN
    -- Insert sample listings if none exist
    IF NOT EXISTS (SELECT 1 FROM listings LIMIT 1) THEN
        INSERT INTO listings (title, description, category, price, rating, location, type, image, features, amenities, duration, difficulty_level) VALUES
        -- Tours
        ('Serengeti Safari Adventure', 'Experience the great migration with our 5-day Serengeti safari. Witness millions of wildebeest and zebra crossing the plains in one of nature''s most spectacular events.', 'tour', 1200, 4.8, 'Serengeti, Tanzania', 'Safari', 'https://images.unsplash.com/photo-1516026672322-bc52d61a55d5?w=800', ARRAY['Game drives', 'Professional guide', 'All meals included', 'Transportation'], ARRAY['4WD vehicle', 'Binoculars', 'First aid kit'], '5 days', 'Moderate'),
        ('Mount Kilimanjaro Trek', 'Conquer Africa''s highest peak with our guided 7-day Machame route trek. Professional guides, full support, and breathtaking views await you on this adventure of a lifetime.', 'tour', 2500, 4.9, 'Kilimanjaro, Tanzania', 'Trekking', 'https://images.unsplash.com/photo-1609198092458-38a293c7ac4b?w=800', ARRAY['Professional guides', 'Porter service', 'All equipment', 'Meals included'], ARRAY['Camping gear', 'Oxygen tanks', 'Medical kit'], '7 days', 'Challenging'),
        ('Zanzibar Cultural Tour', 'Explore the spice island''s rich history, stunning Stone Town architecture, and pristine beaches. Learn about local culture, taste exotic spices, and relax on white sand beaches.', 'tour', 800, 4.7, 'Zanzibar, Tanzania', 'Cultural', 'https://images.unsplash.com/photo-1544735716-392fe2489ffa?w=800', ARRAY['Stone Town tour', 'Spice farm visit', 'Beach time', 'Local guide'], ARRAY['Air conditioning', 'Lunch included', 'Transportation'], '3 days', 'Easy'),
        
        -- Stays
        ('Safari Lodge Serengeti', 'Luxury tented camp overlooking the Serengeti plains. Experience the wild in comfort with our all-inclusive package featuring game drives, gourmet meals, and spa services.', 'stay', 450, 4.9, 'Serengeti, Tanzania', 'Lodge', 'https://images.unsplash.com/photo-1564501049412-61c2a3083791?w=800', ARRAY['Game drives', 'All meals', 'Spa services', 'Bar'], ARRAY['WiFi', 'Pool', 'Restaurant', 'Lounge'], NULL, NULL),
        ('Zanzibar Beach Resort', 'Beachfront resort with private beach access, world-class spa, and exciting water sports activities. Perfect for relaxation and adventure in paradise.', 'stay', 280, 4.6, 'Zanzibar, Tanzania', 'Resort', 'https://images.unsplash.com/photo-1520637836862-4d197d17c5a0?w=800', ARRAY['Private beach', 'Water sports', 'Spa', 'Multiple restaurants'], ARRAY['WiFi', 'Pool', 'Gym', 'Kids club'], NULL, NULL),
        ('Nairobi City Hotel', 'Modern hotel in the heart of Nairobi with easy access to national parks and city attractions. Perfect base for exploring Kenya''s capital and nearby wildlife areas.', 'stay', 120, 4.4, 'Nairobi, Kenya', 'Hotel', 'https://images.unsplash.com/photo-1566073771259-6a8506099945?w=800', ARRAY['City center location', 'Airport shuttle', 'Business center', 'Fitness center'], ARRAY['WiFi', 'Restaurant', 'Room service', 'Parking'], NULL, NULL),
        
        -- Volunteer Opportunities
        ('Wildlife Conservation Project', 'Help protect endangered species in Kenya''s national parks. Participate in research, anti-poaching efforts, and community education programs to make a real difference.', 'volunteer', 0, 4.8, 'Maasai Mara, Kenya', 'Conservation', 'https://images.unsplash.com/photo-1547036967-23d11aacaee0?w=800', ARRAY['Research participation', 'Anti-poaching support', 'Community outreach', 'Wildlife monitoring'], ARRAY['Accommodation', 'Meals', 'Training', 'Certificate'], '2-12 weeks', NULL),
        ('Community Education Program', 'Teach English and basic skills to children in rural communities. Help build a brighter future while experiencing authentic African culture and forming lasting friendships.', 'volunteer', 0, 4.9, 'Arusha, Tanzania', 'Education', 'https://images.unsplash.com/photo-1488521787991-ed7bbaae773c?w=800', ARRAY['Teaching support', 'Curriculum development', 'Cultural exchange', 'Community projects'], ARRAY['Accommodation', 'Meals', 'Teaching materials', 'Orientation'], '4-24 weeks', NULL),
        ('Healthcare Support Initiative', 'Support local healthcare facilities and help provide medical care to underserved communities. Work alongside local medical professionals to improve health outcomes.', 'volunteer', 0, 4.7, 'Kampala, Uganda', 'Healthcare', 'https://images.unsplash.com/photo-1576091160399-112ba8d25d1f?w=800', ARRAY['Medical assistance', 'Health education', 'Community outreach', 'Professional development'], ARRAY['Accommodation', 'Meals', 'Medical supplies', 'Supervision'], '6-16 weeks', NULL);
    END IF;
END $$;
