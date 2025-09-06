-- Add new columns to the custom_requests table
ALTER TABLE public.custom_requests
ADD COLUMN IF NOT EXISTS full_name TEXT,
ADD COLUMN IF NOT EXISTS email TEXT,
ADD COLUMN IF NOT EXISTS phone TEXT,
ADD COLUMN IF NOT EXISTS whatsapp_number TEXT,
ADD COLUMN IF NOT EXISTS status TEXT DEFAULT 'Pending' NOT NULL;

-- Enable Row Level Security if not already enabled
ALTER TABLE public.custom_requests ENABLE ROW LEVEL SECURITY;

-- Drop existing policies to avoid conflicts
DROP POLICY IF EXISTS "Users can create their own custom requests" ON public.custom_requests;
DROP POLICY IF EXISTS "Users can view their own custom requests" ON public.custom_requests;
DROP POLICY IF EXISTS "Admins can manage all custom requests" ON public.custom_requests;

-- Create policies for custom_requests
CREATE POLICY "Users can create their own custom requests"
ON public.custom_requests
FOR INSERT
TO authenticated
WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can view their own custom requests"
ON public.custom_requests
FOR SELECT
TO authenticated
USING (auth.uid() = user_id);

CREATE POLICY "Admins can manage all custom requests"
ON public.custom_requests
FOR ALL
TO service_role
USING (true);
