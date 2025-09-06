/*
# [Operation] Backfill User Profiles & Reset Booking RLS
This script ensures that every user in the 'auth.users' table has a corresponding entry in the 'public.profiles' table. It also resets and correctly configures the Row Level Security (RLS) policies for the 'bookings' table to ensure logged-in users can create and view their own bookings.

## Query Description:
This operation is designed to fix data consistency issues for existing users who may have signed up before profile creation was automated. It is safe to run multiple times. It will not affect existing profiles or bookings but will create missing profiles and reset security policies to a known good state. This is crucial for fixing booking failures related to foreign key violations.

## Metadata:
- Schema-Category: ["Data", "Structural"]
- Impact-Level: ["Medium"]
- Requires-Backup: false
- Reversible: false

## Structure Details:
- Affects `public.profiles` by inserting missing rows.
- Affects `public.bookings` by dropping and recreating RLS policies.

## Security Implications:
- RLS Status: Enabled
- Policy Changes: Yes
- Auth Requirements: This script ensures that authenticated users have the correct permissions to interact with the bookings table.

## Performance Impact:
- Indexes: None
- Triggers: None
- Estimated Impact: Low. The query to find missing profiles is efficient.
*/

-- Step 1: Backfill profiles for any existing users who are missing one.
-- This is safe to run multiple times.
INSERT INTO public.profiles (id, email, full_name, role)
SELECT
    u.id,
    u.email,
    u.raw_user_meta_data->>'full_name' AS full_name,
    'user'
FROM
    auth.users u
WHERE
    NOT EXISTS (
        SELECT 1
        FROM public.profiles p
        WHERE p.id = u.id
    );

-- Step 2: Reset and correctly configure RLS policies for the bookings table.
-- This ensures that previous, potentially incorrect policies are removed.

-- Enable RLS on the table if it's not already enabled.
ALTER TABLE public.bookings ENABLE ROW LEVEL SECURITY;

-- Drop existing policies to ensure a clean slate.
DROP POLICY IF EXISTS "Users can view their own bookings" ON public.bookings;
DROP POLICY IF EXISTS "Users can create their own bookings" ON public.bookings;

-- Create the correct SELECT policy.
CREATE POLICY "Users can view their own bookings"
ON public.bookings
FOR SELECT
USING (auth.uid() = user_id);

-- Create the correct INSERT policy.
CREATE POLICY "Users can create their own bookings"
ON public.bookings
FOR INSERT
WITH CHECK (auth.uid() = user_id);
