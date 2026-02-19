# CleanLoop — Tasarım İyileştirme Raporu

Bu döküman, başka bir ajanın uygulaması için hazırlanmıştır.
Her madde bağımsız, spesifik ve uygulanabilir şekilde yazılmıştır.

---

## ✅ Tamamlananlar

Aşağıdaki maddeler önceki oturumlarda uygulanmıştır:

| # | Değişiklik | Durum |
|---|-----------|-------|
| T1 | N+1 Query: `_getRecentCleans()` tek sorguda JOIN ile yeniden yazıldı | ✅ Tamamlandı |
| T2 | Timezone hardcoded `Europe/Istanbul` → cihaz yerel saatine taşındı (`task_selection_service.dart`, `notification_service.dart`) | ✅ Tamamlandı |
| T3 | Streak Freeze mekanizması eklendi (ayda 2 hak, Hive tabanlı) | ✅ Tamamlandı |
| T4 | Görev tamamlama sonrası streak UI anında güncelleniyor (optimistic update) | ✅ Tamamlandı |
| T5 | Bildirim izni reddedilince SnackBar geri bildirimi eklendi | ✅ Tamamlandı |
| T6 | Push notification + local notif sync: `available_start` kullanılıyor, OneSignal sync eklendi | ✅ Tamamlandı |
| T7 | Görev blacklist: "Bu görevi bir daha gösterme" özelliği eklendi | ✅ Tamamlandı |
| T8 | Özel oda ekleme kaldırıldı: onboarding + settings'te yalnızca preset odalar listeleniyor | ✅ Tamamlandı |

---

## 1. Hard-coded Renkler — AppColors'a Taşı

### Sorun
Birden fazla dosyada sabit hex renk değerleri var; tema değişince tümünü bulmak zorlaşır.

### Değişiklikler

**`lib/core/theme/app_colors.dart`** — Şu iki rengi ekle:

```dart
// Semantic renkler
static const Color snackbarDark = Color(0xFF323232);
static const Color snackbarActionMint = Color(0xFF80CBC4);
```

**`lib/features/home/presentation/screens/home_screen.dart`** — Hard-coded renkleri değiştir:

| Satır | Eski | Yeni |
|-------|------|------|
| 82 | `backgroundColor: const Color(0xFF323232)` | `backgroundColor: AppColors.snackbarDark` |
| 91 | `textColor: const Color(0xFF80CBC4)` | `textColor: AppColors.snackbarActionMint` |
| 276 | `backgroundColor: const Color(0xFF323232)` | `backgroundColor: AppColors.snackbarDark` |

**`lib/features/home/presentation/widgets/task_reveal_popup.dart`** — Hard-coded renkleri değiştir:

| Satır | Eski | Yeni |
|-------|------|------|
| 198 | `Color(0xFFFFD54F)` → gradient | `AppColors.accentLight` |
| 199 | `Color(0xFFFFB300)` → gradient | `AppColors.accentDark` |
| 205 | `Color(0xFFFFB300).withOpacity(0.5)` | `AppColors.accentDark.withOpacity(0.5)` |

**`lib/features/home/presentation/screens/home_screen.dart`** — `_GiftBox` widget'ı:

| Satır | Eski | Yeni |
|-------|------|------|
| 561 | `Color(0xFFFFCC80)` | `AppColors.accentLight` |
| 562 | `Color(0xFFFFB74D)` | `AppColors.accent` |
| 568 | `Color(0xFFFFB74D).withOpacity(0.3)` | `AppColors.accent.withOpacity(0.3)` |

---

## 2. Snackbar Tekrarı — Ortak Yardımcı Fonksiyon

### Sorun
`home_screen.dart` içinde aynı SnackBar yapısı 2 farklı yerde tekrar ediyor (satır 68-98 ve 274-286). `login_screen.dart`'ta da benzer ama farklı bir varyant var (satır 38-58).

### Değişiklik

**`lib/features/home/presentation/screens/home_screen.dart`** — `_HomeScreenState` sınıfına şu metodu ekle, mevcut iki SnackBar kodunu bununla değiştir:

```dart
void _showDarkSnackbar(String message, {SnackBarAction? action}) {
  if (!mounted) return;
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(message, style: const TextStyle(fontSize: 14)),
      backgroundColor: AppColors.snackbarDark,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.all(16),
      duration: const Duration(seconds: 4),
      action: action,
    ),
  );
}
```

İlk kullanım (bildirim izni reddedildi, satır 68-98):
```dart
_showDarkSnackbar(
  l10n.notificationPermissionDeniedMessage,
  action: SnackBarAction(
    label: l10n.notificationPermissionOpenSettings,
    textColor: AppColors.snackbarActionMint,
    onPressed: notificationService.openNotificationSettings,
  ),
);
```

İkinci kullanım (görev blacklist, satır 274-286):
```dart
_showDarkSnackbar(l10n.taskBlacklistedMessage);
```

---

## 3. Bottom Navigation — Material 3 NavigationBar'a Geç

### Sorun
`_BottomNavBar` ve `_NavItem` sınıfları (home_screen.dart, satır 1222-1321) `GestureDetector` + `Container` ile manuel bir navigation bar inşa ediyor. Material 3'ün `NavigationBar` widget'ı bu ihtiyacı karşılıyor, daha az kod ve otomatik erişilebilirlik sağlıyor.

### Değişiklik

**`lib/features/home/presentation/screens/home_screen.dart`** — `_BottomNavBar` sınıfını (satır 1222-1276) tamamen sil ve şununla değiştir:

```dart
class _BottomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const _BottomNavBar({required this.currentIndex, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return NavigationBar(
      selectedIndex: currentIndex,
      onDestinationSelected: onTap,
      backgroundColor: Colors.white,
      indicatorColor: AppColors.primaryLight.withOpacity(0.3),
      destinations: [
        NavigationDestination(
          icon: const Icon(Icons.home_outlined),
          selectedIcon: const Icon(Icons.home_rounded),
          label: l10n.home,
        ),
        NavigationDestination(
          icon: const Icon(Icons.calendar_today_outlined),
          selectedIcon: const Icon(Icons.calendar_today_rounded),
          label: l10n.progress,
        ),
        NavigationDestination(
          icon: const Icon(Icons.person_outline_rounded),
          selectedIcon: const Icon(Icons.person_rounded),
          label: l10n.profile,
        ),
      ],
    );
  }
}
```

`_NavItem` sınıfını (satır 1279-1321) tamamen sil — artık kullanılmıyor.

`app_theme.dart`'ta `bottomNavigationBarTheme` bölümünü (satır 161-167) kaldır ve şunu ekle:
```dart
navigationBarTheme: NavigationBarThemeData(
  backgroundColor: AppColors.surface,
  indicatorColor: AppColors.primaryLight.withOpacity(0.3),
  labelTextStyle: WidgetStateProperty.resolveWith((states) {
    final selected = states.contains(WidgetState.selected);
    return TextStyle(
      fontFamily: 'Nunito',
      fontSize: 12,
      fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
      color: selected ? AppColors.primary : AppColors.textHint,
    );
  }),
  iconTheme: WidgetStateProperty.resolveWith((states) {
    final selected = states.contains(WidgetState.selected);
    return IconThemeData(
      color: selected ? AppColors.primary : AppColors.textHint,
      size: 24,
    );
  }),
),
```

---

## 4. Timer Ekranı — Kapatma Butonu Erişilebilirlik

### Sorun
`_TopBar` (timer_screen.dart, satır 214-263) içindeki kapatma butonu `GestureDetector` + ham `Container` ile yapılmış. `IconButton` kullanmak hem minimum touch target standardını otomatik karşılar hem de Semantics label ekler.

### Değişiklik

**`lib/features/timer/presentation/screens/timer_screen.dart`** — `_TopBar.build` metodunda (satır 227-244):

Eski:
```dart
GestureDetector(
  onTap: onClose,
  child: Container(
    width: 44,
    height: 44,
    decoration: BoxDecoration(
      color: AppColors.surfaceVariant,
      shape: BoxShape.circle,
    ),
    child: const Icon(
      Icons.close_rounded,
      color: AppColors.textSecondary,
      size: 22,
    ),
  ),
),
```

Yeni:
```dart
IconButton(
  onPressed: onClose,
  tooltip: 'Çıkış',
  style: IconButton.styleFrom(
    backgroundColor: AppColors.surfaceVariant,
    shape: const CircleBorder(),
  ),
  icon: const Icon(
    Icons.close_rounded,
    color: AppColors.textSecondary,
    size: 22,
  ),
),
```

---

## 5. Streak Badge — GestureDetector Yerine InkWell

### Sorun
`_StreakBadge` (home_screen.dart, satır 302-341) tıklanabilir değil ama görsel olarak interaktif hissettiriyor. Gelecekte tıklama eklenecekse doğru widget kullanılmalı. Şu an için asıl mesele: `Colors.white` hard-coded (satır 314).

### Değişiklik

**`lib/features/home/presentation/screens/home_screen.dart`** — `_StreakBadge.build` metodunda (satır 312-340):

`color: Colors.white,` → `color: AppColors.surface,`

---

## 6. Version String — AppConstants'a Taşı

### Sorun
`SettingsContent.build` içinde (settings_screen.dart, satır 202) `'CleanLoop v1.0.0'` string'i hard-coded. `app_constants.dart`'ta zaten `appName` ve `appVersion` var.

### Değişiklik

**`lib/features/settings/presentation/screens/settings_screen.dart`** — `AppConstants` import'u zaten eklendi (T8 ile birlikte). Satır 202'yi değiştir:

Eski:
```dart
'CleanLoop v1.0.0',
```

Yeni:
```dart
'${AppConstants.appName} v${AppConstants.appVersion}',
```

---

## 7. Dil Tile — Hard-coded String Kaldır

### Sorun
`_LanguageTile.build` (settings_screen.dart, satır 880) içinde `'Dil / Language'` string'i hard-coded, lokalizasyona girmemiş.

### Değişiklik

**`lib/l10n/app_en.arb`** — Şunu ekle:
```json
"languageLabel": "Language"
```

**`lib/l10n/app_tr.arb`** — Şunu ekle:
```json
"languageLabel": "Dil"
```

**`lib/features/settings/presentation/screens/settings_screen.dart`** — `_LanguageTile.build` metodunda satır 880-883'ü değiştir:
```dart
// Eski:
title: const Text(
  'Dil / Language',
  style: TextStyle(fontWeight: FontWeight.w500),
),

// Yeni:
title: Text(
  AppLocalizations.of(context)!.languageLabel,
  style: const TextStyle(fontWeight: FontWeight.w500),
),
```

---

## 8. Login Logo — Gerçek Uygulama İkonu Kullan

### Sorun
`_Logo` (login_screen.dart, satır 387-411) `Icons.home_rounded` kullanıyor. Bu temizlik uygulamasının logosu değil; splash ekranında Lottie animasyonu var ama login ekranında Material ikon var. Daha karakteristik bir ikon kullanılmalı.

### Değişiklik

**`lib/features/auth/presentation/screens/login_screen.dart`** — `_Logo.build` metodunda (satır 404):

Eski:
```dart
child: const Icon(
  Icons.home_rounded,
  size: 40,
  color: Colors.white,
),
```

Yeni:
```dart
child: const Icon(
  Icons.cleaning_services_rounded,
  size: 40,
  color: Colors.white,
),
```

---

## 9. AppBar Geri Butonu — Leading Otomatik

### Sorun
`SettingsScreen` (settings_screen.dart, satır 512-530) `leading` olarak manuel `IconButton` tanımlamış. GoRouter + AppBar zaten otomatik geri butonu ekler; bu satır gereksiz.

### Değişiklik

**`lib/features/settings/presentation/screens/settings_screen.dart`** — `SettingsScreen.build` metodunda (satır 521-527):

Eski:
```dart
appBar: AppBar(
  title: Text(l10n.settings),
  leading: IconButton(
    icon: const Icon(Icons.arrow_back),
    onPressed: () => context.pop(),
  ),
),
```

Yeni:
```dart
appBar: AppBar(
  title: Text(l10n.settings),
),
```

---

## 10. Task Reveal Popup — Konfeti Renkleri AppColors'tan

### Sorun
`TaskRevealPopup` (task_reveal_popup.dart, satır 126-133) konfeti renklerinde `Colors.orange`, `Colors.pink`, `Colors.purple` gibi Material renkler kullanılmış. Tema renklerinden sapmak görsel tutarsızlık yaratır.

### Değişiklik

**`lib/features/home/presentation/widgets/task_reveal_popup.dart`** — Satır 126-133:

Eski:
```dart
colors: [
  AppColors.primary,
  AppColors.accent,
  AppColors.success,
  Colors.orange,
  Colors.pink,
  Colors.purple,
],
```

Yeni:
```dart
colors: [
  AppColors.primary,
  AppColors.primaryLight,
  AppColors.accent,
  AppColors.accentLight,
  AppColors.success,
  AppColors.secondary,
],
```

---

## 11. Görev Tamamlama İkonu — Mop Emoji Yerine Check

### Sorun
`_RevealedCard` (home_screen.dart, satır 625) görev açıldıktan sonra `🧹` emojisi gösteriyor. Aynı emoji `TaskRevealPopup` içinde de var (task_reveal_popup.dart, satır 378). Görevin türüne göre dinamik ikon gösterilmesi daha anlamlı olurdu; ancak bu büyük değişiklik. Minimum değişiklik: popup'ta görev başlığının altında ikon her zaman `🧹` gösteriyor, bu kabul edilebilir. Asıl sorun `_RevealedCard`'da `🧹`'nin her görev tipi için gösterilmesi — en azından task type bilgisi varsa buna göre ikon seçilmeli.

**Bu madde bilgi amaçlıdır; değişiklik isteğe bağlıdır.**

---

## 12. Splash Ekranı Arka Planı — Tutarsızlık Gider

### Sorun
`SplashScreen.build` (splash_screen.dart, satır 165) `backgroundColor: Colors.white` kullanıyor. Diğer ekranlar `AppColors.background` kullanıyor. Bu iki renk çok yakın ama farklı (`#FFFFFF` vs `#F8FFFE`).

### Değişiklik

**`lib/core/presentation/screens/splash_screen.dart`** — Satır 165:

Eski:
```dart
backgroundColor: Colors.white,
```

Yeni:
```dart
backgroundColor: AppColors.background,
```

---

## 13. Timer Ekranı — İlerleme Göstergesi Anlamlılaştır

### Sorun
`_TimerDisplay` (timer_screen.dart, satır 344-351) durum badge'inde `'● ${l10n.running}'` ve `'○ ${l10n.ready}'` gibi unicode karakterler kullanılmış. Bu karakterler farklı platform/fontlarda farklı render edilebilir.

### Değişiklik

**`lib/features/timer/presentation/screens/timer_screen.dart`** — Satır 344-351:

Eski:
```dart
isCompleted
    ? '✓ ${l10n.completed}'
    : isRunning
        ? '● ${l10n.running}'
        : '○ ${l10n.ready}',
```

Yeni — Text widget'ı Icon + Text Row'a çevir:
```dart
Row(
  mainAxisSize: MainAxisSize.min,
  children: [
    Icon(
      isCompleted
          ? Icons.check_circle_rounded
          : isRunning
              ? Icons.play_circle_rounded
              : Icons.circle_outlined,
      size: 14,
      color: isCompleted ? AppColors.success : AppColors.primary,
    ),
    const SizedBox(width: 4),
    Text(
      isCompleted
          ? l10n.completed
          : isRunning
              ? l10n.running
              : l10n.ready,
      style: TextStyle(
        color: isCompleted ? AppColors.success : AppColors.primary,
        fontWeight: FontWeight.w600,
        fontSize: 13,
      ),
    ),
  ],
),
```

> Not: Container içindeki `Text` widget'ını bu `Row` ile değiştir. `child: Text(...)` → `child: Row(...)`.

---

## 14. Settings — Duration Dialog Sadece 15 Dakika

### Sorun
`_showDurationDialog` (settings_screen.dart, satır 263) içinde `[10, 15]` listesi hard-coded.
`AppConstants.taskDurationOptions` zaten `[15]` olarak güncellenmiştir (önceki oturumda).
Settings ekranındaki seçenek listesi de bununla uyumlu olmalıdır.

### Değişiklik

**`lib/features/settings/presentation/screens/settings_screen.dart`** — `AppConstants` import'u zaten mevcut. Satır 263:

Eski:
```dart
Row(
  children: [10, 15].map((duration) {
```

Yeni:
```dart
Row(
  children: AppConstants.taskDurationOptions.map((duration) {
```

> **Not:** `AppConstants.taskDurationOptions = [15]` olduğu için tek seçenek kalır; seçim gereksizleşir. İstersen duration tile'ı tamamen dialog yerine sadece bilgi gösterir hale getirebilirsin (`onTap: null`).

---

## 15. ~~Özel Oda Ekleme~~ — Kaldırıldı ✅

### Sorun (Çözüldü)
`room_setup_screen.dart` ve `_RoomsBottomSheet` (settings) içinde kullanıcı serbest metin girerek özel oda ekleyebiliyordu. Bu özellik kaldırılması istendi.

### Yapılan Değişiklik
- `room_setup_screen.dart`: `_customController`, `_showAddCustomRoomDialog()` ve "Özel oda ekle" `OutlinedButton` kaldırıldı.
- `settings_screen.dart` (`_RoomsBottomSheet`): `_controller`, `_addRoom()` (TextField tabanlı), serbest metin `TextField` + ekleme butonu kaldırıldı. Yerine `AppConstants.roomPresets`'ten filtreli "Hızlı Ekle" chip'leri eklendi.

---

## 16. withOpacity Deprecation — withValues'a Geç

### Sorun
Flutter son sürümlerinde `Color.withOpacity()` deprecated oldu; `Color.withValues(alpha: x)` kullanılması öneriliyor. Şu an 50+ `info` uyarısı var.

### Etkilenen Dosyalar (en yoğun)
- `home_screen.dart` (~20 kullanım)
- `task_reveal_popup.dart` (~10 kullanım)
- `settings_screen.dart` (~8 kullanım)

### Değişiklik
Her `color.withOpacity(x)` → `color.withValues(alpha: x)` olarak değiştir.

> Toplu değiştirme için: `sed -i 's/\.withOpacity(\(.*\))/.withValues(alpha: \1)/g'` (test et).

---

## Öncelik Sırası (Güncel)

| # | Değişiklik | Etki | Zorluk | Durum |
|---|-----------|------|--------|-------|
| 16 | `withOpacity` → `withValues` | Düşük | Düşük | ⏳ Bekliyor |
| 1 | Hard-coded renkler → AppColors | Yüksek | Düşük | ⏳ Bekliyor |
| 2 | Snackbar yardımcı fonksiyon | Orta | Düşük | ⏳ Bekliyor |
| 3 | NavigationBar geçişi | Yüksek | Orta | ⏳ Bekliyor |
| 6 | Version string → AppConstants | Düşük | Çok Düşük | ⏳ Bekliyor |
| 7 | Dil label lokalizasyonu | Orta | Düşük | ⏳ Bekliyor |
| 8 | Login logo ikonu | Orta | Çok Düşük | ⏳ Bekliyor |
| 9 | AppBar leading kaldır | Düşük | Çok Düşük | ⏳ Bekliyor |
| 10 | Konfeti renkleri | Düşük | Çok Düşük | ⏳ Bekliyor |
| 12 | Splash arka plan tutarlılığı | Düşük | Çok Düşük | ⏳ Bekliyor |
| 13 | Timer durum badge | Orta | Düşük | ⏳ Bekliyor |
| 14 | Duration dialog → AppConstants | Orta | Düşük | ⏳ Bekliyor |
| 4 | Timer kapatma butonu | Orta | Düşük | ⏳ Bekliyor |
| 5 | Streak badge rengi | Düşük | Çok Düşük | ⏳ Bekliyor |
| 15 | Özel oda ekleme kaldır | — | — | ✅ Tamamlandı |
| T1 | N+1 query fix | — | — | ✅ Tamamlandı |
| T2 | Timezone fix | — | — | ✅ Tamamlandı |
| T3 | Streak Freeze | — | — | ✅ Tamamlandı |
| T4 | Optimistic streak update | — | — | ✅ Tamamlandı |
| T5 | Notification permission feedback | — | — | ✅ Tamamlandı |
| T6 | Push + local notif sync | — | — | ✅ Tamamlandı |
| T7 | Görev blacklist | — | — | ✅ Tamamlandı |

---

## Değiştirilmeyecekler (Kapsam Dışı)

- Mevcut routing yapısı (GoRouter) — çalışıyor
- Riverpod state management mimarisi — iyi yapılandırılmış
- Feature-based klasör yapısı — doğru
- Lokalizasyon altyapısı (ARB dosyaları) — eksiksiz
- Supabase entegrasyonu — iş mantığı
- Animasyon süresi sabitleri — işlevsel, kritik değil
