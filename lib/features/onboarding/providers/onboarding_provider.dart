import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/services/supabase_service.dart';
import '../../../shared/models/room.dart';
import '../../../shared/models/user_profile.dart';

/// Onboarding durumu
class OnboardingState {
  final List<String> rooms;
  final String availableStart;
  final String availableEnd;
  final int preferredMinutes;
  final bool isLoading;
  final String? error;

  const OnboardingState({
    this.rooms = const [],
    this.availableStart = '19:00',
    this.availableEnd = '22:00',
    this.preferredMinutes = 10,
    this.isLoading = false,
    this.error,
  });

  OnboardingState copyWith({
    List<String>? rooms,
    String? availableStart,
    String? availableEnd,
    int? preferredMinutes,
    bool? isLoading,
    String? error,
  }) {
    return OnboardingState(
      rooms: rooms ?? this.rooms,
      availableStart: availableStart ?? this.availableStart,
      availableEnd: availableEnd ?? this.availableEnd,
      preferredMinutes: preferredMinutes ?? this.preferredMinutes,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

/// Onboarding notifier
class OnboardingNotifier extends StateNotifier<OnboardingState> {
  OnboardingNotifier() : super(const OnboardingState());

  final _uuid = const Uuid();

  /// Odaları ayarla
  void setRooms(List<String> rooms) {
    state = state.copyWith(rooms: rooms);
  }

  /// Müsait zamanı ayarla
  void setAvailableTime({required String start, required String end}) {
    state = state.copyWith(
      availableStart: start,
      availableEnd: end,
    );
  }

  /// Tercih edilen süreyi ayarla
  void setPreferredMinutes(int minutes) {
    state = state.copyWith(preferredMinutes: minutes);
  }

  /// Onboarding verilerini kaydet
  Future<void> saveOnboardingData() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      // Mevcut kullanıcıyı kontrol et
      var user = SupabaseService.currentUser;
      
      // Kullanıcı yoksa hata ver (login ekranından geçmiş olmalı)
      if (user == null) {
        throw Exception('Kullanıcı oturumu bulunamadı');
      }

      final userId = user.id;
      final now = DateTime.now();

      // Kullanıcı profilini oluştur
      final profile = UserProfile(
        id: userId,
        preferredMinutes: state.preferredMinutes,
        availableStart: state.availableStart,
        availableEnd: state.availableEnd,
        notificationsEnabled: true,
        motivationEnabled: true,
        soundEnabled: true,
        preferredLanguage: 'tr', // Varsayılan Türkçe
        timezone: AppConstants.defaultTimezone,
        createdAt: now,
      );

      // Supabase'e profil kaydet
      await SupabaseService.client.from('users_profile').upsert(profile.toJson());

      // Odaları kaydet
      final roomsData = state.rooms.asMap().entries.map((entry) {
        return Room(
          id: _uuid.v4(),
          userId: userId,
          name: entry.value,
          sortOrder: entry.key,
          createdAt: now,
        ).toJson();
      }).toList();

      if (roomsData.isNotEmpty) {
        await SupabaseService.client.from('rooms').insert(roomsData);
      }

      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      rethrow;
    }
  }
}

/// Onboarding provider
final onboardingProvider = StateNotifierProvider<OnboardingNotifier, OnboardingState>(
  (ref) => OnboardingNotifier(),
);

