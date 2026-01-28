# 🚀 CleanLoop - Proje Yol Haritası

> **Son Güncelleme:** 2026-01-24  
> **Durum:** MVP Tamamlandı ✅ | Production Hazırlığı Devam Ediyor 🚧

---

## 📊 Genel Durum

### ✅ Tamamlanan Özellikler (MVP)
- [x] Flutter proje altyapısı
- [x] Supabase backend entegrasyonu
- [x] Authentication (Email, Google OAuth)
- [x] Onboarding akışı
- [x] Günlük görev sistemi (akıllı seçim)
- [x] Timer ve tamamlama ekranları
- [x] Streak ve takvim görünümü
- [x] Bildirimler (local + push)
- [x] Ayarlar ve profil yönetimi
- [x] Çoklu dil desteği (TR/EN)
- [x] Custom splash screen
- [x] Veri persistence (Supabase)
- [x] Offline cache desteği

### 🚧 Devam Eden / Yapılacaklar

---

## 🎯 Öncelik Sırasına Göre Yapılacaklar

### 🔴 YÜKSEK ÖNCELİK (Production İçin Gerekli)

#### 1. Apple OAuth Yapılandırması
**Durum:** ⏳ Bekliyor  
**Öncelik:** 🔴 Yüksek  
**Tahmini Süre:** 2-3 saat

**Görevler:**
- [ ] Apple Developer Console'da App ID oluştur
- [ ] Sign In with Apple capability ekle
- [ ] Services ID oluştur (Supabase için)
- [ ] Key oluştur ve .p8 dosyasını indir
- [ ] Supabase Dashboard → Authentication → Providers → Apple aktifleştir
- [ ] Xcode'da Sign In with Apple capability ekle
- [ ] Test et (gerçek iOS cihaz gerekli)

**Notlar:**
- Apple Developer hesabı gerekiyor ($99/yıl)
- iOS gerçek cihazda test edilmeli
- Rehber: `OAUTH_SETUP_GUIDE.md`

---

#### 2. Edge Functions Deploy Kontrolü
**Durum:** ⏳ Kontrol Edilmeli  
**Öncelik:** 🔴 Yüksek  
**Tahmini Süre:** 30 dakika (kontrol) / 1 saat (deploy)

**Kontrol:**
- [ ] Supabase Dashboard → Edge Functions sekmesini kontrol et
- [ ] `send-notifications` deploy edilmiş mi? (curl ile test)
- [ ] `profile`, `rooms`, `tasks` deploy edilmiş mi? (Opsiyonel)

**Eğer Deploy Edilmemişse:**
- [ ] Supabase Dashboard'dan manuel deploy (kolay yöntem)
- [ ] Veya Supabase CLI ile deploy
- [ ] Environment variables ayarla
- [ ] Test et

**Rehberler:**
- `EDGE_FUNCTIONS_CHECK.md` - Kontrol rehberi
- `DEPLOY_INSTRUCTIONS.md` - Deploy rehberi

**Notlar:**
- `send-notifications` muhtemelen deploy edilmiş (cron jobs çalışıyorsa)
- Diğer functions (`profile`, `rooms`, `tasks`) opsiyonel
- Şu an Supabase client doğrudan kullanılıyor (RLS ile güvenli)

---

#### 3. OneSignal Segment ve Otomatik Bildirimler
**Durum:** ⏳ Kısmen Tamamlandı  
**Öncelik:** 🔴 Yüksek  
**Tahmini Süre:** 1-2 saat

**Tamamlanan:**
- [x] OneSignal Flutter entegrasyonu
- [x] Tag güncelleme sistemi (Flutter tarafı)
- [x] Supabase Edge Function (send-notifications)
- [x] Cron jobs (pg_cron) kuruldu ve çalışıyor ✅

**Yapılacaklar:**
- [ ] OneSignal Dashboard'da segment'ler oluştur (analytics için):
  - `inactive_today` (completed_today != yes)
  - `streak_risk` (streak > 0 AND completed_today != yes)
  - `champions` (streak >= 7)
  - `dormant_users` (last_active 2+ gün önce)
  - `new_users` (total_completed < 3)
- [ ] Segment'leri test et
- [ ] iOS APNs sertifikası (gerçek cihaz için - opsiyonel)

**Notlar:**
- ✅ **Cron jobs zaten çalışıyor** (Supabase'de otomatik bildirimler aktif)
- OneSignal Dashboard segment'leri analytics için kullanılabilir
- Otomatik bildirimler Supabase cron jobs üzerinden çalışıyor
- **Rehber:** `ONESIGNAL_SEGMENTS_GUIDE.md` (detaylı adım adım)

---

### 🟡 ORTA ÖNCELİK (İyileştirmeler)

#### 4. Ses Dosyaları Ekleme
**Durum:** ⏳ Bekliyor  
**Öncelik:** 🟡 Orta  
**Tahmini Süre:** 1 saat

**Görevler:**
- [ ] `assets/sounds/` klasörüne MP3 dosyaları ekle:
  - [ ] `complete.mp3` - Görev tamamlama sesi
  - [ ] `celebration.mp3` - Kutlama sesi
  - [ ] `tap.mp3` - Buton tıklama sesi
  - [ ] `notification.mp3` - Bildirim sesi
- [ ] Ses dosyalarını test et
- [ ] Ses kalitesini optimize et

**Notlar:**
- Ses dosyaları olmadan da uygulama çalışır (HapticFeedback aktif)
- Opsiyonel özellik
- Ücretsiz ses kaynakları: Freesound.org, Zapsplat

---

#### 5. Provider'ları API Service'e Bağlama
**Durum:** ⏳ Bekliyor  
**Öncelik:** 🟡 Orta  
**Tahmini Süre:** 3-4 saat

**Görevler:**
- [ ] Edge Functions deploy sonrası yapılabilir
- [ ] `api_service.dart` kullanarak provider'ları güncelle
- [ ] Supabase client doğrudan kullanımını azalt
- [ ] Error handling iyileştir
- [ ] Retry logic ekle

**Notlar:**
- Şu an Supabase client doğrudan kullanılıyor (RLS ile güvenli)
- Edge Functions deploy sonrası yapılabilir
- Mevcut kod çalışıyor, refactoring

---

### 🟢 DÜŞÜK ÖNCELİK (Gelecek Özellikler)

#### 6. Analytics Entegrasyonu
**Durum:** ⏳ Planlama Aşamasında  
**Öncelik:** 🟢 Düşük  
**Tahmini Süre:** 4-5 saat

**Görevler:**
- [ ] Firebase Analytics entegrasyonu
- [ ] Kullanıcı event'leri tanımla:
  - Görev tamamlama
  - Streak kayıtları
  - Onboarding tamamlama
  - Ayar değişiklikleri
- [ ] Crash reporting (Firebase Crashlytics)
- [ ] Dashboard kurulumu

**Notlar:**
- MVP için gerekli değil
- Production sonrası eklenebilir

---

#### 7. App Store / Play Store Hazırlığı
**Durum:** ⏳ Planlama Aşamasında  
**Öncelik:** 🟢 Düşük  
**Tahmini Süre:** 8-10 saat

**Görevler:**
- [ ] App Store Connect hesabı
- [ ] Play Console hesabı
- [ ] Privacy policy hazırla
- [ ] Terms of service hazırla
- [ ] Screenshots hazırla (tüm cihazlar için)
- [ ] Marketing materyalleri
- [ ] App Store açıklaması (TR + EN)
- [ ] Play Store açıklaması (TR + EN)
- [ ] App icon ve splash screen finalize
- [ ] TestFlight / Internal testing

**Notlar:**
- Apple Developer hesabı: $99/yıl
- Google Play Developer hesabı: $25 (tek seferlik)
- Privacy policy zorunlu (GDPR)

---

## 📋 Tamamlanan Özellikler Detayı

### ✅ Faz 1: Proje Altyapısı
- Flutter projesi oluşturuldu
- Bağımlılıklar eklendi (Riverpod, go_router, Hive, Supabase, vb.)
- Tema ve renk paleti tanımlandı
- Klasör yapısı oluşturuldu

### ✅ Faz 2: Supabase Kurulumu
- Tablo şemaları oluşturuldu (schema.sql)
- RLS politikaları tanımlandı
- Seed data hazırlandı (25 görev)
- Edge Functions oluşturuldu (profile, rooms, tasks, send-notifications)

### ✅ Faz 3: Authentication
- Email ile kayıt/giriş
- Google OAuth entegrasyonu ✅
- Apple OAuth entegrasyonu (kod hazır, yapılandırma gerekiyor)
- Auth service oluşturuldu
- Login ekranı tasarlandı

### ✅ Faz 4: Onboarding
- Welcome ekranı (animasyonlu)
- Oda seçim ekranı
- Saat seçim ekranı
- Süre seçim ekranı
- Verileri kaydetme (Supabase)

### ✅ Faz 5: Görev Sistemi
- 25 görev tanımlandı
- Günlük görev üretme algoritması
- Aynı oda/tip ardışık gelmeme kuralı
- Kural gevşetme mantığı
- Europe/Istanbul timezone desteği

### ✅ Faz 6: Ana Ekran
- Selamlama ve streak badge
- Ev illustrasyonu (CustomPaint)
- Temizlik seviyesi göstergesi
- Animasyonlu görev alma popup'ı
- Bottom navigation (Home, Progress, Settings)
- İstatistik ve geçmiş tek tab'da birleştirildi

### ✅ Faz 7: Timer ve Tamamlama
- Countdown timer
- Start/Pause/Resume
- Progress ring
- Erken tamamlama seçeneği
- Basılı tut tamamlama
- Parçacık animasyonları

### ✅ Faz 8: Takvim ve Streak
- Son 14 gün grid görünümü
- Tamamlanan günler işaretleme
- Current streak hesaplama
- Best streak hesaplama

### ✅ Faz 9: Bildirimler
- flutter_local_notifications entegrasyonu
- OneSignal push notifications entegrasyonu
- İzin isteme akışı
- Günlük görev bildirimi zamanlama
- Otomatik bildirimler (cron jobs)
- Tag güncelleme sistemi

### ✅ Faz 10: Ayarlar
- Oda düzenleme
- Süre değiştirme
- Bildirim toggle'ları
- Ses aç/kapa
- Dil seçimi (TR/EN)
- Verileri sıfırla

### ✅ Faz 11: UI/UX İyileştirmeleri
- App Icons (iOS & Android)
- Custom Splash Screen (veri yükleme ile)
- Ses efektleri servisi + HapticFeedback
- Offline cache desteği
- Çoklu dil desteği (i18n)

### ✅ Faz 12: Veri Persistence
- Görev açılma durumu (revealed_at)
- Ses ayarı (sound_enabled)
- Dil tercihi (preferred_language)
- Tüm veriler Supabase'de saklanıyor

---

## 🐛 Bilinen Sorunlar

### Çözülen Sorunlar ✅
- ✅ Anonim girişte görev tamamlanmıyor → Düzeltildi
- ✅ Çıkış yapınca oda bilgileri kayboluyor → Düzeltildi
- ✅ Progress'teki settings ikonu çalışmıyor → Düzeltildi
- ✅ Google sign-in "not supported" hatası → Düzeltildi
- ✅ Home ekranında flicker → Custom splash screen ile düzeltildi
- ✅ Görev açılma durumu kayboluyor → Supabase persistence ile düzeltildi

### Aktif Sorunlar
- Yok (şu an için)

---

## 📁 Dosya Yapısı

```
lib/
├── core/
│   ├── constants/
│   ├── providers/
│   │   └── locale_provider.dart
│   ├── router/
│   ├── services/
│   │   ├── api_service.dart
│   │   ├── auth_service.dart
│   │   ├── cache_service.dart
│   │   ├── local_storage_service.dart
│   │   ├── notification_service.dart
│   │   ├── onesignal_service.dart
│   │   ├── sound_service.dart
│   │   └── supabase_service.dart
│   └── theme/
├── features/
│   ├── auth/
│   ├── calendar/
│   ├── home/
│   ├── onboarding/
│   ├── settings/
│   └── timer/
├── l10n/
│   ├── app_en.arb
│   ├── app_tr.arb
│   └── generated/
└── shared/

supabase/
├── functions/
│   ├── profile/
│   ├── rooms/
│   ├── tasks/
│   └── send-notifications/
├── schema.sql
├── seed.sql
├── migration_add_persistence.sql
└── cron_jobs_simple.sql
```

---

## 🔒 Güvenlik Notları

1. **API Key Koruması**
   - Supabase Anon Key mobil uygulamada kullanılabilir (RLS ile korunuyor)
   - Service Role Key SADECE Edge Functions'da kullanılmalı

2. **RLS (Row Level Security)**
   - Tüm tablolarda aktif
   - Kullanıcı sadece kendi verisini görebilir

3. **Input Validation**
   - Tüm API'lerde input validation var
   - SQL injection koruması (Supabase client)

4. **Auth Token**
   - JWT token ile kimlik doğrulama
   - Token süresi dolunca otomatik yenileme

---

## 📚 Dokümantasyon

- `PLAN_UPDATE.md` - Detaylı güncelleme notları
- `plan.txt` - Orijinal MVP planı
- `OAUTH_SETUP_GUIDE.md` - OAuth yapılandırma rehberi
- `NOTIFICATION_PLAN.md` - Bildirim sistemi planı
- `SUPABASE_PERSISTENCE_PLAN.md` - Veri persistence planı
- `SPLASH_SCREEN_PLAN.md` - Splash screen planı
- `SETUP_GUIDE.md` - Kurulum rehberi
- `TEST_CHECKLIST.md` - Test checklist'i
- `DEPLOY_INSTRUCTIONS.md` - Deploy talimatları

---

## 🚀 Hızlı Başlangıç

```bash
# Bağımlılıkları yükle
flutter pub get

# Localization dosyalarını oluştur
flutter gen-l10n

# iOS Simulator'da çalıştır
flutter run -d <simulator_id>

# Android Emulator'da çalıştır
flutter run -d <emulator_id>

# Release build (Android)
flutter build apk --release

# Release build (iOS)
flutter build ios --release
```

---

## 📅 Sonraki Adımlar (Öncelik Sırasına Göre)

1. 🔴 **Apple OAuth yapılandır** (2-3 saat)
2. 🔴 **Edge Functions deploy** (1 saat)
3. 🔴 **OneSignal segment'leri oluştur** (2-3 saat)
4. 🟡 **Ses dosyaları ekle** (1 saat)
5. 🟡 **Provider'ları API service'e bağla** (3-4 saat)
6. 🟢 **Analytics entegrasyonu** (4-5 saat)
7. 🟢 **App Store hazırlığı** (8-10 saat)

---

## 📊 İlerleme Durumu

**MVP Tamamlanma:** %95 ✅  
**Production Hazırlık:** %60 🚧

**Tamamlanan Özellikler:** 12/12 ✅  
**Bekleyen Özellikler:** 7 (3 yüksek öncelik, 2 orta öncelik, 2 düşük öncelik)

---

*Son güncelleme: 2026-01-24*  
*Custom splash screen ve veri persistence tamamlandı ✅*

