import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/services/sound_service.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../providers/timer_provider.dart';
import '../widgets/hold_to_complete_button.dart';

/// Timer ekranı
class TimerScreen extends ConsumerStatefulWidget {
  const TimerScreen({super.key});

  @override
  ConsumerState<TimerScreen> createState() => _TimerScreenState();
}

class _TimerScreenState extends ConsumerState<TimerScreen> {
  void _onCompleted() async {
    // Haptic feedback
    HapticFeedback.heavyImpact();
    
    // Tamamlama sesi çal
    soundService.playTaskComplete();
    
    // Görevi tamamla
    await ref.read(timerProvider.notifier).completeTask();
    
    // Completion ekranına git
    if (mounted) {
      context.go(AppRoutes.completion);
    }
  }

  @override
  Widget build(BuildContext context) {
    final timerState = ref.watch(timerProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              // Üst bar
              _TopBar(
                taskTitle: timerState.taskTitle,
                onClose: () => _showExitDialog(context),
              ),

              const Spacer(),

              // Timer göstergesi
              _TimerDisplay(
                remainingSeconds: timerState.remainingSeconds,
                totalSeconds: timerState.totalSeconds,
                isRunning: timerState.isRunning,
                isCompleted: timerState.isTimerCompleted,
              ),

              const Spacer(),

              // Kontroller
              if (!timerState.isTaskCompleted)
                _buildControls(context, ref, timerState),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildControls(BuildContext context, WidgetRef ref, TimerState state) {
    final l10n = AppLocalizations.of(context)!;
    
    // Timer tamamlandıysa "basılı tut" butonu göster
    if (state.isTimerCompleted) {
      return Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.success.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.check_circle_outline, color: AppColors.success, size: 20),
                const SizedBox(width: 8),
                Text(
                  l10n.timeUp,
                  style: TextStyle(
                    color: AppColors.success,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          HoldToCompleteButton(onCompleted: _onCompleted),
        ],
      );
    }

    // Timer kontrolleri
    return Column(
      children: [
        // Ana buton
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Timer başlamadıysa veya durduysa
            if (!state.isRunning)
              _ActionButton(
                icon: Icons.play_arrow_rounded,
                label: state.remainingSeconds == state.totalSeconds ? l10n.start : l10n.resume,
                isPrimary: true,
                onTap: () => ref.read(timerProvider.notifier).start(),
              ),

            // Timer çalışıyorsa
            if (state.isRunning)
              _ActionButton(
                icon: Icons.pause_rounded,
                label: l10n.pause,
                isPrimary: true,
                onTap: () => ref.read(timerProvider.notifier).pause(),
              ),
          ],
        ),
        
        const SizedBox(height: 16),

        // Erken tamamla butonu
        TextButton(
          onPressed: () => _showEarlyCompleteDialog(context, ref),
          child: Text(
            l10n.earlyComplete,
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 14,
            ),
          ),
        ),
      ],
    );
  }

  void _showExitDialog(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(l10n.confirmExitTitle),
        content: Text(l10n.progressWillNotBeSaved),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancel),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              context.go(AppRoutes.home);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
            ),
            child: Text(l10n.exit),
          ),
        ],
      ),
    );
  }

  void _showEarlyCompleteDialog(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(l10n.earlyComplete),
        content: Text(l10n.confirmEarlyComplete),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancel),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ref.read(timerProvider.notifier).markTimerCompleted();
            },
            child: Text(l10n.complete),
          ),
        ],
      ),
    );
  }
}

/// Üst bar
class _TopBar extends StatelessWidget {
  final String taskTitle;
  final VoidCallback onClose;

  const _TopBar({
    required this.taskTitle,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Kapat butonu
        GestureDetector(
          onTap: onClose,
          child: Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.surfaceVariant,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.close_rounded,
              color: AppColors.textSecondary,
              size: 22,
            ),
          ),
        ),
        const Spacer(),
        // Görev başlığı
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: AppColors.surfaceVariant,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            taskTitle,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ),
        const Spacer(),
        const SizedBox(width: 44), // Balance
      ],
    );
  }
}

/// Timer göstergesi
class _TimerDisplay extends StatelessWidget {
  final int remainingSeconds;
  final int totalSeconds;
  final bool isRunning;
  final bool isCompleted;

  const _TimerDisplay({
    required this.remainingSeconds,
    required this.totalSeconds,
    required this.isRunning,
    required this.isCompleted,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final minutes = (remainingSeconds ~/ 60).toString().padLeft(2, '0');
    final seconds = (remainingSeconds % 60).toString().padLeft(2, '0');
    final progress = totalSeconds > 0 ? 1 - (remainingSeconds / totalSeconds) : 0.0;

    return Column(
      children: [
        // Timer dairesi
        SizedBox(
          width: 280,
          height: 280,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Arka plan dairesi
              Container(
                width: 280,
                height: 280,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.surfaceVariant.withValues(alpha: 0.5),
                ),
              ),

              // İlerleme dairesi
              SizedBox(
                width: 260,
                height: 260,
                child: CircularProgressIndicator(
                  value: progress,
                  strokeWidth: 8,
                  backgroundColor: Colors.transparent,
                  valueColor: AlwaysStoppedAnimation(
                    isCompleted ? AppColors.success : AppColors.primary,
                  ),
                  strokeCap: StrokeCap.round,
                ),
              ),

              // Zaman metni
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '$minutes:$seconds',
                    style: Theme.of(context).textTheme.displayLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                      fontSize: 56,
                      color: isCompleted ? AppColors.success : AppColors.textPrimary,
                      letterSpacing: 2,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: (isCompleted ? AppColors.success : AppColors.primary)
                          .withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      isCompleted
                          ? '✓ ${l10n.completed}'
                          : isRunning
                              ? '● ${l10n.running}'
                              : '○ ${l10n.ready}',
                      style: TextStyle(
                        color: isCompleted ? AppColors.success : AppColors.primary,
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Aksiyon butonu
class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isPrimary;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.isPrimary,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 18),
        decoration: BoxDecoration(
          color: isPrimary ? AppColors.primary : AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          boxShadow: isPrimary
              ? [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.3),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isPrimary ? Colors.white : AppColors.primary,
              size: 26,
            ),
            const SizedBox(width: 10),
            Text(
              label,
              style: TextStyle(
                color: isPrimary ? Colors.white : AppColors.primary,
                fontWeight: FontWeight.w600,
                fontSize: 17,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
