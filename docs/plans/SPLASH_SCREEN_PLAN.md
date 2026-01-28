# 🎨 Custom Splash Screen Plan

## 🐛 Mevcut Sorun

1. Home ekranı hemen açılıyor
2. "Görevi Gör" butonu görünüyor
3. Arka planda veri çekiliyor
4. Görev açıldıysa ekran güncelleniyor (flicker/glitch)

**Kullanıcı Deneyimi:** Kötü - ekran titriyor, butonlar değişiyor

---

## ✅ Çözüm: Custom Splash Screen

### Akış:
```
Uygulama Açılır
    ↓
Splash Screen (Animasyonlu)
    ↓
Arka Planda Veri Yükleme:
  - HomeProvider.loadData()
  - Görev durumu kontrolü
  - Streak hesaplama
    ↓
Veriler Hazır
    ↓
Home Screen'e Yönlendir (Doğru durumla)
```

---

## 📋 Uygulama Planı

### Faz 1: Custom Splash Screen Widget
- Animasyonlu logo/icon
- Loading indicator
- "Yükleniyor..." metni (opsiyonel)

### Faz 2: Veri Yükleme Logic
- `HomeProvider.loadData()` çağır
- `SettingsProvider.refresh()` çağır
- `LocaleProvider._loadLocale()` çağır
- Tüm veriler hazır olana kadar bekle

### Faz 3: Router Güncelleme
- Splash'i initial route yap
- Veriler yüklendikten sonra home'a yönlendir
- Eğer onboarding tamamlanmamışsa welcome'a yönlendir

---

## 🎯 Özellikler

- ✅ Smooth animasyon
- ✅ Veri yükleme sırasında kullanıcı bekleme durumunda
- ✅ Home ekranı doğru durumla açılır (flicker yok)
- ✅ Offline mod desteği (cache'den yükle)

---

*Son güncelleme: 2026-01-24*

