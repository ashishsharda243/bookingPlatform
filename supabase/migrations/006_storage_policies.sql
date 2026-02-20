-- ============================================================
-- Storage Policies for Hall Images
-- ============================================================

-- 1. Create the storage bucket if it doesn't exist
INSERT INTO storage.buckets (id, name, public)
VALUES ('hall_images', 'hall_images', true)
ON CONFLICT (id) DO NOTHING;

-- 2. Enable RLS on objects (standard practice, though enabled by default usually)
ALTER TABLE storage.objects ENABLE ROW LEVEL SECURITY;

-- 3. Policy: Public Read Access
-- Anyone can view images from the 'hall_images' bucket
DROP POLICY IF EXISTS "Public Access" ON storage.objects;
CREATE POLICY "Public Access"
ON storage.objects FOR SELECT
USING ( bucket_id = 'hall_images' );

-- 4. Policy: Authenticated Upload Access
-- Only authenticated users (owners/admins) can upload images
DROP POLICY IF EXISTS "Authenticated Upload" ON storage.objects;
CREATE POLICY "Authenticated Upload"
ON storage.objects FOR INSERT
WITH CHECK (
    bucket_id = 'hall_images'
    AND auth.role() = 'authenticated'
);

-- 5. Policy: Owner Delete Access
-- Users can updates/delete their own uploaded files
DROP POLICY IF EXISTS "Owner Delete" ON storage.objects;
CREATE POLICY "Owner Delete"
ON storage.objects FOR DELETE
USING (
    bucket_id = 'hall_images'
    AND auth.uid() = owner
);

DROP POLICY IF EXISTS "Owner Update" ON storage.objects;
CREATE POLICY "Owner Update"
ON storage.objects FOR UPDATE
USING (
    bucket_id = 'hall_images'
    AND auth.uid() = owner
);
