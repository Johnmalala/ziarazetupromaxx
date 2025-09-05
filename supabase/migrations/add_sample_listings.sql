-- This script inserts three sample listings (a tour, a stay, and a volunteer opportunity)
-- into your 'listings' table. Each is marked with status = 'published' to ensure
-- they are visible on your live website.

-- Sample Tour
INSERT INTO public.listings (title, description, category, price, rating, location, type, image, status, features, itinerary, availability)
VALUES 
(
  'Serengeti Great Migration Safari', 
  'Witness the breathtaking Great Migration in the Serengeti. This 7-day safari takes you through the heart of Tanzania''s most famous national park, offering unparalleled wildlife viewing opportunities.',
  'tour',
  2500,
  4.9,
  'Serengeti, Tanzania',
  'Safari',
  'https://images.unsplash.com/photo-1534430480872-740484a7ae53?q=80&w=1740&auto=format&fit=crop',
  'published',
  '{"duration": "7 Days", "group_size": "Max 6 people"}',
  '{"day_1": "Arrive at Kilimanjaro Airport and transfer to Arusha.", "day_2": "Drive to Serengeti National Park.", "day_3_5": "Full day game drives in Serengeti.", "day_6": "Visit Ngorongoro Crater.", "day_7": "Return to Arusha for departure."}',
  '{"booked_dates": []}'
);

-- Sample Stay
INSERT INTO public.listings (title, description, category, price, rating, location, type, image, status, amenities, availability)
VALUES 
(
  'Zanzibar Beachfront Villa',
  'A luxurious private villa on the pristine beaches of Nungwi, Zanzibar. Enjoy stunning ocean views, a private pool, and world-class service. Perfect for a romantic getaway or family vacation.',
  'stay',
  350,
  4.8,
  'Nungwi, Zanzibar',
  'Villa',
  'https://images.unsplash.com/photo-1610641818989-c2051b5e2cfd?q=80&w=1740&auto=format&fit=crop',
  'published',
  '["Private Pool", "Air Conditioning", "Free Wifi", "Beach Access", "Daily Housekeeping"]',
  '{"booked_dates": ["2025-10-10", "2025-10-11", "2025-10-12"]}'
);

-- Sample Volunteer Opportunity
INSERT INTO public.listings (title, description, category, price, rating, location, type, image, status, features)
VALUES 
(
  'Community School Teaching Assistance',
  'Support local education initiatives by assisting teachers in a community school near Arusha. Help with English lessons, sports activities, and creative arts. A rewarding experience to make a real impact.',
  'volunteer',
  0,
  null,
  'Arusha, Tanzania',
  'Education',
  'https://images.unsplash.com/photo-1509062522246-3755977927d7?q=80&w=1832&auto=format&fit=crop',
  'published',
  '{"duration": "Min 2 weeks", "commitment": "Mon-Fri, 9am-3pm"}'
);
