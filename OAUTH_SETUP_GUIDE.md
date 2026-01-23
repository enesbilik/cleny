# OAuth Kurulum Rehberi (Google & Apple Sign-In)

Bu rehber, CleanLoop uygulaması için Google ve Apple ile oturum açma özelliklerini aktifleştirmeni sağlayacak.

---

## 📱 BÖLÜM 1: Google Sign-In Kurulumu

### Adım 1.1: Google Cloud Console'da Proje Oluştur

1. https://console.cloud.google.com adresine git
2. Üst menüden proje seçiciye tıkla → **"New Project"**
3. Proje adı: `CleanLoop` → **Create**
4. Yeni projeyi seç

### Adım 1.2: OAuth Consent Screen Ayarla

1. Sol menüden **"APIs & Services"** → **"OAuth consent screen"**
2. User Type: **External** → **Create**
3. Formu doldur:
   - App name: `CleanLoop`
   - User support email: `senin@email.com`
   - Developer contact: `senin@email.com`
4. **Save and Continue** → Scopes kısmını geç → **Save and Continue**
5. Test users ekle (kendi emailini ekle) → **Save and Continue**

### Adım 1.3: iOS için OAuth Client ID Oluştur

1. **"APIs & Services"** → **"Credentials"** → **"+ CREATE CREDENTIALS"** → **"OAuth client ID"**
2. Application type: **iOS**
3. Name: `CleanLoop iOS`
4. Bundle ID: `com.cleanloop.cleanloop` (pubspec.yaml'daki ile aynı olmalı)
5. **Create** → **iOS Client ID**'yi kopyala

### Adım 1.4: Android için OAuth Client ID Oluştur

1. **"+ CREATE CREDENTIALS"** → **"OAuth client ID"**
2. Application type: **Android**
3. Name: `CleanLoop Android`
4. Package name: `com.cleanloop.cleanloop`
5. SHA-1 certificate fingerprint almak için terminalde:
   ```bash
   cd /Users/enesbilik/Documents/repo/cleny/android
   ./gradlew signingReport
   ```
   Debug SHA-1 değerini kopyala ve yapıştır.
6. **Create** → **Android Client ID**'yi kopyala

### Adım 1.5: Web için OAuth Client ID Oluştur (Supabase için gerekli)

1. **"+ CREATE CREDENTIALS"** → **"OAuth client ID"**
2. Application type: **Web application**
3. Name: `CleanLoop Web`
4. Authorized redirect URIs ekle:
   ```
   https://YOUR_SUPABASE_PROJECT_REF.supabase.co/auth/v1/callback
   ```
   > ⚠️ `YOUR_SUPABASE_PROJECT_REF` kısmını Supabase proje URL'inden al
5. **Create**
6. **Client ID** ve **Client Secret**'ı kopyala (Supabase'e ekleyeceğiz)

### Adım 1.6: Supabase'de Google Provider'ı Aktifleştir

1. https://supabase.com/dashboard adresine git
2. Projenizi seç
3. **Authentication** → **Providers** → **Google**
4. **Enable Sign in with Google** toggle'ını aç
5. **Client ID**: Web OAuth Client ID'yi yapıştır
6. **Client Secret**: Web OAuth Client Secret'ı yapıştır
7. **Save**

### Adım 1.7: Flutter'da Google Sign-In Yapılandır

**iOS (Info.plist)** - Zaten yapılandırıldı, sadece Client ID'yi güncelle:

```xml
<!-- /Users/enesbilik/Documents/repo/cleny/ios/Runner/Info.plist -->
<key>GIDClientID</key>
<string>IOS_CLIENT_ID_BURAYA</string>
```

**iOS Bundle ID Kontrolü:**
`ios/Runner.xcodeproj/project.pbxproj` dosyasında Bundle Identifier'ın `com.cleanloop.cleanloop` olduğundan emin ol.

---

## 🍎 BÖLÜM 2: Apple Sign-In Kurulumu

> ⚠️ Apple Developer Program üyeliği gerekli ($99/yıl)

### Adım 2.1: Apple Developer Console'da App ID Oluştur

1. https://developer.apple.com/account adresine git
2. **Certificates, Identifiers & Profiles** → **Identifiers**
3. **+** butonuna tıkla → **App IDs** → **Continue**
4. Type: **App** → **Continue**
5. Formu doldur:
   - Description: `CleanLoop`
   - Bundle ID: **Explicit** → `com.cleanloop.cleanloop`
6. Capabilities bölümünde **Sign In with Apple** ✓ işaretle
7. **Continue** → **Register**

### Adım 2.2: Services ID Oluştur (Supabase için)

1. **Identifiers** → **+** → **Services IDs** → **Continue**
2. Formu doldur:
   - Description: `CleanLoop Web`
   - Identifier: `com.cleanloop.cleanloop.web`
3. **Continue** → **Register**
4. Oluşturulan Services ID'ye tıkla
5. **Sign In with Apple** ✓ işaretle → **Configure**
6. Primary App ID: `CleanLoop (com.cleanloop.cleanloop)` seç
7. Domains and Subdomains ekle:
   ```
   YOUR_SUPABASE_PROJECT_REF.supabase.co
   ```
8. Return URLs ekle:
   ```
   https://YOUR_SUPABASE_PROJECT_REF.supabase.co/auth/v1/callback
   ```
9. **Save** → **Continue** → **Save**

### Adım 2.3: Key Oluştur

1. **Keys** → **+** → Name: `CleanLoop Sign In`
2. **Sign In with Apple** ✓ işaretle → **Configure**
3. Primary App ID: `CleanLoop` seç → **Save**
4. **Continue** → **Register**
5. **Download** butonuyla `.p8` dosyasını indir (BU DOSYA BİR KERE İNDİRİLEBİLİR!)
6. **Key ID**'yi not al

### Adım 2.4: Team ID'yi Bul

1. https://developer.apple.com/account → Sağ üstte ismin altında
2. Veya **Membership** sayfasında **Team ID** yazar

### Adım 2.5: Supabase'de Apple Provider'ı Aktifleştir

1. Supabase Dashboard → **Authentication** → **Providers** → **Apple**
2. **Enable Sign in with Apple** toggle'ını aç
3. Bilgileri doldur:
   - **Client ID (Services ID)**: `com.cleanloop.cleanloop.web`
   - **Secret Key**: `.p8` dosyasının içeriğini yapıştır (-----BEGIN PRIVATE KEY----- ile başlayan)
   - **Key ID**: Key oluştururken aldığın ID
   - **Team ID**: Apple Developer hesabındaki Team ID
4. **Save**

### Adım 2.6: Xcode'da Sign In with Apple Capability Ekle

1. Xcode'da `ios/Runner.xcworkspace` aç
2. Runner target seç → **Signing & Capabilities** tab
3. **+ Capability** → **Sign In with Apple** ekle
4. Team'ini seç ve Signing ayarlarını yap

---

## 🔧 BÖLÜM 3: Flutter Kodu Güncellemeleri

Google Client ID'yi `.env` dosyasına ekle:

```env
# /Users/enesbilik/Documents/repo/cleny/.env
SUPABASE_URL=https://YOUR_PROJECT.supabase.co
SUPABASE_ANON_KEY=your_anon_key
GOOGLE_IOS_CLIENT_ID=your_ios_client_id.apps.googleusercontent.com
GOOGLE_WEB_CLIENT_ID=your_web_client_id.apps.googleusercontent.com
```

---

## ✅ BÖLÜM 4: Test Kontrol Listesi

### Google Sign-In Test
- [ ] Google Cloud Console'da proje oluşturuldu
- [ ] OAuth Consent Screen yapılandırıldı
- [ ] iOS Client ID oluşturuldu
- [ ] Android Client ID oluşturuldu (SHA-1 ile)
- [ ] Web Client ID oluşturuldu
- [ ] Supabase'de Google provider aktif ve credentials girildi
- [ ] iOS Info.plist'te GIDClientID güncellendi
- [ ] Test: iOS'ta Google ile giriş çalışıyor

### Apple Sign-In Test
- [ ] Apple Developer'da App ID oluşturuldu (Sign In with Apple aktif)
- [ ] Services ID oluşturuldu ve yapılandırıldı
- [ ] Key oluşturuldu ve .p8 dosyası indirildi
- [ ] Team ID not edildi
- [ ] Supabase'de Apple provider aktif ve tüm credentials girildi
- [ ] Xcode'da Sign In with Apple capability eklendi
- [ ] Test: iOS'ta Apple ile giriş çalışıyor

---

## 🆘 Sorun Giderme

### "invalid_client" Hatası (Google)
- Client ID ve Secret'ın doğru olduğundan emin ol
- Redirect URI'nin tam olarak eşleştiğinden emin ol

### "Sign in with Apple failed" Hatası
- Services ID'nin doğru yapılandırıldığından emin ol
- Return URL'in Supabase callback URL'i ile eşleştiğinden emin ol
- .p8 key'in doğru şekilde yapıştırıldığından emin ol

### Google Sign-In "not supported" Hatası (Native)
- `google_sign_in` paketi için iOS Client ID gerekli
- Bundle ID'nin Google Console'daki ile aynı olduğundan emin ol

---

## 📋 Hızlı Referans - Gerekli Değerler

| Değer | Nereden Alınır |
|-------|----------------|
| Supabase Project Ref | Dashboard URL'inden (xxx.supabase.co) |
| Google Web Client ID | Google Cloud Console → Credentials |
| Google Web Client Secret | Google Cloud Console → Credentials |
| Google iOS Client ID | Google Cloud Console → Credentials |
| Apple Services ID | Apple Developer → Identifiers |
| Apple Key ID | Apple Developer → Keys |
| Apple Team ID | Apple Developer → Membership |
| Apple Private Key (.p8) | Apple Developer → Keys (bir kere indirilir!) |

---

**Yardıma ihtiyacın olursa, hangi adımda olduğunu söyle!** 🚀

