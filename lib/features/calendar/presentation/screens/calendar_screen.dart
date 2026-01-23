import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../providers/calendar_provider.dart';

/// Takvim ekranı
class CalendarScreen extends ConsumerWidget {
  const CalendarScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final calendarState = ref.watch(calendarProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Geçmiş'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: calendarState.isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Streak kartları
                  _StreakCards(
                    currentStreak: calendarState.currentStreak,
                    bestStreak: calendarState.bestStreak,
                    totalCompleted: calendarState.totalCompleted,
                  ),
                  const SizedBox(height: 32),

                  // Takvim başlığı
                  Text(
                    'Son ${AppConstants.calendarDaysToShow} Gün',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 16),

                  // Takvim grid
                  _CalendarGrid(
                    completedDates: calendarState.completedDates,
                  ),

                  const SizedBox(height: 24),

                  // Açıklama
                  _Legend(),
                ],
              ),
            ),
    );
  }
}

/// Streak kartları
class _StreakCards extends StatelessWidget {
  final int currentStreak;
  final int bestStreak;
  final int totalCompleted;

  const _StreakCards({
    required this.currentStreak,
    required this.bestStreak,
    required this.totalCompleted,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _StatCard(
            icon: Icons.local_fire_department,
            value: currentStreak.toString(),
            label: 'Güncel Seri',
            color: AppColors.accent,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _StatCard(
            icon: Icons.emoji_events,
            value: bestStreak.toString(),
            label: 'En İyi Seri',
            color: AppColors.accentDark,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _StatCard(
            icon: Icons.check_circle,
            value: totalCompleted.toString(),
            label: 'Toplam',
            color: AppColors.success,
          ),
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color color;

  const _StatCard({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 8),
          Text(
            value,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              color: color,
              fontWeight: FontWeight.w700,
            ),
          ),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

/// Takvim grid
class _CalendarGrid extends StatelessWidget {
  final Set<DateTime> completedDates;

  const _CalendarGrid({required this.completedDates});

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now();
    final days = List.generate(
      AppConstants.calendarDaysToShow,
      (index) => DateTime(today.year, today.month, today.day)
          .subtract(Duration(days: AppConstants.calendarDaysToShow - 1 - index)),
    );

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7,
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
      ),
      itemCount: days.length,
      itemBuilder: (context, index) {
        final day = days[index];
        final isCompleted = completedDates.any(
          (d) => d.year == day.year && d.month == day.month && d.day == day.day,
        );
        final isToday = day.year == today.year &&
            day.month == today.month &&
            day.day == today.day;
        final isFuture = day.isAfter(today);

        return _CalendarDay(
          day: day,
          isCompleted: isCompleted,
          isToday: isToday,
          isFuture: isFuture,
        );
      },
    );
  }
}

class _CalendarDay extends StatelessWidget {
  final DateTime day;
  final bool isCompleted;
  final bool isToday;
  final bool isFuture;

  const _CalendarDay({
    required this.day,
    required this.isCompleted,
    required this.isToday,
    required this.isFuture,
  });

  @override
  Widget build(BuildContext context) {
    final dayFormat = DateFormat('d');

    Color backgroundColor;
    Color textColor;
    BoxBorder? border;

    if (isFuture) {
      backgroundColor = AppColors.surfaceVariant.withValues(alpha: 0.5);
      textColor = AppColors.textHint;
    } else if (isCompleted) {
      backgroundColor = AppColors.success;
      textColor = Colors.white;
    } else {
      backgroundColor = AppColors.surface;
      textColor = AppColors.textSecondary;
    }

    if (isToday) {
      border = Border.all(color: AppColors.primary, width: 2);
    }

    return Container(
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(8),
        border: border,
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              dayFormat.format(day),
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                color: textColor,
                fontWeight: isToday ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
            if (isCompleted)
              const Icon(
                Icons.check,
                size: 14,
                color: Colors.white,
              ),
          ],
        ),
      ),
    );
  }
}

/// Açıklama
class _Legend extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _LegendItem(
          color: AppColors.success,
          label: 'Tamamlandı',
        ),
        const SizedBox(width: 24),
        _LegendItem(
          color: AppColors.surface,
          label: 'Tamamlanmadı',
          hasBorder: true,
        ),
        const SizedBox(width: 24),
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: AppColors.primary, width: 2),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          'Bugün',
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }
}

class _LegendItem extends StatelessWidget {
  final Color color;
  final String label;
  final bool hasBorder;

  const _LegendItem({
    required this.color,
    required this.label,
    this.hasBorder = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
            border: hasBorder ? Border.all(color: AppColors.surfaceVariant) : null,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }
}

