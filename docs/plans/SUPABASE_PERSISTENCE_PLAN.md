# 🔄 Supabase Persistence Plan

## 🐛 Tespit Edilen Sorunlar

### 1. **isTaskRevealed** - Görev Açılma Durumu ❌
**Sorun:** Görev açıldıktan sonra uygulama kapanıp açıldığında tekrar "görevi gör" diyor.

**Çözüm:** `daily_tasks` tablosuna `revealed_at` kolonu ekle ve Supabase'den oku.

---

### 2. **soundEnabled** - Ses Ayarı ⚠️
**Sorun:** `users_profile.sound_enabled` kolonu var ama kullanılmıyor. Local storage'dan okunuyor.

**Çözüm:** `soundEnabled`'i Supabase'den oku ve güncelle.

---

### 3. **preferred_language** - Dil Tercihi ❌
**Sorun:** Dil tercihi sadece local storage'da tutuluyor, Supabase'de yok.

**Çözüm:** `users_profile` tablosuna `preferred_language` kolonu ekle.

---

## 📋 Uygulama Planı

### Faz 1: Database Schema Güncellemesi

#### 1.1. `daily_tasks` tablosuna `revealed_at` ekle
```sql
ALTER TABLE daily_tasks 
ADD COLUMN IF NOT EXISTS revealed_at TIMESTAMPTZ;
```

#### 1.2. `users_profile` tablosuna `preferred_language` ekle
```sql
ALTER TABLE users_profile 
ADD COLUMN IF NOT EXISTS preferred_language TEXT DEFAULT 'tr' 
CHECK (preferred_language IN ('tr', 'en'));
```

---

### Faz 2: Flutter Kod Güncellemeleri

#### 2.1. `DailyTask` Model Güncelleme
- `revealedAt` field ekle
- `fromJson` ve `toJson` güncelle

#### 2.2. `UserProfile` Model Güncelleme
- `preferredLanguage` field ekle
- `fromJson` ve `toJson` güncelle

#### 2.3. `HomeProvider` Güncelleme
- `revealTask()` fonksiyonunu Supabase'e kaydet
- `_loadFromNetwork()` fonksiyonunda `revealed_at`'i oku
- `isTaskRevealed` state'ini `revealed_at != null` olarak belirle

#### 2.4. `SettingsProvider` Güncelleme
- `soundEnabled`'i Supabase'den oku (local storage yerine)
- `setSoundEnabled()` fonksiyonunu Supabase'e kaydet

#### 2.5. `LocaleProvider` Güncelleme
- `preferred_language`'i Supabase'den oku
- `setLocale()` fonksiyonunu Supabase'e kaydet

---

### Faz 3: Migration ve Test

#### 3.1. Supabase Migration
- SQL migration dosyası oluştur
- Supabase SQL Editor'da çalıştır

#### 3.2. Test Senaryoları
1. ✅ Görev aç → Uygulamayı kapat → Aç → Görev açık görünmeli
2. ✅ Ses ayarını değiştir → Uygulamayı kapat → Aç → Ayar korunmalı
3. ✅ Dili değiştir → Uygulamayı kapat → Aç → Dil korunmalı

---

## 📊 Veri Akışı

### Önceki Durum (Hatalı):
```
Görev Aç → Memory'de isTaskRevealed = true
Uygulama Kapanır → State kaybolur
Uygulama Açılır → isTaskRevealed = false (default)
```

### Yeni Durum (Doğru):
```
Görev Aç → Supabase'de revealed_at = NOW()
Uygulama Kapanır → Veri Supabase'de
Uygulama Açılır → revealed_at != null → isTaskRevealed = true
```

---

## 🎯 Öncelik Sırası

1. **🔴 Yüksek:** `revealed_at` (Görev açılma durumu)
2. **🟡 Orta:** `sound_enabled` (Ses ayarı)
3. **🟢 Düşük:** `preferred_language` (Dil tercihi)

---

*Son güncelleme: 2026-01-23*

