/*
  # [DEMO CONTENT] Add Sample Published Listings
  This script inserts three sample listings (a tour, a stay, and a volunteer opportunity) directly into your database.
  All listings are marked with status = 'published' to ensure they are visible on the live website.
  This is for diagnostic purposes to confirm the website's data fetching and RLS policies are working correctly.

  ## Query Description:
  - Inserts 3 new rows into the `public.listings` table.
  - This operation is safe and does not affect existing data.

  ## Metadata:
  - Schema-Category: "Data"
  - Impact-Level: "Low"
  - Requires-Backup: false
  - Reversible: true (can be deleted manually from your dashboard)
*/

INSERT INTO public.listings (title, description, category, price, rating, location, type, image, status, features, itinerary, availability)
VALUES
(
  'DEMO: Majestic Maasai Mara Safari',
  'Experience the thrill of a lifetime on a 3-day safari through the world-renowned Maasai Mara National Reserve. Witness the Great Migration, spot the Big Five, and immerse yourself in the stunning landscapes of the African savanna.',
  'tour',
  1250,
  4.9,
  'Maasai Mara, Kenya',
  'Safari',
  'https://images.unsplash.com/photo-1534569645818-3a1a3b5e4443?q=80&w=1740&auto=format&fit=crop',
  'published',
  '{"duration": "3 Days / 2 Nights", "group_size": "Max 6 people"}',
  '{"day_1": "Arrival in Maasai Mara, evening game drive.", "day_2": "Full day game drive with picnic lunch.", "day_3": "Morning game drive and departure."}',
  '{"booked_dates": ["2025-10-10", "2025-10-11", "2025-10-15"]}'
),
(
  'DEMO: Serene Diani Beach Villa',
  'Relax and unwind in this beautiful beachfront villa on the pristine shores of Diani Beach. Enjoy private access to the white sandy beaches, a stunning pool, and modern amenities for the perfect coastal getaway.',
  'stay',
  250,
  4.8,
  'Diani Beach, Kenya',
  'Villa',
  'https://images.unsplash.com/photo-1610641818989-c2051b5e2cfd?q=80&w=1740&auto=format&fit=crop',
  'published',
  null,
  null,
  '{"booked_dates": ["2025-11-05", "2025-11-06", "2025-11-12", "2025-11-13"]}'
),
(
  'DEMO: Community School Teaching Project',
  'Make a lasting impact by volunteering at a local community school in a rural village near Nairobi. Assist teachers, engage with students, and help create a positive learning environment for children.',
  'volunteer',
  0,
  5.0,
  'Nairobi, Kenya',
  'Education',
  'https://images.unsplash.com/photo-1542744173-8e7e53415bb0?q=80&w=1740&auto=format&fit=crop',
  'published',
  null,
  null,
  null
);
