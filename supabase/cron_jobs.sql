-- CleanLoop Cron Jobs — 6 Bildirim Tipi
-- Supabase SQL Editor'da çalıştırın.

CREATE EXTENSION IF NOT EXISTS pg_cron;
CREATE EXTENSION IF NOT EXISTS pg_net;

-- Mevcut job'ları temizle
SELECT cron.unschedule('morning_notification');
SELECT cron.unschedule('afternoon_notification');
SELECT cron.unschedule('evening_notification');
SELECT cron.unschedule('late_notification');
SELECT cron.unschedule('daily_reminder');
SELECT cron.unschedule('milestone_check');
SELECT cron.unschedule('dormant_check');
SELECT cron.unschedule('inactive_today');
SELECT cron.unschedule('streak_risk');
SELECT cron.unschedule('weekly_summary');

-- =====================================================
-- ANON KEY (verify_jwt=false olduğu için yeterli)
-- =====================================================
DO $$ DECLARE anon_key TEXT := 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImJnb2tnZWZ0aHdtYmlzZGRuaWtpIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjkxNjMyOTIsImV4cCI6MjA4NDczOTI5Mn0.uHrzHSkAI4J_IeojELHakHSL2Dgj6oLTHTBbdfEI7_o';
BEGIN NULL; END $$;

-- 1. Günlük hatırlatıcı — herkese — 09:00 Istanbul (06:00 UTC)
SELECT cron.schedule(
  'daily_reminder',
  '0 6 * * *',
  $$
  SELECT net.http_post(
    url := 'https://bgokgefthwmbisddniki.supabase.co/functions/v1/send-notifications?type=daily',
    headers := '{"Content-Type":"application/json","Authorization":"Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImJnb2tnZWZ0aHdtYmlzZGRuaWtpIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjkxNjMyOTIsImV4cCI6MjA4NDczOTI5Mn0.uHrzHSkAI4J_IeojELHakHSL2Dgj6oLTHTBbdfEI7_o"}'::jsonb,
    body := '{}'::jsonb
  );
  $$
);

-- 2. Streak milestone — bugün tamamlayıp 7/14/30/... gün olanlara — 10:00 Istanbul (07:00 UTC)
SELECT cron.schedule(
  'milestone_check',
  '0 7 * * *',
  $$
  SELECT net.http_post(
    url := 'https://bgokgefthwmbisddniki.supabase.co/functions/v1/send-notifications?type=milestone',
    headers := '{"Content-Type":"application/json","Authorization":"Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImJnb2tnZWZ0aHdtYmlzZGRuaWtpIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjkxNjMyOTIsImV4cCI6MjA4NDczOTI5Mn0.uHrzHSkAI4J_IeojELHakHSL2Dgj6oLTHTBbdfEI7_o"}'::jsonb,
    body := '{}'::jsonb
  );
  $$
);

-- 3. Yeniden kazanım (dormant) — 3+ gündür gelmeyenlere — 12:00 Istanbul (09:00 UTC)
SELECT cron.schedule(
  'dormant_check',
  '0 9 * * *',
  $$
  SELECT net.http_post(
    url := 'https://bgokgefthwmbisddniki.supabase.co/functions/v1/send-notifications?type=dormant',
    headers := '{"Content-Type":"application/json","Authorization":"Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImJnb2tnZWZ0aHdtYmlzZGRuaWtpIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjkxNjMyOTIsImV4cCI6MjA4NDczOTI5Mn0.uHrzHSkAI4J_IeojELHakHSL2Dgj6oLTHTBbdfEI7_o"}'::jsonb,
    body := '{}'::jsonb
  );
  $$
);

-- 4. Uygulamayı açmadın — bugün hiç girmeyenlere — 14:00 Istanbul (11:00 UTC)
SELECT cron.schedule(
  'inactive_today',
  '0 11 * * *',
  $$
  SELECT net.http_post(
    url := 'https://bgokgefthwmbisddniki.supabase.co/functions/v1/send-notifications?type=inactive',
    headers := '{"Content-Type":"application/json","Authorization":"Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImJnb2tnZWZ0aHdtYmlzZGRuaWtpIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjkxNjMyOTIsImV4cCI6MjA4NDczOTI5Mn0.uHrzHSkAI4J_IeojELHakHSL2Dgj6oLTHTBbdfEI7_o"}'::jsonb,
    body := '{}'::jsonb
  );
  $$
);

-- 5. Streak tehlikede — dün yaptı ama bugün yapmadı — 21:00 Istanbul (18:00 UTC)
SELECT cron.schedule(
  'streak_risk',
  '0 18 * * *',
  $$
  SELECT net.http_post(
    url := 'https://bgokgefthwmbisddniki.supabase.co/functions/v1/send-notifications?type=streak_risk',
    headers := '{"Content-Type":"application/json","Authorization":"Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImJnb2tnZWZ0aHdtYmlzZGRuaWtpIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjkxNjMyOTIsImV4cCI6MjA4NDczOTI5Mn0.uHrzHSkAI4J_IeojELHakHSL2Dgj6oLTHTBbdfEI7_o"}'::jsonb,
    body := '{}'::jsonb
  );
  $$
);

-- 6. Haftalık özet — herkese Pazartesi sabahı — 09:00 Istanbul (06:00 UTC)
SELECT cron.schedule(
  'weekly_summary',
  '0 6 * * 1',
  $$
  SELECT net.http_post(
    url := 'https://bgokgefthwmbisddniki.supabase.co/functions/v1/send-notifications?type=weekly',
    headers := '{"Content-Type":"application/json","Authorization":"Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImJnb2tnZWZ0aHdtYmlzZGRuaWtpIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjkxNjMyOTIsImV4cCI6MjA4NDczOTI5Mn0.uHrzHSkAI4J_IeojELHakHSL2Dgj6oLTHTBbdfEI7_o"}'::jsonb,
    body := '{}'::jsonb
  );
  $$
);

-- Sonucu listele
SELECT jobid, jobname, schedule, active FROM cron.job ORDER BY jobid;
