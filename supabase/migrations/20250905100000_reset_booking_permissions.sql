/*
# [Booking Permissions Reset]
This script resets and correctly configures the security policies for the "bookings" table.
It ensures that logged-in users can create and view their own bookings, which is essential for the booking system to function correctly.

## Query Description:
This operation is safe and non-destructive. It will:
1. Enable Row Level Security (RLS) on the `bookings` table.
2. Drop any existing, potentially incorrect policies for inserting or viewing bookings to avoid conflicts.
3. Create a new, correct policy that allows users to create bookings for themselves.
4. Create a new, correct policy that allows users to view only their own bookings.

This is the definitive fix for the "Failed to make a booking" error.

## Metadata:
- Schema-Category: "Security"
- Impact-Level: "Low"
- Requires-Backup: false
- Reversible: true (by dropping the created policies)

## Security Implications:
- RLS Status: Enabled
- Policy Changes: Yes (resets policies for user bookings)
- Auth Requirements: Users must be authenticated to perform these actions.
*/

DO $$
BEGIN
  -- Enable Row Level Security on the bookings table if not already enabled
  IF NOT EXISTS (SELECT 1 FROM pg_tables WHERE schemaname = 'public' AND tablename = 'bookings' AND rowsecurity = 't') THEN
    ALTER TABLE public.bookings ENABLE ROW LEVEL SECURITY;
    RAISE NOTICE 'Row Level Security enabled on "bookings" table.';
  END IF;

  -- Drop existing policies to ensure a clean slate
  DROP POLICY IF EXISTS "Allow authenticated users to create their own bookings" ON public.bookings;
  DROP POLICY IF EXISTS "Allow users to view their own bookings" ON public.bookings;

  -- Allow authenticated users to create a booking for themselves
  CREATE POLICY "Allow authenticated users to create their own bookings"
  ON public.bookings
  FOR INSERT
  TO authenticated
  WITH CHECK (auth.uid() = user_id);

  RAISE NOTICE 'INSERT policy for user bookings created successfully.';

  -- Allow users to view their own bookings
  CREATE POLICY "Allow users to view their own bookings"
  ON public.bookings
  FOR SELECT
  TO authenticated
  USING (auth.uid() = user_id);

  RAISE NOTICE 'SELECT policy for user bookings created successfully.';

END $$;
