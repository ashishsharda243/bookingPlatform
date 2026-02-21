-- Migration: Schedule booking reminder notifications 1 hour before slot start.
-- Uses pg_cron + pg_net to call the send-notification Edge Function.
-- Requirements: 8.2

-- Ensure required extensions are available (idempotent)
CREATE EXTENSION IF NOT EXISTS pg_cron;
CREATE EXTENSION IF NOT EXISTS pg_net;

-- -------------------------------------------------------------------------
-- Function: send_booking_reminders
-- Finds confirmed bookings whose slot starts within the next hour and
-- that have not yet received a reminder, then calls the send-notification
-- Edge Function for each.
-- -------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION send_booking_reminders()
RETURNS void
LANGUAGE plpgsql
AS $$
DECLARE
  rec RECORD;
  base_url TEXT;
  service_key TEXT;
BEGIN
  base_url := current_setting('app.settings.supabase_url');
  service_key := current_setting('app.settings.service_role_key');

  FOR rec IN
    SELECT
      b.id AS booking_id,
      b.user_id,
      h.name AS hall_name,
      s.date,
      s.start_time
    FROM bookings b
    JOIN slots s ON s.id = b.slot_id
    JOIN halls h ON h.id = b.hall_id
    WHERE b.booking_status = 'confirmed'
      AND b.reminder_sent IS NOT TRUE
      AND (s.date + s.start_time) BETWEEN now() AND (now() + interval '1 hour')
  LOOP
    -- Call the send-notification Edge Function via pg_net
    PERFORM net.http_post(
      url := base_url || '/functions/v1/send-notification',
      headers := jsonb_build_object(
        'Content-Type', 'application/json',
        'Authorization', 'Bearer ' || service_key
      ),
      body := jsonb_build_object(
        'user_id', rec.user_id,
        'title', 'Booking Reminder',
        'body', format('Your booking at %s starts at %s today!', rec.hall_name, rec.start_time::text),
        'data', jsonb_build_object('booking_id', rec.booking_id, 'type', 'reminder')
      )
    );

    -- Mark reminder as sent so we don't send duplicates
    UPDATE bookings SET reminder_sent = TRUE WHERE id = rec.booking_id;
  END LOOP;
END;
$$;

-- Add reminder_sent column to bookings if it doesn't exist
ALTER TABLE bookings ADD COLUMN IF NOT EXISTS reminder_sent BOOLEAN DEFAULT FALSE;

-- Schedule the reminder function to run every 15 minutes
SELECT cron.schedule(
  'send-booking-reminders',
  '*/15 * * * *',
  $cron$
  SELECT send_booking_reminders();
  $cron$
);
