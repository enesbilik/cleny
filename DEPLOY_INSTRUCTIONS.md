# 🚀 Edge Function Deploy Rehberi

## Yöntem 1: Supabase Dashboard (KOLAY) ✅

### Adım 1: Edge Function Oluştur

1. **Supabase Dashboard** → https://supabase.com/dashboard
2. **Projen seç** → Sol menüden **Edge Functions**
3. **"Create a new function"** butonuna tıkla
4. **Function name:** `send-notifications`
5. **"Create function"** tıkla

### Adım 2: Kodu Yapıştır

1. **Code Editor** açılacak
2. **Tüm kodu sil**
3. Şu dosyadaki kodu kopyala: `supabase/functions/send-notifications/index.ts`
4. **Yapıştır**
5. **"Deploy"** butonuna bas

### Adım 3: Environment Variables Ekle

1. **Settings** sekmesine git
2. **Secrets** bölümünde:
   - `ONESIGNAL_REST_API_KEY` = `os_v2_app_ntibato5dvar3gcsv3o7jwllgk62eslaz6oe5o45hg2zxexzuyvkc62wdrl5gmnlslkhicrm2fvvvpor4v2atztufnrntzfkuudsruy`
   - `SUPABASE_URL` = `https://bgokgefthwmbisddniki.supabase.co`
   - `SUPABASE_SERVICE_ROLE_KEY` = (Settings → API → service_role key)

3. **Save**

---

## Yöntem 2: Supabase CLI (GELİŞMİŞ)

### Adım 1: Access Token Al

1. **Supabase Dashboard** → **Account Settings** → **Access Tokens**
2. **Generate new token** → Kopyala

### Adım 2: Deploy

```bash
cd /Users/enesbilik/Documents/repo/cleny

# Login
export SUPABASE_ACCESS_TOKEN="YOUR_TOKEN_HERE"
supabase link --project-ref bgokgefthwmbisddniki

# Deploy
supabase functions deploy send-notifications
```

---

## ✅ Test Et

Deploy sonrası test et:

```bash
curl -X POST \
  'https://bgokgefthwmbisddniki.supabase.co/functions/v1/send-notifications?type=morning' \
  -H 'Authorization: Bearer YOUR_ANON_KEY'
```

---

*Son güncelleme: 2026-01-23*

