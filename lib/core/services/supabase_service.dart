import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Supabase servisi
class SupabaseService {
  static SupabaseClient? _client;

  /// Supabase client'ı al
  static SupabaseClient get client {
    if (_client == null) {
      throw Exception('Supabase henüz başlatılmadı. Önce initialize() çağırın.');
    }
    return _client!;
  }

  /// Supabase'i başlat
  /// Build: flutter run --dart-define=SUPABASE_URL=https://x.supabase.co --dart-define=SUPABASE_ANON_KEY=xxx
  static Future<void> initialize() async {
    const url = String.fromEnvironment('SUPABASE_URL');
    const anonKey = String.fromEnvironment('SUPABASE_ANON_KEY');

    if (url.isEmpty || anonKey.isEmpty) {
      throw Exception(
        'SUPABASE_URL and SUPABASE_ANON_KEY must be set via --dart-define at build time',
      );
    }

    await Supabase.initialize(
      url: url,
      anonKey: anonKey,
    );

    _client = Supabase.instance.client;
  }

  /// Anonim giriş yap
  static Future<User?> signInAnonymously() async {
    final response = await client.auth.signInAnonymously();
    return response.user;
  }

  /// Mevcut kullanıcıyı al
  static User? get currentUser => client.auth.currentUser;

  /// Oturum açık mı?
  static bool get isAuthenticated => currentUser != null;

  /// Çıkış yap
  static Future<void> signOut() async {
    await client.auth.signOut();
  }

  // =====================================================
  // KULLANICI PROFİLİ VE ODA İŞLEMLERİ
  // =====================================================

  /// Kullanıcının profilini al
  static Future<Map<String, dynamic>?> getUserProfile(String userId) async {
    try {
      final response = await client
          .from('users_profile')
          .select()
          .eq('user_id', userId)
          .maybeSingle();
      return response;
    } catch (e) {
      debugPrint('getUserProfile error: $e');
      return null;
    }
  }

  /// Kullanıcının odalarını al
  static Future<List<Map<String, dynamic>>> getUserRooms(String userId) async {
    try {
      final response = await client
          .from('rooms')
          .select()
          .eq('user_id', userId)
          .order('sort_order');
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      debugPrint('getUserRooms error: $e');
      return [];
    }
  }

  /// Kullanıcının onboarding'i tamamlayıp tamamlamadığını kontrol et
  /// Profil ve en az 1 oda varsa tamamlanmış sayılır
  static Future<bool> checkOnboardingCompleted(String userId) async {
    try {
      // Profil var mı?
      final profile = await getUserProfile(userId);
      if (profile == null) {
        debugPrint('checkOnboardingCompleted: No profile found');
        return false;
      }

      // En az 1 oda var mı?
      final rooms = await getUserRooms(userId);
      final hasRooms = rooms.isNotEmpty;
      debugPrint('checkOnboardingCompleted: Profile found, rooms: ${rooms.length}');
      return hasRooms;
    } catch (e) {
      debugPrint('checkOnboardingCompleted error: $e');
      return false;
    }
  }

  /// Bugünün görevini al
  static Future<Map<String, dynamic>?> getTodayTask(String userId) async {
    try {
      final today = DateTime.now().toIso8601String().split('T').first;
      final response = await client
          .from('daily_tasks')
          .select()
          .eq('user_id', userId)
          .eq('date', today)
          .maybeSingle();
      return response;
    } catch (e) {
      debugPrint('getTodayTask error: $e');
      return null;
    }
  }
}

