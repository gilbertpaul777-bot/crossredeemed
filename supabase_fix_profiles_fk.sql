-- Fix: Add foreign key relationship from posts to profiles
-- This allows us to fetch the creator's username and avatar_url in the same query as the video post.

ALTER TABLE public.posts
ADD CONSTRAINT fk_posts_user_profile
FOREIGN KEY (user_id) REFERENCES public.profiles(id)
ON DELETE CASCADE;
