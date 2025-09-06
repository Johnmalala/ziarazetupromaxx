/*
          # [Feature] Add 'Pay on Arrival' Option
          This migration updates the payment options to include a new 'pay_on_arrival' method.

          ## Query Description: 
          This operation modifies the 'bookings' table to allow a new value in the 'payment_plan' column. It first removes the existing constraint, then adds a new one with the added option. This is a safe structural change and does not affect existing data.
          
          ## Metadata:
          - Schema-Category: "Structural"
          - Impact-Level: "Low"
          - Requires-Backup: false
          - Reversible: true
          
          ## Structure Details:
          - Table: bookings
          - Column: payment_plan
          - Constraint: bookings_payment_plan_check
          
          ## Security Implications:
          - RLS Status: Unchanged
          - Policy Changes: No
          - Auth Requirements: None
          
          ## Performance Impact:
          - Indexes: None
          - Triggers: None
          - Estimated Impact: Negligible
          */

-- First, drop the existing constraint
ALTER TABLE public.bookings DROP CONSTRAINT IF EXISTS bookings_payment_plan_check;

-- Then, add the new constraint with the 'pay_on_arrival' option
ALTER TABLE public.bookings
ADD CONSTRAINT bookings_payment_plan_check
CHECK (payment_plan IN ('full', 'deposit', 'lipa_mdogo_mdogo', 'pay_on_arrival'));
