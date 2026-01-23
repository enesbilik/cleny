import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../l10n/generated/app_localizations.dart';

/// Hoş geldin ekranı
class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeIn;
  late Animation<Offset> _slideUp;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _fadeIn = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
      ),
    );

    _slideUp = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.2, 1.0, curve: Curves.easeOut),
      ),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const Spacer(flex: 1),
              
              // Logo ve animasyon
              FadeTransition(
                opacity: _fadeIn,
                child: _LogoSection(),
              ),
              
              const Spacer(flex: 1),
              
              // İçerik
              SlideTransition(
                position: _slideUp,
                child: FadeTransition(
                  opacity: _fadeIn,
                  child: Builder(
                    builder: (context) {
                      final l10n = AppLocalizations.of(context)!;
                      
                      return Column(
                        children: [
                          // Başlık
                          Text(
                            l10n.cleanHomePeacefulLife,
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.displaySmall?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                              height: 1.2,
                            ),
                          ),
                          
                          const SizedBox(height: 16),
                          
                          // Alt başlık
                          Text(
                            l10n.onlyTenMinutesDaily,
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              color: AppColors.textSecondary,
                              height: 1.5,
                            ),
                          ),
                          
                          const SizedBox(height: 48),
                          
                          // Özellikler
                          _FeatureRow(
                            icon: Icons.timer_outlined,
                            text: l10n.microTasksBigDifference,
                          ),
                          const SizedBox(height: 16),
                          _FeatureRow(
                            icon: Icons.card_giftcard_outlined,
                            text: l10n.newSurpriseDaily,
                          ),
                          const SizedBox(height: 16),
                          _FeatureRow(
                            icon: Icons.emoji_events_outlined,
                            text: l10n.streakMotivation,
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ),
              
              const Spacer(flex: 2),
              
              // Başla butonu
              FadeTransition(
                opacity: _fadeIn,
                child: Builder(
                  builder: (context) {
                    final l10n = AppLocalizations.of(context)!;
                    
                    return SizedBox(
                      width: double.infinity,
                      height: 60,
                      child: ElevatedButton(
                        onPressed: () => context.go(AppRoutes.roomSetup),
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              l10n.getStarted,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Icon(Icons.arrow_forward_rounded, size: 22),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}

/// Logo bölümü
class _LogoSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Dış halka
        Container(
          width: 180,
          height: 180,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.primaryLight.withValues(alpha: 0.15),
          ),
        ),
        // Orta halka
        Container(
          width: 140,
          height: 140,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.primaryLight.withValues(alpha: 0.25),
          ),
        ),
        // İç daire (logo)
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            gradient: AppColors.primaryGradient,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.3),
                blurRadius: 24,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: const Icon(
            Icons.home_rounded,
            size: 48,
            color: Colors.white,
          ),
        ),
        // Dekoratif elementler
        Positioned(
          top: 20,
          right: 10,
          child: _DecorDot(color: AppColors.accent, size: 12),
        ),
        Positioned(
          bottom: 30,
          left: 15,
          child: _DecorDot(color: AppColors.secondary, size: 8),
        ),
        Positioned(
          top: 60,
          left: 5,
          child: _DecorDot(color: AppColors.primaryLight, size: 10),
        ),
      ],
    );
  }
}

/// Dekoratif nokta
class _DecorDot extends StatelessWidget {
  final Color color;
  final double size;

  const _DecorDot({required this.color, required this.size});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color.withValues(alpha: 0.6),
      ),
    );
  }
}

/// Özellik satırı
class _FeatureRow extends StatelessWidget {
  final IconData icon;
  final String text;

  const _FeatureRow({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: AppColors.primaryLight.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            icon,
            color: AppColors.primary,
            size: 20,
          ),
        ),
        const SizedBox(width: 12),
        Text(
          text,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
