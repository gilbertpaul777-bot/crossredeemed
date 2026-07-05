-- Up Migration

-- 1. Add is_shadowbanned to users table
ALTER TABLE public.users ADD COLUMN IF NOT EXISTS is_shadowbanned BOOLEAN DEFAULT FALSE;

-- 2. Update RLS on faith_wall_posts to filter out shadowbanned users unless it's their own post
-- First, drop existing select policy if it exists (assuming it was named 'Select faith_wall_posts')
DROP POLICY IF EXISTS "Select faith_wall_posts" ON public.faith_wall_posts;

-- Create new select policy
-- A post is visible if the author is NOT shadowbanned OR the current user is the author
CREATE POLICY "Select faith_wall_posts" ON public.faith_wall_posts
FOR SELECT
USING (
  -- Check if the author is shadowbanned
  (NOT EXISTS (
    SELECT 1 FROM public.users u 
    WHERE u.id = faith_wall_posts.user_id 
    AND u.is_shadowbanned = TRUE
  )) 
  OR 
  -- Or if it's the current user's own post
  (auth.uid() = user_id)
);

-- 3. Update RLS on faith_wall_comments
DROP POLICY IF EXISTS "Select faith_wall_comments" ON public.faith_wall_comments;

CREATE POLICY "Select faith_wall_comments" ON public.faith_wall_comments
FOR SELECT
USING (
  (NOT EXISTS (
    SELECT 1 FROM public.users u 
    WHERE u.id = faith_wall_comments.user_id 
    AND u.is_shadowbanned = TRUE
  )) 
  OR 
  (auth.uid() = user_id)
);
