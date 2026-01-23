import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../../../shared/providers/app_state_provider.dart';
import '../../providers/onboarding_provider.dart';

/// Günlük süre seçim ekranı
class DurationSetupScreen extends ConsumerStatefulWidget {
  const DurationSetupScreen({super.key});

  @override
  ConsumerState<DurationSetupScreen> createState() => _DurationSetupScreenState();
}

class _DurationSetupScreenState extends ConsumerState<DurationSetupScreen> {
  int _selectedDuration = AppConstants.defaultTaskDuration;

  Future<void> _completeOnboarding() async {
    // Süreyi provider'a kaydet
    ref.read(onboardingProvider.notifier).setPreferredMinutes(_selectedDuration);

    // Onboarding verilerini kaydet
    await ref.read(onboardingProvider.notifier).saveOnboardingData();

    // Onboarding'i tamamla
    await ref.read(appStateProvider.notifier).completeOnboarding();

    if (mounted) {
      context.go(AppRoutes.home);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final onboardingState = ref.watch(onboardingProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.dailyGoal),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go(AppRoutes.timeSetup),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Başlık
              Text(
                l10n.howMuchTimeDaily,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 8),
              Text(
                l10n.tasksAdjustedByDuration,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 48),

              // Süre seçenekleri
              ...AppConstants.taskDurationOptions.map((duration) {
                final isSelected = _selectedDuration == duration;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: _DurationOption(
                    duration: duration,
                    isSelected: isSelected,
                    onTap: () => setState(() => _selectedDuration = duration),
                    quickTaskLabel: l10n.quickAndPracticalTasks,
                    comprehensiveTaskLabel: l10n.moreComprehensiveTasks,
                    minutesLabel: l10n.minutes(duration),
                  ),
                );
              }),

              const SizedBox(height: 24),

              // Özet kartı
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: AppColors.surfaceGradient,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.primaryLight.withValues(alpha: 0.5)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.yourSelections,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 16),
                    _SummaryRow(
                      icon: Icons.home_outlined,
                      label: l10n.rooms,
                      value: l10n.roomsCount(onboardingState.rooms.length),
                    ),
                    const SizedBox(height: 12),
                    _SummaryRow(
                      icon: Icons.schedule_outlined,
                      label: l10n.timeRange,
                      value: '${onboardingState.availableStart} - ${onboardingState.availableEnd}',
                    ),
                    const SizedBox(height: 12),
                    _SummaryRow(
                      icon: Icons.timer_outlined,
                      label: l10n.dailyDuration,
                      value: l10n.minutes(_selectedDuration),
                    ),
                  ],
                ),
              ),

              const Spacer(),

              // Başla butonu
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: onboardingState.isLoading ? null : _completeOnboarding,
                  child: onboardingState.isLoading
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Text(l10n.startCleaning),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DurationOption extends StatelessWidget {
  final int duration;
  final bool isSelected;
  final VoidCallback onTap;
  final String quickTaskLabel;
  final String comprehensiveTaskLabel;
  final String minutesLabel;

  const _DurationOption({
    required this.duration,
    required this.isSelected,
    required this.onTap,
    required this.quickTaskLabel,
    required this.comprehensiveTaskLabel,
    required this.minutesLabel,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryLight.withValues(alpha: 0.2) : AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.surfaceVariant,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.2),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.primary
                    : AppColors.surfaceVariant,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.timer,
                color: isSelected ? Colors.white : AppColors.textSecondary,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    minutesLabel,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: isSelected ? AppColors.primary : AppColors.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    duration == 10
                        ? quickTaskLabel
                        : comprehensiveTaskLabel,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
            if (isSelected)
              const Icon(
                Icons.check_circle,
                color: AppColors.primary,
              ),
          ],
        ),
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _SummaryRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 20, color: AppColors.textSecondary),
        const SizedBox(width: 12),
        Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const Spacer(),
        Text(
          value,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
            color: AppColors.primary,
          ),
        ),
      ],
    );
  }
}

