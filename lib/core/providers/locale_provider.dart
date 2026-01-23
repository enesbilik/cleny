import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/local_storage_service.dart';

const String _localeKey = 'app_locale';

/// Uygulama dili provider
final localeProvider = StateNotifierProvider<LocaleNotifier, Locale>((ref) {
  return LocaleNotifier();
});

/// Locale notifier
class LocaleNotifier extends StateNotifier<Locale> {
  LocaleNotifier() : super(_loadLocale());

  static Locale _loadLocale() {
    final savedLocale = LocalStorageService.getSetting<String>(_localeKey);
    if (savedLocale != null) {
      return Locale(savedLocale);
    }
    // Varsayılan olarak Türkçe
    return const Locale('tr');
  }

  /// Dili değiştir
  Future<void> setLocale(Locale locale) async {
    await LocalStorageService.saveSetting(_localeKey, locale.languageCode);
    state = locale;
  }

  /// Türkçeye çevir
  Future<void> setTurkish() => setLocale(const Locale('tr'));

  /// İngilizceye çevir
  Future<void> setEnglish() => setLocale(const Locale('en'));

  /// Mevcut dil Türkçe mi?
  bool get isTurkish => state.languageCode == 'tr';
}

