-- This migration fixes the issue of published listings not appearing on the website.
-- It adds a specific Row Level Security (RLS) policy to the `listings` table.

-- First, we safely remove any previous, potentially conflicting read policies.
DROP POLICY IF EXISTS "Public can view published listings" ON public.listings;
DROP POLICY IF EXISTS "Allow public read access to listings" ON public.listings;

/*
# [Create Public Read Policy for Listings]
This policy grants read-only access to the `listings` table for all public website visitors.

## Query Description: This operation is safe and non-destructive. It adds a security rule that allows anyone to view listings, but ONLY if their `status` is 'published'. It does not affect your ability to manage all listings from your admin dashboard. This is the standard and required way to make content visible on a public website while keeping drafts hidden.

## Metadata:
- Schema-Category: ["Safe", "Security"]
- Impact-Level: ["Low"]
- Requires-Backup: false
- Reversible: true

## Security Implications:
- RLS Status: Enabled
- Policy Changes: Yes
- Auth Requirements: Allows anonymous access for viewing published listings.
*/
CREATE POLICY "Public can view published listings"
ON public.listings
FOR SELECT
TO anon, authenticated
USING (status ILIKE 'published');
