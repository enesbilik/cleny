# Google Sign-In Kurulumu

Google Sign-In'in çalışması için aşağıdaki adımları tamamlamanız gerekiyor.

## 1. Google Cloud Console Yapılandırması

1. [Google Cloud Console](https://console.cloud.google.com/) adresine gidin
2. Proje oluşturun veya mevcut projeyi seçin
3. **APIs & Services > Credentials** bölümüne gidin
4. **Create Credentials > OAuth client ID** seçin

### iOS İçin:
1. Application type: **iOS**
2. Bundle ID: `com.cleanloop.cleanloop`
3. Client ID'yi kopyalayın (örn: `123456789-abcdef.apps.googleusercontent.com`)

### Android İçin:
1. Application type: **Android**
2. Package name: `com.cleanloop.cleanloop`
3. SHA-1 certificate fingerprint ekleyin:
   ```bash
   # Debug için
   keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android -keypass android
   ```

### Web İçin (Supabase):
1. Application type: **Web application**
2. Authorized redirect URIs:
   - `https://YOUR_SUPABASE_PROJECT.supabase.co/auth/v1/callback`

## 2. iOS Yapılandırması

`ios/Runner/Info.plist` dosyasında URL scheme'i güncelleyin:

```xml
<key>CFBundleURLTypes</key>
<array>
    ...
    <dict>
        <key>CFBundleTypeRole</key>
        <string>Editor</string>
        <key>CFBundleURLSchemes</key>
        <array>
            <string>com.googleusercontent.apps.YOUR_IOS_CLIENT_ID</string>
        </array>
    </dict>
</array>
```

**YOUR_IOS_CLIENT_ID** kısmını Google Cloud Console'dan aldığınız iOS Client ID ile değiştirin.

## 3. Supabase Yapılandırması

1. Supabase Dashboard'a gidin
2. **Authentication > Providers > Google** seçin
3. **Web application** Client ID ve Secret'ı girin
4. **Enable** yapın

## 4. Test Etme

Uygulama artık Google Sign-In destekleyecektir:
- iOS'ta native Google Sign-In popup'ı açılacak
- Başarılı girişten sonra kullanıcı otomatik yönlendirilecek

## Notlar

- iOS Simulator'da Google Sign-In çalışmayabilir, gerçek cihazda test edin
- Debug mode'da SHA-1, release mode'da farklı SHA-1 gerekir
- Apple Developer hesabınızda Sign in with Apple capability aktif olmalı

---

*Yardıma mı ihtiyacınız var? Supabase dokümantasyonuna bakın: https://supabase.com/docs/guides/auth/social-login/auth-google*

