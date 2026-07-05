-- Create the storage bucket for avatars if it doesn't exist
insert into storage.buckets (id, name, public)
values ('avatars', 'avatars', true)
on conflict (id) do nothing;

-- Set up RLS policies on the avatars bucket

-- Allow public read access to all avatars
create policy "Public Access"
on storage.objects for select
using ( bucket_id = 'avatars' );

-- Allow authenticated users to upload avatars
create policy "Users can upload their own avatar"
on storage.objects for insert
with check ( bucket_id = 'avatars' AND auth.role() = 'authenticated' );

-- Allow authenticated users to update their avatars
create policy "Users can update their own avatar"
on storage.objects for update
using ( bucket_id = 'avatars' AND auth.role() = 'authenticated' );

-- Allow authenticated users to delete their avatars
create policy "Users can delete their own avatar"
on storage.objects for delete
using ( bucket_id = 'avatars' AND auth.role() = 'authenticated' );
