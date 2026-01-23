-- CleanLoop Cron Jobs
-- Bu dosyayı Supabase SQL Editor'da çalıştırın

-- Gerekli extension'ları aktifleştir
CREATE EXTENSION IF NOT EXISTS pg_cron;
CREATE EXTENSION IF NOT EXISTS pg_net;

-- Mevcut job'ları temizle (varsa)
SELECT cron.unschedule('morning_notification');
SELECT cron.unschedule('afternoon_notification');
SELECT cron.unschedule('evening_notification');
SELECT cron.unschedule('late_notification');

-- =====================================================
-- CRON JOBS (Istanbul Timezone: UTC+3)
-- =====================================================

-- 1. Sabah Motivasyon - 09:00 Istanbul = 06:00 UTC
SELECT cron.schedule(
  'morning_notification',
  '0 6 * * *',  -- Her gün 06:00 UTC (09:00 Istanbul)
  $$
  SELECT net.http_post(
    url := 'https://bgokgefthwmbisddniki.supabase.co/functions/v1/send-notifications?type=morning',
    headers := '{"Authorization": "Bearer ' || current_setting('app.settings.service_role_key') || '"}'::jsonb
  );
  $$
);

-- 2. Öğleden Sonra Hatırlatma - 14:00 Istanbul = 11:00 UTC
SELECT cron.schedule(
  'afternoon_notification',
  '0 11 * * *',  -- Her gün 11:00 UTC (14:00 Istanbul)
  $$
  SELECT net.http_post(
    url := 'https://bgokgefthwmbisddniki.supabase.co/functions/v1/send-notifications?type=reminder',
    headers := '{"Authorization": "Bearer ' || current_setting('app.settings.service_role_key') || '"}'::jsonb
  );
  $$
);

-- 3. Akşam Uyarı - 19:00 Istanbul = 16:00 UTC
SELECT cron.schedule(
  'evening_notification',
  '0 16 * * *',  -- Her gün 16:00 UTC (19:00 Istanbul)
  $$
  SELECT net.http_post(
    url := 'https://bgokgefthwmbisddniki.supabase.co/functions/v1/send-notifications?type=evening',
    headers := '{"Authorization": "Bearer ' || current_setting('app.settings.service_role_key') || '"}'::jsonb
  );
  $$
);

-- 4. Son Dakika Uyarı - 21:00 Istanbul = 18:00 UTC
SELECT cron.schedule(
  'late_notification',
  '0 18 * * *',  -- Her gün 18:00 UTC (21:00 Istanbul)
  $$
  SELECT net.http_post(
    url := 'https://bgokgefthwmbisddniki.supabase.co/functions/v1/send-notifications?type=late',
    headers := '{"Authorization": "Bearer ' || current_setting('app.settings.service_role_key') || '"}'::jsonb
  );
  $$
);

-- Job'ları listele
SELECT * FROM cron.job;

-- =====================================================
-- NOTLAR
-- =====================================================
-- 
-- pg_cron UTC timezone kullanır!
-- Istanbul = UTC + 3 saat
-- 
-- Job'u test etmek için:
-- SELECT net.http_post(
--   url := 'https://bgokgefthwmbisddniki.supabase.co/functions/v1/send-notifications?type=morning',
--   headers := '{"Authorization": "Bearer YOUR_SERVICE_ROLE_KEY"}'::jsonb
-- );
--
-- Job geçmişini görmek için:
-- SELECT * FROM cron.job_run_details ORDER BY start_time DESC LIMIT 10;

