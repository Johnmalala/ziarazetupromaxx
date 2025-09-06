/*
  # [Booking Permissions Reset]
  This script resets and correctly applies the necessary Row Level Security (RLS) policies for the 'bookings' table. It ensures that authenticated users can create and view their own bookings, which is essential for the booking system to function correctly.

  ## Query Description:
  This operation is safe and non-destructive. It will first remove any existing booking-related policies to avoid conflicts and then create the correct ones. It ensures that the security rules are in the right state for the application to work, without affecting any existing booking data.

  ## Metadata:
  - Schema-Category: "Security"
  - Impact-Level: "Low"
  - Requires-Backup: false
  - Reversible: true (by dropping the created policies)

  ## Structure Details:
  - Affects table: public.bookings
  - Creates/Replaces policies:
    - "Users can create their own bookings" (INSERT)
    - "Users can view their own bookings" (SELECT)

  ## Security Implications:
  - RLS Status: Enables RLS on the bookings table.
  - Policy Changes: Yes, resets policies to allow users to manage their own bookings.
  - Auth Requirements: Requires users to be authenticated (logged in) to perform these actions.

  ## Performance Impact:
  - Indexes: None
  - Triggers: None
  - Estimated Impact: Negligible. RLS checks are highly optimized in PostgreSQL.
*/

DO $$
BEGIN
  -- Enable Row Level Security on the bookings table if it's not already enabled.
  ALTER TABLE public.bookings ENABLE ROW LEVEL SECURITY;
  RAISE NOTICE 'Row Level Security enabled on "bookings" table.';

  -- Drop existing policies to ensure a clean slate
  DROP POLICY IF EXISTS "Users can create their own bookings" ON public.bookings;
  DROP POLICY IF EXISTS "Users can view their own bookings" ON public.bookings;
  RAISE NOTICE 'Dropped existing booking policies if they existed.';

  -- Create policy to allow users to INSERT their own bookings
  CREATE POLICY "Users can create their own bookings"
  ON public.bookings
  FOR INSERT
  TO authenticated
  WITH CHECK (auth.uid() = user_id);
  RAISE NOTICE 'Created INSERT policy for bookings.';

  -- Create policy to allow users to SELECT their own bookings
  CREATE POLICY "Users can view their own bookings"
  ON public.bookings
  FOR SELECT
  TO authenticated
  USING (auth.uid() = user_id);
  RAISE NOTICE 'Created SELECT policy for bookings.';

  RAISE NOTICE 'Booking permissions have been successfully reset.';
END $$;
