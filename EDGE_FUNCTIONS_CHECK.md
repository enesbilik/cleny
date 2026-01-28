# 🔍 Edge Functions Deploy Kontrol Rehberi

## ✅ Hızlı Kontrol

Edge Functions'ların deploy edilip edilmediğini kontrol etmek için:

### Yöntem 1: Supabase Dashboard (Kolay)

1. **Supabase Dashboard** → https://supabase.com/dashboard
2. **Projenizi seçin** (bgokgefthwmbisddniki)
3. Sol menüden **Edge Functions** sekmesine gidin
4. **Deploy edilmiş fonksiyonları görün:**
   - `send-notifications` ✅ (Deploy edilmiş görünmeli)
   - `profile` ❓
   - `rooms` ❓
   - `tasks` ❓

**Eğer fonksiyonlar listede yoksa:** Deploy edilmemiş demektir.

---

### Yöntem 2: API Endpoint Test (Kesin)

Terminal'de şu komutları çalıştırın:

```bash
# send-notifications test
curl -X POST \
  'https://bgokgefthwmbisddniki.supabase.co/functions/v1/send-notifications?type=morning' \
  -H 'Authorization: Bearer YOUR_ANON_KEY' \
  -H 'Content-Type: application/json'

# profile test
curl -X GET \
  'https://bgokgefthwmbisddniki.supabase.co/functions/v1/profile' \
  -H 'Authorization: Bearer YOUR_ANON_KEY'

# rooms test
curl -X GET \
  'https://bgokgefthwmbisddniki.supabase.co/functions/v1/rooms' \
  -H 'Authorization: Bearer YOUR_ANON_KEY'

# tasks test
curl -X GET \
  'https://bgokgefthwmbisddniki.supabase.co/functions/v1/tasks' \
  -H 'Authorization: Bearer YOUR_ANON_KEY'
```

**Beklenen Sonuç:**
- ✅ `200 OK` veya `201 Created` → Deploy edilmiş
- ❌ `404 Not Found` → Deploy edilmemiş
- ❌ `500 Internal Server Error` → Deploy edilmiş ama hata var

---

## 📋 Mevcut Edge Functions Listesi

Projede şu Edge Functions var:

1. **`send-notifications`** - Push notification gönderme
   - Dosya: `supabase/functions/send-notifications/index.ts`
   - Durum: ❓ Kontrol edilmeli

2. **`profile`** - Kullanıcı profil API
   - Dosya: `supabase/functions/profile/index.ts`
   - Durum: ❓ Kontrol edilmeli

3. **`rooms`** - Oda yönetimi API
   - Dosya: `supabase/functions/rooms/index.ts`
   - Durum: ❓ Kontrol edilmeli

4. **`tasks`** - Görev yönetimi API
   - Dosya: `supabase/functions/tasks/index.ts`
   - Durum: ❓ Kontrol edilmeli

---

## 🚀 Deploy Etme (Eğer Deploy Edilmemişse)

### Yöntem 1: Supabase Dashboard (Kolay) ✅

#### `send-notifications` Deploy

1. **Supabase Dashboard** → **Edge Functions**
2. **"Create a new function"** → **Function name:** `send-notifications`
3. **Code Editor** açılacak
4. `supabase/functions/send-notifications/index.ts` dosyasındaki kodu kopyala-yapıştır
5. **Settings** → **Secrets:**
   - `ONESIGNAL_REST_API_KEY` = `os_v2_app_ntibato5dvar3gcsv3o7jwllgk62eslaz6oe5o45hg2zxexzuyvkc62wdrl5gmnlslkhicrm2fvvvpor4v2atztufnrntzfkuudsruy`
   - `SUPABASE_URL` = `https://bgokgefthwmbisddniki.supabase.co`
   - `SUPABASE_SERVICE_ROLE_KEY` = (Settings → API → service_role key)
6. **Deploy**

#### Diğer Functions Deploy

Aynı adımları `profile`, `rooms`, `tasks` için tekrarla.

---

### Yöntem 2: Supabase CLI (Gelişmiş)

```bash
# Supabase CLI kurulumu (eğer yoksa)
npm install -g supabase

# Login
supabase login

# Proje link
supabase link --project-ref bgokgefthwmbisddniki

# Deploy
supabase functions deploy send-notifications
supabase functions deploy profile
supabase functions deploy rooms
supabase functions deploy tasks
```

---

## ⚠️ Önemli Notlar

1. **`send-notifications` zaten çalışıyor olabilir:**
   - Cron jobs çalışıyorsa deploy edilmiş demektir
   - Test etmek için yukarıdaki curl komutunu kullanın

2. **Diğer functions (`profile`, `rooms`, `tasks`):**
   - Şu an Supabase client doğrudan kullanılıyor (RLS ile güvenli)
   - Edge Functions deploy opsiyonel
   - Deploy etmek isterseniz yukarıdaki adımları takip edin

3. **Environment Variables:**
   - Her function için gerekli environment variables'ı ayarlayın
   - Dashboard'dan **Settings** → **Secrets** bölümünden ekleyin

---

## ✅ Deploy Sonrası Kontrol

1. **Dashboard'da görünüyor mu?** ✅
2. **API endpoint çalışıyor mu?** (curl ile test)
3. **Environment variables ayarlı mı?** ✅
4. **Logs'ta hata var mı?** (Dashboard → Edge Functions → Logs)

---

## 📝 Checklist

- [ ] Supabase Dashboard'da Edge Functions sekmesini kontrol et
- [ ] `send-notifications` deploy edilmiş mi?
- [ ] `profile` deploy edilmiş mi? (Opsiyonel)
- [ ] `rooms` deploy edilmiş mi? (Opsiyonel)
- [ ] `tasks` deploy edilmiş mi? (Opsiyonel)
- [ ] Environment variables ayarlı mı?
- [ ] Test bildirimi gönder (curl ile)
- [ ] Logs'ta hata var mı kontrol et

---

## 🔗 İlgili Dosyalar

- `DEPLOY_INSTRUCTIONS.md` - Detaylı deploy rehberi
- `supabase/functions/` - Tüm Edge Functions kodları
- `PROJECT_ROADMAP.md` - Genel proje durumu

---

*Son güncelleme: 2026-01-24*

