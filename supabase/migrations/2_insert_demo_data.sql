-- Script 2: Insert Demo Products
-- Run this script ONLY AFTER the 'Fix Schema' script has completed successfully.

-- First, we delete any old demo data to prevent duplicates.
DELETE FROM public.listings WHERE title IN ('Masai Mara Grand Safari', 'Zanzibar Beachfront Villa', 'Community School Teaching Project');

-- Now, we insert the new, correctly formatted demo data.
INSERT INTO public.listings (title, description, category, price, rating, location, type, image, status, features, amenities, itinerary, availability)
VALUES
(
  'Masai Mara Grand Safari', 
  'Experience the breathtaking wildlife of the Masai Mara on this 5-day guided safari. Witness the Great Migration and see the Big Five in their natural habitat.', 
  'tour', 
  1200, 
  4.9, 
  'Masai Mara, Kenya', 
  'Safari', 
  'https://images.unsplash.com/photo-1534569524880-1e84742046f2?w=800', 
  'published', 
  '{"duration": "5 Days", "group_size": "Max 6 people"}',
  null,
  '{"day_1": "Arrival and evening game drive.", "day_2": "Full day game drive.", "day_3": "Visit a Maasai village.", "day_4": "Morning game drive and relax.", "day_5": "Departure."}', 
  '{"booked_dates": ["2025-08-10", "2025-08-11"]}'
),
(
  'Zanzibar Beachfront Villa', 
  'A luxurious private villa on the pristine beaches of Nungwi, Zanzibar. Perfect for a romantic getaway or a family vacation.', 
  'stay', 
  350, 
  4.8, 
  'Nungwi, Zanzibar', 
  'Villa', 
  'https://images.unsplash.com/photo-1610044522924-a36923814506?w=800', 
  'published', 
  '{"beds": 2, "baths": 2}', 
  '["wifi", "air conditioning", "private pool", "beach access"]',
  '{"check_in": "14:00", "check_out": "11:00"}', 
  '{"booked_dates": ["2025-09-01", "2025-09-02", "2025-09-03"]}'
),
(
  'Community School Teaching Project', 
  'Volunteer your time to teach English and other subjects at a local community school in Arusha. A rewarding experience to make a real impact.', 
  'volunteer', 
  0, 
  4.7, 
  'Arusha, Tanzania', 
  'Education', 
  'https://images.unsplash.com/photo-1524178232363-1fb2b075b655?w=800', 
  'published', 
  '{"commitment": "Min 2 weeks", "subject": "English"}',
  null,
  '{"responsibilities": ["Teaching classes", "organizing activities", "assisting local teachers."]}', 
  '{}'
);
