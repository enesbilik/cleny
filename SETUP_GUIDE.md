# CleanLoop MVP - Kurulum Rehberi

Bu rehber, projeyi çalıştırmak için gerekli tüm adımları içerir.

---

## 1. Flutter Bağımlılıkları

```bash
cd /path/to/cleny
flutter pub get
```

---

## 2. Environment Dosyası

`.env` dosyası oluşturun:

```bash
cp .env.example .env
```

`.env` içeriği:

```env
SUPABASE_URL=https://your-project.supabase.co
SUPABASE_ANON_KEY=your-anon-key
```

---

## 3. Supabase Yapılandırması

### 3.1 Tablo Şeması

Supabase SQL Editor'da `supabase/schema.sql` dosyasını çalıştırın.

### 3.2 Seed Data

Supabase SQL Editor'da `supabase/seed.sql` dosyasını çalıştırın.

### 3.3 Edge Functions Deploy

```bash
# Supabase CLI kurulu değilse
npm install -g supabase

# Giriş yap
supabase login

# Projeyi bağla
supabase link --project-ref your-project-ref

# Functions deploy
supabase functions deploy profile
supabase functions deploy rooms
supabase functions deploy tasks
```

### 3.4 Auth Providers Ayarları

#### Email Auth
1. Supabase Dashboard → Authentication → Providers
2. Email provider'ı aktif edin
3. "Confirm email" seçeneğini tercihinize göre ayarlayın

#### Google OAuth
1. [Google Cloud Console](https://console.cloud.google.com/) → APIs & Services → Credentials
2. OAuth 2.0 Client ID oluşturun (Web application)
3. Authorized redirect URIs ekleyin:
   - `https://your-project.supabase.co/auth/v1/callback`
4. Client ID ve Secret'ı kopyalayın
5. Supabase Dashboard → Authentication → Providers → Google
6. Client ID ve Secret'ı yapıştırın
7. Enable'ı aktif edin

#### Apple OAuth
1. [Apple Developer](https://developer.apple.com/) → Certificates, Identifiers & Profiles
2. Services ID oluşturun
3. Sign in with Apple'ı yapılandırın
4. Return URLs ekleyin:
   - `https://your-project.supabase.co/auth/v1/callback`
5. Supabase Dashboard → Authentication → Providers → Apple
6. Service ID ve Secret Key'i yapıştırın

#### Anonymous Auth (Opsiyonel)
1. Supabase Dashboard → Authentication → Providers
2. "Allow anonymous sign-ins" seçeneğini aktif edin

### 3.5 URL Configuration

Supabase Dashboard → Authentication → URL Configuration

- Site URL: `com.cleanloop.cleanloop://login-callback`
- Redirect URLs (Whitelist):
  - `com.cleanloop.cleanloop://login-callback`
  - `http://localhost:3000/auth/callback` (development)

---

## 4. iOS Yapılandırması

### 4.1 Bundle Identifier

`ios/Runner.xcodeproj/project.pbxproj` dosyasında Bundle Identifier'ı kontrol edin:

```
PRODUCT_BUNDLE_IDENTIFIER = com.cleanloop.cleanloop;
```

### 4.2 URL Scheme (Zaten eklendi)

`ios/Runner/Info.plist` içinde:

```xml
<key>CFBundleURLTypes</key>
<array>
    <dict>
        <key>CFBundleTypeRole</key>
        <string>Editor</string>
        <key>CFBundleURLSchemes</key>
        <array>
            <string>com.cleanloop.cleanloop</string>
        </array>
    </dict>
</array>
```

---

## 5. Android Yapılandırması

### 5.1 Deep Link (Zaten eklendi)

`android/app/src/main/AndroidManifest.xml` içinde intent-filter zaten ekli.

### 5.2 Google Sign-In (Android)

Google OAuth için SHA-1 certificate fingerprint gerekli:

```bash
# Debug
keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android -keypass android

# Release (kendi keystore'unuz)
keytool -list -v -keystore your-release-key.keystore -alias your-alias
```

SHA-1'i Google Cloud Console'daki OAuth Client'a ekleyin.

---

## 6. Çalıştırma

### iOS Simulator

```bash
flutter run -d iPhone
```

### Android Emulator

```bash
flutter run -d emulator-5554
```

### Fiziksel Cihaz

```bash
flutter run
```

---

## 7. Test

Test checklist için `TEST_CHECKLIST.md` dosyasını inceleyin.

---

## Sorun Giderme

### Edge Functions 401 Unauthorized

- `.env` dosyasındaki `SUPABASE_ANON_KEY` doğru mu kontrol edin
- Auth token'ın geçerli olduğundan emin olun

### OAuth Redirect Çalışmıyor

- URL schemes iOS ve Android'de doğru yapılandırılmış mı kontrol edin
- Supabase Dashboard'da Redirect URLs whitelist'e eklenmiş mi kontrol edin

### Google Sign-In Hatası

- SHA-1 fingerprint Google Cloud Console'a eklenmiş mi kontrol edin
- Package name doğru mu kontrol edin

### Apple Sign-In Hatası

- iOS cihaz veya simulator'da Sign in with Apple capability eklenmiş mi kontrol edin
- Bundle ID Apple Developer hesabındaki ile eşleşiyor mu kontrol edin

---

*Son güncelleme: 2026-01-23*

