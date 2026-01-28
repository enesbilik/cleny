import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/onboarding/presentation/screens/onboarding_screen.dart';
import '../../features/onboarding/presentation/screens/welcome_screen.dart';
import '../../features/onboarding/presentation/screens/room_setup_screen.dart';
import '../../features/onboarding/presentation/screens/time_setup_screen.dart';
import '../../features/onboarding/presentation/screens/duration_setup_screen.dart';
import '../../features/home/presentation/screens/home_screen.dart';
import '../../features/timer/presentation/screens/timer_screen.dart';
import '../../features/timer/presentation/screens/completion_screen.dart';
import '../../features/settings/presentation/screens/settings_screen.dart';
import '../../features/calendar/presentation/screens/calendar_screen.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../core/services/auth_service.dart';
import '../../core/presentation/screens/splash_screen.dart';

/// Route isimleri
class AppRoutes {
  AppRoutes._();

  static const String splash = '/';
  static const String login = '/login';
  static const String welcome = '/welcome';
  static const String onboarding = '/onboarding';
  static const String roomSetup = '/onboarding/rooms';
  static const String timeSetup = '/onboarding/time';
  static const String durationSetup = '/onboarding/duration';
  static const String home = '/home';
  static const String timer = '/timer';
  static const String completion = '/completion';
  static const String settings = '/settings';
  static const String calendar = '/calendar';
}

/// Router provider
/// NOT: ref.watch yerine ref.read kullanıyoruz çünkü router'ın sürekli yeniden oluşturulmasını istemiyoruz
/// Splash screen kendi yönlendirmesini yapıyor, bu yüzden redirect'i minimal tutuyoruz
final routerProvider = Provider<GoRouter>((ref) {
  // ref.watch yerine ref.read kullan - router'ı sürekli yeniden oluşturma
  // Sadece gerekli durumlarda redirect yap

  return GoRouter(
    initialLocation: AppRoutes.splash,
    debugLogDiagnostics: false, // Log spam'ini azalt
    redirect: (context, state) {
      final isAuthenticated = authService.isAuthenticated;
      final isGoingToLogin = state.matchedLocation == AppRoutes.login;
      final isGoingToSplash = state.matchedLocation == AppRoutes.splash;

      // Splash screen kendi yönlendirmesini yapıyor, redirect yapma
      if (isGoingToSplash) {
        return null;
      }

      // Auth olmadan sadece login ve splash sayfalarına erişilebilir
      if (!isAuthenticated && !isGoingToLogin && !isGoingToSplash) {
        return AppRoutes.login;
      }

      // Auth varsa login'e gitmeye çalışırsa splash'e yönlendir (splash kendi yönlendirmesini yapar)
      if (isAuthenticated && isGoingToLogin) {
        return AppRoutes.splash;
      }

      // Diğer durumlar için splash screen kendi yönlendirmesini yapacak
      return null;
    },
    routes: [
      // Splash
      GoRoute(
        path: AppRoutes.splash,
        builder: (context, state) => const SplashScreen(),
      ),

      // Login
      GoRoute(
        path: AppRoutes.login,
        builder: (context, state) => const LoginScreen(),
      ),

      // Welcome
      GoRoute(
        path: AppRoutes.welcome,
        builder: (context, state) => const WelcomeScreen(),
      ),

      // Onboarding Flow
      GoRoute(
        path: AppRoutes.onboarding,
        builder: (context, state) => const OnboardingScreen(),
        routes: [
          GoRoute(
            path: 'rooms',
            builder: (context, state) => const RoomSetupScreen(),
          ),
          GoRoute(
            path: 'time',
            builder: (context, state) => const TimeSetupScreen(),
          ),
          GoRoute(
            path: 'duration',
            builder: (context, state) => const DurationSetupScreen(),
          ),
        ],
      ),

      // Home
      GoRoute(
        path: AppRoutes.home,
        builder: (context, state) => const HomeScreen(),
      ),

      // Timer
      GoRoute(
        path: AppRoutes.timer,
        builder: (context, state) => const TimerScreen(),
      ),

      // Completion
      GoRoute(
        path: AppRoutes.completion,
        builder: (context, state) => const CompletionScreen(),
      ),

      // Settings
      GoRoute(
        path: AppRoutes.settings,
        builder: (context, state) => const SettingsScreen(),
      ),

      // Calendar
      GoRoute(
        path: AppRoutes.calendar,
        builder: (context, state) => const CalendarScreen(),
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Text('Sayfa bulunamadı: ${state.matchedLocation}'),
      ),
    ),
  );
});


