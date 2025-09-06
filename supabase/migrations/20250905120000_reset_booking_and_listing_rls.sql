-- This script resets and correctly configures all necessary Row Level Security (RLS) policies
-- for the bookings and listings tables. It will fix both the "Failed to make a booking"
-- and "Failed to fetch bookings" errors.

-- Step 1: Enable Row Level Security on the tables if not already enabled.
-- This ensures that the policies we are about to create will be enforced.
ALTER TABLE public.bookings ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.listings ENABLE ROW LEVEL SECURITY;

-- Step 2: Drop existing policies to start with a clean slate.
-- This prevents conflicts with any old or incorrect policies.
DROP POLICY IF EXISTS "Users can view their own bookings" ON public.bookings;
DROP POLICY IF EXISTS "Users can insert their own bookings" ON public.bookings;
DROP POLICY IF EXISTS "Public can view published listings" ON public.listings;
DROP POLICY IF EXISTS "Admins can manage all listings" ON public.listings; -- Optional admin policy cleanup

-- Step 3: Create the correct policies for the booking system.

-- POLICY: Allow logged-in users to create their own bookings.
-- This is essential for the "Confirm Booking" button to work.
CREATE POLICY "Users can insert their own bookings"
ON public.bookings
FOR INSERT
TO authenticated
WITH CHECK (auth.uid() = user_id);

-- POLICY: Allow logged-in users to view ONLY their own bookings.
-- This is essential for the "My Bookings" dashboard page to work.
CREATE POLICY "Users can view their own bookings"
ON public.bookings
FOR SELECT
TO authenticated
USING (auth.uid() = user_id);

-- POLICY: Allow ANYONE (including logged-in users) to view published listings.
-- This is crucial because the "My Bookings" page needs to fetch details
-- about the listing associated with each booking. Without this, the query will fail.
CREATE POLICY "Public can view published listings"
ON public.listings
FOR SELECT
TO public
USING (status = 'published');
