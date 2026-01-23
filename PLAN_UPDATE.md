# CleanLoop MVP - Plan Güncellemesi

## Tamamlanan Özellikler ✅

### Faz 1: Proje Altyapısı ✅
- [x] Flutter projesi oluşturuldu
- [x] Bağımlılıklar eklendi (Riverpod, go_router, Hive, Supabase, vb.)
- [x] Tema ve renk paleti tanımlandı
- [x] Klasör yapısı oluşturuldu

### Faz 2: Supabase Kurulumu ✅
- [x] Tablo şemaları oluşturuldu (schema.sql)
- [x] RLS politikaları tanımlandı
- [x] Seed data hazırlandı (25 görev)
- [x] Edge Functions oluşturuldu (profile, rooms, tasks)

### Faz 3: Authentication ✅
- [x] Email ile kayıt/giriş
- [x] Google OAuth entegrasyonu (kod hazır, yapılandırma gerekiyor)
- [x] Apple OAuth entegrasyonu (kod hazır, yapılandırma gerekiyor)
- [x] Apple login sadece iOS'ta görünüyor (Platform.isIOS kontrolü)
- [x] Auth service oluşturuldu
- [x] Login ekranı tasarlandı
- [x] "Kayıt olmadan devam et" seçeneği kaldırıldı
- [x] Giriş başarılı snackbar'ı kaldırıldı

### Faz 4: Onboarding ✅
- [x] Welcome ekranı (animasyonlu)
- [x] Oda seçim ekranı
- [x] Saat seçim ekranı
- [x] Süre seçim ekranı
- [x] Verileri kaydetme
- [x] Oda bilgileri Supabase'e kaydediliyor (bug düzeltildi)

### Faz 5: Görev Kataloğu ✅
- [x] 25 görev tanımlandı
- [x] Görev tipleri: vacuum, wipe, tidy, trash, kitchen, laundry, bath, dust
- [x] Room scope: ROOM_REQUIRED, ROOM_OPTIONAL
- [x] Seed SQL hazırlandı

### Faz 6: Akıllı Görev Seçimi ✅
- [x] Günlük görev üretme algoritması
- [x] Aynı oda/tip ardışık gelmeme kuralı
- [x] Kural gevşetme mantığı
- [x] Europe/Istanbul timezone desteği

### Faz 7: Ana Ekran ✅
- [x] Selamlama ve streak badge
- [x] Ev illustrasyonu (CustomPaint)
- [x] Temizlik seviyesi göstergesi
- [x] Animasyonlu görev alma popup'ı
- [x] Bottom navigation (Home, Progress, Settings tab)
- [x] İstatistik ve geçmiş tek tab'da birleştirildi
- [x] Tamamlanan görevler listesi

### Faz 8: Timer Ekranı ✅
- [x] Countdown timer
- [x] Start/Pause/Resume
- [x] Progress ring
- [x] Erken tamamlama seçeneği

### Faz 9: Tamamlama Ekranı ✅
- [x] Parçacık animasyonları
- [x] Check ikonu animasyonu
- [x] Başarı mesajı
- [x] Ana ekrana dönüş

### Faz 10: Basılı Tut Tamamlama ✅
- [x] Hold to complete butonu
- [x] Progress animasyonu
- [x] Sabun kabarcıkları efekti

### Faz 11: Takvim ve Streak ✅
- [x] Son 14 gün grid görünümü
- [x] Tamamlanan günler işaretleme
- [x] Current streak hesaplama
- [x] Best streak hesaplama

### Faz 12: Bildirimler ✅
- [x] flutter_local_notifications entegrasyonu
- [x] İzin isteme akışı
- [x] Günlük görev bildirimi zamanlama
- [x] Motivasyon bildirimi
- [x] **YENİ:** Bildirim saati değiştirme özelliği

### Faz 13: Ayarlar ✅
- [x] Oda düzenleme
- [x] Süre değiştirme
- [x] Bildirim toggle'ları
- [x] Ses aç/kapa
- [x] Verileri sıfırla
- [x] **YENİ:** Bildirim saati değiştirme (bottom sheet)
- [x] **YENİ:** Dil seçimi (Türkçe/İngilizce)
- [x] Settings artık tab olarak çalışıyor (ayrı route değil)

### Faz 14: Backend (API Layer) ✅
- [x] Edge Functions altyapısı
- [x] CORS handling
- [x] Auth middleware
- [x] Input validation
- [x] Profile API
- [x] Rooms API
- [x] Tasks API

### Faz 15: API Service (Flutter) ✅
- [x] HTTP client wrapper
- [x] Auth header yönetimi
- [x] Response parsing
- [x] Error handling

### Faz 16: UI/UX İyileştirmeleri ✅
- [x] App Icons (iOS & Android)
- [x] Splash Screen
- [x] Ses efektleri servisi + HapticFeedback
- [x] Offline cache desteği
- [x] Progress sayfasındaki gereksiz > ikonu kaldırıldı

### Faz 17: Çoklu Dil Desteği (i18n) ✅
- [x] flutter_localizations entegrasyonu
- [x] ARB dosyaları (lib/l10n/)
- [x] Türkçe çeviriler (app_tr.arb)
- [x] İngilizce çeviriler (app_en.arb)
- [x] Locale provider (dil tercihini saklıyor)
- [x] Ayarlarda dil değiştirme UI'ı

---

## Eksik/Bekleyen Özellikler ⏳

### 🔴 Yüksek Öncelik (Manuel Yapılandırma Gerekiyor)

#### 1. Google OAuth Yapılandırması
- [ ] Google Cloud Console'da proje oluştur
- [ ] OAuth Consent Screen ayarla
- [ ] iOS Client ID oluştur (Bundle ID: `com.cleanloop.cleanloop`)
- [ ] Android Client ID oluştur (SHA-1 fingerprint ile)
- [ ] Web Client ID oluştur (Supabase redirect URL ile)
- [ ] Supabase Dashboard → Authentication → Providers → Google aktifleştir
- [ ] iOS `Info.plist`'te `GIDClientID` güncelle
- **Rehber:** `OAUTH_SETUP_GUIDE.md`

#### 2. Apple OAuth Yapılandırması
- [ ] Apple Developer Console'da App ID oluştur
- [ ] Sign In with Apple capability ekle
- [ ] Services ID oluştur (Supabase için)
- [ ] Key oluştur ve .p8 dosyasını indir
- [ ] Supabase Dashboard → Authentication → Providers → Apple aktifleştir
- [ ] Xcode'da Sign In with Apple capability ekle
- **Rehber:** `OAUTH_SETUP_GUIDE.md`

#### 3. Edge Functions Deploy
- [ ] Supabase CLI ile login: `supabase login`
- [ ] Fonksiyonları deploy et: `supabase functions deploy`
- [ ] Environment variables ayarla (Dashboard'dan)

#### 4. Ses Dosyaları Ekleme
`assets/sounds/` klasörüne aşağıdaki MP3 dosyalarını ekle:
- [ ] `complete.mp3` - Görev tamamlama sesi
- [ ] `celebration.mp3` - Kutlama sesi
- [ ] `tap.mp3` - Buton tıklama sesi
- [ ] `notification.mp3` - Bildirim sesi
> Not: Ses dosyaları olmadan da uygulama çalışır (HapticFeedback aktif)

### 🟡 Orta Öncelik

#### 5. Push Notifications (FCM)
- [ ] Firebase projesi oluştur
- [ ] Firebase Cloud Messaging entegrasyonu
- [ ] iOS APNs sertifikası
- [ ] Android configuration
- [ ] Backend'den bildirim gönderme

#### 6. Provider'ları API'ye Bağlama
- [ ] Edge Functions deploy sonrası yapılabilir
- [ ] Şu an Supabase client doğrudan kullanılıyor (RLS ile güvenli)

#### 7. UI Stringleri Lokalize Etme ✅
- [x] Tüm hardcoded Türkçe stringler ARB dosyalarına taşındı
- [x] `AppLocalizations.of(context)!.xxx` kullanıldı
- [x] login_screen.dart lokalize edildi
- [x] home_screen.dart lokalize edildi
- [x] settings_screen.dart lokalize edildi
- [x] timer_screen.dart lokalize edildi
- [x] completion_screen.dart lokalize edildi
- [x] welcome_screen.dart lokalize edildi
- [x] room_setup_screen.dart lokalize edildi
- [x] task_reveal_popup.dart lokalize edildi

### 🟢 Düşük Öncelik

#### 8. Analytics
- [ ] Firebase Analytics entegrasyonu
- [ ] Kullanıcı event'leri (görev tamamlama, streak, vb.)
- [ ] Crash reporting (Firebase Crashlytics)

#### 9. App Store Hazırlığı
- [ ] App Store Connect hesabı
- [ ] Play Console hesabı
- [ ] Privacy policy
- [ ] Screenshots ve marketing materyalleri
- [ ] App Store açıklaması

---

## Bug Fixes Log 🐛

| Tarih | Bug | Çözüm |
|-------|-----|-------|
| 2026-01-23 | Anonim girişte görev tamamlanmıyor | completeTask() sadece gerekli alanları güncelliyor |
| 2026-01-23 | Çıkış yapınca oda bilgileri kayboluyor | onboarding_provider mevcut user ID kullanıyor |
| 2026-01-23 | Progress'teki settings ikonu çalışmıyor | İkon kaldırıldı, settings tab olarak çalışıyor |
| 2026-01-23 | Google sign-in "not supported" hatası | google_sign_in paketi + native entegrasyon |
| 2026-01-23 | Email kayıt sonrası feedback yok | Snackbar eklendi (sonra başarılı için kaldırıldı) |

---

## Güvenlik Notları 🔒

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

## Dosya Yapısı

```
lib/
├── core/
│   ├── constants/
│   ├── providers/
│   │   └── locale_provider.dart     # YENİ - Dil yönetimi
│   ├── router/
│   ├── services/
│   │   ├── api_service.dart
│   │   ├── auth_service.dart
│   │   ├── cache_service.dart
│   │   ├── local_storage_service.dart
│   │   ├── notification_service.dart
│   │   ├── sound_service.dart       # HapticFeedback desteği eklendi
│   │   └── supabase_service.dart
│   └── theme/
├── features/
│   ├── auth/
│   │   └── presentation/
│   │       └── screens/
│   │           └── login_screen.dart
│   ├── home/
│   │   └── presentation/
│   │       ├── screens/
│   │       │   └── home_screen.dart  # Settings tab entegre
│   │       └── widgets/
│   │           └── task_reveal_popup.dart
│   ├── onboarding/
│   ├── settings/
│   │   └── presentation/
│   │       └── screens/
│   │           └── settings_screen.dart  # Dil seçimi + bildirim saati
│   └── timer/
├── l10n/                            # YENİ
│   ├── app_en.arb
│   ├── app_tr.arb
│   └── generated/
│       ├── app_localizations.dart
│       ├── app_localizations_en.dart
│       └── app_localizations_tr.dart
└── shared/

assets/
├── icon/
│   ├── app_icon.png
│   ├── app_icon_foreground.png
│   └── splash_icon.png
├── sounds/                          # Ses dosyaları eklenmeli
│   └── README.md
├── images/
├── animations/
└── data/

supabase/
├── functions/
│   ├── _shared/
│   ├── profile/
│   ├── rooms/
│   └── tasks/
├── schema.sql
└── seed.sql
```

---

## Hızlı Başlangıç Komutları

```bash
# Bağımlılıkları yükle
flutter pub get

# Localization dosyalarını oluştur
flutter gen-l10n

# iOS Simulator'da çalıştır
flutter run -d <simulator_id>

# Release build (Android)
flutter build apk --release

# Release build (iOS)
flutter build ios --release
```

---

## Sonraki Adımlar (Öncelik Sırasına Göre)

1. ✅ `flutter pub get` çalıştır
2. 🔴 Google OAuth yapılandır (OAUTH_SETUP_GUIDE.md)
3. 🔴 Apple OAuth yapılandır (OAUTH_SETUP_GUIDE.md)
4. 🔴 Edge Functions'ları Supabase'e deploy et
5. 🟡 Ses dosyalarını ekle
6. 🟡 UI stringlerini lokalize et (AppLocalizations kullan)
7. 🟢 TEST_CHECKLIST.md'yi takip ederek test et
8. 🟢 App Store / Play Store için hazırla

---

*Son güncelleme: 2026-01-23*
*Eklenenler: Bildirim saati değiştirme, Türkçe/İngilizce dil desteği, Bug fixes, Snackbar kaldırıldı*
