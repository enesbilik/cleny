import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz_data;

/// Bildirim servisi
class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;

  /// Servisi başlat
  Future<void> initialize() async {
    if (_initialized) return;

    // Timezone'ları başlat
    tz_data.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('Europe/Istanbul'));

    // Android ayarları
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');

    // iOS ayarları
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    const settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notifications.initialize(
      settings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    _initialized = true;
  }

  /// Bildirime tıklandığında
  void _onNotificationTapped(NotificationResponse response) {
    debugPrint('Notification tapped: ${response.payload}');
    // İleride deep linking eklenebilir
  }

  /// İzin iste
  Future<bool> requestPermission() async {
    if (Platform.isIOS) {
      final result = await _notifications
          .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(
            alert: true,
            badge: true,
            sound: true,
          );
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

  /// Günlük görev bildirimi zamanla
  Future<void> scheduleDailyTaskNotification({
    required int hour,
    required int minute,
    String title = 'Bugünün Sürprizi Hazır! 🎁',
    String body = '10 dakikada evini toparla!',
  }) async {
    // Mevcut bildirimi iptal et
    await _notifications.cancel(1);

    // Yeni zamanı hesapla
    final now = tz.TZDateTime.now(tz.local);
    var scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );

    // Eğer zaman geçtiyse yarına ayarla
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    await _notifications.zonedSchedule(
      1, // Görev bildirimi ID'si
      title,
      body,
      scheduledDate,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'daily_task',
          'Günlük Görev',
          channelDescription: 'Günlük temizlik görev bildirimleri',
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time, // Her gün tekrarla
    );

    debugPrint('Bildirim zamanlandı: $scheduledDate');
  }

  /// Motivasyon bildirimi zamanla
  Future<void> scheduleMotivationNotification({
    int hour = 12,
    int minute = 0,
    String title = 'Küçük Adımlar, Büyük Fark! ✨',
    String body = 'Bugün bir mikro görev tamamladın mı?',
  }) async {
    // Mevcut bildirimi iptal et
    await _notifications.cancel(2);

    final now = tz.TZDateTime.now(tz.local);
    var scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );

    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    await _notifications.zonedSchedule(
      2, // Motivasyon bildirimi ID'si
      title,
      body,
      scheduledDate,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'motivation',
          'Motivasyon',
          channelDescription: 'Motivasyon bildirimleri',
          importance: Importance.defaultImportance,
          priority: Priority.defaultPriority,
          icon: '@mipmap/ic_launcher',
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: false,
          presentSound: true,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  /// Tüm bildirimleri iptal et
  Future<void> cancelAllNotifications() async {
    await _notifications.cancelAll();
  }

  /// Belirli bir bildirimi iptal et
  Future<void> cancelNotification(int id) async {
    await _notifications.cancel(id);
  }

  /// Timer tamamlandı bildirimi (anında)
  Future<void> showTimerCompletedNotification() async {
    await _notifications.show(
      100,
      'Süre Doldu! ⏰',
      'Görevini tamamlamak için uygulamaya dön.',
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'timer',
          'Timer',
          channelDescription: 'Timer bildirimleri',
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
    );
  }

  /// 🧪 TEST: Anında bildirim göster
  Future<void> showTestNotification() async {
    await _notifications.show(
      999,
      'Test Bildirimi 🧪',
      'Bildirimler çalışıyor! Harika!',
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'test',
          'Test',
          channelDescription: 'Test bildirimleri',
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
    );
  }

  /// 🧪 TEST: 5 saniye sonra bildirim göster
  Future<void> showDelayedTestNotification() async {
    final scheduledDate = tz.TZDateTime.now(tz.local).add(const Duration(seconds: 5));
    
    await _notifications.zonedSchedule(
      998,
      'Zamanlanmış Test 🕐',
      '5 saniye sonra geldi! Zamanlama çalışıyor!',
      scheduledDate,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'test',
          'Test',
          channelDescription: 'Test bildirimleri',
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
    
    debugPrint('Test bildirimi zamanlandı: $scheduledDate');
  }

  /// Motivasyon mesajları listesi
  static const List<Map<String, String>> motivationMessages = [
    {'title': 'Bugün Harika Bir Gün! 🌟', 'body': 'Sadece 10 dakika ile evini değiştir!'},
    {'title': 'Süpermen Değilsin, Ama... 💪', 'body': 'Süper temiz bir ev yapabilirsin!'},
    {'title': 'Netflix Bekleyebilir 📺', 'body': 'Önce 10 dakika temizlik, sonra dizi!'},
    {'title': 'Temizlik = Terapi 🧘', 'body': 'Zihnini de temizle, evini de!'},
    {'title': '3... 2... 1... Başla! 🚀', 'body': 'Bugünün görevi seni bekliyor!'},
    {'title': 'Anne Görse Gurur Duyardı 👩', 'body': '10 dakikada anneyi mutlu et!'},
    {'title': 'Streak\'ini Kırma! 🔥', 'body': 'Bugün de devam et, şampiyon!'},
    {'title': 'Evdeki Kahraman! 🦸', 'body': 'Bugünkü görevini al ve parla!'},
    {'title': 'Mikro Görev Zamanı! ⚡', 'body': 'Küçük adım, büyük fark yaratır!'},
    {'title': 'Temiz Ev, Mutlu Sen! 😊', 'body': 'Bugün de kendine bir iyilik yap!'},
  ];

  /// 🧪 TEST: Rastgele motivasyon bildirimi göster (5 saniye sonra)
  Future<void> showRandomMotivationNotification() async {
    final random = DateTime.now().millisecondsSinceEpoch % motivationMessages.length;
    final message = motivationMessages[random];
    final scheduledDate = tz.TZDateTime.now(tz.local).add(const Duration(seconds: 5));
    
    await _notifications.zonedSchedule(
      997,
      message['title']!,
      message['body']!,
      scheduledDate,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'motivation',
          'Motivasyon',
          channelDescription: 'Motivasyon bildirimleri',
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
    
    debugPrint('Motivasyon bildirimi zamanlandı: $scheduledDate');
  }
}

