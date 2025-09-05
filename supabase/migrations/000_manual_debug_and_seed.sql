-- Comprehensive Debugging and Seeding Script for Ziarazetu Listings

-- STEP 1: Ensure the 'listings' table has all necessary columns.
-- This is safe to run multiple times. It only adds columns if they don't exist.
DO $$
BEGIN
    -- Add 'status' column if it doesn't exist
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name='listings' AND column_name='status') THEN
        ALTER TABLE public.listings ADD COLUMN status TEXT DEFAULT 'draft';
        RAISE NOTICE 'Column "status" added to "listings" table.';
    END IF;

    -- Add 'rating' column if it doesn't exist
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name='listings' AND column_name='rating') THEN
        ALTER TABLE public.listings ADD COLUMN rating NUMERIC;
        RAISE NOTICE 'Column "rating" added to "listings" table.';
    END IF;

    -- Add 'location' column if it doesn't exist
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name='listings' AND column_name='location') THEN
        ALTER TABLE public.listings ADD COLUMN location TEXT;
        RAISE NOTICE 'Column "location" added to "listings" table.';
    END IF;

    -- Add 'type' column if it doesn't exist
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name='listings' AND column_name='type') THEN
        ALTER TABLE public.listings ADD COLUMN type TEXT;
        RAISE NOTICE 'Column "type" added to "listings" table.';
    END IF;
    
    -- Add 'features' column if it doesn't exist
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name='listings' AND column_name='features') THEN
        ALTER TABLE public.listings ADD COLUMN features JSONB;
        RAISE NOTICE 'Column "features" added to "listings" table.';
    END IF;

    -- Add 'amenities' column if it doesn't exist
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name='listings' AND column_name='amenities') THEN
        ALTER TABLE public.listings ADD COLUMN amenities JSONB;
        RAISE NOTICE 'Column "amenities" added to "listings" table.';
    END IF;

    -- Add 'itinerary' column if it doesn't exist
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name='listings' AND column_name='itinerary') THEN
        ALTER TABLE public.listings ADD COLUMN itinerary JSONB;
        RAISE NOTICE 'Column "itinerary" added to "listings" table.';
    END IF;
    
    -- Add 'availability' column if it doesn't exist
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name='listings' AND column_name='availability') THEN
        ALTER TABLE public.listings ADD COLUMN availability JSONB;
        RAISE NOTICE 'Column "availability" added to "listings" table.';
    END IF;
END;
$$;


-- STEP 2: Ensure Row Level Security (RLS) is enabled and correctly configured.
-- This is critical for data to be visible on the public website.

-- Enable RLS on the listings table if it's not already enabled.
ALTER TABLE public.listings ENABLE ROW LEVEL SECURITY;
RAISE NOTICE 'Row Level Security enabled on "listings" table.';

-- Drop any existing policy to avoid conflicts, then create the correct one.
-- This policy allows ANYONE to VIEW a listing IF AND ONLY IF its status is 'published'.
DROP POLICY IF EXISTS "Public can view published listings" ON public.listings;
CREATE POLICY "Public can view published listings"
ON public.listings
FOR SELECT
USING (status = 'published');
RAISE NOTICE 'RLS policy "Public can view published listings" created successfully.';


-- STEP 3: Clean up old demo data and insert fresh, correctly formatted demo listings.
-- This ensures we are working with a clean slate.

-- Delete any listings that might have been inserted by previous debug scripts.
DELETE FROM public.listings WHERE title IN (
  'Ziarazetu Demo: Maasai Mara Safari',
  'Ziarazetu Demo: Diani Beach Villa',
  'Ziarazetu Demo: Community School Project'
);
RAISE NOTICE 'Cleaned up previous demo listings.';

-- Insert new, guaranteed-to-be-correct demo data.
-- IMPORTANT: The status is explicitly set to 'published' (all lowercase).
INSERT INTO public.listings (title, description, category, price, rating, location, type, image, status, features, itinerary, availability)
VALUES 
(
  'Ziarazetu Demo: Maasai Mara Safari', 
  'Experience the breathtaking Great Migration in this 3-day safari adventure. See the Big Five and witness one of nature''s greatest spectacles.',
  'tour', 
  450, 
  4.9, 
  'Maasai Mara, Kenya', 
  'Safari', 
  'https://images.unsplash.com/photo-1534437431453-43b243b708d5?w=800',
  'published',
  '{"duration": "3 Days", "group_size": "6 people"}',
  '{"day_1": "Arrival and evening game drive.", "day_2": "Full day game drive exploring the Mara river.", "day_3": "Morning game drive and departure."}',
  '{"booked_dates": ["2025-10-15", "2025-10-16"]}'
),
(
  'Ziarazetu Demo: Diani Beach Villa',
  'A luxurious beachfront villa with a private pool and stunning ocean views. Perfect for a relaxing getaway on the beautiful Kenyan coast.',
  'stay',
  250,
  4.8,
  'Diani Beach, Kenya',
  'Villa',
  'https://images.unsplash.com/photo-1582610285924-f41134a4a4ac?w=800',
  'published',
  null,
  null,
  '{"booked_dates": ["2025-11-01", "2025-11-02", "2025-11-03"]}'
),
(
  'Ziarazetu Demo: Community School Project',
  'Help teach English and support local children in a rural community school. A rewarding experience that makes a real difference.',
  'volunteer',
  0,
  null,
  'Arusha, Tanzania',
  'Education',
  'https://images.unsplash.com/photo-1509062522246-3755977927d7?w=800',
  'published',
  null,
  null,
  null
);

RAISE NOTICE 'Successfully inserted 3 new demo listings. Please refresh your website to check if they are visible.';
