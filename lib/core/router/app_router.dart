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
import '../../shared/providers/app_state_provider.dart';
import '../../core/services/auth_service.dart';

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
final routerProvider = Provider<GoRouter>((ref) {
  final appState = ref.watch(appStateProvider);

  return GoRouter(
    initialLocation: AppRoutes.splash,
    debugLogDiagnostics: true,
    redirect: (context, state) {
      final isAuthenticated = authService.isAuthenticated;
      final isOnboardingCompleted = appState.isOnboardingCompleted;
      final isGoingToOnboarding = state.matchedLocation.startsWith('/onboarding') ||
          state.matchedLocation == AppRoutes.welcome;
      final isGoingToLogin = state.matchedLocation == AppRoutes.login;

      // Splash'tan yönlendirme
      if (state.matchedLocation == AppRoutes.splash) {
        if (!isAuthenticated) {
          return AppRoutes.login;
        } else if (isOnboardingCompleted) {
          return AppRoutes.home;
        } else {
          return AppRoutes.welcome;
        }
      }

      // Auth olmadan sadece login sayfasına erişilebilir
      if (!isAuthenticated && !isGoingToLogin) {
        return AppRoutes.login;
      }

      // Auth varsa login'e gitmeye çalışırsa yönlendir
      if (isAuthenticated && isGoingToLogin) {
        if (isOnboardingCompleted) {
          return AppRoutes.home;
        } else {
          return AppRoutes.welcome;
        }
      }

      // Onboarding tamamlanmamışsa onboarding'e yönlendir
      if (isAuthenticated && !isOnboardingCompleted && !isGoingToOnboarding) {
        return AppRoutes.welcome;
      }

      // Onboarding tamamlanmışsa ve onboarding sayfasına gidiyorsa ana sayfaya yönlendir
      if (isOnboardingCompleted && isGoingToOnboarding) {
        return AppRoutes.home;
      }

      return null;
    },
    routes: [
      // Splash
      GoRoute(
        path: AppRoutes.splash,
        builder: (context, state) => const _SplashScreen(),
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

/// Basit splash ekranı
class _SplashScreen extends StatelessWidget {
  const _SplashScreen();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}

