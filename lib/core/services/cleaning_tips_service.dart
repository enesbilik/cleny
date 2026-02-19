import 'package:flutter/foundation.dart';
import 'supabase_service.dart';
import 'cache_service.dart' show cacheService;

/// Temizlik ipucu modeli
class CleaningTip {
  final String id;
  final String tipText;
  final String? category;

  CleaningTip({
    required this.id,
    required this.tipText,
    this.category,
  });

  factory CleaningTip.fromJson(Map<String, dynamic> json) {
    return CleaningTip(
      id: json['id'] as String,
      tipText: json['tip_text'] as String,
      category: json['category'] as String?,
    );
  }
}

/// Temizlik ipuçları servisi
class CleaningTipsService {
  static const String _cacheKey = 'daily_cleaning_tip';
  static const String _cacheDateKey = 'daily_cleaning_tip_date';

  /// Günün ipucunu al (cache destekli - her gün bir kez çekilir)
  /// Bugünün tarihine (tip_date) göre spesifik ipucu seçilir.
  static Future<String?> getDailyTip() async {
    try {
      final today = DateTime.now();
      final todayStr = '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';

      // Cache'den bugünün ipucunu kontrol et
      final cachedDate = cacheService.get<String>(
        _cacheDateKey,
        fromJson: (d) => d as String,
        ignoreExpiry: true,
      );

      if (cachedDate == todayStr) {
        final cachedTip = cacheService.get<String>(
          _cacheKey,
          fromJson: (d) => d as String,
          ignoreExpiry: true,
        );
        if (cachedTip != null && cachedTip.isNotEmpty) {
          debugPrint('Daily tip loaded from cache');
          return cachedTip;
        }
      }

      // Önce bugünün tarihine ait spesifik ipucunu çek
      final response = await SupabaseService.client
          .from('cleaning_tips')
          .select('id, tip_text, category')
          .eq('is_active', true)
          .eq('tip_date', todayStr)
          .limit(1);

      if ((response as List).isNotEmpty) {
        final tip = CleaningTip.fromJson(response[0]);
        await _saveToCache(tip.tipText, todayStr);
        debugPrint('Daily tip fetched from Supabase for $todayStr: ${tip.tipText}');
        return tip.tipText;
      }

      // Bugün için kayıt yoksa en yakın geçmiş tarihli ipucuna bak
      final fallbackResponse = await SupabaseService.client
          .from('cleaning_tips')
          .select('id, tip_text, category')
          .eq('is_active', true)
          .not('tip_date', 'is', null)
          .lte('tip_date', todayStr)
          .order('tip_date', ascending: false)
          .limit(1);

      if ((fallbackResponse as List).isNotEmpty) {
        final tip = CleaningTip.fromJson(fallbackResponse[0]);
        await _saveToCache(tip.tipText, todayStr);
        debugPrint('Daily tip fallback (closest past date): ${tip.tipText}');
        return tip.tipText;
      }

      debugPrint('No cleaning tip found for $todayStr');
      return null;
    } catch (e) {
      debugPrint('getDailyTip error: $e');

      // Hata durumunda cache'den eski ipucu varsa onu göster
      final cachedTip = cacheService.get<String>(
        _cacheKey,
        fromJson: (d) => d as String,
        ignoreExpiry: true,
      );
      return cachedTip;
    }
  }

  /// Cache'e kaydet helper metodu
  static Future<void> _saveToCache(String tipText, String dateStr) async {
    await cacheService.save(
      _cacheKey,
      tipText,
      validFor: const Duration(days: 1),
    );
    await cacheService.save(
      _cacheDateKey,
      dateStr,
      validFor: const Duration(days: 1),
    );
  }

  /// Tüm ipuçlarını al (admin/yönetim için)
  static Future<List<CleaningTip>> getAllTips() async {
    try {
      final response = await SupabaseService.client
          .from('cleaning_tips')
          .select('id, tip_text, category')
          .eq('is_active', true)
          .order('created_at', ascending: false);

      return (response as List)
          .map((item) => CleaningTip.fromJson(item))
          .toList();
    } catch (e) {
      debugPrint('getAllTips error: $e');
      return [];
    }
  }
}
