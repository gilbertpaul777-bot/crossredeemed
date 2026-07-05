-- ==========================================
-- SUPABASE NOTIFICATIONS & TRIGGERS SETUP
-- ==========================================

-- 1. Create the notifications table
CREATE TABLE IF NOT EXISTS public.notifications (
  id uuid DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id uuid REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL, -- The receiver
  actor_id uuid REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL, -- The person who did the action
  type text NOT NULL, -- 'post_like', 'post_comment', 'faith_wall_like'
  post_id uuid, -- Reference to the post or faith wall post
  is_read boolean DEFAULT false,
  created_at timestamp with time zone DEFAULT timezone('utc'::text, now())
);

ALTER TABLE public.notifications ENABLE ROW LEVEL SECURITY;

-- Users can only see and manage their own notifications
DROP POLICY IF EXISTS "Users can view their own notifications" ON public.notifications;
CREATE POLICY "Users can view their own notifications" 
ON public.notifications FOR ALL TO authenticated USING (auth.uid() = user_id);

-- ==========================================
-- TRIGGERS
-- ==========================================

-- Trigger 1: Video Like
CREATE OR REPLACE FUNCTION public.handle_post_like()
RETURNS TRIGGER AS $$
DECLARE
  post_author_id uuid;
BEGIN
  -- Get the author of the post
  SELECT user_id INTO post_author_id FROM public.posts WHERE id = NEW.post_id;
  
  -- Only notify if the liker is NOT the author
  IF NEW.user_id != post_author_id THEN
    INSERT INTO public.notifications (user_id, actor_id, type, post_id)
    VALUES (post_author_id, NEW.user_id, 'post_like', NEW.post_id);
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

DROP TRIGGER IF EXISTS on_post_like ON public.post_likes;
CREATE TRIGGER on_post_like
  AFTER INSERT ON public.post_likes
  FOR EACH ROW EXECUTE PROCEDURE public.handle_post_like();


-- Trigger 2: Video Comment
CREATE OR REPLACE FUNCTION public.handle_post_comment()
RETURNS TRIGGER AS $$
DECLARE
  post_author_id uuid;
BEGIN
  -- Get the author of the post
  SELECT user_id INTO post_author_id FROM public.posts WHERE id = NEW.post_id;
  
  -- Only notify if the commenter is NOT the author
  IF NEW.user_id != post_author_id THEN
    INSERT INTO public.notifications (user_id, actor_id, type, post_id)
    VALUES (post_author_id, NEW.user_id, 'post_comment', NEW.post_id);
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

DROP TRIGGER IF EXISTS on_post_comment ON public.post_comments;
CREATE TRIGGER on_post_comment
  AFTER INSERT ON public.post_comments
  FOR EACH ROW EXECUTE PROCEDURE public.handle_post_comment();


-- Trigger 3: Faith Wall Like
CREATE OR REPLACE FUNCTION public.handle_faith_wall_like()
RETURNS TRIGGER AS $$
DECLARE
  post_author_id uuid;
BEGIN
  -- Get the author of the faith wall post
  SELECT user_id INTO post_author_id FROM public.faith_wall_posts WHERE id = NEW.post_id;
  
  -- Only notify if the liker is NOT the author
  IF NEW.user_id != post_author_id THEN
    INSERT INTO public.notifications (user_id, actor_id, type, post_id)
    VALUES (post_author_id, NEW.user_id, 'faith_wall_like', NEW.post_id);
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

DROP TRIGGER IF EXISTS on_faith_wall_like ON public.faith_wall_likes;
CREATE TRIGGER on_faith_wall_like
  AFTER INSERT ON public.faith_wall_likes
  FOR EACH ROW EXECUTE PROCEDURE public.handle_faith_wall_like();
