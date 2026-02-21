-- Add google_map_link column to halls table
ALTER TABLE halls 
ADD COLUMN IF NOT EXISTS google_map_link TEXT;

-- Verify the column was added (optional, for manual checks)
-- SELECT column_name, data_type 
-- FROM information_schema.columns 
-- WHERE table_name = 'halls' AND column_name = 'google_map_link';
