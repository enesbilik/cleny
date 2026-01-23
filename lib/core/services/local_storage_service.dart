import 'package:hive_flutter/hive_flutter.dart';

/// Local storage servisi (Hive)
class LocalStorageService {
  static const String _settingsBoxName = 'settings';
  static const String _cacheBoxName = 'cache';

  static Box? _settingsBox;
  static Box? _cacheBox;

  /// Hive'ı başlat
  static Future<void> initialize() async {
    await Hive.initFlutter();
    _settingsBox = await Hive.openBox(_settingsBoxName);
    _cacheBox = await Hive.openBox(_cacheBoxName);
  }

  /// Settings box'ı al
  static Box get settingsBox {
    if (_settingsBox == null) {
      throw Exception('LocalStorageService henüz başlatılmadı');
    }
    return _settingsBox!;
  }

  /// Cache box'ı al
  static Box get cacheBox {
    if (_cacheBox == null) {
      throw Exception('LocalStorageService henüz başlatılmadı');
    }
    return _cacheBox!;
  }

  // Settings methods
  static Future<void> saveSetting<T>(String key, T value) async {
    await settingsBox.put(key, value);
  }

  static T? getSetting<T>(String key, {T? defaultValue}) {
    return settingsBox.get(key, defaultValue: defaultValue) as T?;
  }

  static Future<void> deleteSetting(String key) async {
    await settingsBox.delete(key);
  }

  // Cache methods
  static Future<void> saveCache<T>(String key, T value) async {
    await cacheBox.put(key, value);
  }

  static T? getCache<T>(String key, {T? defaultValue}) {
    return cacheBox.get(key, defaultValue: defaultValue) as T?;
  }

  static Future<void> deleteCache(String key) async {
    await cacheBox.delete(key);
  }

  /// Tüm verileri temizle
  static Future<void> clearAll() async {
    await settingsBox.clear();
    await cacheBox.clear();
  }

  /// Sadece cache'i temizle
  static Future<void> clearCache() async {
    await cacheBox.clear();
  }
}

