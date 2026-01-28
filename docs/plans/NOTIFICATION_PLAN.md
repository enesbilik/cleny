# 🔔 CleanLoop - Otomatik Bildirim Planı

## 📊 Bildirim Stratejisi

### Günlük Bildirim Takvimi (4 bildirim/gün)

| Saat | Tip | Hedef Kitle | Mesaj Örneği |
|------|-----|-------------|--------------|
| 09:00 | Sabah Motivasyon | Herkes | "Güne temiz başla! ☀️" |
| 14:00 | Görev Hatırlatma | Görevi yapmamış | "Bugünün görevi seni bekliyor! 🎁" |
| 19:00 | Akşam Uyarı | Görevi yapmamış | "Son şans! Streak'ini koru 🔥" |
| 21:00 | Son Dakika | Görevi yapmamış | "Sadece 10 dakika! Yapabilirsin 💪" |

---

## 🎯 OneSignal Segment'leri

### Segment 1: `inactive_today`
- **Kural:** `completed_today != yes`
- **Kullanım:** Görev hatırlatma bildirimleri

### Segment 2: `streak_risk`
- **Kural:** `streak > 0` AND `completed_today != yes`
- **Kullanım:** "Streak'ini kaybetme!" uyarısı

### Segment 3: `champions`
- **Kural:** `streak >= 7`
- **Kullanım:** Özel tebrik mesajları

### Segment 4: `dormant_users`
- **Kural:** `last_active_date` 2+ gün önce
- **Kullanım:** "Seni özledik!" re-engagement

### Segment 5: `new_users`
- **Kural:** `total_completed < 3`
- **Kullanım:** Onboarding/teşvik mesajları

---

## 💬 Bildirim Mesajları (Rastgele Seçilecek)

### Sabah Motivasyon (09:00)
```
1. "Günaydın! Bugün küçük bir adım, büyük bir fark 🌟"
2. "Kahveni al, görevine bak! ☕"
3. "Temiz ev, temiz zihin. Hazır mısın? 🧘"
4. "Bugün hangi odayı parlatacaksın? ✨"
5. "10 dakika = 1 günlük huzur 💚"
```

### Görev Hatırlatma (14:00)
```
1. "Öğleden sonra enerjisi! Görevine bak 🎁"
2. "Bugünün sürprizi seni bekliyor! 🎲"
3. "Molana 10 dakika ekle, evini temizle 🧹"
4. "Netflix'e ara ver, 10 dakika temizlik yap 📺"
5. "Streak: {streak} gün! Devam et 🔥"
```

### Akşam Uyarı (19:00)
```
1. "Akşam oldu! Görevini tamamladın mı? 🌙"
2. "Son şans! Streak'ini korumak için 10 dakika 🔥"
3. "Gün bitmeden evini topla, rahat uyu 😴"
4. "Anne arar gibi: Odanı topladın mı? 👩"
5. "Bugünü pas geçme, yarın daha zor! 💪"
```

### Son Dakika (21:00) - Sadece yapmamışlara
```
1. "⚠️ SON 3 SAAT! Streak kaybetmek üzeresin!"
2. "Sadece 10 dakika! Yarın kendine teşekkür edeceksin 🙏"
3. "Uykudan önce küçük bir hamle? 🌙"
4. "Streak: {streak} gün tehlikede! Kurtar 🆘"
```

### Tebrik (Görev tamamlandığında)
```
1. "Harika! Streak: {streak} gün 🎉"
2. "Bugün de başardın! Evdeki kahraman 🦸"
3. "10 dakika geçti, ev parladı ✨"
4. "{streak} gün üst üste! Efsane 🏆"
```

---

## 🔧 Teknik Uygulama

### 1. Flutter Tarafı (Tag Güncelleme)
```dart
// Görev tamamlandığında
OneSignalService.updateTaskStatus(
  completedToday: true,
  totalCompleted: 15,
);
OneSignalService.updateStreakTag(5);

// Uygulama açıldığında
OneSignalService.updateLastActive();
```

### 2. OneSignal Dashboard Ayarları
- **Segments** oluştur (yukarıdaki kurallara göre)
- **Automated Messages** kur:
  - Recurring: Daily
  - Time: 09:00, 14:00, 19:00, 21:00 (Istanbul)
  - Segment: İlgili segment

### 3. Supabase Edge Function (Opsiyonel - Gelişmiş)
```typescript
// Her gece 00:00'da çalışır
// Tüm kullanıcıların completed_today tag'ini sıfırlar
// OneSignal API ile tag günceller
```

---

## 📱 Test Planı

### Android Test
1. Android emulator başlat
2. Uygulamayı yükle
3. Google ile giriş yap
4. OneSignal Dashboard'dan test bildirimi gönder
5. Bildirimi gör ✅

### iOS Test (Gerçek Cihaz Gerekli)
1. Gerçek iPhone'a yükle
2. Apple Developer hesabından APNs ayarla
3. Test et

---

## 📅 Uygulama Sırası

1. ✅ OneSignal Flutter entegrasyonu
2. ⏳ Flutter'da tag güncelleme kodları
3. ⏳ OneSignal'da segment'ler oluştur
4. ⏳ OneSignal'da zamanlanmış mesajlar kur
5. ⏳ Android'de test
6. ⏳ iOS'ta test (opsiyonel - gerçek cihaz gerekli)

---

*Son güncelleme: 2026-01-23*

