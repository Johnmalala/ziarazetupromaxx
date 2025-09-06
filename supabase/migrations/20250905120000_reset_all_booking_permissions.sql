-- This script resets and correctly configures all necessary RLS policies for the booking system.
-- It ensures that users can create and view their own bookings, and admins have full access.

-- Step 1: Enable Row Level Security on the necessary tables.
-- This is a safe operation; it does nothing if RLS is already enabled.
ALTER TABLE public.bookings ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.listings ENABLE ROW LEVEL SECURITY;

-- Step 2: Drop all existing policies on the bookings table to ensure a clean slate.
-- This prevents conflicts with old or incorrect policies.
DROP POLICY IF EXISTS "Users can view their own bookings" ON public.bookings;
DROP POLICY IF EXISTS "Users can insert their own bookings" ON public.bookings;
DROP POLICY IF EXISTS "Admins can view all bookings" ON public.bookings;
DROP POLICY IF EXISTS "Admins can update bookings" ON public.bookings;
DROP POLICY IF EXISTS "Public can view published listings" ON public.listings;
DROP POLICY IF EXISTS "Users can view their own profile" ON public.profiles;

-- Step 3: Create the correct policies for regular users, as specified.
-- Allows users to insert bookings for themselves.
CREATE POLICY "Users can insert their own bookings"
ON public.bookings FOR INSERT
TO authenticated
WITH CHECK (auth.uid() = user_id);

-- Allows users to view only their own bookings.
CREATE POLICY "Users can view their own bookings"
ON public.bookings FOR SELECT
TO authenticated
USING (auth.uid() = user_id);

-- Step 4: Create the correct policies for admins, as specified.
-- Allows users with the 'admin' role to view all bookings.
CREATE POLICY "Admins can view all bookings"
ON public.bookings FOR SELECT
TO authenticated
USING (
  (SELECT role FROM public.profiles WHERE id = auth.uid()) = 'admin'
);

-- Allows users with the 'admin' role to update any booking (e.g., to mark as 'paid').
CREATE POLICY "Admins can update bookings"
ON public.bookings FOR UPDATE
TO authenticated
USING (
  (SELECT role FROM public.profiles WHERE id = auth.uid()) = 'admin'
);

-- Step 5: Ensure supporting tables have correct select policies.
-- This is crucial. To view bookings, users also need to be able to read the listing details.
CREATE POLICY "Public can view published listings"
ON public.listings FOR SELECT
TO anon, authenticated
USING (status = 'published');

-- Users should be able to view their own profile.
CREATE POLICY "Users can view their own profile"
ON public.profiles FOR SELECT
TO authenticated
USING (auth.uid() = id);

-- Step 6: Backfill profiles for any existing users who might be missing one.
-- This prevents "foreign key constraint" errors for users created before the trigger was in place.
INSERT INTO public.profiles (id, full_name, email, role)
SELECT id, raw_user_meta_data->>'full_name', email, 'user'
FROM auth.users
ON CONFLICT (id) DO NOTHING;
