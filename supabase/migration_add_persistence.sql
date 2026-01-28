-- Migration: Supabase Persistence Güncellemeleri
-- Bu dosyayı Supabase SQL Editor'da çalıştırın

-- =====================================================
-- 1. daily_tasks tablosuna revealed_at ekle
-- =====================================================
ALTER TABLE daily_tasks 
ADD COLUMN IF NOT EXISTS revealed_at TIMESTAMPTZ;

-- Index ekle (sorgu performansı için)
CREATE INDEX IF NOT EXISTS idx_daily_tasks_revealed_at 
ON daily_tasks(revealed_at) 
WHERE revealed_at IS NOT NULL;

-- =====================================================
-- 2. users_profile tablosuna preferred_language ekle
-- =====================================================
ALTER TABLE users_profile 
ADD COLUMN IF NOT EXISTS preferred_language TEXT DEFAULT 'tr' 
CHECK (preferred_language IN ('tr', 'en'));

-- =====================================================
-- 3. sound_enabled zaten var, kontrol et
-- =====================================================
-- users_profile.sound_enabled kolonu zaten mevcut
-- Sadece kontrol için:
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns 
    WHERE table_name = 'users_profile' 
    AND column_name = 'sound_enabled'
  ) THEN
    ALTER TABLE users_profile 
    ADD COLUMN sound_enabled BOOLEAN DEFAULT TRUE;
  END IF;
END $$;

-- =====================================================
-- 4. Mevcut verileri güncelle (opsiyonel)
-- =====================================================
-- Eğer completed_at varsa, revealed_at'i de set et
UPDATE daily_tasks 
SET revealed_at = completed_at 
WHERE revealed_at IS NULL 
AND completed_at IS NOT NULL;

-- Mevcut kullanıcıların dil tercihini 'tr' yap (default)
UPDATE users_profile 
SET preferred_language = 'tr' 
WHERE preferred_language IS NULL;

-- =====================================================
-- 5. RLS Politikaları (zaten var, kontrol için)
-- =====================================================
-- daily_tasks için RLS zaten aktif
-- users_profile için RLS zaten aktif

-- =====================================================
-- KONTROL
-- =====================================================
-- Kolonların eklendiğini kontrol et:
SELECT 
  column_name, 
  data_type, 
  is_nullable,
  column_default
FROM information_schema.columns 
WHERE table_name = 'daily_tasks' 
AND column_name IN ('revealed_at')
UNION ALL
SELECT 
  column_name, 
  data_type, 
  is_nullable,
  column_default
FROM information_schema.columns 
WHERE table_name = 'users_profile' 
AND column_name IN ('preferred_language', 'sound_enabled');

