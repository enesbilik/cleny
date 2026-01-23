import 'dart:convert';
import 'dart:math';
import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'supabase_service.dart';

/// Auth sonuç sınıfı
class AuthResult {
  final bool success;
  final User? user;
  final String? error;
  final bool needsEmailConfirmation;

  AuthResult({
    required this.success,
    this.user,
    this.error,
    this.needsEmailConfirmation = false,
  });
}

/// Auth Service - Kimlik doğrulama servisi
class AuthService {
  static AuthService? _instance;
  static AuthService get instance => _instance ??= AuthService._();

  AuthService._();

  SupabaseClient get _client => SupabaseService.client;

  // Google Sign In instance
  final _googleSignIn = GoogleSignIn(
    scopes: ['email', 'profile'],
  );

  /// Mevcut kullanıcı
  User? get currentUser => _client.auth.currentUser;

  /// Oturum açık mı?
  bool get isAuthenticated => currentUser != null;

  /// Auth state stream
  Stream<AuthState> get authStateChanges => _client.auth.onAuthStateChange;

  // ==================== EMAIL AUTH ====================

  /// Email ile kayıt
  Future<AuthResult> signUpWithEmail({
    required String email,
    required String password,
    String? name,
  }) async {
    try {
      final response = await _client.auth.signUp(
        email: email,
        password: password,
        data: name != null ? {'name': name} : null,
      );

      // Kullanıcı oluşturuldu ama session yoksa email doğrulaması gerekiyor
      if (response.user != null && response.session == null) {
        return AuthResult(
          success: true,
          user: response.user,
          needsEmailConfirmation: true,
        );
      }

      if (response.user != null && response.session != null) {
        return AuthResult(success: true, user: response.user);
      } else {
        return AuthResult(success: false, error: 'Kayıt başarısız');
      }
    } on AuthException catch (e) {
      return AuthResult(success: false, error: _translateAuthError(e.message));
    } catch (e) {
      return AuthResult(success: false, error: e.toString());
    }
  }

  /// Email ile giriş
  Future<AuthResult> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _client.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.user != null) {
        return AuthResult(success: true, user: response.user);
      } else {
        return AuthResult(success: false, error: 'Giriş başarısız');
      }
    } on AuthException catch (e) {
      return AuthResult(success: false, error: _translateAuthError(e.message));
    } catch (e) {
      return AuthResult(success: false, error: e.toString());
    }
  }

  /// Şifre sıfırlama emaili gönder
  Future<AuthResult> sendPasswordResetEmail(String email) async {
    try {
      await _client.auth.resetPasswordForEmail(email);
      return AuthResult(success: true);
    } on AuthException catch (e) {
      return AuthResult(success: false, error: _translateAuthError(e.message));
    } catch (e) {
      return AuthResult(success: false, error: e.toString());
    }
  }

  // ==================== GOOGLE AUTH ====================

  /// Google ile giriş (Native)
  Future<AuthResult> signInWithGoogle() async {
    try {
      // Google Sign In
      final googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        return AuthResult(success: false, error: 'Google girişi iptal edildi');
      }

      final googleAuth = await googleUser.authentication;
      final idToken = googleAuth.idToken;
      final accessToken = googleAuth.accessToken;

      if (idToken == null) {
        return AuthResult(success: false, error: 'Google token alınamadı');
      }

      // Supabase'e giriş yap
      final response = await _client.auth.signInWithIdToken(
        provider: OAuthProvider.google,
        idToken: idToken,
        accessToken: accessToken,
      );

      if (response.user != null) {
        return AuthResult(success: true, user: response.user);
      } else {
        return AuthResult(success: false, error: 'Google girişi başarısız');
      }
    } on AuthException catch (e) {
      debugPrint('Google Auth Error: ${e.message}');
      return AuthResult(success: false, error: _translateAuthError(e.message));
    } catch (e) {
      debugPrint('Google Sign In Error: $e');
      return AuthResult(success: false, error: 'Google ile giriş yapılamadı');
    }
  }

  // ==================== APPLE AUTH ====================

  /// Apple ile giriş (Native)
  Future<AuthResult> signInWithApple() async {
    try {
      // Rastgele nonce oluştur
      final rawNonce = _generateNonce();
      final hashedNonce = sha256.convert(utf8.encode(rawNonce)).toString();

      // Apple Sign In
      final credential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
        nonce: hashedNonce,
      );

      final idToken = credential.identityToken;
      if (idToken == null) {
        return AuthResult(success: false, error: 'Apple token alınamadı');
      }

      // Supabase'e giriş yap
      final response = await _client.auth.signInWithIdToken(
        provider: OAuthProvider.apple,
        idToken: idToken,
        nonce: rawNonce,
      );

      if (response.user != null) {
        // İsim bilgisini güncelle (Apple sadece ilk girişte veriyor)
        if (credential.givenName != null || credential.familyName != null) {
          final fullName = [credential.givenName, credential.familyName]
              .where((n) => n != null && n.isNotEmpty)
              .join(' ');
          if (fullName.isNotEmpty) {
            await _client.auth.updateUser(
              UserAttributes(data: {'name': fullName}),
            );
          }
        }
        return AuthResult(success: true, user: response.user);
      } else {
        return AuthResult(success: false, error: 'Apple girişi başarısız');
      }
    } on SignInWithAppleAuthorizationException catch (e) {
      if (e.code == AuthorizationErrorCode.canceled) {
        return AuthResult(success: false, error: 'Apple girişi iptal edildi');
      }
      return AuthResult(success: false, error: e.message);
    } on AuthException catch (e) {
      debugPrint('Apple Auth Error: ${e.message}');
      return AuthResult(success: false, error: _translateAuthError(e.message));
    } catch (e) {
      debugPrint('Apple Sign In Error: $e');
      return AuthResult(success: false, error: 'Apple ile giriş yapılamadı');
    }
  }

  // ==================== ANONYMOUS AUTH ====================

  /// Anonim giriş
  Future<AuthResult> signInAnonymously() async {
    try {
      final response = await _client.auth.signInAnonymously();

      if (response.user != null) {
        return AuthResult(success: true, user: response.user);
      } else {
        return AuthResult(success: false, error: 'Anonim giriş başarısız');
      }
    } on AuthException catch (e) {
      return AuthResult(success: false, error: _translateAuthError(e.message));
    } catch (e) {
      return AuthResult(success: false, error: e.toString());
    }
  }

  // ==================== COMMON ====================

  /// Çıkış yap
  Future<void> signOut() async {
    // Google'dan da çıkış yap
    try {
      await _googleSignIn.signOut();
    } catch (_) {}
    
    await _client.auth.signOut();
  }

  /// Kullanıcı bilgilerini güncelle
  Future<AuthResult> updateUser({String? name, String? email}) async {
    try {
      final response = await _client.auth.updateUser(
        UserAttributes(
          email: email,
          data: name != null ? {'name': name} : null,
        ),
      );

      if (response.user != null) {
        return AuthResult(success: true, user: response.user);
      } else {
        return AuthResult(success: false, error: 'Güncelleme başarısız');
      }
    } on AuthException catch (e) {
      return AuthResult(success: false, error: _translateAuthError(e.message));
    } catch (e) {
      return AuthResult(success: false, error: e.toString());
    }
  }

  /// Hesabı sil
  Future<AuthResult> deleteAccount() async {
    return AuthResult(success: false, error: 'Bu özellik henüz mevcut değil');
  }

  // ==================== HELPERS ====================

  /// Rastgele nonce oluştur (Apple Sign In için)
  String _generateNonce([int length = 32]) {
    const charset = '0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._';
    final random = Random.secure();
    return List.generate(length, (_) => charset[random.nextInt(charset.length)]).join();
  }

  /// Auth hatalarını Türkçeye çevir
  String _translateAuthError(String message) {
    final errorMap = {
      'Invalid login credentials': 'Geçersiz email veya şifre',
      'Email not confirmed': 'Email adresinizi doğrulamanız gerekiyor',
      'User already registered': 'Bu email zaten kayıtlı',
      'Password should be at least 6 characters': 'Şifre en az 6 karakter olmalı',
      'Invalid email': 'Geçersiz email adresi',
      'Email rate limit exceeded': 'Çok fazla deneme yaptınız. Lütfen bekleyin.',
      'Anonymous sign-ins are disabled': 'Anonim giriş devre dışı',
      'Provider not supported': 'Bu giriş yöntemi desteklenmiyor',
    };

    return errorMap[message] ?? message;
  }
}

// Singleton instance
final authService = AuthService.instance;
