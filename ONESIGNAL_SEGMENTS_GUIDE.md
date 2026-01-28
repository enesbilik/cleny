# 🎯 OneSignal Segment ve Otomatik Bildirimler Rehberi

## 📋 Genel Bakış

OneSignal Dashboard'da segment'ler oluşturup otomatik bildirimler kurarak kullanıcılara zamanlı ve hedefli bildirimler gönderebilirsiniz.

---

## ✅ Ön Hazırlık (Tamamlandı)

- [x] OneSignal hesabı oluşturuldu
- [x] Flutter entegrasyonu yapıldı
- [x] Tag güncelleme sistemi çalışıyor
- [x] Supabase Edge Function (`send-notifications`) deploy edildi
- [x] Cron jobs kuruldu (pg_cron)

---

## 🎯 Adım 1: OneSignal Dashboard'a Giriş

1. **OneSignal Dashboard** → https://app.onesignal.com
2. **Projenizi seçin** (CleanLoop)
3. **Audience** sekmesine gidin

---

## 📊 Adım 2: Segment'ler Oluştur

### Segment 1: `inactive_today` (Bugün Görev Yapmayanlar)

**Amaç:** Bugün görevini tamamlamamış kullanıcılara hatırlatma göndermek

**Oluşturma:**
1. **Audience** → **Segments** → **New Segment**
2. **Segment Name:** `inactive_today`
3. **Filter Rules:**
   - `completed_today` **is not equal to** `yes`
4. **Save**

**Kullanım:** Öğleden sonra (14:00), akşam (19:00), gece (21:00) bildirimleri

---

### Segment 2: `streak_risk` (Streak Tehlikede)

**Amaç:** Streak'i olan ama bugün görev yapmayan kullanıcılara uyarı

**Oluşturma:**
1. **New Segment**
2. **Segment Name:** `streak_risk`
3. **Filter Rules:**
   - `current_streak` **is greater than** `0`
   - **AND** `completed_today` **is not equal to** `yes`
4. **Save**

**Kullanım:** Akşam (19:00) ve gece (21:00) uyarı bildirimleri

---

### Segment 3: `champions` (Şampiyonlar)

**Amaç:** 7+ gün streak'i olan kullanıcılara özel tebrik

**Oluşturma:**
1. **New Segment**
2. **Segment Name:** `champions`
3. **Filter Rules:**
   - `current_streak` **is greater than or equal to** `7`
4. **Save**

**Kullanım:** Özel motivasyon mesajları

---

### Segment 4: `dormant_users` (Pasif Kullanıcılar)

**Amaç:** 2+ gün uygulamaya girmeyen kullanıcıları geri kazanmak

**Oluşturma:**
1. **New Segment**
2. **Segment Name:** `dormant_users`
3. **Filter Rules:**
   - `last_active` **is less than** `2 days ago`
4. **Save**

**Not:** OneSignal'da `last_active` tag'i ISO8601 formatında tutuluyor. Bu segment için OneSignal'ın built-in "Last Active" filtresini kullanabilirsiniz:
- **Last Active** **is more than** `2 days ago`

**Kullanım:** "Seni özledik!" re-engagement mesajları

---

### Segment 5: `new_users` (Yeni Kullanıcılar)

**Amaç:** İlk 3 görevini tamamlamamış kullanıcılara onboarding desteği

**Oluşturma:**
1. **New Segment**
2. **Segment Name:** `new_users`
3. **Filter Rules:**
   - `total_completed` **is less than** `3`
   - **OR** `total_completed` **does not exist**

**Not:** OneSignal'da tag yoksa "does not exist" kullanın.

**Kullanım:** Onboarding ve teşvik mesajları

---

## ⏰ Adım 3: Zamanlanmış Mesajlar (Automated Messages)

### Mesaj 1: Sabah Motivasyon (09:00)

**Oluşturma:**
1. **Messages** → **New Message** → **Automated**
2. **Message Type:** Push Notification
3. **Name:** `Morning Motivation - 09:00`
4. **Schedule:**
   - **Recurring:** Daily
   - **Time:** 09:00 (Istanbul timezone)
5. **Audience:**
   - **Send to:** All Users (veya `active_users` segment'i)
6. **Message Content:**
   - **Title:** `Günaydın! ☀️`
   - **Message:** `Bugün küçük bir adım, büyük bir fark!`
7. **Save & Activate**

**Alternatif Mesajlar (Rastgele seçilebilir):**
- "Yeni Gün, Yeni Fırsat! 🌟 - 10 dakikada evini değiştir!"
- "Kahveni Al! ☕ - Bugünün görevi seni bekliyor!"

---

### Mesaj 2: Öğleden Sonra Hatırlatma (14:00)

**Oluşturma:**
1. **New Message** → **Automated**
2. **Name:** `Afternoon Reminder - 14:00`
3. **Schedule:**
   - **Recurring:** Daily
   - **Time:** 14:00
4. **Audience:**
   - **Send to:** Segment → `inactive_today`
5. **Message Content:**
   - **Title:** `Görev Zamanı! 🎁`
   - **Message:** `Bugünün sürprizi hazır, aç ve başla!`
6. **Save & Activate**

**Alternatif Mesajlar:**
- "Molana 10 Dakika Ekle 🧹 - Temizlik yap, sonra rahatlık!"
- "Netflix Bekleyebilir 📺 - Önce görev, sonra dizi!"

---

### Mesaj 3: Akşam Uyarı (19:00)

**Oluşturma:**
1. **New Message** → **Automated**
2. **Name:** `Evening Warning - 19:00`
3. **Schedule:**
   - **Recurring:** Daily
   - **Time:** 19:00
4. **Audience:**
   - **Send to:** Segment → `streak_risk`
5. **Message Content:**
   - **Title:** `Son Şans! 🔥`
   - **Message:** `Streak'ini kaybetmemek için 10 dakika!`
6. **Save & Activate**

**Alternatif Mesajlar:**
- "Gün Bitmeden! ⏰ - Görevini tamamla, rahat uyu!"
- "Streak Tehlikede! ⚠️ - Bugün de devam et, şampiyon!"

---

### Mesaj 4: Son Dakika (21:00)

**Oluşturma:**
1. **New Message** → **Automated**
2. **Name:** `Late Night - 21:00`
3. **Schedule:**
   - **Recurring:** Daily
   - **Time:** 21:00
4. **Audience:**
   - **Send to:** Segment → `streak_risk`
5. **Message Content:**
   - **Title:** `SON 3 SAAT! 🆘`
   - **Message:** `Streak kaybetmek üzeresin!`
6. **Save & Activate**

**Alternatif Mesajlar:**
- "Hadi Son Bir Gayret! 🏃‍♀️ - Evini temizle, kendini iyi hisset!"
- "Görevini Tamamla! ✅ - Pişman olma, şimdi yap!"

---

## 🔄 Alternatif: Supabase Cron Jobs (Zaten Kurulu)

**Not:** Supabase'de cron jobs zaten kurulu ve çalışıyor. Bu yöntem OneSignal Dashboard'dan daha esnek çünkü:
- Mesajları rastgele seçebilir
- Kullanıcı durumuna göre filtreleme yapabilir
- Supabase'den veri çekebilir

**Mevcut Cron Jobs:**
- ✅ 09:00 - Sabah motivasyon (tüm kullanıcılar)
- ✅ 14:00 - Öğleden sonra hatırlatma (görev yapmayanlar)
- ✅ 19:00 - Akşam uyarı (görev yapmayanlar)
- ✅ 21:00 - Son dakika (görev yapmayanlar)

**Dosya:** `supabase/cron_jobs_simple.sql`

---

## 🧪 Test Etme

### Test 1: Segment'leri Kontrol Et

1. **Audience** → **Segments**
2. Her segment'in **Member Count**'unu kontrol et
3. En az 1 kullanıcı olmalı (test için)

### Test 2: Manuel Bildirim Gönder

1. **Messages** → **New Message** → **Push Notification**
2. **Audience:** Segment → `inactive_today`
3. **Message:** Test mesajı
4. **Send Now**

### Test 3: Zamanlanmış Mesajı Test Et

1. **Messages** → **Automated Messages**
2. Test mesajı oluştur (1 dakika sonra gönder)
3. Bekle ve kontrol et

---

## 📊 Tag Güncelleme Kontrolü

Flutter uygulamasında tag'ler şu durumlarda güncelleniyor:

1. **Login sonrası:**
   ```dart
   OneSignalService.syncCurrentUser();
   ```

2. **Görev tamamlandığında:**
   ```dart
   OneSignalService.updateTaskStatus(completedToday: true);
   OneSignalService.updateStreakTag(streak);
   ```

3. **Uygulama açıldığında:**
   ```dart
   OneSignalService.updateLastActive();
   ```

**Tag'ler:**
- `external_id` - Supabase user_id
- `completed_today` - "yes" veya "no"
- `current_streak` - Sayı (örn: "5")
- `cleanliness_level` - Sayı (0-4)
- `preferred_language` - "tr" veya "en"
- `last_active` - ISO8601 timestamp

---

## 🎯 Önerilen Segment Stratejisi

### Senaryo 1: Sadece OneSignal Dashboard Kullan
- ✅ Kolay kurulum
- ✅ Görsel arayüz
- ❌ Rastgele mesaj seçimi yok
- ❌ Karmaşık filtreleme zor

### Senaryo 2: Supabase Cron Jobs Kullan (Önerilen)
- ✅ Rastgele mesaj seçimi
- ✅ Karmaşık filtreleme (Supabase'den)
- ✅ Esnek mantık
- ✅ Zaten kurulu ve çalışıyor

**Öneri:** Supabase cron jobs'u kullan, OneSignal segment'lerini analytics için kullan.

---

## 📝 Checklist

- [ ] OneSignal Dashboard'a giriş yap
- [ ] 5 segment oluştur (yukarıdaki gibi)
- [ ] Segment'lerin member count'unu kontrol et
- [ ] Test bildirimi gönder
- [ ] Supabase cron jobs'un çalıştığını doğrula
- [ ] Gerçek kullanıcılarla test et

---

## 🔗 İlgili Dosyalar

- `supabase/functions/send-notifications/index.ts` - Edge Function
- `supabase/cron_jobs_simple.sql` - Cron jobs SQL
- `lib/core/services/onesignal_service.dart` - Flutter entegrasyonu
- `docs/plans/NOTIFICATION_PLAN.md` - Detaylı plan

---

*Son güncelleme: 2026-01-24*

