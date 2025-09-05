-- This script adds the missing 'rating' column to your 'listings' table.
-- It's safe to run even if the column already exists.

ALTER TABLE public.listings
ADD COLUMN IF NOT EXISTS rating NUMERIC(2, 1);
