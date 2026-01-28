# CleanLoop 🧹

Beyaz yakalıların günde sadece 10-15 dakika ayırarak evlerini düzenli tutmalarını sağlayan mikro temizlik uygulaması.

## Özellikler

- **Akıllı Görev Atama**: Her gün farklı oda ve görev tipi kombinasyonları
- **Sürpriz Kutusu**: Günlük görevinizi sürpriz olarak açın
- **Timer**: Başlat/Durdur/Devam özellikleriyle zamanlayıcı
- **Basılı Tut Tamamlama**: Eğlenceli temizleme animasyonu
- **Ev Görseli**: Temizlik seviyenizi görsel olarak takip edin
- **Streak Takibi**: Ardışık günlerinizi takip edin
- **Takvim**: Son 14 günün geçmişini görün
- **Bildirimler**: Hatırlatma ve motivasyon bildirimleri

## Kurulum

### Gereksinimler

- Flutter SDK 3.9+
- Dart SDK 3.9+
- Supabase hesabı

### 1. Projeyi Klonla

```bash
git clone <repo-url>
cd cleny
```

### 2. Bağımlılıkları Yükle

```bash
flutter pub get
```

### 3. Supabase Kurulumu

1. [Supabase](https://supabase.com) üzerinde yeni bir proje oluşturun
2. SQL Editor'da `supabase/schema.sql` dosyasını çalıştırın
3. Ardından `supabase/seed.sql` dosyasını çalıştırın (görev kataloğu)
4. Authentication > Settings > Anonymous Sign-ins'i aktif edin

### 4. Environment Dosyası

`.env` dosyasını oluşturun:

```env
SUPABASE_URL=https://your-project.supabase.co
SUPABASE_ANON_KEY=your-anon-key
```

### 5. Uygulamayı Çalıştır

```bash
# iOS
flutter run -d ios

# Android
flutter run -d android
```

## Proje Yapısı

```
lib/
├── core/
│   ├── constants/      # Sabitler
│   ├── router/         # Routing (go_router)
│   ├── services/       # Servisler (Supabase, Local Storage, Notifications)
│   └── theme/          # Tema ve renkler
├── features/
│   ├── calendar/       # Takvim ekranı
│   ├── home/           # Ana ekran
│   ├── onboarding/     # Onboarding akışı
│   ├── settings/       # Ayarlar
│   └── timer/          # Timer ekranı
└── shared/
    ├── models/         # Veri modelleri
    ├── providers/      # Global state
    └── widgets/        # Ortak widgetlar
```

## Veritabanı Şeması

### users_profile
- Kullanıcı tercihleri (süre, bildirim saati vb.)

### rooms
- Kullanıcının odaları

### tasks_catalog
- 25+ hazır görev tanımı

### daily_tasks
- Günlük atanan görevler ve tamamlama durumu

## Teknolojiler

- **Flutter** - UI Framework
- **Riverpod** - State Management
- **go_router** - Routing
- **Hive** - Local Storage
- **Supabase** - Backend (Auth + Database)
- **flutter_local_notifications** - Bildirimler

## Akıllı Görev Seçimi

Algoritma şu kuralları uygular:
1. Son 1 günde kullanılan oda tekrar seçilmez
2. Son 1 günde kullanılan görev tipi tekrar seçilmez
3. Kural sağlanamazsa kademeli gevşetme yapılır
4. Her gün Europe/Istanbul timezone'una göre sıfırlanır

## 📋 Proje Durumu ve Planlar

**Güncel yol haritası ve yapılacaklar için:** [`PROJECT_ROADMAP.md`](./PROJECT_ROADMAP.md) dosyasına bakın.

### Hızlı Durum
- ✅ MVP Tamamlandı (%95)
- 🚧 Production Hazırlığı (%60)
- 📊 12/12 özellik tamamlandı
- ⏳ 7 özellik bekliyor (3 yüksek öncelik)

## 📚 Dokümantasyon

- [`PROJECT_ROADMAP.md`](./PROJECT_ROADMAP.md) - **Güncel yol haritası ve planlar**
- [`docs/plans/`](./docs/plans/) - Arşiv plan dosyaları
- [`OAUTH_SETUP_GUIDE.md`](./OAUTH_SETUP_GUIDE.md) - OAuth yapılandırma rehberi
- [`SETUP_GUIDE.md`](./SETUP_GUIDE.md) - Detaylı kurulum rehberi
- [`TEST_CHECKLIST.md`](./TEST_CHECKLIST.md) - Test checklist'i

## Lisans

MIT
