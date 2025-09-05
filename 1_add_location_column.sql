/*
# [Migration] Add 'location' column to listings table
This script safely adds the 'location' text column to the public.listings table if it does not already exist. This is necessary to store location information for all listing types.

## Query Description:
- This operation alters the structure of the 'listings' table.
- It is a non-destructive change and will not affect existing data.

## Metadata:
- Schema-Category: "Structural"
- Impact-Level: "Low"
- Requires-Backup: false
- Reversible: true (by dropping the column)
*/
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1
        FROM information_schema.columns
        WHERE table_schema = 'public'
        AND table_name = 'listings'
        AND column_name = 'location'
    ) THEN
        ALTER TABLE public.listings ADD COLUMN location TEXT;
    END IF;
END $$;
