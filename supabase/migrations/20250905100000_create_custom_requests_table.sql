DO $$
BEGIN

-- Create the custom_requests table if it doesn't exist
IF NOT EXISTS (SELECT FROM pg_tables WHERE schemaname = 'public' AND tablename  = 'custom_requests') THEN
    CREATE TABLE public.custom_requests (
        id uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
        user_id uuid REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
        full_name text,
        email text,
        phone text,
        whatsapp_number text,
        trip_details text NOT NULL,
        budget numeric,
        status text DEFAULT 'Pending' NOT NULL,
        created_at timestamp with time zone DEFAULT now() NOT NULL
    );
    RAISE NOTICE 'Table "custom_requests" created.';
END IF;

-- Enable Row Level Security
ALTER TABLE public.custom_requests ENABLE ROW LEVEL SECURITY;
RAISE NOTICE 'Row Level Security enabled on "custom_requests" table.';

-- Policies for custom_requests
-- 1. Users can insert their own requests
DROP POLICY IF EXISTS "Users can create their own custom requests" ON public.custom_requests;
CREATE POLICY "Users can create their own custom requests"
ON public.custom_requests FOR INSERT
TO authenticated
WITH CHECK (auth.uid() = user_id);
RAISE NOTICE 'Policy "Users can create their own custom requests" created.';

-- 2. Users can view their own requests
DROP POLICY IF EXISTS "Users can view their own custom requests" ON public.custom_requests;
CREATE POLICY "Users can view their own custom requests"
ON public.custom_requests FOR SELECT
TO authenticated
USING (auth.uid() = user_id);
RAISE NOTICE 'Policy "Users can view their own custom requests" created.';

-- 3. Admins can manage all requests (for your separate admin dashboard)
DROP POLICY IF EXISTS "Admins can manage all custom requests" ON public.custom_requests;
CREATE POLICY "Admins can manage all custom requests"
ON public.custom_requests FOR ALL
TO authenticated
USING (
  (SELECT role FROM public.profiles WHERE id = auth.uid()) = 'admin'
)
WITH CHECK (
  (SELECT role FROM public.profiles WHERE id = auth.uid()) = 'admin'
);
RAISE NOTICE 'Policy "Admins can manage all custom requests" created.';

END $$;
