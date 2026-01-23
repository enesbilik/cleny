import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'local_storage_service.dart';
import '../constants/app_constants.dart';

/// Ses efektleri türleri
enum SoundType {
  taskComplete,    // Görev tamamlama
  buttonTap,       // Buton tıklama
  celebration,     // Kutlama
  notification,    // Bildirim
}

/// Sound Service - Ses efektleri yönetimi
class SoundService {
  static SoundService? _instance;
  static SoundService get instance => _instance ??= SoundService._();
  
  SoundService._();

  final AudioPlayer _player = AudioPlayer();
  bool _isInitialized = false;

  /// Ses dosyaları mapping
  static const Map<SoundType, String> _soundFiles = {
    SoundType.taskComplete: 'sounds/complete.mp3',
    SoundType.buttonTap: 'sounds/tap.mp3',
    SoundType.celebration: 'sounds/celebration.mp3',
    SoundType.notification: 'sounds/notification.mp3',
  };

  /// Servisi başlat
  Future<void> initialize() async {
    if (_isInitialized) return;
    
    try {
      // AudioPlayer'ı yapılandır
      await _player.setReleaseMode(ReleaseMode.stop);
      _isInitialized = true;
      debugPrint('SoundService initialized');
    } catch (e) {
      debugPrint('SoundService initialization error: $e');
    }
  }

  /// Ses açık mı kontrol et
  bool get isSoundEnabled {
    return LocalStorageService.getSetting<bool>(
      AppConstants.soundEnabledKey,
      defaultValue: true,
    ) ?? true;
  }

  /// Ses çal
  Future<void> play(SoundType type) async {
    if (!isSoundEnabled) return;
    if (!_isInitialized) await initialize();

    // Haptic feedback her zaman çalışsın
    _triggerHaptic(type);

    try {
      final soundFile = _soundFiles[type];
      if (soundFile == null) return;

      await _player.stop();
      await _player.play(AssetSource(soundFile));
      
      debugPrint('Playing sound: $soundFile');
    } catch (e) {
      // Ses dosyası yoksa sessizce devam et, haptic zaten çalıştı
      debugPrint('Sound play error (haptic triggered): $e');
    }
  }

  /// Haptic feedback tetikle
  void _triggerHaptic(SoundType type) {
    switch (type) {
      case SoundType.taskComplete:
      case SoundType.celebration:
        HapticFeedback.heavyImpact();
        break;
      case SoundType.buttonTap:
        HapticFeedback.lightImpact();
        break;
      case SoundType.notification:
        HapticFeedback.mediumImpact();
        break;
    }
  }

  /// Görev tamamlama sesi
  Future<void> playTaskComplete() => play(SoundType.taskComplete);

  /// Buton tıklama sesi
  Future<void> playButtonTap() => play(SoundType.buttonTap);

  /// Kutlama sesi
  Future<void> playCelebration() => play(SoundType.celebration);

  /// Bildirim sesi
  Future<void> playNotification() => play(SoundType.notification);

  /// Servisi kapat
  Future<void> dispose() async {
    await _player.dispose();
    _isInitialized = false;
  }
}

// Singleton instance
final soundService = SoundService.instance;

