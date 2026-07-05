-- ==========================================
-- SUPABASE TRUST & SAFETY SCHEMA SETUP
-- ==========================================

-- 1. Create the user_blocks table
CREATE TABLE IF NOT EXISTS public.user_blocks (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  blocker_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
  blocked_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()),
  UNIQUE(blocker_id, blocked_id)
);

-- Enable RLS on user_blocks
ALTER TABLE public.user_blocks ENABLE ROW LEVEL SECURITY;

-- Blockers can see who they blocked
DROP POLICY IF EXISTS "Users can see their own blocks" ON public.user_blocks;
CREATE POLICY "Users can see their own blocks" 
ON public.user_blocks FOR SELECT USING (auth.uid() = blocker_id);

-- Users can insert blocks
DROP POLICY IF EXISTS "Users can insert their own blocks" ON public.user_blocks;
CREATE POLICY "Users can insert their own blocks" 
ON public.user_blocks FOR INSERT TO authenticated WITH CHECK (auth.uid() = blocker_id);

-- Users can delete their own blocks (unblock)
DROP POLICY IF EXISTS "Users can delete their own blocks" ON public.user_blocks;
CREATE POLICY "Users can delete their own blocks" 
ON public.user_blocks FOR DELETE USING (auth.uid() = blocker_id);


-- 2. Create the reports table
CREATE TABLE IF NOT EXISTS public.reports (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  reporter_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
  reported_user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
  reported_post_id UUID REFERENCES public.posts(id) ON DELETE CASCADE,
  reason TEXT NOT NULL,
  details TEXT,
  status TEXT DEFAULT 'pending', -- pending, reviewed, dismissed, action_taken
  created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now())
);

-- Enable RLS on reports
ALTER TABLE public.reports ENABLE ROW LEVEL SECURITY;

-- Users can insert reports
DROP POLICY IF EXISTS "Users can insert reports" ON public.reports;
CREATE POLICY "Users can insert reports" 
ON public.reports FOR INSERT TO authenticated WITH CHECK (auth.uid() = reporter_id);

-- Only admins/service role can view reports (or the reporter)
DROP POLICY IF EXISTS "Users can view their own reports" ON public.reports;
CREATE POLICY "Users can view their own reports" 
ON public.reports FOR SELECT USING (auth.uid() = reporter_id);
