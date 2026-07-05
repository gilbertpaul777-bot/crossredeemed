-- ==========================================
-- SUPABASE BIBLE USER DATA SETUP
-- ==========================================

-- 1. Bible Bookmarks Table
CREATE TABLE IF NOT EXISTS public.bible_bookmarks (
  id uuid DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id uuid REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
  book text NOT NULL,
  chapter integer NOT NULL,
  verse integer NOT NULL,
  text text NOT NULL,
  created_at timestamp with time zone DEFAULT timezone('utc'::text, now())
);

ALTER TABLE public.bible_bookmarks ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Users can manage their own bookmarks" ON public.bible_bookmarks;
CREATE POLICY "Users can manage their own bookmarks" 
ON public.bible_bookmarks FOR ALL TO authenticated USING (auth.uid() = user_id);

-- 2. Bible Notes Table
CREATE TABLE IF NOT EXISTS public.bible_notes (
  id uuid DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id uuid REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
  book text NOT NULL,
  chapter integer NOT NULL,
  verse integer NOT NULL,
  verse_text text NOT NULL,
  note_text text NOT NULL,
  created_at timestamp with time zone DEFAULT timezone('utc'::text, now())
);

ALTER TABLE public.bible_notes ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Users can manage their own notes" ON public.bible_notes;
CREATE POLICY "Users can manage their own notes" 
ON public.bible_notes FOR ALL TO authenticated USING (auth.uid() = user_id);

-- 3. Bible History Table
CREATE TABLE IF NOT EXISTS public.bible_history (
  id uuid DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id uuid REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
  book text NOT NULL,
  chapter integer NOT NULL,
  last_read_at timestamp with time zone DEFAULT timezone('utc'::text, now()),
  UNIQUE(user_id, book, chapter)
);

ALTER TABLE public.bible_history ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Users can manage their own history" ON public.bible_history;
CREATE POLICY "Users can manage their own history" 
ON public.bible_history FOR ALL TO authenticated USING (auth.uid() = user_id);
