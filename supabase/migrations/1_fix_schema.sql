-- Script 1: Fix the Database Schema
-- This script safely adds all potentially missing columns and sets the correct security rules.
-- It is safe to run this script multiple times.

ALTER TABLE public.listings ADD COLUMN IF NOT EXISTS status TEXT;
ALTER TABLE public.listings ADD COLUMN IF NOT EXISTS rating NUMERIC;
ALTER TABLE public.listings ADD COLUMN IF NOT EXISTS location TEXT;
ALTER TABLE public.listings ADD COLUMN IF NOT EXISTS type TEXT;
ALTER TABLE public.listings ADD COLUMN IF NOT EXISTS features JSONB;
ALTER TABLE public.listings ADD COLUMN IF NOT EXISTS amenities JSONB;
ALTER TABLE public.listings ADD COLUMN IF NOT EXISTS itinerary JSONB;

-- This enables Row Level Security (RLS) and creates the correct policy.
-- This allows the public to view ONLY listings that are marked as 'published'.
ALTER TABLE public.listings ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Public can view published listings" ON public.listings;

CREATE POLICY "Public can view published listings" ON public.listings
FOR SELECT USING (status = 'published');
