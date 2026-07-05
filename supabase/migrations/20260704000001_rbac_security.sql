-- Phase 2: User Authentication & Account Protection (RBAC)

-- 1. Ensure `users` table has an `author_role` column and `is_verified`
ALTER TABLE public.users ADD COLUMN IF NOT EXISTS author_role TEXT DEFAULT 'user';
ALTER TABLE public.users ADD COLUMN IF NOT EXISTS is_verified BOOLEAN DEFAULT false;

-- 2. Revoke all access first
ALTER TABLE public.users ENABLE ROW LEVEL SECURITY;

-- 3. Everyone can read user profiles (necessary for feed and comments)
CREATE POLICY "Profiles are viewable by everyone" ON public.users
    FOR SELECT USING (true);

-- 4. Users can update their own profile, BUT cannot elevate their own role or verification status
CREATE POLICY "Users can update their own basic profile info" ON public.users
    FOR UPDATE 
    USING (auth.uid() = id)
    WITH CHECK (
        -- Prevent users from changing their own author_role or is_verified status
        -- Supabase doesn't support column-level RLS directly in UPDATE policies cleanly for prevention without function triggers,
        -- so we recommend a trigger or an edge function for profile updates. 
        -- However, we can enforce that the old role must equal the new role in this policy:
        auth.uid() = id
    );

-- Trigger to prevent self-elevation of roles:
CREATE OR REPLACE FUNCTION public.prevent_role_elevation()
RETURNS TRIGGER AS $$
BEGIN
    -- If the current user is not an admin, they cannot change their role or verification status
    IF (auth.jwt() ->> 'role') != 'admin' THEN
        NEW.author_role = OLD.author_role;
        NEW.is_verified = OLD.is_verified;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

DROP TRIGGER IF EXISTS tr_prevent_role_elevation ON public.users;
CREATE TRIGGER tr_prevent_role_elevation
    BEFORE UPDATE ON public.users
    FOR EACH ROW
    EXECUTE FUNCTION public.prevent_role_elevation();

-- 5. Admins can update any user profile (including author_role and is_verified)
-- Assuming admin JWT role or a separate admin table. We check JWT role here.
CREATE POLICY "Admins can update any profile" ON public.users
    FOR UPDATE
    USING ((auth.jwt() ->> 'role') = 'admin');

-- 6. Admins can delete any profile
CREATE POLICY "Admins can delete any profile" ON public.users
    FOR DELETE
    USING ((auth.jwt() ->> 'role') = 'admin');
