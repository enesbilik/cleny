import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../core/services/local_storage_service.dart';
import '../../../core/services/supabase_service.dart';

/// Settings durumu
class SettingsState {
  final bool isLoading;
  final List<String> rooms;
  final int preferredMinutes;
  final String availableStart;
  final String availableEnd;
  final bool notificationsEnabled;
  final bool motivationEnabled;
  final bool soundEnabled;
  final String? error;

  const SettingsState({
    this.isLoading = true,
    this.rooms = const [],
    this.preferredMinutes = 15,
    this.availableStart = '19:00',
    this.availableEnd = '22:00',
    this.notificationsEnabled = true,
    this.motivationEnabled = true,
    this.soundEnabled = true,
    this.error,
  });

  int get roomCount => rooms.length;

  SettingsState copyWith({
    bool? isLoading,
    List<String>? rooms,
    int? preferredMinutes,
    String? availableStart,
    String? availableEnd,
    bool? notificationsEnabled,
    bool? motivationEnabled,
    bool? soundEnabled,
    String? error,
  }) {
    return SettingsState(
      isLoading: isLoading ?? this.isLoading,
      rooms: rooms ?? this.rooms,
      preferredMinutes: preferredMinutes ?? this.preferredMinutes,
      availableStart: availableStart ?? this.availableStart,
      availableEnd: availableEnd ?? this.availableEnd,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      motivationEnabled: motivationEnabled ?? this.motivationEnabled,
      soundEnabled: soundEnabled ?? this.soundEnabled,
      error: error,
    );
  }
}

/// Settings notifier
class SettingsNotifier extends StateNotifier<SettingsState> {
  SettingsNotifier() : super(const SettingsState()) {
    _loadSettings();
  }

  final _uuid = const Uuid();

  /// Verileri yeniden yükle (dışarıdan çağrılabilir)
  Future<void> refresh() async {
    await _loadSettings();
  }

  Future<void> _loadSettings() async {
    try {
      final userId = SupabaseService.currentUser?.id;
      if (userId == null) {
        state = state.copyWith(isLoading: false);
        return;
      }

      // Profil bilgilerini al
      final profileResponse = await SupabaseService.client
          .from('users_profile')
          .select()
          .eq('user_id', userId)
          .maybeSingle();

      // Odaları al
      final roomsResponse = await SupabaseService.client
          .from('rooms')
          .select()
          .eq('user_id', userId)
          .order('sort_order');

      final rooms = (roomsResponse as List)
          .map((e) => e['name'] as String)
          .toList();

      // Ses ayarını Supabase'den al (local storage yerine)
      final soundEnabled = profileResponse?['sound_enabled'] as bool? ?? true;

      state = state.copyWith(
        isLoading: false,
        rooms: rooms,
        preferredMinutes: profileResponse?['preferred_minutes'] ?? 15,
        availableStart: profileResponse?['available_start'] ?? '19:00',
        availableEnd: profileResponse?['available_end'] ?? '22:00',
        notificationsEnabled: profileResponse?['notifications_enabled'] ?? true,
        motivationEnabled: profileResponse?['motivation_enabled'] ?? true,
        soundEnabled: soundEnabled,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// Odaları güncelle
  Future<void> updateRooms(List<String> rooms) async {
    try {
      final userId = SupabaseService.currentUser?.id;
      if (userId == null) return;

      // Mevcut odaları sil
      await SupabaseService.client
          .from('rooms')
          .delete()
          .eq('user_id', userId);

      // Yeni odaları ekle
      final roomsData = rooms.asMap().entries.map((entry) {
        return {
          'id': _uuid.v4(),
          'user_id': userId,
          'name': entry.value,
          'sort_order': entry.key,
          'created_at': DateTime.now().toIso8601String(),
        };
      }).toList();

      if (roomsData.isNotEmpty) {
        await SupabaseService.client.from('rooms').insert(roomsData);
      }

      state = state.copyWith(rooms: rooms);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  /// Tercih edilen süreyi ayarla
  Future<void> setPreferredMinutes(int minutes) async {
    try {
      final userId = SupabaseService.currentUser?.id;
      if (userId == null) return;

      await SupabaseService.client
          .from('users_profile')
          .update({'preferred_minutes': minutes})
          .eq('user_id', userId);

      state = state.copyWith(preferredMinutes: minutes);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  /// Bildirim ayarını değiştir ve zamanlamayı güncelle
  Future<void> setNotificationsEnabled(bool enabled) async {
    try {
      final userId = SupabaseService.currentUser?.id;
      if (userId == null) return;

      await SupabaseService.client
          .from('users_profile')
          .update({'notifications_enabled': enabled})
          .eq('user_id', userId);

      state = state.copyWith(notificationsEnabled: enabled);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  /// Motivasyon ayarını değiştir
  Future<void> setMotivationEnabled(bool enabled) async {
    try {
      final userId = SupabaseService.currentUser?.id;
      if (userId == null) return;

      await SupabaseService.client
          .from('users_profile')
          .update({'motivation_enabled': enabled})
          .eq('user_id', userId);

      state = state.copyWith(motivationEnabled: enabled);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  /// Ses ayarını değiştir
  Future<void> setSoundEnabled(bool enabled) async {
    try {
      final userId = SupabaseService.currentUser?.id;
      if (userId == null) return;

      // Supabase'e kaydet
      await SupabaseService.client
          .from('users_profile')
          .update({'sound_enabled': enabled})
          .eq('user_id', userId);

      // State güncelle
      state = state.copyWith(soundEnabled: enabled);
      
      debugPrint('setSoundEnabled: Saved to Supabase: $enabled');
    } catch (e) {
      debugPrint('setSoundEnabled ERROR: $e');
      // Hata olsa bile state'i güncelle (offline mod)
      state = state.copyWith(soundEnabled: enabled);
    }
  }

  /// Bildirim saatini ayarla ve zamanlamayı güncelle
  Future<void> setAvailableTime(String start, String end) async {
    try {
      final userId = SupabaseService.currentUser?.id;
      if (userId == null) return;

      await SupabaseService.client
          .from('users_profile')
          .update({
            'available_start': start,
            'available_end': end,
          })
          .eq('user_id', userId);

      state = state.copyWith(availableStart: start, availableEnd: end);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  /// Tüm verileri sıfırla
  Future<void> resetAllData() async {
    try {
      final userId = SupabaseService.currentUser?.id;
      if (userId == null) return;

      // Supabase verilerini sil
      await SupabaseService.client
          .from('daily_tasks')
          .delete()
          .eq('user_id', userId);
      await SupabaseService.client
          .from('rooms')
          .delete()
          .eq('user_id', userId);
      await SupabaseService.client
          .from('users_profile')
          .delete()
          .eq('user_id', userId);

      // Local storage'ı temizle
      await LocalStorageService.clearAll();

      // Çıkış yap
      await SupabaseService.signOut();
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }
}

/// Settings provider
final settingsProvider = StateNotifierProvider<SettingsNotifier, SettingsState>(
  (ref) => SettingsNotifier(),
);

