-- Create the direct_messages table
CREATE TABLE public.direct_messages (
  id uuid DEFAULT gen_random_uuid() PRIMARY KEY,
  sender_id uuid REFERENCES auth.users(id) ON DELETE CASCADE,
  receiver_id uuid REFERENCES auth.users(id) ON DELETE CASCADE,
  content text NOT NULL,
  created_at timestamp with time zone DEFAULT timezone('utc'::text, now()) NOT NULL,
  is_read boolean DEFAULT false
);

-- Enable Row Level Security (RLS)
ALTER TABLE public.direct_messages ENABLE ROW LEVEL SECURITY;

-- Create Policies
-- Users can read messages where they are the sender OR the receiver
CREATE POLICY "Users can read their own messages"
ON public.direct_messages
FOR SELECT
USING (auth.uid() = sender_id OR auth.uid() = receiver_id);

-- Users can only insert messages where they are the sender
CREATE POLICY "Users can send messages"
ON public.direct_messages
FOR INSERT
TO authenticated
WITH CHECK (auth.uid() = sender_id);

-- Users can update messages where they are the receiver (to mark as read)
CREATE POLICY "Users can mark messages as read"
ON public.direct_messages
FOR UPDATE
TO authenticated
USING (auth.uid() = receiver_id);
