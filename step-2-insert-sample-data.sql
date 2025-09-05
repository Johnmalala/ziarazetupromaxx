-- After running Step 1, run this script to insert sample data.
-- This data is correctly formatted to appear on your website.

INSERT INTO public.listings (title, description, category, price, rating, location, type, image, status, features, itinerary, availability)
VALUES 
('Majestic Maasai Mara Safari', 'Experience the thrill of a lifetime on a 3-day safari in the world-renowned Maasai Mara National Reserve. Witness the Great Migration (seasonal), spot the Big Five, and immerse yourself in the stunning landscapes of Kenya.', 'tour', 1200, 4.9, 'Maasai Mara, Kenya', 'Safari', 'https://images.unsplash.com/photo-1534430480872-3498386e7856?w=800', 'published', '{"duration": "3 Days", "group_size": "6 people"}', '{"day_1": "Arrival and evening game drive.", "day_2": "Full day game drive.", "day_3": "Morning game drive and departure."}', '{"booked_dates": ["2025-08-10", "2025-08-15"]}'),
('Community Teaching Project in Arusha', 'Make a difference by teaching English and other subjects to children in a local community school near Arusha. This is a rewarding experience that allows you to immerse yourself in Tanzanian culture.', 'volunteer', 0, null, 'Arusha, Tanzania', 'Education', 'https://images.unsplash.com/photo-1509062522246-3755977927d7?w=800', 'published', '{"commitment": "2 weeks minimum"}', null, null);

INSERT INTO public.listings (title, description, category, price, rating, location, type, image, status, features, amenities, availability)
VALUES
('Serene Beachfront Villa in Diani', 'Relax in a luxurious private villa on the beautiful Diani Beach. Enjoy stunning ocean views, a private pool, and direct beach access. Perfect for a romantic getaway or a family vacation.', 'stay', 350, 4.8, 'Diani Beach, Kenya', 'Villa', 'https://images.unsplash.com/photo-1610641818989-c2051b5e2cfd?w=800', 'published', '{"bedrooms": 3, "bathrooms": 4}', '["Private Pool", "WiFi", "Air Conditioning", "Beach Access"]', '{"booked_dates": ["2025-09-01", "2025-09-05"]}');
