import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/local_storage_service.dart';
import '../services/supabase_service.dart';

const String _localeKey = 'app_locale';

/// Uygulama dili provider
final localeProvider = StateNotifierProvider<LocaleNotifier, Locale>((ref) {
  return LocaleNotifier();
});

/// Locale notifier
class LocaleNotifier extends StateNotifier<Locale> {
  LocaleNotifier() : super(const Locale('tr')) {
    loadLocale();
  }

  /// Locale'i yükle (public - splash screen'den çağrılabilir)
  Future<void> loadLocale() async {
    try {
      // Önce Supabase'den oku (eğer login yapılmışsa)
      if (SupabaseService.isAuthenticated) {
        final userId = SupabaseService.currentUser?.id;
        if (userId != null) {
          final profileResponse = await SupabaseService.client
              .from('users_profile')
              .select('preferred_language')
              .eq('user_id', userId)
              .maybeSingle();

          final preferredLanguage = profileResponse?['preferred_language'] as String?;
          if (preferredLanguage != null && (preferredLanguage == 'tr' || preferredLanguage == 'en')) {
            state = Locale(preferredLanguage);
            debugPrint('Locale loaded from Supabase: $preferredLanguage');
            return;
          }
        }
      }

      // Supabase'de yoksa local storage'dan oku
      final savedLocale = LocalStorageService.getSetting<String>(_localeKey);
      if (savedLocale != null) {
        state = Locale(savedLocale);
        debugPrint('Locale loaded from local storage: $savedLocale');
        return;
      }

      // Varsayılan olarak Türkçe
      state = const Locale('tr');
    } catch (e) {
      debugPrint('_loadLocale ERROR: $e');
      // Hata durumunda local storage'dan oku
      final savedLocale = LocalStorageService.getSetting<String>(_localeKey);
      if (savedLocale != null) {
        state = Locale(savedLocale);
      }
    }
  }

  /// Dili değiştir
  Future<void> setLocale(Locale locale) async {
    state = locale;

    try {
      // Supabase'e kaydet (eğer login yapılmışsa)
      if (SupabaseService.isAuthenticated) {
        final userId = SupabaseService.currentUser?.id;
        if (userId != null) {
          await SupabaseService.client
              .from('users_profile')
              .update({'preferred_language': locale.languageCode})
              .eq('user_id', userId);
          
          debugPrint('Locale saved to Supabase: ${locale.languageCode}');
        }
      }

      // Local storage'a da kaydet (fallback)
      await LocalStorageService.saveSetting(_localeKey, locale.languageCode);
    } catch (e) {
      debugPrint('setLocale ERROR: $e');
      // Hata olsa bile local storage'a kaydet
      await LocalStorageService.saveSetting(_localeKey, locale.languageCode);
    }
  }

  /// Türkçeye çevir
  Future<void> setTurkish() => setLocale(const Locale('tr'));

  /// İngilizceye çevir
  Future<void> setEnglish() => setLocale(const Locale('en'));

  /// Mevcut dil Türkçe mi?
  bool get isTurkish => state.languageCode == 'tr';
}

