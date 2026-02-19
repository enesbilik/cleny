import 'package:flutter/foundation.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';

import 'supabase_service.dart';

/// OneSignal Push Notification servisi
class OneSignalService {
  static const String _appId = '6cd0104d-dd1d-411d-9852-aeddf4d96b32';
  
  static bool _initialized = false;

  /// OneSignal'ı başlat
  static Future<void> initialize() async {
    if (_initialized) return;

    // Debug logging (production'da kapat)
    OneSignal.Debug.setLogLevel(OSLogLevel.verbose);

    // OneSignal'ı başlat
    OneSignal.initialize(_appId);

    // Bildirim izni iste
    await OneSignal.Notifications.requestPermission(true);

    // Bildirim tıklama dinleyicisi
    OneSignal.Notifications.addClickListener((event) {
      debugPrint('OneSignal: Bildirime tıklandı: ${event.notification.title}');
      // İleride deep linking eklenebilir
    });

    // Bildirim geldiğinde (foreground)
    OneSignal.Notifications.addForegroundWillDisplayListener((event) {
      debugPrint('OneSignal: Bildirim geldi: ${event.notification.title}');
      // Bildirimi göster
      event.preventDefault();
      event.notification.display();
    });

    _initialized = true;
    debugPrint('OneSignal initialized ✅');
  }

  /// Kullanıcıyı OneSignal'a kaydet (login sonrası çağır)
  static Future<void> setExternalUserId(String? userId) async {
    if (userId == null) return;
    
    try {
      await OneSignal.login(userId);
      debugPrint('OneSignal: User ID set: $userId');
    } catch (e) {
      debugPrint('OneSignal setExternalUserId error: $e');
    }
  }

  /// Kullanıcı çıkış yaptığında
  static Future<void> removeExternalUserId() async {
    try {
      await OneSignal.logout();
      debugPrint('OneSignal: User logged out');
    } catch (e) {
      debugPrint('OneSignal logout error: $e');
    }
  }

  /// Kullanıcıya tag ekle (segmentation için)
  static Future<void> setUserTags(Map<String, String> tags) async {
    try {
      await OneSignal.User.addTags(tags);
      debugPrint('OneSignal: Tags set: $tags');
    } catch (e) {
      debugPrint('OneSignal setUserTags error: $e');
    }
  }

  /// Streak bilgisini güncelle (segmentation için)
  static Future<void> updateStreakTag(int streak) async {
    await setUserTags({'streak': streak.toString()});
  }

  /// Görev durumunu güncelle
  static Future<void> updateTaskStatus({
    required bool completedToday,
    required int totalCompleted,
  }) async {
    await setUserTags({'completed_today': completedToday ? 'yes' : 'no'});
  }

  /// Son aktif zamanı güncelle
  static Future<void> updateLastActive() async {
    final now = DateTime.now();
    await setUserTags({
      'last_active_date': '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}',
    });
  }

  /// Mevcut kullanıcı ID'sini al ve OneSignal'a kaydet
  static Future<void> syncCurrentUser() async {
    final user = SupabaseService.currentUser;
    if (user != null) {
      await setExternalUserId(user.id);
      await updateLastActive();
    }
  }
}

