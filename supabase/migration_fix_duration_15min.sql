-- Migration: Tüm görev sürelerini 15 dakikaya güncelle
-- Supabase SQL Editor'da çalıştırın

-- 1. tasks_catalog: tüm estimated_minutes'ı 15 yap
UPDATE tasks_catalog SET estimated_minutes = 15;

-- 2. users_profile: preferred_minutes constraint'i güncelle (10'dan 15'e)
-- Önce mevcut CHECK constraint'i kaldır, sonra yeni ekle
ALTER TABLE users_profile DROP CONSTRAINT IF EXISTS users_profile_preferred_minutes_check;
ALTER TABLE users_profile ALTER COLUMN preferred_minutes SET DEFAULT 15;
ALTER TABLE users_profile ADD CONSTRAINT users_profile_preferred_minutes_check CHECK (preferred_minutes IN (15));

-- 3. Mevcut kullanıcıların preferred_minutes'ını da 15 yap
UPDATE users_profile SET preferred_minutes = 15 WHERE preferred_minutes = 10;

-- 4. tasks_catalog DEFAULT'u güncelle
ALTER TABLE tasks_catalog ALTER COLUMN estimated_minutes SET DEFAULT 15;

-- Verify
SELECT id, title, estimated_minutes FROM tasks_catalog ORDER BY id;
SELECT user_id, preferred_minutes FROM users_profile;
