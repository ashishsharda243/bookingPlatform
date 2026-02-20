-- ============================================================
-- Fix RLS Infinite Recursion on Users Table
-- ============================================================

-- Problem: The previous `users_select` policy checked for "admin" role 
-- by querying the `users` table itself. This caused the policy to 
-- trigger itself recursively (Infinite Recursion 42P17).

-- Solution: Create a "Security Definer" function to check admin status.
-- Security Definer functions run with the privileges of the creator 
-- (superuser/postgres), effectively bypassing RLS for that specific check.

-- 1. Create helper function to check if current user is admin
CREATE OR REPLACE FUNCTION is_admin()
RETURNS BOOLEAN
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
  RETURN EXISTS (
    SELECT 1 FROM public.users 
    WHERE id = auth.uid() 
    AND role = 'admin'
  );
END;
$$;

-- 2. Drop the problematic recursive policies
DROP POLICY IF EXISTS users_select ON users;
DROP POLICY IF EXISTS users_update ON users;

-- 3. Re-create policies using the new function
CREATE POLICY users_select ON users FOR SELECT USING (
    auth.uid() = id OR is_admin()
);

CREATE POLICY users_update ON users FOR UPDATE USING (
    auth.uid() = id OR is_admin()
);

-- 4. Apply similar fix for other tables where we checked admin status recursively
-- (Halls, Bookings, etc. were also checking `users` table, which triggered `users` RLS)

-- Update Halls Policies
DROP POLICY IF EXISTS halls_select ON halls;
DROP POLICY IF EXISTS halls_update ON halls;
DROP POLICY IF EXISTS halls_insert ON halls;

CREATE POLICY halls_select ON halls FOR SELECT USING (
    approval_status = 'approved' OR
    owner_id = auth.uid() OR
    is_admin()
);

CREATE POLICY halls_insert ON halls FOR INSERT WITH CHECK (
    owner_id = auth.uid() AND
    (
        EXISTS (SELECT 1 FROM public.users WHERE id = auth.uid() AND role = 'owner') 
        OR is_admin()
    )
    -- Note: We still query users for 'owner' check, but since we are INSERTING into halls, 
    -- we are not selecting from halls, so it shouldn't recurse on halls. 
    -- However, it DOES select from users.
    -- To be safe, let's fix the owner check too.
);

CREATE POLICY halls_update ON halls FOR UPDATE USING (
    owner_id = auth.uid() OR is_admin()
);
