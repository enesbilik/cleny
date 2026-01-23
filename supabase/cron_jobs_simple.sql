-- CleanLoop Cron Jobs (Basitleştirilmiş)
-- Bu dosyayı Supabase SQL Editor'da çalıştırın
-- ÖNCE: Settings → API → service_role key'i kopyala ve aşağıdaki YOUR_SERVICE_ROLE_KEY yerine yapıştır

-- Gerekli extension'ları aktifleştir
CREATE EXTENSION IF NOT EXISTS pg_cron;
CREATE EXTENSION IF NOT EXISTS pg_net;

-- Mevcut job'ları temizle (eğer varsa)
DO $$
BEGIN
  -- Job varsa unschedule et, yoksa devam et
  IF EXISTS (SELECT 1 FROM cron.job WHERE jobname = 'morning_notification') THEN
    PERFORM cron.unschedule('morning_notification');
  END IF;
  IF EXISTS (SELECT 1 FROM cron.job WHERE jobname = 'afternoon_notification') THEN
    PERFORM cron.unschedule('afternoon_notification');
  END IF;
  IF EXISTS (SELECT 1 FROM cron.job WHERE jobname = 'evening_notification') THEN
    PERFORM cron.unschedule('evening_notification');
  END IF;
  IF EXISTS (SELECT 1 FROM cron.job WHERE jobname = 'late_notification') THEN
    PERFORM cron.unschedule('late_notification');
  END IF;
END $$;

-- ⚠️ Service Role Key: eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImJnb2tnZWZ0aHdtYmlzZGRuaWtpIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc2OTE2MzI5MiwiZXhwIjoyMDg0NzM5MjkyfQ.IebvUgK1YZJg-mp81Rn0ewdTe6Dsuys71puaWInLl5o

-- 1. Sabah Motivasyon - 09:00 Istanbul = 06:00 UTC
SELECT cron.schedule(
  'morning_notification',
  '0 6 * * *',  -- Her gün 06:00 UTC (09:00 Istanbul)
  $$
  SELECT net.http_post(
    url := 'https://bgokgefthwmbisddniki.supabase.co/functions/v1/send-notifications?type=morning',
    headers := jsonb_build_object(
      'Content-Type', 'application/json',
      'Authorization', 'Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImJnb2tnZWZ0aHdtYmlzZGRuaWtpIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc2OTE2MzI5MiwiZXhwIjoyMDg0NzM5MjkyfQ.IebvUgK1YZJg-mp81Rn0ewdTe6Dsuys71puaWInLl5o'
    )
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
    headers := jsonb_build_object(
      'Content-Type', 'application/json',
      'Authorization', 'Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImJnb2tnZWZ0aHdtYmlzZGRuaWtpIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc2OTE2MzI5MiwiZXhwIjoyMDg0NzM5MjkyfQ.IebvUgK1YZJg-mp81Rn0ewdTe6Dsuys71puaWInLl5o'
    )
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
    headers := jsonb_build_object(
      'Content-Type', 'application/json',
      'Authorization', 'Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImJnb2tnZWZ0aHdtYmlzZGRuaWtpIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc2OTE2MzI5MiwiZXhwIjoyMDg0NzM5MjkyfQ.IebvUgK1YZJg-mp81Rn0ewdTe6Dsuys71puaWInLl5o'
    )
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
    headers := jsonb_build_object(
      'Content-Type', 'application/json',
      'Authorization', 'Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImJnb2tnZWZ0aHdtYmlzZGRuaWtpIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc2OTE2MzI5MiwiZXhwIjoyMDg0NzM5MjkyfQ.IebvUgK1YZJg-mp81Rn0ewdTe6Dsuys71puaWInLl5o'
    )
  );
  $$
);

-- Job'ları listele
SELECT * FROM cron.job;

-- =====================================================
-- TEST
-- =====================================================
-- Manuel test için:
-- SELECT net.http_post(
--   url := 'https://bgokgefthwmbisddniki.supabase.co/functions/v1/send-notifications?type=morning',
--   headers := jsonb_build_object(
--     'Content-Type', 'application/json',
--     'Authorization', 'Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImJnb2tnZWZ0aHdtYmlzZGRuaWtpIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc2OTE2MzI5MiwiZXhwIjoyMDg0NzM5MjkyfQ.IebvUgK1YZJg-mp81Rn0ewdTe6Dsuys71puaWInLl5o'
--   )
-- );

-- Job geçmişini görmek için:
-- SELECT * FROM cron.job_run_details ORDER BY start_time DESC LIMIT 10;

