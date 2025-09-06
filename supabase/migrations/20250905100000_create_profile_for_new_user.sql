/*
  # Create Profile for New User Trigger
  This migration creates a trigger that automatically inserts a new row into the public.profiles table whenever a new user signs up in the auth.users table.

  ## Query Description:
  This operation is safe and essential for application functionality. It ensures that every authenticated user has a corresponding public profile, which is required for making bookings and other actions. It does not affect existing data and prevents booking failures for new users.

  ## Metadata:
  - Schema-Category: "Structural"
  - Impact-Level: "Low"
  - Requires-Backup: false
  - Reversible: true (by dropping the trigger and function)

  ## Structure Details:
  - Creates a new function: `public.handle_new_user()`
  - Creates a new trigger: `on_auth_user_created` on the `auth.users` table.

  ## Security Implications:
  - RLS Status: Not directly affected, but enables RLS policies on `profiles` to work correctly for new users.
  - Policy Changes: No
  - Auth Requirements: This trigger is dependent on Supabase Auth.
*/

-- Create a function to handle new user creation
create or replace function public.handle_new_user()
returns trigger
language plpgsql
security definer set search_path = public
as $$
begin
  insert into public.profiles (id, full_name, email)
  values (new.id, new.raw_user_meta_data->>'full_name', new.email);
  return new;
end;
$$;

-- Create a trigger to call the function when a new user is created
drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created
  after insert on auth.users
  for each row execute procedure public.handle_new_user();
