import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';

/// Cache anahtar sabitleri
class CacheKeys {
  static const String userProfile = 'user_profile';
  static const String rooms = 'rooms';
  static const String todayTask = 'today_task';
  static const String tasksCatalog = 'tasks_catalog';
  static const String completedTasks = 'completed_tasks';
  static const String stats = 'stats';
  static const String lastSync = 'last_sync';
}

/// Cache süresi sabitleri
class CacheDuration {
  static const Duration profile = Duration(hours: 24);
  static const Duration rooms = Duration(hours: 24);
  static const Duration todayTask = Duration(hours: 1);
  static const Duration catalog = Duration(days: 7);
  static const Duration stats = Duration(hours: 1);
}

/// Cache girişi wrapper'ı
class CacheEntry<T> {
  final T data;
  final DateTime cachedAt;
  final Duration validFor;

  CacheEntry({
    required this.data,
    required this.cachedAt,
    required this.validFor,
  });

  bool get isExpired => DateTime.now().difference(cachedAt) > validFor;
  bool get isValid => !isExpired;

  Map<String, dynamic> toJson(dynamic Function(T) dataToJson) => {
    'data': dataToJson(data),
    'cachedAt': cachedAt.toIso8601String(),
    'validFor': validFor.inMilliseconds,
  };

  factory CacheEntry.fromJson(
    Map<String, dynamic> json,
    T Function(dynamic) dataFromJson,
  ) {
    return CacheEntry(
      data: dataFromJson(json['data']),
      cachedAt: DateTime.parse(json['cachedAt']),
      validFor: Duration(milliseconds: json['validFor']),
    );
  }
}

/// Cache Service - Offline veri yönetimi
class CacheService {
  static CacheService? _instance;
  static CacheService get instance => _instance ??= CacheService._();
  
  CacheService._();

  static const String _boxName = 'cleanloop_cache';
  Box? _box;

  /// Servisi başlat
  Future<void> initialize() async {
    try {
      _box = await Hive.openBox(_boxName);
      debugPrint('CacheService initialized');
    } catch (e) {
      debugPrint('CacheService initialization error: $e');
    }
  }

  /// Veri kaydet
  Future<void> save<T>(
    String key,
    T data, {
    Duration validFor = const Duration(hours: 1),
    dynamic Function(T)? toJson,
  }) async {
    if (_box == null) return;

    try {
      final entry = {
        'data': toJson != null ? toJson(data) : data,
        'cachedAt': DateTime.now().toIso8601String(),
        'validFor': validFor.inMilliseconds,
      };

      await _box!.put(key, entry);
      debugPrint('Cache saved: $key');
    } catch (e) {
      debugPrint('Cache save error: $e');
    }
  }

  /// Veri getir (geçerli ise)
  T? get<T>(
    String key, {
    T Function(dynamic)? fromJson,
    bool ignoreExpiry = false,
  }) {
    if (_box == null) return null;

    try {
      final entry = _box!.get(key);
      if (entry == null) return null;

      final cachedAt = DateTime.parse(entry['cachedAt']);
      final validFor = Duration(milliseconds: entry['validFor']);
      final isExpired = DateTime.now().difference(cachedAt) > validFor;

      if (!ignoreExpiry && isExpired) {
        debugPrint('Cache expired: $key');
        return null;
      }

      final data = entry['data'];
      return fromJson != null ? fromJson(data) : data as T;
    } catch (e) {
      debugPrint('Cache get error: $e');
      return null;
    }
  }

  /// Veri sil
  Future<void> delete(String key) async {
    if (_box == null) return;

    try {
      await _box!.delete(key);
      debugPrint('Cache deleted: $key');
    } catch (e) {
      debugPrint('Cache delete error: $e');
    }
  }

  /// Tüm cache'i temizle
  Future<void> clearAll() async {
    if (_box == null) return;

    try {
      await _box!.clear();
      debugPrint('Cache cleared');
    } catch (e) {
      debugPrint('Cache clear error: $e');
    }
  }

  /// Belirli prefix ile başlayan anahtarları temizle
  Future<void> clearWithPrefix(String prefix) async {
    if (_box == null) return;

    try {
      final keysToDelete = _box!.keys.where((k) => k.toString().startsWith(prefix)).toList();
      for (final key in keysToDelete) {
        await _box!.delete(key);
      }
      debugPrint('Cache cleared with prefix: $prefix');
    } catch (e) {
      debugPrint('Cache clear error: $e');
    }
  }

  /// Cache durumunu kontrol et
  bool has(String key) {
    if (_box == null) return false;
    return _box!.containsKey(key);
  }

  /// Cache geçerli mi kontrol et
  bool isValid(String key) {
    if (_box == null) return false;

    try {
      final entry = _box!.get(key);
      if (entry == null) return false;

      final cachedAt = DateTime.parse(entry['cachedAt']);
      final validFor = Duration(milliseconds: entry['validFor']);
      return DateTime.now().difference(cachedAt) <= validFor;
    } catch (e) {
      return false;
    }
  }

  /// Son senkronizasyon zamanını kaydet
  Future<void> setLastSync() async {
    await save(CacheKeys.lastSync, DateTime.now().toIso8601String());
  }

  /// Son senkronizasyon zamanını getir
  DateTime? getLastSync() {
    final timestamp = get<String>(CacheKeys.lastSync, ignoreExpiry: true);
    return timestamp != null ? DateTime.tryParse(timestamp) : null;
  }

  // ==================== SPECIFIC CACHE METHODS ====================

  /// Kullanıcı profilini cache'le
  Future<void> cacheUserProfile(Map<String, dynamic> profile) async {
    await save(
      CacheKeys.userProfile,
      profile,
      validFor: CacheDuration.profile,
    );
  }

  /// Kullanıcı profilini getir
  Map<String, dynamic>? getCachedUserProfile() {
    return get<Map<String, dynamic>>(
      CacheKeys.userProfile,
      fromJson: (data) => Map<String, dynamic>.from(data),
    );
  }

  /// Odaları cache'le
  Future<void> cacheRooms(List<Map<String, dynamic>> rooms) async {
    await save(
      CacheKeys.rooms,
      rooms,
      validFor: CacheDuration.rooms,
    );
  }

  /// Odaları getir
  List<Map<String, dynamic>>? getCachedRooms() {
    return get<List<Map<String, dynamic>>>(
      CacheKeys.rooms,
      fromJson: (data) => List<Map<String, dynamic>>.from(
        (data as List).map((e) => Map<String, dynamic>.from(e)),
      ),
    );
  }

  /// Bugünün görevini cache'le
  Future<void> cacheTodayTask(Map<String, dynamic> task) async {
    await save(
      CacheKeys.todayTask,
      task,
      validFor: CacheDuration.todayTask,
    );
  }

  /// Bugünün görevini getir
  Map<String, dynamic>? getCachedTodayTask() {
    return get<Map<String, dynamic>>(
      CacheKeys.todayTask,
      fromJson: (data) => Map<String, dynamic>.from(data),
    );
  }

  /// Görev kataloğunu cache'le
  Future<void> cacheTasksCatalog(List<Map<String, dynamic>> catalog) async {
    await save(
      CacheKeys.tasksCatalog,
      catalog,
      validFor: CacheDuration.catalog,
    );
  }

  /// Görev kataloğunu getir
  List<Map<String, dynamic>>? getCachedTasksCatalog() {
    return get<List<Map<String, dynamic>>>(
      CacheKeys.tasksCatalog,
      fromJson: (data) => List<Map<String, dynamic>>.from(
        (data as List).map((e) => Map<String, dynamic>.from(e)),
      ),
    );
  }

  /// İstatistikleri cache'le
  Future<void> cacheStats(Map<String, dynamic> stats) async {
    await save(
      CacheKeys.stats,
      stats,
      validFor: CacheDuration.stats,
    );
  }

  /// İstatistikleri getir
  Map<String, dynamic>? getCachedStats() {
    return get<Map<String, dynamic>>(
      CacheKeys.stats,
      fromJson: (data) => Map<String, dynamic>.from(data),
    );
  }
}

// Singleton instance
final cacheService = CacheService.instance;

