-- ==========================================
-- SUPABASE FAITH WALL SCHEMA SETUP
-- ==========================================

-- 1. Create or Update the faith_wall_posts table
CREATE TABLE IF NOT EXISTS public.faith_wall_posts (
  id uuid DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id uuid REFERENCES auth.users(id) ON DELETE CASCADE,
  type text NOT NULL CHECK (type IN ('prayer_request', 'testimony', 'praise_report')),
  content text NOT NULL,
  created_at timestamp with time zone DEFAULT timezone('utc'::text, now()) NOT NULL,
  likes_count integer DEFAULT 0,
  comments_count integer DEFAULT 0
);

-- Add author columns if they don't exist (because the table might have already existed)
ALTER TABLE public.faith_wall_posts ADD COLUMN IF NOT EXISTS author_username TEXT;
ALTER TABLE public.faith_wall_posts ADD COLUMN IF NOT EXISTS author_avatar TEXT;

-- Enable Row Level Security (RLS)
ALTER TABLE public.faith_wall_posts ENABLE ROW LEVEL SECURITY;

-- Safely recreate policies
DROP POLICY IF EXISTS "Allow public read access to faith_wall_posts" ON public.faith_wall_posts;
CREATE POLICY "Allow public read access to faith_wall_posts" 
ON public.faith_wall_posts FOR SELECT USING (true);

DROP POLICY IF EXISTS "Allow authenticated users to insert faith_wall_posts" ON public.faith_wall_posts;
CREATE POLICY "Allow authenticated users to insert faith_wall_posts" 
ON public.faith_wall_posts FOR INSERT TO authenticated WITH CHECK (auth.uid() = user_id);

DROP POLICY IF EXISTS "Allow users to update own faith_wall_posts" ON public.faith_wall_posts;
CREATE POLICY "Allow users to update own faith_wall_posts" 
ON public.faith_wall_posts FOR UPDATE TO authenticated USING (auth.uid() = user_id);

DROP POLICY IF EXISTS "Allow users to delete own faith_wall_posts" ON public.faith_wall_posts;
CREATE POLICY "Allow users to delete own faith_wall_posts" 
ON public.faith_wall_posts FOR DELETE TO authenticated USING (auth.uid() = user_id);

-- ==========================================
-- 2. Create faith_wall_likes table
-- ==========================================
CREATE TABLE IF NOT EXISTS public.faith_wall_likes (
  id uuid DEFAULT gen_random_uuid() PRIMARY KEY,
  post_id uuid NOT NULL REFERENCES faith_wall_posts(id) ON DELETE CASCADE,
  user_id uuid NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(post_id, user_id)
);

ALTER TABLE public.faith_wall_likes ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Faith Wall likes viewable by everyone" ON faith_wall_likes;
CREATE POLICY "Faith Wall likes viewable by everyone" ON faith_wall_likes
  FOR SELECT USING (true);

DROP POLICY IF EXISTS "Users can insert their own faith wall likes" ON faith_wall_likes;
CREATE POLICY "Users can insert their own faith wall likes" ON faith_wall_likes
  FOR INSERT WITH CHECK (auth.uid() = user_id);

DROP POLICY IF EXISTS "Users can delete their own faith wall likes" ON faith_wall_likes;
CREATE POLICY "Users can delete their own faith wall likes" ON faith_wall_likes
  FOR DELETE USING (auth.uid() = user_id);


-- ==========================================
-- 3. Create faith_wall_comments table
-- ==========================================
CREATE TABLE IF NOT EXISTS public.faith_wall_comments (
  id uuid DEFAULT gen_random_uuid() PRIMARY KEY,
  post_id uuid NOT NULL REFERENCES faith_wall_posts(id) ON DELETE CASCADE,
  user_id uuid NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  content TEXT NOT NULL,
  author_username TEXT,
  author_avatar TEXT,
  likes INT DEFAULT 0,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

ALTER TABLE public.faith_wall_comments ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Faith Wall comments viewable by everyone" ON faith_wall_comments;
CREATE POLICY "Faith Wall comments viewable by everyone" ON faith_wall_comments
  FOR SELECT USING (true);

DROP POLICY IF EXISTS "Users can insert their own faith wall comments" ON faith_wall_comments;
CREATE POLICY "Users can insert their own faith wall comments" ON faith_wall_comments
  FOR INSERT WITH CHECK (auth.uid() = user_id);

DROP POLICY IF EXISTS "Users can delete their own faith wall comments" ON faith_wall_comments;
CREATE POLICY "Users can delete their own faith wall comments" ON faith_wall_comments
  FOR DELETE USING (auth.uid() = user_id);
