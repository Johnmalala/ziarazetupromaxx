DO $$
BEGIN
  -- Enable Row Level Security on the bookings table if it's not already enabled.
  IF NOT EXISTS (SELECT 1 FROM pg_tables WHERE schemaname = 'public' AND tablename = 'bookings' AND rowsecurity = 't') THEN
    ALTER TABLE public.bookings ENABLE ROW LEVEL SECURITY;
    RAISE NOTICE 'Row Level Security enabled on "bookings" table.';
  END IF;

  -- Drop any existing policies for the authenticated role to ensure a clean slate.
  DROP POLICY IF EXISTS "Authenticated users can create their own bookings" ON public.bookings;
  DROP POLICY IF EXISTS "Users can view their own bookings" ON public.bookings;

  -- Create a policy to allow authenticated users to INSERT new bookings for themselves.
  -- The `WITH CHECK` clause ensures that the `user_id` of the new booking MUST match the ID of the person creating it.
  CREATE POLICY "Authenticated users can create their own bookings"
  ON public.bookings
  FOR INSERT
  TO authenticated
  WITH CHECK (auth.uid() = user_id);

  RAISE NOTICE 'INSERT policy for bookings created successfully.';

  -- Create a policy to allow authenticated users to SELECT (view) only their own bookings.
  -- The `USING` clause filters the rows so that only bookings where the `user_id` matches the current user's ID are visible.
  CREATE POLICY "Users can view their own bookings"
  ON public.bookings
  FOR SELECT
  TO authenticated
  USING (auth.uid() = user_id);

  RAISE NOTICE 'SELECT policy for bookings created successfully.';

END $$;
