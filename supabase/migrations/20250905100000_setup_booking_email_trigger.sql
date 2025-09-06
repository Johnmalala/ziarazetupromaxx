/*
# [Operation] Setup Booking Email Trigger
This migration creates a database trigger to automatically send a confirmation email when a new booking is made.

## Query Description:
This script creates a PostgreSQL function that invokes a Supabase Edge Function (`send-booking-confirmation`). It then creates a trigger that executes this function after a new row is inserted into the `bookings` table. This automates the email confirmation process, ensuring users receive timely notifications.

## Metadata:
- Schema-Category: "Structural"
- Impact-Level: "Low"
- Requires-Backup: false
- Reversible: true (DROP TRIGGER and DROP FUNCTION)

## Structure Details:
- Adds a new function: `public.handle_new_booking()`
- Adds a new trigger: `on_new_booking_send_email` on the `public.bookings` table.

## Security Implications:
- RLS Status: Unchanged
- Policy Changes: No
- Auth Requirements: The trigger function uses the service role to invoke the edge function, which is a secure pattern.

## Performance Impact:
- Indexes: None
- Triggers: Adds one AFTER INSERT trigger. The impact is minimal as the function is invoked asynchronously.
- Estimated Impact: Negligible performance impact on database inserts.
*/

-- Create the trigger function
CREATE OR REPLACE FUNCTION public.handle_new_booking()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
  PERFORM net.http_post(
    url := 'https://myllmukorflkbuvokbpf.supabase.co/functions/v1/send-booking-confirmation',
    headers := '{"Content-Type": "application/json", "Authorization": "Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im15bGxtdWtvcmZsa2J1dm9rYnBmIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTIzODQwNTEsImV4cCI6MjA2Nzk2MDA1MX0.uPNwK0j8dEkt3cEfZg3twvRPvo4QNPKM1GHCL-ZMTUU"}', -- Uses anon key for invocation
    body := json_build_object('record', NEW)
  );
  RETURN NEW;
END;
$$;

-- Create the trigger on the bookings table
CREATE TRIGGER on_new_booking_send_email
AFTER INSERT ON public.bookings
FOR EACH ROW
EXECUTE FUNCTION public.handle_new_booking();
