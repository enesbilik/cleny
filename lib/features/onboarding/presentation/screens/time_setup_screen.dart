import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../providers/onboarding_provider.dart';

/// Zaman aralığı seçim ekranı
class TimeSetupScreen extends ConsumerStatefulWidget {
  const TimeSetupScreen({super.key});

  @override
  ConsumerState<TimeSetupScreen> createState() => _TimeSetupScreenState();
}

class _TimeSetupScreenState extends ConsumerState<TimeSetupScreen> {
  TimeOfDay _startTime = const TimeOfDay(hour: 19, minute: 0);
  TimeOfDay _endTime = const TimeOfDay(hour: 22, minute: 0);

  Future<void> _selectStartTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _startTime,
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _startTime = picked;
        // End time, start time'dan önce olamaz
        if (_endTime.hour < _startTime.hour ||
            (_endTime.hour == _startTime.hour && _endTime.minute <= _startTime.minute)) {
          _endTime = TimeOfDay(hour: _startTime.hour + 1, minute: 0);
        }
      });
    }
  }

  Future<void> _selectEndTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _endTime,
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
          child: child!,
        );
      },
    );

    if (picked != null) {
      // End time, start time'dan sonra olmalı
      if (picked.hour > _startTime.hour ||
          (picked.hour == _startTime.hour && picked.minute > _startTime.minute)) {
        setState(() {
          _endTime = picked;
        });
      } else {
        if (mounted) {
          final l10n = AppLocalizations.of(context)!;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(l10n.endTimeMustBeAfterStart)),
          );
        }
      }
    }
  }

  String _formatTime(TimeOfDay time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  void _continue() {
    // Saatleri provider'a kaydet
    ref.read(onboardingProvider.notifier).setAvailableTime(
      start: _formatTime(_startTime),
      end: _formatTime(_endTime),
    );

    context.go(AppRoutes.durationSetup);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.availableTime),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go(AppRoutes.roomSetup),
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
                l10n.whenAreYouAvailable,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 8),
              Text(
                l10n.notificationsBetweenTime,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 48),

              // İkon
              Center(
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: AppColors.secondaryLight.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.schedule,
                    size: 48,
                    color: AppColors.secondary,
                  ),
                ),
              ),
              const SizedBox(height: 48),

              // Saat seçiciler
              Row(
                children: [
                  Expanded(
                    child: _TimeSelector(
                      label: l10n.startTime,
                      time: _formatTime(_startTime),
                      onTap: _selectStartTime,
                    ),
                  ),
                  const SizedBox(width: 16),
                  const Icon(
                    Icons.arrow_forward,
                    color: AppColors.textHint,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _TimeSelector(
                      label: l10n.endTime,
                      time: _formatTime(_endTime),
                      onTap: _selectEndTime,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Bilgi notu
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surfaceVariant,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.info_outline,
                      color: AppColors.textSecondary,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        l10n.notificationsRandomTime,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ),
                  ],
                ),
              ),

              const Spacer(),

              // Devam butonu
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _continue,
                  child: Text(l10n.continueButton),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TimeSelector extends StatelessWidget {
  final String label;
  final String time;
  final VoidCallback onTap;

  const _TimeSelector({
    required this.label,
    required this.time,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.primary),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 8),
            Text(
              time,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

