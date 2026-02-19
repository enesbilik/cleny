-- CleanLoop MVP Database Schema
-- Bu dosyayı Supabase SQL Editor'da çalıştırın

-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- =====================================================
-- TABLES
-- =====================================================

-- Users Profile
CREATE TABLE IF NOT EXISTS users_profile (
    user_id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ,
    preferred_minutes INTEGER DEFAULT 15 CHECK (preferred_minutes IN (15)),
    available_start TIME DEFAULT '19:00',
    available_end TIME DEFAULT '22:00',
    notifications_enabled BOOLEAN DEFAULT TRUE,
    motivation_enabled BOOLEAN DEFAULT TRUE,
    sound_enabled BOOLEAN DEFAULT TRUE,
    timezone TEXT DEFAULT 'Europe/Istanbul'
);

-- Rooms
CREATE TABLE IF NOT EXISTS rooms (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    name TEXT NOT NULL,
    sort_order INTEGER DEFAULT 0,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ
);

-- Tasks Catalog (Seed data - read only for users)
CREATE TABLE IF NOT EXISTS tasks_catalog (
    id TEXT PRIMARY KEY,
    title TEXT NOT NULL,
    description TEXT,
    estimated_minutes INTEGER NOT NULL DEFAULT 15,
    task_type TEXT NOT NULL,
    room_scope TEXT NOT NULL DEFAULT 'ROOM_REQUIRED' CHECK (room_scope IN ('ROOM_REQUIRED', 'ROOM_OPTIONAL')),
    difficulty INTEGER DEFAULT 1 CHECK (difficulty BETWEEN 1 AND 3),
    audio_key TEXT,
    icon_key TEXT DEFAULT 'cleaning'
);

-- Daily Tasks
CREATE TABLE IF NOT EXISTS daily_tasks (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    date DATE NOT NULL,
    task_catalog_id TEXT NOT NULL REFERENCES tasks_catalog(id),
    room_id UUID REFERENCES rooms(id) ON DELETE SET NULL,
    status TEXT NOT NULL DEFAULT 'assigned' CHECK (status IN ('assigned', 'completed', 'skipped')),
    assigned_at TIMESTAMPTZ DEFAULT NOW(),
    completed_at TIMESTAMPTZ,
    completion_method TEXT,
    duration_seconds INTEGER,
    
    -- Her kullanıcı için günde tek görev
    UNIQUE(user_id, date)
);

-- Cleaning Tips (Temizlik İpuçları)
CREATE TABLE IF NOT EXISTS cleaning_tips (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    tip_text TEXT NOT NULL,
    category TEXT, -- Örn: 'bulaşık', 'perde', 'ince_temizlik', 'genel'
    day_of_week INTEGER CHECK (day_of_week BETWEEN 1 AND 7), -- (eski kolon, artık kullanılmıyor)
    tip_date DATE, -- Hangi tarih için gösterilmeli (NULL ise genel)
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ,
    is_active BOOLEAN DEFAULT TRUE
);
ALTER TABLE cleaning_tips ADD COLUMN IF NOT EXISTS tip_date DATE;

-- =====================================================
-- INDEXES
-- =====================================================

CREATE INDEX IF NOT EXISTS idx_rooms_user_id ON rooms(user_id);
CREATE INDEX IF NOT EXISTS idx_daily_tasks_user_id ON daily_tasks(user_id);
CREATE INDEX IF NOT EXISTS idx_daily_tasks_date ON daily_tasks(date);
CREATE INDEX IF NOT EXISTS idx_daily_tasks_user_date ON daily_tasks(user_id, date);
CREATE INDEX IF NOT EXISTS idx_cleaning_tips_active ON cleaning_tips(is_active) WHERE is_active = TRUE;
CREATE INDEX IF NOT EXISTS idx_cleaning_tips_tip_date ON cleaning_tips(tip_date);

-- =====================================================
-- ROW LEVEL SECURITY (RLS)
-- =====================================================

-- Enable RLS
ALTER TABLE users_profile ENABLE ROW LEVEL SECURITY;
ALTER TABLE rooms ENABLE ROW LEVEL SECURITY;
ALTER TABLE tasks_catalog ENABLE ROW LEVEL SECURITY;
ALTER TABLE daily_tasks ENABLE ROW LEVEL SECURITY;
ALTER TABLE cleaning_tips ENABLE ROW LEVEL SECURITY;

-- Users Profile Policies
DROP POLICY IF EXISTS "Users can view own profile" ON users_profile;
CREATE POLICY "Users can view own profile" ON users_profile
    FOR SELECT USING (auth.uid() = user_id);

DROP POLICY IF EXISTS "Users can insert own profile" ON users_profile;
CREATE POLICY "Users can insert own profile" ON users_profile
    FOR INSERT WITH CHECK (auth.uid() = user_id);

DROP POLICY IF EXISTS "Users can update own profile" ON users_profile;
CREATE POLICY "Users can update own profile" ON users_profile
    FOR UPDATE USING (auth.uid() = user_id);

DROP POLICY IF EXISTS "Users can delete own profile" ON users_profile;
CREATE POLICY "Users can delete own profile" ON users_profile
    FOR DELETE USING (auth.uid() = user_id);

-- Rooms Policies
DROP POLICY IF EXISTS "Users can view own rooms" ON rooms;
CREATE POLICY "Users can view own rooms" ON rooms
    FOR SELECT USING (auth.uid() = user_id);

DROP POLICY IF EXISTS "Users can insert own rooms" ON rooms;
CREATE POLICY "Users can insert own rooms" ON rooms
    FOR INSERT WITH CHECK (auth.uid() = user_id);

DROP POLICY IF EXISTS "Users can update own rooms" ON rooms;
CREATE POLICY "Users can update own rooms" ON rooms
    FOR UPDATE USING (auth.uid() = user_id);

DROP POLICY IF EXISTS "Users can delete own rooms" ON rooms;
CREATE POLICY "Users can delete own rooms" ON rooms
    FOR DELETE USING (auth.uid() = user_id);

-- Tasks Catalog Policies (read-only for all authenticated users)
DROP POLICY IF EXISTS "Anyone can view tasks catalog" ON tasks_catalog;
CREATE POLICY "Anyone can view tasks catalog" ON tasks_catalog
    FOR SELECT USING (true);

-- Cleaning Tips Policies (read-only for all authenticated users)
DROP POLICY IF EXISTS "Anyone can view active cleaning tips" ON cleaning_tips;
CREATE POLICY "Anyone can view active cleaning tips" ON cleaning_tips
    FOR SELECT USING (is_active = TRUE);

-- Daily Tasks Policies
DROP POLICY IF EXISTS "Users can view own daily tasks" ON daily_tasks;
CREATE POLICY "Users can view own daily tasks" ON daily_tasks
    FOR SELECT USING (auth.uid() = user_id);

DROP POLICY IF EXISTS "Users can insert own daily tasks" ON daily_tasks;
CREATE POLICY "Users can insert own daily tasks" ON daily_tasks
    FOR INSERT WITH CHECK (auth.uid() = user_id);

DROP POLICY IF EXISTS "Users can update own daily tasks" ON daily_tasks;
CREATE POLICY "Users can update own daily tasks" ON daily_tasks
    FOR UPDATE USING (auth.uid() = user_id);

DROP POLICY IF EXISTS "Users can delete own daily tasks" ON daily_tasks;
CREATE POLICY "Users can delete own daily tasks" ON daily_tasks
    FOR DELETE USING (auth.uid() = user_id);

-- =====================================================
-- FUNCTIONS
-- =====================================================

-- Updated at trigger function
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Apply updated_at trigger
DROP TRIGGER IF EXISTS update_users_profile_updated_at ON users_profile;
CREATE TRIGGER update_users_profile_updated_at
    BEFORE UPDATE ON users_profile
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

DROP TRIGGER IF EXISTS update_rooms_updated_at ON rooms;
CREATE TRIGGER update_rooms_updated_at
    BEFORE UPDATE ON rooms
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

DROP TRIGGER IF EXISTS update_cleaning_tips_updated_at ON cleaning_tips;
CREATE TRIGGER update_cleaning_tips_updated_at
    BEFORE UPDATE ON cleaning_tips
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- =====================================================
-- SEED DATA
-- =====================================================

-- Tarih bazlı temizlik ipuçları (her gün farklı ipucu)
-- Bu veriler MCP/migrations ile eklenir; script yeniden çalıştırıldığında çakışma yaratmaz.
-- Üretim ortamında ayrı bir migration veya admin paneli ile güncellenir.

