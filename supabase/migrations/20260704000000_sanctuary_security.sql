-- Phase 1: Protecting The Sanctuary

-- Create user_public_keys table for End-to-End Encryption
CREATE TABLE IF NOT EXISTS public.user_public_keys (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
    public_key TEXT NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL,
    UNIQUE(user_id)
);

-- Enable RLS
ALTER TABLE public.user_public_keys ENABLE ROW LEVEL SECURITY;

-- Allow users to read any public key
CREATE POLICY "Public keys are viewable by everyone" ON public.user_public_keys
    FOR SELECT USING (true);

-- Allow users to insert their own public key
CREATE POLICY "Users can insert their own public key" ON public.user_public_keys
    FOR INSERT WITH CHECK (auth.uid() = user_id);

-- Allow users to update their own public key
CREATE POLICY "Users can update their own public key" ON public.user_public_keys
    FOR UPDATE USING (auth.uid() = user_id);

-- Add expires_at column to messages for Auto-Deletion
ALTER TABLE public.messages ADD COLUMN IF NOT EXISTS expires_at TIMESTAMP WITH TIME ZONE;

-- Note: A pg_cron job should be set up via Supabase dashboard or SQL to periodically delete expired messages:
-- SELECT cron.schedule('delete-expired-messages', '0 * * * *', $$
--    DELETE FROM messages WHERE expires_at < NOW();
-- $$);
