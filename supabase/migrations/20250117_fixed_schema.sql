/*
# Fixed Ziarazetu Database Schema Migration

This migration creates the complete database schema for Ziarazetu with proper data type consistency.
All primary keys and foreign keys use UUID type for compatibility.

## Query Description:
Creates tables for user profiles, listings, bookings, volunteer applications, custom requests, and payment installments with proper relationships and security policies. Fixes data type mismatches and ensures all foreign key constraints work correctly.

## Metadata:
- Schema-Category: "Safe"
- Impact-Level: "Medium"
- Requires-Backup: false
- Reversible: true

## Structure Details:
- profiles: User profile data linked to auth.users
- listings: Tours, stays, and volunteer opportunities
- bookings: Reservation and payment tracking
- volunteer_applications: Volunteer program applications
- custom_requests: Custom trip planning requests
- payment_installments: Installment payment tracking

## Security Implications:
- RLS Status: Enabled
- Policy Changes: Yes
- Auth Requirements: Row-level security policies for user data isolation

## Performance Impact:
- Indexes: Added on frequently queried columns
- Triggers: Auto-timestamp updates and profile creation
- Estimated Impact: Minimal - optimized for query performance
*/

-- Enable UUID extension if not already enabled
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Create profiles table with proper role column if it doesn't exist
DO $$ 
BEGIN
    IF NOT EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'profiles') THEN
        CREATE TABLE profiles (
            id uuid REFERENCES auth.users ON DELETE CASCADE PRIMARY KEY,
            full_name text,
            email text,
            role text DEFAULT 'user' CHECK (role IN ('user', 'admin')),
            created_at timestamp with time zone DEFAULT timezone('utc'::text, now()) NOT NULL,
            updated_at timestamp with time zone DEFAULT timezone('utc'::text, now()) NOT NULL
        );
    END IF;
    
    -- Add role column if it doesn't exist
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'profiles' AND column_name = 'role') THEN
        ALTER TABLE profiles ADD COLUMN role text DEFAULT 'user' CHECK (role IN ('user', 'admin'));
    END IF;
    
    -- Add updated_at column if it doesn't exist
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'profiles' AND column_name = 'updated_at') THEN
        ALTER TABLE profiles ADD COLUMN updated_at timestamp with time zone DEFAULT timezone('utc'::text, now()) NOT NULL;
    END IF;
END $$;

-- Create listings table
CREATE TABLE IF NOT EXISTS listings (
    id uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
    title text NOT NULL,
    description text,
    category text NOT NULL CHECK (category IN ('tour', 'stay', 'volunteer')),
    price numeric DEFAULT 0,
    rating numeric DEFAULT 0 CHECK (rating >= 0 AND rating <= 5),
    location text,
    type text,
    availability jsonb DEFAULT '{}',
    image text,
    features text[] DEFAULT '{}',
    amenities text[] DEFAULT '{}',
    itinerary jsonb DEFAULT '{}',
    host_info jsonb DEFAULT '{}',
    created_at timestamp with time zone DEFAULT timezone('utc'::text, now()) NOT NULL,
    updated_at timestamp with time zone DEFAULT timezone('utc'::text, now()) NOT NULL
);

-- Create bookings table with UUID primary key
CREATE TABLE IF NOT EXISTS bookings (
    id uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
    listing_id uuid REFERENCES listings(id) ON DELETE CASCADE,
    user_id uuid REFERENCES profiles(id) ON DELETE CASCADE,
    total_amount numeric NOT NULL,
    deposit_amount numeric DEFAULT 0,
    payment_status text DEFAULT 'pending' CHECK (payment_status IN ('pending', 'paid', 'partial', 'cancelled')),
    payment_plan text DEFAULT 'full' CHECK (payment_plan IN ('full', 'deposit', 'lipa_mdogo_mdogo')),
    booking_date date,
    check_in date,
    check_out date,
    guests integer DEFAULT 1,
    special_requests text,
    paystack_reference text,
    created_at timestamp with time zone DEFAULT timezone('utc'::text, now()) NOT NULL,
    updated_at timestamp with time zone DEFAULT timezone('utc'::text, now()) NOT NULL
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
    emergency_contact jsonb DEFAULT '{}',
    status text DEFAULT 'pending' CHECK (status IN ('pending', 'approved', 'rejected')),
    created_at timestamp with time zone DEFAULT timezone('utc'::text, now()) NOT NULL,
    updated_at timestamp with time zone DEFAULT timezone('utc'::text, now()) NOT NULL
);

-- Create custom requests table
CREATE TABLE IF NOT EXISTS custom_requests (
    id uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id uuid REFERENCES profiles(id) ON DELETE CASCADE,
    trip_details text NOT NULL,
    budget numeric,
    travel_dates text,
    group_size integer DEFAULT 1,
    special_requirements text,
    contact_preference text DEFAULT 'email',
    status text DEFAULT 'pending' CHECK (status IN ('pending', 'in_progress', 'completed', 'cancelled')),
    admin_notes text,
    created_at timestamp with time zone DEFAULT timezone('utc'::text, now()) NOT NULL,
    updated_at timestamp with time zone DEFAULT timezone('utc'::text, now()) NOT NULL
);

-- Create payment installments table with proper UUID foreign key
CREATE TABLE IF NOT EXISTS payment_installments (
    id uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
    booking_id uuid REFERENCES bookings(id) ON DELETE CASCADE,
    installment_number integer NOT NULL,
    amount numeric NOT NULL,
    due_date date NOT NULL,
    paid_date date,
    status text DEFAULT 'pending' CHECK (status IN ('pending', 'paid', 'overdue', 'cancelled')),
    paystack_reference text,
    created_at timestamp with time zone DEFAULT timezone('utc'::text, now()) NOT NULL,
    updated_at timestamp with time zone DEFAULT timezone('utc'::text, now()) NOT NULL
);

-- Enable Row Level Security
ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE listings ENABLE ROW LEVEL SECURITY;
ALTER TABLE bookings ENABLE ROW LEVEL SECURITY;
ALTER TABLE volunteer_applications ENABLE ROW LEVEL SECURITY;
ALTER TABLE custom_requests ENABLE ROW LEVEL SECURITY;
ALTER TABLE payment_installments ENABLE ROW LEVEL SECURITY;

-- Create RLS policies for profiles
CREATE POLICY IF NOT EXISTS "Users can view own profile" ON profiles
    FOR SELECT USING (auth.uid() = id);

CREATE POLICY IF NOT EXISTS "Users can update own profile" ON profiles
    FOR UPDATE USING (auth.uid() = id);

-- Create RLS policies for listings (public read, admin write)
CREATE POLICY IF NOT EXISTS "Anyone can view listings" ON listings
    FOR SELECT USING (true);

CREATE POLICY IF NOT EXISTS "Admins can manage listings" ON listings
    FOR ALL USING (
        auth.uid() IN (
            SELECT id FROM profiles WHERE role = 'admin'
        )
    );

-- Create RLS policies for bookings
CREATE POLICY IF NOT EXISTS "Users can view own bookings" ON bookings
    FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY IF NOT EXISTS "Users can create own bookings" ON bookings
    FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY IF NOT EXISTS "Users can update own bookings" ON bookings
    FOR UPDATE USING (auth.uid() = user_id);

CREATE POLICY IF NOT EXISTS "Admins can view all bookings" ON bookings
    FOR SELECT USING (
        auth.uid() IN (
            SELECT id FROM profiles WHERE role = 'admin'
        )
    );

-- Create RLS policies for volunteer applications
CREATE POLICY IF NOT EXISTS "Users can view own applications" ON volunteer_applications
    FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY IF NOT EXISTS "Users can create applications" ON volunteer_applications
    FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY IF NOT EXISTS "Admins can manage applications" ON volunteer_applications
    FOR ALL USING (
        auth.uid() IN (
            SELECT id FROM profiles WHERE role = 'admin'
        )
    );

-- Create RLS policies for custom requests
CREATE POLICY IF NOT EXISTS "Users can view own requests" ON custom_requests
    FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY IF NOT EXISTS "Users can create requests" ON custom_requests
    FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY IF NOT EXISTS "Users can update own requests" ON custom_requests
    FOR UPDATE USING (auth.uid() = user_id);

CREATE POLICY IF NOT EXISTS "Admins can manage requests" ON custom_requests
    FOR ALL USING (
        auth.uid() IN (
            SELECT id FROM profiles WHERE role = 'admin'
        )
    );

-- Create RLS policies for payment installments
CREATE POLICY IF NOT EXISTS "Users can view own installments" ON payment_installments
    FOR SELECT USING (
        auth.uid() IN (
            SELECT user_id FROM bookings WHERE id = booking_id
        )
    );

CREATE POLICY IF NOT EXISTS "Admins can manage installments" ON payment_installments
    FOR ALL USING (
        auth.uid() IN (
            SELECT id FROM profiles WHERE role = 'admin'
        )
    );

-- Create indexes for better performance
CREATE INDEX IF NOT EXISTS idx_listings_category ON listings(category);
CREATE INDEX IF NOT EXISTS idx_listings_location ON listings(location);
CREATE INDEX IF NOT EXISTS idx_listings_price ON listings(price);
CREATE INDEX IF NOT EXISTS idx_bookings_user_id ON bookings(user_id);
CREATE INDEX IF NOT EXISTS idx_bookings_listing_id ON bookings(listing_id);
CREATE INDEX IF NOT EXISTS idx_bookings_status ON bookings(payment_status);
CREATE INDEX IF NOT EXISTS idx_volunteer_applications_user_id ON volunteer_applications(user_id);
CREATE INDEX IF NOT EXISTS idx_volunteer_applications_opportunity_id ON volunteer_applications(opportunity_id);
CREATE INDEX IF NOT EXISTS idx_custom_requests_user_id ON custom_requests(user_id);
CREATE INDEX IF NOT EXISTS idx_payment_installments_booking_id ON payment_installments(booking_id);

-- Create trigger function for updating timestamps
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = timezone('utc'::text, now());
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Create triggers for updating timestamps
CREATE TRIGGER IF NOT EXISTS update_profiles_updated_at 
    BEFORE UPDATE ON profiles 
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER IF NOT EXISTS update_listings_updated_at 
    BEFORE UPDATE ON listings 
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER IF NOT EXISTS update_bookings_updated_at 
    BEFORE UPDATE ON bookings 
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER IF NOT EXISTS update_volunteer_applications_updated_at 
    BEFORE UPDATE ON volunteer_applications 
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER IF NOT EXISTS update_custom_requests_updated_at 
    BEFORE UPDATE ON custom_requests 
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER IF NOT EXISTS update_payment_installments_updated_at 
    BEFORE UPDATE ON payment_installments 
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- Create function to handle profile creation
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO public.profiles (id, full_name, email)
    VALUES (NEW.id, NEW.raw_user_meta_data->>'full_name', NEW.email);
    RETURN NEW;
END;
$$ language 'plpgsql' SECURITY DEFINER;

-- Create trigger for automatic profile creation
CREATE TRIGGER IF NOT EXISTS on_auth_user_created
    AFTER INSERT ON auth.users
    FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();

-- Insert sample listings only if the table is empty
INSERT INTO listings (title, description, category, price, rating, location, type, image)
SELECT * FROM (VALUES
    ('Serengeti Safari Adventure', 'Experience the great migration with our 5-day Serengeti safari. Witness millions of wildebeest and zebra crossing the plains in one of nature''s most spectacular events.', 'tour', 1200, 4.8, 'Serengeti, Tanzania', 'Safari', 'https://images.unsplash.com/photo-1516026672322-bc52d61a55d5?w=800'),
    ('Mount Kilimanjaro Trek', 'Conquer Africa''s highest peak with our guided 7-day Machame route trek. Professional guides and full support included for this once-in-a-lifetime adventure.', 'tour', 2500, 4.9, 'Kilimanjaro, Tanzania', 'Trekking', 'https://images.unsplash.com/photo-1609198092458-38a293c7ac4b?w=800'),
    ('Zanzibar Cultural Tour', 'Explore the spice island''s rich history, stone town architecture, and pristine beaches. Immerse yourself in local culture and traditions.', 'tour', 800, 4.7, 'Zanzibar, Tanzania', 'Cultural', 'https://images.unsplash.com/photo-1544735716-392fe2489ffa?w=800'),
    ('Safari Lodge Serengeti', 'Luxury tented camp overlooking the Serengeti plains. All-inclusive package with game drives, meals, and premium accommodation.', 'stay', 450, 4.9, 'Serengeti, Tanzania', 'Lodge', 'https://images.unsplash.com/photo-1564501049412-61c2a3083791?w=800'),
    ('Zanzibar Beach Resort', 'Beachfront resort with private beach access, spa facilities, and comprehensive water sports activities for the perfect tropical getaway.', 'stay', 280, 4.6, 'Zanzibar, Tanzania', 'Resort', 'https://images.unsplash.com/photo-1520637836862-4d197d17c5a0?w=800'),
    ('Nairobi City Hotel', 'Modern hotel in the heart of Nairobi with easy access to national parks and city attractions. Perfect base for exploring Kenya.', 'stay', 120, 4.4, 'Nairobi, Kenya', 'Hotel', 'https://images.unsplash.com/photo-1566073771259-6a8506099945?w=800'),
    ('Wildlife Conservation Project', 'Help protect endangered species in Kenya''s national parks. Participate in research, monitoring, and conservation efforts.', 'volunteer', 0, 4.8, 'Maasai Mara, Kenya', 'Conservation', 'https://images.unsplash.com/photo-1547036967-23d11aacaee0?w=800'),
    ('Community Education Program', 'Teach English and basic skills to children in rural communities. Make a lasting impact on young lives and local education.', 'volunteer', 0, 4.9, 'Arusha, Tanzania', 'Education', 'https://images.unsplash.com/photo-1488521787991-ed7bbaae773c?w=800'),
    ('Healthcare Support Initiative', 'Support local healthcare facilities and help provide medical care to underserved communities across East Africa.', 'volunteer', 0, 4.7, 'Kampala, Uganda', 'Healthcare', 'https://images.unsplash.com/photo-1576091160399-112ba8d25d1f?w=800')
) AS v(title, description, category, price, rating, location, type, image)
WHERE NOT EXISTS (SELECT 1 FROM listings LIMIT 1);
