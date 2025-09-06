DO $$
BEGIN
  -- Enable Row Level Security on the bookings table if it's not already enabled.
  -- This is the master switch for all security policies on this table.
  ALTER TABLE public.bookings ENABLE ROW LEVEL SECURITY;
  RAISE NOTICE 'Row Level Security enabled on "bookings" table.';

  -- Policy: Allow authenticated users to INSERT a booking for themselves.
  -- This is the rule that fixes the "Failed to make a booking" error.
  -- It checks that the user_id in the new booking matches the ID of the person making the request.
  DROP POLICY IF EXISTS "Users can create their own bookings" ON public.bookings;
  CREATE POLICY "Users can create their own bookings"
    ON public.bookings
    FOR INSERT
    TO authenticated
    WITH CHECK (auth.uid() = user_id);
  RAISE NOTICE 'Policy created: Users can create their own bookings.';

  -- Policy: Allow users to SELECT (view) only their own bookings.
  -- This rule ensures that a user can only see their own bookings on the "My Bookings" page.
  DROP POLICY IF EXISTS "Users can view their own bookings" ON public.bookings;
  CREATE POLICY "Users can view their own bookings"
    ON public.bookings
    FOR SELECT
    TO authenticated
    USING (auth.uid() = user_id);
  RAISE NOTICE 'Policy created: Users can view their own bookings.';

  -- Policy: Allow admin roles to bypass RLS for all operations.
  -- This is a standard best practice to ensure your admin dashboard continues to work correctly.
  DROP POLICY IF EXISTS "Admins can manage all bookings" ON public.bookings;
  CREATE POLICY "Admins can manage all bookings"
    ON public.bookings
    FOR ALL
    TO service_role
    USING (true);
  RAISE NOTICE 'Policy created: Admins can manage all bookings.';

EXCEPTION
  WHEN OTHERS THEN
    RAISE EXCEPTION 'An error occurred during the permission setup: %', SQLERRM;
END;
$$;
