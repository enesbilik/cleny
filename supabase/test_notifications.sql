-- Test Bildirimleri - Manuel Çalıştırma
-- Bu dosyayı Supabase SQL Editor'da çalıştırın

-- =====================================================
-- ADIM 1: Bugünün görevini "assigned" yap (test için)
-- =====================================================
-- ÖNCE: Kendi user_id'ni bul
-- SELECT id FROM auth.users WHERE email = 'senin@email.com';

-- Sonra bugünün görevini "assigned" yap (test için)
UPDATE daily_tasks 
SET 
  status = 'assigned',
  completed_at = NULL,
  completion_method = NULL
WHERE 
  user_id = (SELECT id FROM auth.users LIMIT 1)  -- İlk kullanıcıyı al (kendi ID'ni yazabilirsin)
  AND date = CURRENT_DATE;

-- Kontrol et
SELECT 
  id,
  user_id,
  date,
  status,
  completed_at
FROM daily_tasks 
WHERE date = CURRENT_DATE;

-- =====================================================
-- ADIM 2: Job'ları manuel çalıştır
-- =====================================================

-- 1. Sabah bildirimi (morning)
SELECT net.http_post(
  url := 'https://bgokgefthwmbisddniki.supabase.co/functions/v1/send-notifications?type=morning',
  headers := jsonb_build_object(
    'Content-Type', 'application/json',
    'Authorization', 'Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImJnb2tnZWZ0aHdtYmlzZGRuaWtpIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc2OTE2MzI5MiwiZXhwIjoyMDg0NzM5MjkyfQ.IebvUgK1YZJg-mp81Rn0ewdTe6Dsuys71puaWInLl5o'
  )
) as morning_request_id;

-- 2. Öğleden sonra bildirimi (reminder)
SELECT net.http_post(
  url := 'https://bgokgefthwmbisddniki.supabase.co/functions/v1/send-notifications?type=reminder',
  headers := jsonb_build_object(
    'Content-Type', 'application/json',
    'Authorization', 'Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImJnb2tnZWZ0aHdtYmlzZGRuaWtpIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc2OTE2MzI5MiwiZXhwIjoyMDg0NzM5MjkyfQ.IebvUgK1YZJg-mp81Rn0ewdTe6Dsuys71puaWInLl5o'
  )
) as reminder_request_id;

-- 3. Akşam bildirimi (evening)
SELECT net.http_post(
  url := 'https://bgokgefthwmbisddniki.supabase.co/functions/v1/send-notifications?type=evening',
  headers := jsonb_build_object(
    'Content-Type', 'application/json',
    'Authorization', 'Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImJnb2tnZWZ0aHdtYmlzZGRuaWtpIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc2OTE2MzI5MiwiZXhwIjoyMDg0NzM5MjkyfQ.IebvUgK1YZJg-mp81Rn0ewdTe6Dsuys71puaWInLl5o'
  )
) as evening_request_id;

-- 4. Son dakika bildirimi (late)
SELECT net.http_post(
  url := 'https://bgokgefthwmbisddniki.supabase.co/functions/v1/send-notifications?type=late',
  headers := jsonb_build_object(
    'Content-Type', 'application/json',
    'Authorization', 'Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImJnb2tnZWZ0aHdtYmlzZGRuaWtpIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc2OTE2MzI5MiwiZXhwIjoyMDg0NzM5MjkyfQ.IebvUgK1YZJg-mp81Rn0ewdTe6Dsuys71puaWInLl5o'
  )
) as late_request_id;

-- =====================================================
-- ADIM 3: Response'ları görüntüle
-- =====================================================
-- Son 4 response'u gör
SELECT 
  request_id,
  status_code,
  content::text as response_body,
  created
FROM net.http_response_queue
ORDER BY created DESC
LIMIT 4;

-- =====================================================
-- NOT: Bildirim gelmezse kontrol et
-- =====================================================
-- 1. OneSignal'da kullanıcı kayıtlı mı?
-- 2. Android emulator açık mı?
-- 3. Uygulama açık mı? (arka planda olabilir)

