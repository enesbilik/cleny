import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase_auth;

import '../../../core/services/auth_service.dart';
import '../../../core/services/supabase_service.dart';

typedef User = supabase_auth.User;

/// Auth durumu
enum AuthStatus {
  initial,
  authenticated,
  unauthenticated,
  loading,
}

/// Auth state
class AuthState {
  final AuthStatus status;
  final User? user;
  final String? errorMessage;

  const AuthState({
    this.status = AuthStatus.initial,
    this.user,
    this.errorMessage,
  });

  AuthState copyWith({
    AuthStatus? status,
    User? user,
    String? errorMessage,
  }) {
    return AuthState(
      status: status ?? this.status,
      user: user ?? this.user,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  bool get isAuthenticated => status == AuthStatus.authenticated;
  bool get isLoading => status == AuthStatus.loading;
}

/// Auth provider
class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier() : super(const AuthState()) {
    _init();
  }

  StreamSubscription<supabase_auth.AuthState>? _authSubscription;

  void _init() {
    // Mevcut kullanıcıyı kontrol et
    final currentUser = authService.currentUser;
    if (currentUser != null) {
      state = state.copyWith(
        status: AuthStatus.authenticated,
        user: currentUser,
      );
    } else {
      state = state.copyWith(status: AuthStatus.unauthenticated);
    }

    // Auth değişikliklerini dinle
    _authSubscription = SupabaseService.client.auth.onAuthStateChange.listen((data) {
      final event = data.event;
      final session = data.session;

      if (event == supabase_auth.AuthChangeEvent.signedIn && session != null) {
        state = state.copyWith(
          status: AuthStatus.authenticated,
          user: session.user,
        );
      } else if (event == supabase_auth.AuthChangeEvent.signedOut) {
        state = state.copyWith(
          status: AuthStatus.unauthenticated,
          user: null,
        );
      } else if (event == supabase_auth.AuthChangeEvent.tokenRefreshed && session != null) {
        state = state.copyWith(user: session.user);
      }
    });
  }

  /// Email ile giriş
  Future<bool> signInWithEmail(String email, String password) async {
    state = state.copyWith(status: AuthStatus.loading, errorMessage: null);
    
    final result = await authService.signInWithEmail(
      email: email,
      password: password,
    );

    if (result.success) {
      state = state.copyWith(
        status: AuthStatus.authenticated,
        user: result.user,
      );
      return true;
    } else {
      state = state.copyWith(
        status: AuthStatus.unauthenticated,
        errorMessage: result.error,
      );
      return false;
    }
  }

  /// Email ile kayıt
  Future<bool> signUpWithEmail(String email, String password, String? name) async {
    state = state.copyWith(status: AuthStatus.loading, errorMessage: null);
    
    final result = await authService.signUpWithEmail(
      email: email,
      password: password,
      name: name,
    );

    if (result.success) {
      state = state.copyWith(
        status: AuthStatus.authenticated,
        user: result.user,
      );
      return true;
    } else {
      state = state.copyWith(
        status: AuthStatus.unauthenticated,
        errorMessage: result.error,
      );
      return false;
    }
  }

  /// Google ile giriş
  Future<bool> signInWithGoogle() async {
    state = state.copyWith(status: AuthStatus.loading, errorMessage: null);
    
    final result = await authService.signInWithGoogle();

    if (!result.success) {
      state = state.copyWith(
        status: AuthStatus.unauthenticated,
        errorMessage: result.error,
      );
      return false;
    }

    // OAuth durumunda state listener callback ile güncellenecek
    return true;
  }

  /// Apple ile giriş
  Future<bool> signInWithApple() async {
    state = state.copyWith(status: AuthStatus.loading, errorMessage: null);
    
    final result = await authService.signInWithApple();

    if (!result.success) {
      state = state.copyWith(
        status: AuthStatus.unauthenticated,
        errorMessage: result.error,
      );
      return false;
    }

    return true;
  }

  /// Anonim giriş
  Future<bool> signInAnonymously() async {
    state = state.copyWith(status: AuthStatus.loading, errorMessage: null);
    
    final result = await authService.signInAnonymously();

    if (result.success) {
      state = state.copyWith(
        status: AuthStatus.authenticated,
        user: result.user,
      );
      return true;
    } else {
      state = state.copyWith(
        status: AuthStatus.unauthenticated,
        errorMessage: result.error,
      );
      return false;
    }
  }

  /// Çıkış
  Future<void> signOut() async {
    await authService.signOut();
    state = state.copyWith(
      status: AuthStatus.unauthenticated,
      user: null,
    );
  }

  /// Hata mesajını temizle
  void clearError() {
    state = state.copyWith(errorMessage: null);
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    super.dispose();
  }
}

/// Auth provider instance
final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier();
});

/// Sadece auth durumunu dinle
final isAuthenticatedProvider = Provider<bool>((ref) {
  return ref.watch(authProvider).isAuthenticated;
});

/// Mevcut kullanıcı
final currentUserProvider = Provider<User?>((ref) {
  return ref.watch(authProvider).user;
});

