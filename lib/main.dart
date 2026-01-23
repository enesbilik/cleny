import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'l10n/generated/app_localizations.dart';

import 'core/theme/app_theme.dart';
import 'core/router/app_router.dart';
import 'core/services/local_storage_service.dart';
import 'core/services/supabase_service.dart';
import 'core/services/notification_service.dart';
import 'core/services/sound_service.dart';
import 'core/services/cache_service.dart';
import 'core/providers/locale_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Status bar ayarı
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );

  // Sadece dikey mod
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // .env dosyasını yükle
  await dotenv.load(fileName: '.env');

  // Local storage'ı başlat
  await LocalStorageService.initialize();

  // Cache servisini başlat
  await cacheService.initialize();

  // Supabase'i başlat
  try {
    await SupabaseService.initialize();
  } catch (e) {
    debugPrint('Supabase başlatılamadı: $e');
    // Offline modda devam et
  }

  // Bildirimleri başlat
  await NotificationService().initialize();

  // Ses servisini başlat
  await soundService.initialize();

  runApp(
    const ProviderScope(
      child: CleanLoopApp(),
    ),
  );
}

class CleanLoopApp extends ConsumerWidget {
  const CleanLoopApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    final locale = ref.watch(localeProvider);

    return MaterialApp.router(
      key: ValueKey(locale.languageCode), // Locale değiştiğinde rebuild zorla
      title: 'CleanLoop',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      routerConfig: router,
      locale: locale,
      localeResolutionCallback: (locale, supportedLocales) {
        // Kullanıcının seçtiği locale'i öncelikli kullan
        final currentLocale = ref.read(localeProvider);
        return currentLocale;
      },
      supportedLocales: const [
        Locale('en'), // English
        Locale('tr'), // Turkish
      ],
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
    );
  }
}
