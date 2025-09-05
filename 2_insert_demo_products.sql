/*
# [Data] Insert Demo Products
This script inserts three sample listings (a tour, a stay, and a volunteer opportunity) into the public.listings table. These products are correctly formatted with a 'published' status to ensure they are visible on the website.

## Query Description:
- This operation adds new rows to the 'listings' table.
- It will not affect any existing data in the table.

## Metadata:
- Schema-Category: "Data"
- Impact-Level: "Low"
- Requires-Backup: false
- Reversible: true (by deleting the inserted rows)
*/
INSERT INTO public.listings (title, description, category, price, rating, location, type, image, status, features, itinerary, availability)
VALUES
(
  'Majestic Maasai Mara Safari',
  'Experience the thrill of a lifetime on a 3-day safari in the world-renowned Maasai Mara National Reserve. Witness the Great Migration (seasonal), spot the Big Five, and immerse yourself in the stunning landscapes of Kenya.',
  'tour',
  450,
  4.9,
  'Maasai Mara, Kenya',
  'Safari',
  'https://images.unsplash.com/photo-1534569613898-73514041526f?w=800',
  'published',
  '{"duration": "3 Days", "group_size": "Max 6 people"}',
  '{"day_1": "Nairobi to Maasai Mara, evening game drive.", "day_2": "Full day game drive with picnic lunch.", "day_3": "Morning game drive, return to Nairobi."}',
  '{"booked_dates": ["2025-10-15", "2025-10-16"]}'
),
(
  'Serene Beachfront Villa in Diani',
  'Relax and unwind in this stunning beachfront villa in Diani. Enjoy private access to the white sandy beaches, a beautiful swimming pool, and modern amenities for the perfect coastal getaway.',
  'stay',
  200,
  4.8,
  'Diani Beach, Kenya',
  'Villa',
  'https://images.unsplash.com/photo-1610641818989-c2051b5e2cfd?w=800',
  'published',
  '{"bedrooms": 3, "bathrooms": 4}',
  '{"amenities": ["WiFi", "Air Conditioning", "Swimming Pool", "Private Beach Access"]}',
  '{"booked_dates": ["2025-11-01", "2025-11-02", "2025-11-03"]}'
),
(
  'Community Teaching Project in Arusha',
  'Make a difference by volunteering at a local primary school in Arusha. Assist teachers, help with homework, and engage with children to support their educational journey. A truly rewarding experience.',
  'volunteer',
  0,
  5.0,
  'Arusha, Tanzania',
  'Education',
  'https://images.unsplash.com/photo-1524178232363-1fb2b075b655?w=800',
  'published',
  '{"commitment": "Min 2 weeks", "skills": "Basic English"}',
  '{"responsibilities": ["Assisting in classrooms", "Organizing activities", "Mentoring students"]}',
  '{"booked_dates": []}'
);
