-- Migration: Configure pg_cron to expire pending bookings every 5 minutes
-- Requirements: 5.5
-- The expire-bookings Edge Function cancels pending bookings older than 10 minutes
-- and releases their slots back to "available".

-- Enable required extensions
CREATE EXTENSION IF NOT EXISTS pg_cron;
CREATE EXTENSION IF NOT EXISTS pg_net;

-- Schedule the expire-bookings Edge Function to run every 5 minutes via pg_net
-- pg_net makes an HTTP POST to the Supabase Edge Function endpoint
SELECT cron.schedule(
  'expire-pending-bookings',   -- job name
  '*/5 * * * *',               -- every 5 minutes
  $$
  SELECT net.http_post(
    url := current_setting('app.settings.supabase_url') || '/functions/v1/expire-bookings',
    headers := jsonb_build_object(
      'Content-Type', 'application/json',
      'Authorization', 'Bearer ' || current_setting('app.settings.service_role_key')
    ),
    body := '{}'::jsonb
  ) AS request_id;
  $$
);
