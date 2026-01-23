import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../../core/constants/app_constants.dart';
import '../../core/services/supabase_service.dart';
import '../models/user_profile.dart';

/// App durumu
class AppState {
  final bool isOnboardingCompleted;
  final bool isLoading;
  final bool isCheckingOnboarding;
  final UserProfile? userProfile;
  final List<String> userRooms;

  const AppState({
    this.isOnboardingCompleted = false,
    this.isLoading = true,
    this.isCheckingOnboarding = false,
    this.userProfile,
    this.userRooms = const [],
  });

  AppState copyWith({
    bool? isOnboardingCompleted,
    bool? isLoading,
    bool? isCheckingOnboarding,
    UserProfile? userProfile,
    List<String>? userRooms,
  }) {
    return AppState(
      isOnboardingCompleted: isOnboardingCompleted ?? this.isOnboardingCompleted,
      isLoading: isLoading ?? this.isLoading,
      isCheckingOnboarding: isCheckingOnboarding ?? this.isCheckingOnboarding,
      userProfile: userProfile ?? this.userProfile,
      userRooms: userRooms ?? this.userRooms,
    );
  }
}

/// App state notifier
class AppStateNotifier extends StateNotifier<AppState> {
  AppStateNotifier() : super(const AppState()) {
    _initialize();
  }

  late Box _settingsBox;

  Future<void> _initialize() async {
    _settingsBox = await Hive.openBox('settings');
    
    // Önce local'den kontrol et (hızlı başlatma için)
    final localOnboardingCompleted = _settingsBox.get(
      AppConstants.onboardingCompletedKey,
      defaultValue: false,
    ) as bool;

    state = state.copyWith(
      isOnboardingCompleted: localOnboardingCompleted,
      isLoading: false,
    );

    // Kullanıcı giriş yapmışsa Supabase'den de kontrol et
    if (SupabaseService.isAuthenticated) {
      await checkOnboardingFromSupabase();
    }
  }

  /// Supabase'den onboarding durumunu kontrol et
  /// Login sonrası çağrılmalı
  Future<void> checkOnboardingFromSupabase() async {
    final userId = SupabaseService.currentUser?.id;
    if (userId == null) {
      debugPrint('checkOnboardingFromSupabase: No user logged in');
      return;
    }

    state = state.copyWith(isCheckingOnboarding: true);

    try {
      debugPrint('checkOnboardingFromSupabase: Checking for user $userId');
      
      // Supabase'den kontrol et
      final isCompleted = await SupabaseService.checkOnboardingCompleted(userId);
      
      debugPrint('checkOnboardingFromSupabase: Result = $isCompleted');

      if (isCompleted) {
        // Supabase'de tamamlanmış - local'i de güncelle
        await _settingsBox.put(AppConstants.onboardingCompletedKey, true);
        
        // Kullanıcı odalarını al
        final rooms = await SupabaseService.getUserRooms(userId);
        final roomNames = rooms.map((r) => r['name'] as String).toList();
        
        // Kullanıcı profilini al
        final profileData = await SupabaseService.getUserProfile(userId);
        UserProfile? profile;
        if (profileData != null) {
          profile = UserProfile.fromJson(profileData);
        }
        
        state = state.copyWith(
          isOnboardingCompleted: true,
          isCheckingOnboarding: false,
          userRooms: roomNames,
          userProfile: profile,
        );
        
        debugPrint('checkOnboardingFromSupabase: Onboarding marked as completed');
      } else {
        // Supabase'de tamamlanmamış - local'i de güncelle
        await _settingsBox.put(AppConstants.onboardingCompletedKey, false);
        
        state = state.copyWith(
          isOnboardingCompleted: false,
          isCheckingOnboarding: false,
          userRooms: [],
        );
        
        debugPrint('checkOnboardingFromSupabase: Onboarding not completed');
      }
    } catch (e) {
      debugPrint('checkOnboardingFromSupabase error: $e');
      state = state.copyWith(isCheckingOnboarding: false);
    }
  }

  /// Onboarding tamamlandı
  Future<void> completeOnboarding() async {
    await _settingsBox.put(AppConstants.onboardingCompletedKey, true);
    state = state.copyWith(isOnboardingCompleted: true);
  }

  /// Kullanıcı profilini güncelle
  void updateUserProfile(UserProfile profile) {
    state = state.copyWith(userProfile: profile);
  }

  /// Verileri sıfırla
  Future<void> resetData() async {
    await _settingsBox.clear();
    state = const AppState(isOnboardingCompleted: false, isLoading: false);
  }

  /// Çıkış yaptığında state'i temizle
  void clearOnLogout() {
    state = const AppState(isOnboardingCompleted: false, isLoading: false);
  }
}

/// App state provider
final appStateProvider = StateNotifierProvider<AppStateNotifier, AppState>(
  (ref) => AppStateNotifier(),
);

