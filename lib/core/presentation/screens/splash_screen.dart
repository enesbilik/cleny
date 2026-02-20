import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lottie/lottie.dart';

import '../../router/app_router.dart';
import '../../../features/home/providers/home_provider.dart';
import '../../../features/settings/providers/settings_provider.dart';
import '../../../core/providers/locale_provider.dart';
import '../../../shared/providers/app_state_provider.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/services/onesignal_service.dart';

/// Custom Splash Screen - Veri yükleme ile
class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  bool _hasNavigated = false; // Navigate flag - sadece bir kez navigate et
  bool _isLoading = false; // Loading flag - çoklu çağrıları önle

  @override
  void initState() {
    super.initState();
    
    // Animasyon controller
    _controller = AnimationController(
      duration: const Duration(milliseconds: 900),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOutBack,
      ),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeIn,
      ),
    );

    _controller.forward();
    
    // Veri yükleme ve yönlendirme
    _loadDataAndNavigate();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _loadDataAndNavigate() async {
    // Eğer zaten navigate edildiyse veya loading başladıysa, tekrar çalıştırma
    if (_hasNavigated || _isLoading) {
      debugPrint('Splash: Already navigated or loading, skipping...');
      return;
    }

    _isLoading = true;

    try {
      // Minimum bekleme süresi (animasyon gözükebilsin diye)
      await Future.delayed(const Duration(milliseconds: 500));
      
      if (!mounted || _hasNavigated) return;

      final isAuthenticated = authService.isAuthenticated;

      if (!isAuthenticated) {
        // Login sayfasına yönlendir
        if (mounted && !_hasNavigated) {
          _hasNavigated = true;
          context.go(AppRoutes.login);
        }
        return;
      }

      // Kullanıcı giriş yapmışsa verileri yükle
      // 1. Onboarding durumunu kontrol et
      if (!mounted || _hasNavigated) return;
      await ref.read(appStateProvider.notifier).checkOnboardingFromSupabase();
      
      if (!mounted || _hasNavigated) return;
      final appState = ref.read(appStateProvider);
      
      if (!appState.isOnboardingCompleted) {
        // Onboarding tamamlanmamış
        if (mounted && !_hasNavigated) {
          _hasNavigated = true;
          context.go(AppRoutes.welcome);
        }
        return;
      }

      // 2. Locale'i yükle (Supabase'den)
      if (!mounted || _hasNavigated) return;
      await ref.read(localeProvider.notifier).loadLocale();

      // 3. Settings verilerini yükle
      if (!mounted || _hasNavigated) return;
      await ref.read(settingsProvider.notifier).refresh();

      // 4. Home verilerini yükle (görev durumu dahil) - TAM YÜKLENENE KADAR BEKLE
      if (!mounted || _hasNavigated) return;
      await ref.read(homeProvider.notifier).loadData(forceRefresh: false);
      
      // isLoading VE isRefreshing bitene kadar bekle (max 8 saniye)
      // isRefreshing: cache'den hızlı yüklendi, arka planda network refresh devam ediyor
      int retryCount = 0;
      while (retryCount < 80) {
        if (!mounted || _hasNavigated) return;
        final homeState = ref.read(homeProvider);
        if (!homeState.isLoading && !homeState.isRefreshing) {
          debugPrint('Splash: Home data fully loaded (cache + network)');
          break;
        }
        await Future.delayed(const Duration(milliseconds: 100));
        retryCount++;
      }

      // 5. OneSignal sync — navigasyonu bekletmeden arka planda çalıştır
      unawaited(OneSignalService.syncCurrentUser());
      unawaited(OneSignalService.updateLastActive());

      // 6. Home ekranına yönlendir
      if (mounted && !_hasNavigated) {
        _hasNavigated = true;
        context.go(AppRoutes.home);
      }
    } catch (e) {
      debugPrint('Splash screen data loading error: $e');
      // Hata durumunda da home'a git (cache'den yükler)
      if (mounted && !_hasNavigated) {
        _hasNavigated = true;
        context.go(AppRoutes.home);
      }
    } finally {
      _isLoading = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return Opacity(
                opacity: _fadeAnimation.value,
                child: Transform.scale(
                  scale: _scaleAnimation.value,
                  child: Lottie.asset(
                    'assets/animations/splash_spray.json',
                    width: 220,
                    height: 220,
                    repeat: true,
                    frameRate: FrameRate(60),
                    options: LottieOptions(enableMergePaths: true),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

