/*
# [Booking Permissions Reset]
This script resets and correctly configures the Row Level Security (RLS) policies for the "bookings" table. It ensures that authenticated users can create and manage their own bookings, which is essential for the booking system to function correctly.

## Query Description:
This operation will first remove any existing security policies on the `bookings` table to avoid conflicts and then create new, correct policies. This is a safe operation for user data but is critical for application functionality.

## Metadata:
- Schema-Category: "Security"
- Impact-Level: "Medium"
- Requires-Backup: false
- Reversible: true (by dropping the created policies)

## Structure Details:
- Affects table: `public.bookings`
- Operations: `DROP POLICY`, `CREATE POLICY`

## Security Implications:
- RLS Status: Enforces Row Level Security on the `bookings`table.
- Policy Changes: Yes. It creates policies for INSERT, SELECT, UPDATE, and DELETE actions, scoped to the authenticated user.
- Auth Requirements: These policies rely on `auth.uid()` to identify the current user.

## Performance Impact:
- Indexes: No change.
- Triggers: No change.
- Estimated Impact: Low. RLS policies add a minor overhead to queries, but it's necessary for security.
*/

DO $$
BEGIN
  -- Enable Row Level Security on the bookings table if it's not already enabled.
  IF NOT EXISTS (SELECT 1 FROM pg_tables WHERE schemaname = 'public' AND tablename = 'bookings' AND rowsecurity = 't') THEN
    ALTER TABLE public.bookings ENABLE ROW LEVEL SECURITY;
    RAISE NOTICE 'Row Level Security enabled on "bookings" table.';
  END IF;

  -- Drop existing policies to ensure a clean slate
  DROP POLICY IF EXISTS "Authenticated users can create their own bookings" ON public.bookings;
  DROP POLICY IF EXISTS "Users can view their own bookings" ON public.bookings;
  DROP POLICY IF EXISTS "Users can update their own bookings" ON public.bookings;
  DROP POLICY IF EXISTS "Users can delete their own bookings" ON public.bookings;
  RAISE NOTICE 'Dropped existing booking policies if they existed.';

  -- Create new, correct policies
  -- 1. Policy: Authenticated users can create their own bookings.
  CREATE POLICY "Authenticated users can create their own bookings"
  ON public.bookings
  FOR INSERT
  TO authenticated
  WITH CHECK (auth.uid() = user_id);

  -- 2. Policy: Users can view their own bookings.
  CREATE POLICY "Users can view their own bookings"
  ON public.bookings
  FOR SELECT
  TO authenticated
  USING (auth.uid() = user_id);

  -- 3. Policy: Users can update their own bookings (e.g., for cancellation).
  CREATE POLICY "Users can update their own bookings"
  ON public.bookings
  FOR UPDATE
  TO authenticated
  USING (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);

  -- 4. Policy: Users can delete their own bookings (for cancellation).
  CREATE POLICY "Users can delete their own bookings"
  ON public.bookings
  FOR DELETE
  TO authenticated
  USING (auth.uid() = user_id);

  RAISE NOTICE 'Successfully created new RLS policies for the "bookings" table.';

END $$;
