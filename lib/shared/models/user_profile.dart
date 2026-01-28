import 'package:equatable/equatable.dart';

/// Kullanıcı profil modeli
class UserProfile extends Equatable {
  final String id;
  final int preferredMinutes;
  final String availableStart;
  final String availableEnd;
  final bool notificationsEnabled;
  final bool motivationEnabled;
  final bool soundEnabled;
  final String preferredLanguage;
  final String timezone;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const UserProfile({
    required this.id,
    this.preferredMinutes = 10,
    this.availableStart = '19:00',
    this.availableEnd = '22:00',
    this.notificationsEnabled = true,
    this.motivationEnabled = true,
    this.soundEnabled = true,
    this.preferredLanguage = 'tr',
    this.timezone = 'Europe/Istanbul',
    required this.createdAt,
    this.updatedAt,
  });

  /// Boş profil oluştur
  factory UserProfile.empty(String id) {
    return UserProfile(
      id: id,
      createdAt: DateTime.now(),
    );
  }

  /// JSON'dan oluştur
  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['user_id'] as String,
      preferredMinutes: json['preferred_minutes'] as int? ?? 10,
      availableStart: json['available_start'] as String? ?? '19:00',
      availableEnd: json['available_end'] as String? ?? '22:00',
      notificationsEnabled: json['notifications_enabled'] as bool? ?? true,
      motivationEnabled: json['motivation_enabled'] as bool? ?? true,
      soundEnabled: json['sound_enabled'] as bool? ?? true,
      preferredLanguage: json['preferred_language'] as String? ?? 'tr',
      timezone: json['timezone'] as String? ?? 'Europe/Istanbul',
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
    );
  }

  /// JSON'a dönüştür
  Map<String, dynamic> toJson() {
    return {
      'user_id': id,
      'preferred_minutes': preferredMinutes,
      'available_start': availableStart,
      'available_end': availableEnd,
      'notifications_enabled': notificationsEnabled,
      'motivation_enabled': motivationEnabled,
      'sound_enabled': soundEnabled,
      'preferred_language': preferredLanguage,
      'timezone': timezone,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  /// Kopyala ve güncelle
  UserProfile copyWith({
    String? id,
    int? preferredMinutes,
    String? availableStart,
    String? availableEnd,
    bool? notificationsEnabled,
    bool? motivationEnabled,
    bool? soundEnabled,
    String? preferredLanguage,
    String? timezone,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserProfile(
      id: id ?? this.id,
      preferredMinutes: preferredMinutes ?? this.preferredMinutes,
      availableStart: availableStart ?? this.availableStart,
      availableEnd: availableEnd ?? this.availableEnd,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      motivationEnabled: motivationEnabled ?? this.motivationEnabled,
      soundEnabled: soundEnabled ?? this.soundEnabled,
      preferredLanguage: preferredLanguage ?? this.preferredLanguage,
      timezone: timezone ?? this.timezone,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        preferredMinutes,
        availableStart,
        availableEnd,
        notificationsEnabled,
        motivationEnabled,
        soundEnabled,
        preferredLanguage,
        timezone,
        createdAt,
        updatedAt,
      ];
}

