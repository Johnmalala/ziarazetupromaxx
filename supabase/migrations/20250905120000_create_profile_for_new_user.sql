-- This migration creates a trigger that automatically inserts a new row into the public.profiles table
-- whenever a new user signs up in the auth.users table. This is essential for linking user authentication
-- with their public profile data, which is required for features like making bookings.

-- Create the function that will be triggered
create or replace function public.handle_new_user()
returns trigger
language plpgsql
security definer set search_path = public
as $$
begin
  insert into public.profiles (id, full_name, email, role)
  values (new.id, new.raw_user_meta_data->>'full_name', new.email, 'user');
  return new;
end;
$$;

-- Create the trigger that calls the function
drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created
  after insert on auth.users
  for each row execute procedure public.handle_new_user();
