import 'dart:math';
import 'package:flutter/material.dart';
import 'package:confetti/confetti.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../l10n/generated/app_localizations.dart';

/// Görev açma popup'ı - Heyecan verici animasyonlu
class TaskRevealPopup extends StatefulWidget {
  final String taskTitle;
  final int taskDuration;
  final String? roomName;
  final VoidCallback onStart;
  final VoidCallback onClose;
  /// "Bu görevi bir daha gösterme" butonu — null ise gösterilmez
  final VoidCallback? onSkipForever;

  const TaskRevealPopup({
    super.key,
    required this.taskTitle,
    required this.taskDuration,
    this.roomName,
    required this.onStart,
    required this.onClose,
    this.onSkipForever,
  });

  @override
  State<TaskRevealPopup> createState() => _TaskRevealPopupState();
}

class _TaskRevealPopupState extends State<TaskRevealPopup>
    with TickerProviderStateMixin {
  late AnimationController _boxController;
  late AnimationController _contentController;
  late Animation<double> _boxShakeAnimation;
  late Animation<double> _contentFadeAnimation;
  late Animation<double> _contentSlideAnimation;
  late ConfettiController _confettiController;

  bool _isRevealed = false;

  @override
  void initState() {
    super.initState();

    // Kutu sallama animasyonu
    _boxController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _boxShakeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _boxController, curve: Curves.elasticIn),
    );

    // İçerik animasyonu
    _contentController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _contentFadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _contentController, curve: Curves.easeOut),
    );

    _contentSlideAnimation = Tween<double>(begin: 50, end: 0).animate(
      CurvedAnimation(parent: _contentController, curve: Curves.easeOutCubic),
    );

    // Confetti
    _confettiController = ConfettiController(
      duration: const Duration(seconds: 2),
    );

    // Başlangıç animasyonu
    _startRevealAnimation();
  }

  Future<void> _startRevealAnimation() async {
    // Kutuyu salla
    for (int i = 0; i < 3; i++) {
      await Future.delayed(const Duration(milliseconds: 100));
      _boxController.forward();
      await Future.delayed(const Duration(milliseconds: 100));
      _boxController.reverse();
    }

    // Kutuyu aç
    await Future.delayed(const Duration(milliseconds: 200));
    setState(() => _isRevealed = true);
    _boxController.forward();

    // Confetti ve içerik
    await Future.delayed(const Duration(milliseconds: 200));
    _confettiController.play();
    _contentController.forward();
  }

  @override
  void dispose() {
    _boxController.dispose();
    _contentController.dispose();
    _confettiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Stack(
        children: [
          // Confetti
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirectionality: BlastDirectionality.explosive,
              emissionFrequency: 0.05,
              numberOfParticles: 20,
              maxBlastForce: 30,
              minBlastForce: 10,
              gravity: 0.1,
              colors: [
                AppColors.primary,
                AppColors.accent,
                AppColors.success,
                Colors.orange,
                Colors.pink,
                Colors.purple,
              ],
            ),
          ),

          // Ana içerik
          Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Hediye kutusu animasyonu
                  if (!_isRevealed)
                    AnimatedBuilder(
                      animation: _boxShakeAnimation,
                      builder: (context, child) {
                        return Transform.translate(
                          offset: Offset(
                            sin(_boxShakeAnimation.value * pi * 8) * 10,
                            0,
                          ),
                          child: child,
                        );
                      },
                      child: _GiftBoxLarge(),
                    )
                  else
                    AnimatedBuilder(
                      animation: _contentController,
                      builder: (context, child) {
                        return Transform.translate(
                          offset: Offset(0, _contentSlideAnimation.value),
                          child: Opacity(
                            opacity: _contentFadeAnimation.value,
                            child: child,
                          ),
                        );
                      },
                      child: _TaskRevealCard(
                        taskTitle: widget.taskTitle,
                        taskDuration: widget.taskDuration,
                        roomName: widget.roomName,
                        onStart: widget.onStart,
                        onClose: widget.onClose,
                        onSkipForever: widget.onSkipForever,
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Büyük hediye kutusu
class _GiftBoxLarge extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 200,
      height: 200,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFFD54F), Color(0xFFFFB300)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0x80FFB300),
            blurRadius: 30,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Yatay kurdele
          Positioned(
            top: 90,
            left: 0,
            right: 0,
            child: Container(
              height: 20,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.primaryAlpha80,
                    AppColors.primary,
                    AppColors.primaryAlpha80,
                  ],
                ),
              ),
            ),
          ),
          // Dikey kurdele
          Positioned(
            top: 0,
            bottom: 0,
            left: 90,
            child: Container(
              width: 20,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.primaryAlpha80,
                    AppColors.primary,
                    AppColors.primaryAlpha80,
                  ],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
              ),
            ),
          ),
          // Fiyonk
          Positioned(
            top: 60,
            left: 70,
            child: Container(
              width: 60,
              height: 60,
              child: Stack(
                children: [
                  // Sol yay
                  Positioned(
                    left: 0,
                    top: 15,
                    child: Container(
                      width: 25,
                      height: 30,
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                  ),
                  // Sağ yay
                  Positioned(
                    right: 0,
                    top: 15,
                    child: Container(
                      width: 25,
                      height: 30,
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                  ),
                  // Merkez
                  Positioned(
                    left: 20,
                    top: 20,
                    child: Container(
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Soru işareti
          const Center(
            child: Padding(
              padding: EdgeInsets.only(top: 30),
              child: Text(
                '?',
                style: TextStyle(
                  fontSize: 64,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Görev açıklaması kartı
class _TaskRevealCard extends StatelessWidget {
  final String taskTitle;
  final int taskDuration;
  final String? roomName;
  final VoidCallback onStart;
  final VoidCallback onClose;
  final VoidCallback? onSkipForever;

  const _TaskRevealCard({
    required this.taskTitle,
    required this.taskDuration,
    this.roomName,
    required this.onStart,
    required this.onClose,
    this.onSkipForever,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: AppColors.black20,
            blurRadius: 30,
            offset: const Offset(0, 15),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Başarı ikonu
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.primaryAlpha20,
                  AppColors.primaryLightAlpha10,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              shape: BoxShape.circle,
            ),
            child: const Center(
              child: Text('🧹', style: TextStyle(fontSize: 40)),
            ),
          ),
          const SizedBox(height: 20),

          // Başlık
          Text(
            l10n.todaysTask,
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),

          // Görev adı
          Text(
            taskTitle,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w700,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),

          // Oda ve süre bilgisi
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (roomName != null) ...[
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.accentAlpha10,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.home_outlined, size: 16, color: AppColors.accent),
                      const SizedBox(width: 4),
                      Text(
                        roomName!,
                        style: TextStyle(
                          color: AppColors.accent,
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
              ],
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.primaryAlpha10,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.timer_outlined, size: 16, color: AppColors.primary),
                    const SizedBox(width: 4),
                    Text(
                      l10n.minutesShort(taskDuration),
                      style: TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 28),

          // Başlat butonu
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton.icon(
              onPressed: onStart,
              icon: const Icon(Icons.play_arrow_rounded, size: 28),
              label: Text(
                l10n.startNow,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 4,
                shadowColor: AppColors.primaryAlpha30,
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Daha sonra butonu
          TextButton(
            onPressed: onClose,
            child: Text(
              l10n.doItLater,
              style: TextStyle(
                color: AppColors.textHint,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),

          // "Bu görevi bir daha gösterme" butonu
          if (onSkipForever != null) ...[
            const SizedBox(height: 4),
            TextButton(
              onPressed: onSkipForever,
              child: Text(
                l10n.neverShowThisTask,
                style: TextStyle(
                  color: AppColors.textHintAlpha60,
                  fontWeight: FontWeight.w400,
                  fontSize: 12,
                  decoration: TextDecoration.underline,
                  decorationColor: AppColors.textHintAlpha40,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

