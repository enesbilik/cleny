import 'dart:io';
import 'package:app_settings/app_settings.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

const int _kTimerId = 100;
const int _kTestInstantId = 999;

/// Bildirim servisi — singleton
///
/// Yerel bildirimler sadece timer tamamlanma ve anlık test için kullanılır.
/// Günlük görev ve motivasyon bildirimleri OneSignal (Supabase Edge Function) üzerinden gelir.
class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;

  static const _timerChannel = AndroidNotificationDetails(
    'timer',
    'Timer',
    channelDescription: 'Timer tamamlanma bildirimleri',
    importance: Importance.high,
    priority: Priority.high,
    icon: '@mipmap/ic_launcher',
  );

  static const _testChannel = AndroidNotificationDetails(
    'test',
    'Test',
    channelDescription: 'Test bildirimleri',
    importance: Importance.high,
    priority: Priority.high,
    icon: '@mipmap/ic_launcher',
  );

  static const _iosDefault = DarwinNotificationDetails(
    presentAlert: true,
    presentBadge: true,
    presentSound: true,
  );

  // ─── Başlatma ───────────────────────────────────────────────────────────────

  Future<void> initialize() async {
    if (_initialized) return;

    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    await _notifications.initialize(
      const InitializationSettings(android: androidSettings, iOS: iosSettings),
      onDidReceiveNotificationResponse: _onTapped,
    );

    _initialized = true;
    debugPrint('NotificationService initialized ✅');
  }

  void _onTapped(NotificationResponse response) {
    debugPrint('Bildirime tıklandı: ${response.payload}');
  }

  // ─── İzin ───────────────────────────────────────────────────────────────────

  /// Bildirim izni iste. OneSignal için de gerekli.
  Future<bool> requestPermission() async {
    if (Platform.isIOS) {
      final result = await _notifications
          .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(alert: true, badge: true, sound: true);
      return result ?? false;
    } else if (Platform.isAndroid) {
      final result = await _notifications
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.requestNotificationsPermission();
      return result ?? false;
    }
    return false;
  }

  /// Cihazın bildirim ayarları sayfasını aç.
  Future<void> openNotificationSettings() async {
    try {
      await AppSettings.openAppSettings(type: AppSettingsType.notification);
    } catch (e) {
      debugPrint('openNotificationSettings error: $e');
    }
  }

  /// Mevcut bildirim iznini sorgula.
  Future<bool> hasPermission() async {
    if (Platform.isAndroid) {
      final impl = _notifications.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();
      return await impl?.areNotificationsEnabled() ?? false;
    }
    return true;
  }

  // ─── Anlık bildirimler ───────────────────────────────────────────────────────

  /// Timer ekranı kapandığında çalan anlık bildirim.
  Future<void> showTimerCompletedNotification() async {
    await _notifications.show(
      _kTimerId,
      'Süre Doldu! ⏰',
      'Görevini tamamlamak için uygulamaya dön.',
      NotificationDetails(android: _timerChannel, iOS: _iosDefault),
    );
  }

  /// Anında görünen test bildirimi.
  Future<void> showTestNotification() async {
    await _notifications.show(
      _kTestInstantId,
      'Test Bildirimi 🧪',
      'Bildirimler çalışıyor! Harika!',
      NotificationDetails(android: _testChannel, iOS: _iosDefault),
    );
    debugPrint('Test bildirimi gönderildi ✅');
  }

  Future<void> cancelAllNotifications() async => _notifications.cancelAll();
  Future<void> cancelNotification(int id) async => _notifications.cancel(id);
}
