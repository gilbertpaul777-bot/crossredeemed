-- ==========================================
-- SUPABASE SEARCH & PROFILES SCHEMA SETUP
-- ==========================================

-- 1. Create the public profiles table
CREATE TABLE IF NOT EXISTS public.profiles (
  id uuid REFERENCES auth.users(id) ON DELETE CASCADE PRIMARY KEY,
  username text,
  avatar_url text,
  updated_at timestamp with time zone DEFAULT timezone('utc'::text, now())
);

-- Enable RLS
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;

-- Allow public read access to all profiles
DROP POLICY IF EXISTS "Public profiles are viewable by everyone" ON public.profiles;
CREATE POLICY "Public profiles are viewable by everyone" 
ON public.profiles FOR SELECT USING (true);

-- Allow users to update their own profile
DROP POLICY IF EXISTS "Users can update own profile" ON public.profiles;
CREATE POLICY "Users can update own profile" 
ON public.profiles FOR UPDATE TO authenticated USING (auth.uid() = id);

-- 2. Create the Trigger to auto-sync new signups to the profiles table
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO public.profiles (id, username, avatar_url)
  VALUES (
    new.id,
    new.raw_user_meta_data->>'username',
    new.raw_user_meta_data->>'avatar_url'
  );
  RETURN new;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Drop the trigger if it exists so we can recreate it cleanly
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;

-- Recreate the trigger
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE PROCEDURE public.handle_new_user();

-- 3. BACKFILL SCRIPT (To sync any users that existed before this trigger)
INSERT INTO public.profiles (id, username, avatar_url)
SELECT 
  id,
  raw_user_meta_data->>'username',
  raw_user_meta_data->>'avatar_url'
FROM auth.users
ON CONFLICT (id) DO UPDATE 
SET 
  username = EXCLUDED.username,
  avatar_url = EXCLUDED.avatar_url;
