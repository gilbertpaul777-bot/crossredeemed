-- ==========================================
-- SUPABASE POSTS SETUP FOR SCRIPTURE OVERLAY & SECURITY
-- ==========================================

-- 1. Add the new TikTok MVP columns to the posts table
ALTER TABLE public.posts 
ADD COLUMN IF NOT EXISTS scripture_overlay TEXT,
ADD COLUMN IF NOT EXISTS privacy_mode TEXT DEFAULT 'Public',
ADD COLUMN IF NOT EXISTS allow_comments BOOLEAN DEFAULT true,
ADD COLUMN IF NOT EXISTS hashtags TEXT[];

-- ==========================================
-- 2. ENABLE ROW LEVEL SECURITY (RLS) ON POSTS
-- ==========================================
ALTER TABLE public.posts ENABLE ROW LEVEL SECURITY;

-- Allow anyone (public) to view posts
DROP POLICY IF EXISTS "Allow public read access to posts" ON public.posts;
CREATE POLICY "Allow public read access to posts" 
ON public.posts FOR SELECT USING (true);

-- Allow authenticated users to insert their own posts
DROP POLICY IF EXISTS "Allow users to insert own posts" ON public.posts;
CREATE POLICY "Allow users to insert own posts" 
ON public.posts FOR INSERT TO authenticated WITH CHECK (auth.uid() = user_id);

-- Allow authenticated users to update their own posts
DROP POLICY IF EXISTS "Allow users to update own posts" ON public.posts;
CREATE POLICY "Allow users to update own posts" 
ON public.posts FOR UPDATE TO authenticated USING (auth.uid() = user_id);

-- Allow authenticated users to delete their own posts
DROP POLICY IF EXISTS "Allow users to delete own posts" ON public.posts;
CREATE POLICY "Allow users to delete own posts" 
ON public.posts FOR DELETE TO authenticated USING (auth.uid() = user_id);
