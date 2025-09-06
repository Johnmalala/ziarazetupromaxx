/*
  # Add RLS Policies for Bookings

  This migration enables Row Level Security (RLS) on the `bookings` table and adds the necessary policies for users to create and view their own bookings. This is a critical security and functionality fix.

  ## Query Description:
  This operation is safe and non-destructive. It adds security rules to your database. It does not modify or delete any existing data. It ensures that users can only interact with their own booking data, enhancing privacy and security.

  ## Metadata:
  - Schema-Category: "Security"
  - Impact-Level: "Low"
  - Requires-Backup: false
  - Reversible: true (policies can be dropped)

  ## Structure Details:
  - Table Affected: `public.bookings`
  - Policies Added:
    - "Users can create their own bookings." (INSERT)
    - "Users can view their own bookings." (SELECT)

  ## Security Implications:
  - RLS Status: Enabled
  - Policy Changes: Yes, adds INSERT and SELECT policies for authenticated users.
  - Auth Requirements: Users must be authenticated to create or view bookings.

  ## Performance Impact:
  - Indexes: None
  - Triggers: None
  - Estimated Impact: Negligible. RLS checks are highly optimized in PostgreSQL.
*/

-- Enable Row Level Security on the bookings table if it's not already enabled.
ALTER TABLE public.bookings ENABLE ROW LEVEL SECURITY;

-- Drop existing policies if they exist, to ensure a clean slate.
DROP POLICY IF EXISTS "Users can create their own bookings." ON public.bookings;
DROP POLICY IF EXISTS "Users can view their own bookings." ON public.bookings;

-- Policy: Allow authenticated users to create a booking for themselves.
-- The `user_id` of the new booking must match the ID of the currently logged-in user.
CREATE POLICY "Users can create their own bookings."
ON public.bookings
FOR INSERT
TO authenticated
WITH CHECK (auth.uid() = user_id);

-- Policy: Allow authenticated users to view their own bookings.
-- A user can only select rows where their user ID matches the `user_id` in the table.
CREATE POLICY "Users can view their own bookings."
ON public.bookings
FOR SELECT
TO authenticated
USING (auth.uid() = user_id);
