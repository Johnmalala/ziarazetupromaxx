/*
# Safe Schema Update for Ziarazetu Platform
This migration safely adds missing tables and data without recreating existing ones.

## Query Description: 
This operation will safely add missing database tables for the Ziarazetu platform. It checks for existing tables before creating new ones, ensuring no data loss. The migration adds tables for listings, bookings, volunteer applications, custom requests, and payment installments if they don't already exist.

## Metadata:
- Schema-Category: "Safe"
- Impact-Level: "Low" 
- Requires-Backup: false
- Reversible: true

## Structure Details:
- Tables: listings, bookings, volunteer_applications, custom_requests, payment_installments
- Columns: All necessary fields for booking system, volunteer management, and payment tracking
- Constraints: Foreign keys, check constraints, and proper data types

## Security Implications:
- RLS Status: Enabled on all new tables
- Policy Changes: Yes - adds comprehensive RLS policies
- Auth Requirements: Users can only access their own data

## Performance Impact:
- Indexes: Added on frequently queried columns (user_id, listing_id, category)
- Triggers: Profile creation trigger and updated_at triggers
- Estimated Impact: Minimal performance impact, improved query performance
*/

-- Enable UUID extension if not already enabled
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Check if profiles table exists and has the role column, if not add it
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 
        FROM information_schema.columns 
        WHERE table_name = 'profiles' 
        AND column_name = 'role'
    ) THEN
        ALTER TABLE profiles ADD COLUMN role text DEFAULT 'user';
    END IF;
END $$;

-- Create listings table if it doesn't exist
CREATE TABLE IF NOT EXISTS listings (
    id uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
    title text NOT NULL,
    description text,
    category text CHECK (category IN ('tour', 'stay', 'volunteer')) NOT NULL,
    price numeric,
    rating numeric CHECK (rating >= 0 AND rating <= 5),
    location text,
    type text,
    availability jsonb DEFAULT '{}',
    image text,
    created_at timestamp with time zone DEFAULT now(),
    updated_at timestamp with time zone DEFAULT now()
);

-- Create bookings table if it doesn't exist
CREATE TABLE IF NOT EXISTS bookings (
    id uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
    listing_id uuid REFERENCES listings(id) ON DELETE CASCADE,
    user_id uuid REFERENCES profiles(id) ON DELETE CASCADE,
    total_amount numeric NOT NULL,
    payment_status text CHECK (payment_status IN ('pending', 'paid', 'partial')) DEFAULT 'pending',
    payment_plan text CHECK (payment_plan IN ('full', 'deposit', 'lipa_mdogo_mdogo')) DEFAULT 'full',
    booking_date date,
    guests integer DEFAULT 1,
    special_requests text,
    created_at timestamp with time zone DEFAULT now(),
    updated_at timestamp with time zone DEFAULT now()
);

-- Create volunteer_applications table if it doesn't exist
CREATE TABLE IF NOT EXISTS volunteer_applications (
    id uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
    opportunity_id uuid REFERENCES listings(id) ON DELETE CASCADE,
    user_id uuid REFERENCES profiles(id) ON DELETE CASCADE,
    name text NOT NULL,
    email text NOT NULL,
    skills text,
    motivation text,
    availability text,
    status text CHECK (status IN ('pending', 'approved', 'rejected')) DEFAULT 'pending',
    created_at timestamp with time zone DEFAULT now(),
    updated_at timestamp with time zone DEFAULT now()
);

-- Create custom_requests table if it doesn't exist
CREATE TABLE IF NOT EXISTS custom_requests (
    id uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id uuid REFERENCES profiles(id) ON DELETE CASCADE,
    trip_details text NOT NULL,
    budget numeric,
    destination text,
    travel_dates text,
    group_size integer DEFAULT 1,
    status text CHECK (status IN ('pending', 'processing', 'quoted', 'confirmed', 'cancelled')) DEFAULT 'pending',
    created_at timestamp with time zone DEFAULT now(),
    updated_at timestamp with time zone DEFAULT now()
);

-- Create payment_installments table if it doesn't exist
CREATE TABLE IF NOT EXISTS payment_installments (
    id uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
    booking_id uuid REFERENCES bookings(id) ON DELETE CASCADE,
    installment_number integer NOT NULL,
    amount numeric NOT NULL,
    due_date date NOT NULL,
    status text CHECK (status IN ('pending', 'paid', 'overdue')) DEFAULT 'pending',
    paid_at timestamp with time zone,
    created_at timestamp with time zone DEFAULT now()
);

-- Create indexes for better performance
CREATE INDEX IF NOT EXISTS idx_listings_category ON listings(category);
CREATE INDEX IF NOT EXISTS idx_listings_location ON listings(location);
CREATE INDEX IF NOT EXISTS idx_bookings_user_id ON bookings(user_id);
CREATE INDEX IF NOT EXISTS idx_bookings_listing_id ON bookings(listing_id);
CREATE INDEX IF NOT EXISTS idx_volunteer_applications_user_id ON volunteer_applications(user_id);
CREATE INDEX IF NOT EXISTS idx_volunteer_applications_opportunity_id ON volunteer_applications(opportunity_id);
CREATE INDEX IF NOT EXISTS idx_custom_requests_user_id ON custom_requests(user_id);
CREATE INDEX IF NOT EXISTS idx_payment_installments_booking_id ON payment_installments(booking_id);

-- Enable Row Level Security
ALTER TABLE listings ENABLE ROW LEVEL SECURITY;
ALTER TABLE bookings ENABLE ROW LEVEL SECURITY;
ALTER TABLE volunteer_applications ENABLE ROW LEVEL SECURITY;
ALTER TABLE custom_requests ENABLE ROW LEVEL SECURITY;
ALTER TABLE payment_installments ENABLE ROW LEVEL SECURITY;

-- RLS Policies for listings (public read, admin write)
DROP POLICY IF EXISTS "Listings are viewable by everyone" ON listings;
CREATE POLICY "Listings are viewable by everyone" ON listings
    FOR SELECT USING (true);

DROP POLICY IF EXISTS "Admins can manage listings" ON listings;
CREATE POLICY "Admins can manage listings" ON listings
    FOR ALL USING (
        EXISTS (
            SELECT 1 FROM profiles 
            WHERE profiles.id = auth.uid() 
            AND profiles.role = 'admin'
        )
    );

-- RLS Policies for bookings (users can only see their own)
DROP POLICY IF EXISTS "Users can view their own bookings" ON bookings;
CREATE POLICY "Users can view their own bookings" ON bookings
    FOR SELECT USING (auth.uid() = user_id);

DROP POLICY IF EXISTS "Users can create their own bookings" ON bookings;
CREATE POLICY "Users can create their own bookings" ON bookings
    FOR INSERT WITH CHECK (auth.uid() = user_id);

DROP POLICY IF EXISTS "Users can update their own bookings" ON bookings;
CREATE POLICY "Users can update their own bookings" ON bookings
    FOR UPDATE USING (auth.uid() = user_id);

DROP POLICY IF EXISTS "Admins can manage all bookings" ON bookings;
CREATE POLICY "Admins can manage all bookings" ON bookings
    FOR ALL USING (
        EXISTS (
            SELECT 1 FROM profiles 
            WHERE profiles.id = auth.uid() 
            AND profiles.role = 'admin'
        )
    );

-- RLS Policies for volunteer_applications
DROP POLICY IF EXISTS "Users can view their own applications" ON volunteer_applications;
CREATE POLICY "Users can view their own applications" ON volunteer_applications
    FOR SELECT USING (auth.uid() = user_id);

DROP POLICY IF EXISTS "Users can create their own applications" ON volunteer_applications;
CREATE POLICY "Users can create their own applications" ON volunteer_applications
    FOR INSERT WITH CHECK (auth.uid() = user_id);

DROP POLICY IF EXISTS "Admins can manage all applications" ON volunteer_applications;
CREATE POLICY "Admins can manage all applications" ON volunteer_applications
    FOR ALL USING (
        EXISTS (
            SELECT 1 FROM profiles 
            WHERE profiles.id = auth.uid() 
            AND profiles.role = 'admin'
        )
    );

-- RLS Policies for custom_requests
DROP POLICY IF EXISTS "Users can view their own requests" ON custom_requests;
CREATE POLICY "Users can view their own requests" ON custom_requests
    FOR SELECT USING (auth.uid() = user_id);

DROP POLICY IF EXISTS "Users can create their own requests" ON custom_requests;
CREATE POLICY "Users can create their own requests" ON custom_requests
    FOR INSERT WITH CHECK (auth.uid() = user_id);

DROP POLICY IF EXISTS "Admins can manage all requests" ON custom_requests;
CREATE POLICY "Admins can manage all requests" ON custom_requests
    FOR ALL USING (
        EXISTS (
            SELECT 1 FROM profiles 
            WHERE profiles.id = auth.uid() 
            AND profiles.role = 'admin'
        )
    );

-- RLS Policies for payment_installments
DROP POLICY IF EXISTS "Users can view installments for their bookings" ON payment_installments;
CREATE POLICY "Users can view installments for their bookings" ON payment_installments
    FOR SELECT USING (
        EXISTS (
            SELECT 1 FROM bookings 
            WHERE bookings.id = payment_installments.booking_id 
            AND bookings.user_id = auth.uid()
        )
    );

-- Create or replace function to automatically create user profile
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS trigger AS $$
BEGIN
    INSERT INTO public.profiles (id, full_name, email, role)
    VALUES (
        new.id,
        COALESCE(new.raw_user_meta_data->>'full_name', ''),
        new.email,
        'user'
    );
    RETURN new;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Create trigger only if it doesn't exist
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM pg_trigger 
        WHERE tgname = 'on_auth_user_created'
    ) THEN
        CREATE TRIGGER on_auth_user_created
            AFTER INSERT ON auth.users
            FOR EACH ROW EXECUTE PROCEDURE public.handle_new_user();
    END IF;
END $$;

-- Create or replace function to update updated_at timestamp
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = now();
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Create updated_at triggers for all tables
DO $$
BEGIN
    -- For listings
    IF NOT EXISTS (SELECT 1 FROM pg_trigger WHERE tgname = 'update_listings_updated_at') THEN
        CREATE TRIGGER update_listings_updated_at 
            BEFORE UPDATE ON listings 
            FOR EACH ROW EXECUTE PROCEDURE update_updated_at_column();
    END IF;
    
    -- For bookings
    IF NOT EXISTS (SELECT 1 FROM pg_trigger WHERE tgname = 'update_bookings_updated_at') THEN
        CREATE TRIGGER update_bookings_updated_at 
            BEFORE UPDATE ON bookings 
            FOR EACH ROW EXECUTE PROCEDURE update_updated_at_column();
    END IF;
    
    -- For volunteer_applications
    IF NOT EXISTS (SELECT 1 FROM pg_trigger WHERE tgname = 'update_volunteer_applications_updated_at') THEN
        CREATE TRIGGER update_volunteer_applications_updated_at 
            BEFORE UPDATE ON volunteer_applications 
            FOR EACH ROW EXECUTE PROCEDURE update_updated_at_column();
    END IF;
    
    -- For custom_requests
    IF NOT EXISTS (SELECT 1 FROM pg_trigger WHERE tgname = 'update_custom_requests_updated_at') THEN
        CREATE TRIGGER update_custom_requests_updated_at 
            BEFORE UPDATE ON custom_requests 
            FOR EACH ROW EXECUTE PROCEDURE update_updated_at_column();
    END IF;
END $$;

-- Insert sample data only if tables are empty
DO $$
BEGIN
    -- Insert sample listings only if table is empty
    IF NOT EXISTS (SELECT 1 FROM listings LIMIT 1) THEN
        INSERT INTO listings (title, description, category, price, rating, location, type, image) VALUES
        -- Tours
        ('Serengeti Safari Adventure', 'Experience the great migration with our 5-day Serengeti safari. Witness millions of wildebeest and zebra crossing the plains in one of nature''s most spectacular events.', 'tour', 1200, 4.8, 'Serengeti, Tanzania', 'Safari', 'https://images.unsplash.com/photo-1516026672322-bc52d61a55d5?w=800'),
        ('Mount Kilimanjaro Trek', 'Conquer Africa''s highest peak with our guided 7-day Machame route trek. Professional guides, porters, and full support equipment included.', 'tour', 2500, 4.9, 'Kilimanjaro, Tanzania', 'Trekking', 'https://images.unsplash.com/photo-1609198092458-38a293c7ac4b?w=800'),
        ('Zanzibar Cultural Tour', 'Explore the spice island''s rich history, Stone Town architecture, and pristine beaches. Includes spice farm visit and dhow cruise.', 'tour', 800, 4.7, 'Zanzibar, Tanzania', 'Cultural', 'https://images.unsplash.com/photo-1544735716-392fe2489ffa?w=800'),
        
        -- Stays
        ('Safari Lodge Serengeti', 'Luxury tented camp overlooking the Serengeti plains. All-inclusive package with game drives, meals, and sundowner experiences.', 'stay', 450, 4.9, 'Serengeti, Tanzania', 'Lodge', 'https://images.unsplash.com/photo-1564501049412-61c2a3083791?w=800'),
        ('Zanzibar Beach Resort', 'Beachfront resort with private beach access, spa facilities, water sports, and traditional Swahili cuisine.', 'stay', 280, 4.6, 'Zanzibar, Tanzania', 'Resort', 'https://images.unsplash.com/photo-1520637836862-4d197d17c5a0?w=800'),
        ('Nairobi City Hotel', 'Modern hotel in the heart of Nairobi with easy access to national parks, city attractions, and business district.', 'stay', 120, 4.4, 'Nairobi, Kenya', 'Hotel', 'https://images.unsplash.com/photo-1566073771259-6a8506099945?w=800'),
        
        -- Volunteer Opportunities
        ('Wildlife Conservation Project', 'Help protect endangered species in Kenya''s national parks. Participate in research, monitoring, and conservation efforts.', 'volunteer', 0, 4.8, 'Maasai Mara, Kenya', 'Conservation', 'https://images.unsplash.com/photo-1547036967-23d11aacaee0?w=800'),
        ('Community Education Program', 'Teach English and basic skills to children in rural communities. Make a lasting impact on education and development.', 'volunteer', 0, 4.9, 'Arusha, Tanzania', 'Education', 'https://images.unsplash.com/photo-1488521787991-ed7bbaae773c?w=800'),
        ('Healthcare Support Initiative', 'Support local healthcare facilities and help provide medical care to underserved communities in rural areas.', 'volunteer', 0, 4.7, 'Kampala, Uganda', 'Healthcare', 'https://images.unsplash.com/photo-1576091160399-112ba8d25d1f?w=800');
    END IF;
END $$;
