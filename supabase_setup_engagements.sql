-- ==========================================
-- SUPABASE ENGAGEMENTS SCHEMA SETUP
-- ==========================================
-- This script creates the tables and security policies for 
-- Likes, Bookmarks, and Comments on posts.

-- 1. Create post_likes table
CREATE TABLE IF NOT EXISTS post_likes (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  post_id UUID NOT NULL REFERENCES posts(id) ON DELETE CASCADE,
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(post_id, user_id)
);

-- Enable RLS for post_likes
ALTER TABLE post_likes ENABLE ROW LEVEL SECURITY;

-- Allow anyone to read likes
CREATE POLICY "Likes are viewable by everyone" ON post_likes
  FOR SELECT USING (true);

-- Allow authenticated users to insert their own likes
CREATE POLICY "Users can insert their own likes" ON post_likes
  FOR INSERT WITH CHECK (auth.uid() = user_id);

-- Allow authenticated users to delete their own likes
CREATE POLICY "Users can delete their own likes" ON post_likes
  FOR DELETE USING (auth.uid() = user_id);


-- 2. Create post_bookmarks table
CREATE TABLE IF NOT EXISTS post_bookmarks (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  post_id UUID NOT NULL REFERENCES posts(id) ON DELETE CASCADE,
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(post_id, user_id)
);

-- Enable RLS for post_bookmarks
ALTER TABLE post_bookmarks ENABLE ROW LEVEL SECURITY;

-- Allow users to view their own bookmarks
CREATE POLICY "Users can view their own bookmarks" ON post_bookmarks
  FOR SELECT USING (auth.uid() = user_id);

-- Allow authenticated users to insert their own bookmarks
CREATE POLICY "Users can insert their own bookmarks" ON post_bookmarks
  FOR INSERT WITH CHECK (auth.uid() = user_id);

-- Allow authenticated users to delete their own bookmarks
CREATE POLICY "Users can delete their own bookmarks" ON post_bookmarks
  FOR DELETE USING (auth.uid() = user_id);


-- 3. Create post_comments table
CREATE TABLE IF NOT EXISTS post_comments (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  post_id UUID NOT NULL REFERENCES posts(id) ON DELETE CASCADE,
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  content TEXT NOT NULL,
  author_username TEXT,
  author_avatar TEXT,
  likes INT DEFAULT 0,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Enable RLS for post_comments
ALTER TABLE post_comments ENABLE ROW LEVEL SECURITY;

-- Allow anyone to read comments
CREATE POLICY "Comments are viewable by everyone" ON post_comments
  FOR SELECT USING (true);

-- Allow authenticated users to insert comments
CREATE POLICY "Users can insert their own comments" ON post_comments
  FOR INSERT WITH CHECK (auth.uid() = user_id);

-- Allow users to delete their own comments
CREATE POLICY "Users can delete their own comments" ON post_comments
  FOR DELETE USING (auth.uid() = user_id);
