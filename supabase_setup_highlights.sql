-- ==========================================
-- SUPABASE BIBLE HIGHLIGHTS SETUP
-- ==========================================

CREATE TABLE IF NOT EXISTS public.bible_highlights (
  id uuid DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id uuid REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
  book text NOT NULL,
  chapter integer NOT NULL,
  verse integer NOT NULL,
  color_hex text NOT NULL,
  created_at timestamp with time zone DEFAULT timezone('utc'::text, now()),
  UNIQUE(user_id, book, chapter, verse)
);

ALTER TABLE public.bible_highlights ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Users can manage their own highlights" ON public.bible_highlights;
CREATE POLICY "Users can manage their own highlights" 
ON public.bible_highlights FOR ALL TO authenticated USING (auth.uid() = user_id);
