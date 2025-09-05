DO $$
BEGIN
    -- Add missing columns safely, without causing errors if they already exist.
    IF NOT EXISTS (SELECT FROM pg_attribute WHERE attrelid = 'public.listings'::regclass AND attname = 'status' AND NOT attisdropped) THEN
        ALTER TABLE public.listings ADD COLUMN status TEXT DEFAULT 'draft';
        RAISE NOTICE 'Column "status" added to "listings" table.';
    END IF;

    IF NOT EXISTS (SELECT FROM pg_attribute WHERE attrelid = 'public.listings'::regclass AND attname = 'rating' AND NOT attisdropped) THEN
        ALTER TABLE public.listings ADD COLUMN rating NUMERIC;
        RAISE NOTICE 'Column "rating" added to "listings" table.';
    END IF;

    IF NOT EXISTS (SELECT FROM pg_attribute WHERE attrelid = 'public.listings'::regclass AND attname = 'location' AND NOT attisdropped) THEN
        ALTER TABLE public.listings ADD COLUMN location TEXT;
        RAISE NOTICE 'Column "location" added to "listings" table.';
    END IF;

    -- Enable Row Level Security (RLS) on the listings table.
    ALTER TABLE public.listings ENABLE ROW LEVEL SECURITY;
    RAISE NOTICE 'Row Level Security enabled on "listings" table.';

    -- Create a policy to allow public read access to only 'published' listings.
    -- This is safe and will not fail if the policy already exists.
    DROP POLICY IF EXISTS "Public can view published listings" ON public.listings;
    CREATE POLICY "Public can view published listings"
    ON public.listings
    FOR SELECT
    TO anon, authenticated
    USING (status = 'published');
    RAISE NOTICE 'RLS policy "Public can view published listings" created.';

    -- Insert three demo products with the correct status.
    RAISE NOTICE 'Inserting demo listings...';
    INSERT INTO public.listings (title, description, category, price, rating, location, type, image, status, features, itinerary, availability)
    VALUES
    ('Masai Mara Grand Safari', 'Experience the breathtaking wildlife of the Masai Mara on this 5-day guided safari. Witness the Great Migration and see the Big Five in their natural habitat.', 'tour', 1200, 4.9, 'Masai Mara, Kenya', 'Safari', 'https://images.unsplash.com/photo-1534569524880-1e84742046f2?w=800', 'published', '{"duration": "5 Days", "group_size": "Max 6 people"}', '{"day_1": "Arrival and evening game drive.", "day_2": "Full day game drive.", "day_3": "Visit a Maasai village.", "day_4": "Morning game drive and relax.", "day_5": "Departure."}', '{"booked_dates": ["2025-08-10", "2025-08-11"]}'),
    ('Zanzibar Beachfront Villa', 'A luxurious private villa on the pristine beaches of Nungwi, Zanzibar. Perfect for a romantic getaway or a family vacation.', 'stay', 350, 4.8, 'Nungwi, Zanzibar', 'Villa', 'https://images.unsplash.com/photo-1610044522924-a36923814506?w=800', 'published', '{"beds": 2, "baths": 2}', '{"amenities": ["wifi", "air conditioning", "private pool", "beach access"]}', '{"booked_dates": ["2025-09-01", "2025-09-02", "2025-09-03"]}'),
    ('Community School Teaching Project', 'Volunteer your time to teach English and other subjects at a local community school in Arusha. A rewarding experience to make a real impact.', 'volunteer', 0, 4.7, 'Arusha, Tanzania', 'Education', 'https://images.unsplash.com/photo-1524178232363-1fb2b075b655?w=800', 'published', '{"commitment": "Min 2 weeks", "subject": "English"}', '{"responsibilities": "Teaching classes, organizing activities, assisting local teachers."}', '{}');
    RAISE NOTICE 'Demo listings inserted successfully.';

END $$;
