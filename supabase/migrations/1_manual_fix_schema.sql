DO $$
BEGIN
    -- Add 'status' column if it doesn't exist
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='listings' AND column_name='status') THEN
        ALTER TABLE public.listings ADD COLUMN status TEXT DEFAULT 'draft';
        RAISE NOTICE 'Column "status" added to "listings" table.';
    END IF;

    -- Add 'rating' column if it doesn't exist
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='listings' AND column_name='rating') THEN
        ALTER TABLE public.listings ADD COLUMN rating NUMERIC(2,1) DEFAULT 0.0;
        RAISE NOTICE 'Column "rating" added to "listings" table.';
    END IF;
    
    -- Add 'location' column if it doesn't exist
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='listings' AND column_name='location') THEN
        ALTER TABLE public.listings ADD COLUMN location TEXT;
        RAISE NOTICE 'Column "location" added to "listings" table.';
    END IF;

    -- Add 'type' column if it doesn't exist
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='listings' AND column_name='type') THEN
        ALTER TABLE public.listings ADD COLUMN type TEXT;
        RAISE NOTICE 'Column "type" added to "listings" table.';
    END IF;

    -- Add 'images' column if it doesn't exist (as text array)
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='listings' AND column_name='images') THEN
        ALTER TABLE public.listings ADD COLUMN images TEXT[];
        RAISE NOTICE 'Column "images" added to "listings" table.';
    END IF;
    
    -- Add 'features' column if it doesn't exist
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='listings' AND column_name='features') THEN
        ALTER TABLE public.listings ADD COLUMN features JSONB;
        RAISE NOTICE 'Column "features" added to "listings" table.';
    END IF;

    -- Add 'amenities' column if it doesn't exist
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='listings' AND column_name='amenities') THEN
        ALTER TABLE public.listings ADD COLUMN amenities JSONB;
        RAISE NOTICE 'Column "amenities" added to "listings" table.';
    END IF;

    -- Add 'itinerary' column if it doesn't exist
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='listings' AND column_name='itinerary') THEN
        ALTER TABLE public.listings ADD COLUMN itinerary JSONB;
        RAISE NOTICE 'Column "itinerary" added to "listings" table.';
    END IF;

    -- Add 'availability' column if it doesn't exist
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='listings' AND column_name='availability') THEN
        ALTER TABLE public.listings ADD COLUMN availability JSONB;
        RAISE NOTICE 'Column "availability" added to "listings" table.';
    END IF;

    -- Enable Row Level Security on the table
    ALTER TABLE public.listings ENABLE ROW LEVEL SECURITY;
    RAISE NOTICE 'Row Level Security enabled on "listings" table.';

    -- Drop the old policy if it exists, then create the new one
    DROP POLICY IF EXISTS "Public can view published listings" ON public.listings;
    CREATE POLICY "Public can view published listings" ON public.listings
    FOR SELECT USING (status = 'published');
    RAISE NOTICE 'RLS policy created for public to view published listings.';

END $$;
