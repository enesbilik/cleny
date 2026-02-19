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
                          const SizedBox(height: 12),
                          _FeatureRow(
                            icon: Icons.card_giftcard_outlined,
                            text: l10n.newSurpriseDaily,
                          ),
                          const SizedBox(height: 12),
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
          width: 200,
          height: 200,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.primaryLight.withValues(alpha: 0.1),
          ),
        ),
        // Orta halka
        Container(
          width: 160,
          height: 160,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.primaryLight.withValues(alpha: 0.2),
          ),
        ),
        // İç daire (logo)
        Container(
          width: 110,
          height: 110,
          decoration: BoxDecoration(
            gradient: AppColors.primaryGradient,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.35),
                blurRadius: 28,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: const Icon(
            Icons.home_rounded,
            size: 52,
            color: Colors.white,
          ),
        ),
        // Dekoratif elementler
        Positioned(
          top: 18,
          right: 8,
          child: _DecorDot(color: AppColors.primaryLight, size: 14),
        ),
        Positioned(
          bottom: 28,
          left: 12,
          child: _DecorDot(color: AppColors.primary, size: 10),
        ),
        Positioned(
          top: 55,
          left: 2,
          child: _DecorDot(color: AppColors.primaryLight, size: 12),
        ),
        Positioned(
          bottom: 60,
          right: 5,
          child: _DecorDot(color: AppColors.primaryDark, size: 8),
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
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.primaryLight.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.1),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: AppColors.primary,
              size: 22,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              text,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
