import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/services/supabase_service.dart';

/// Calendar durumu
class CalendarState {
  final bool isLoading;
  final Set<DateTime> completedDates;
  final int currentStreak;
  final int bestStreak;
  final int totalCompleted;
  final String? error;

  const CalendarState({
    this.isLoading = true,
    this.completedDates = const {},
    this.currentStreak = 0,
    this.bestStreak = 0,
    this.totalCompleted = 0,
    this.error,
  });

  CalendarState copyWith({
    bool? isLoading,
    Set<DateTime>? completedDates,
    int? currentStreak,
    int? bestStreak,
    int? totalCompleted,
    String? error,
  }) {
    return CalendarState(
      isLoading: isLoading ?? this.isLoading,
      completedDates: completedDates ?? this.completedDates,
      currentStreak: currentStreak ?? this.currentStreak,
      bestStreak: bestStreak ?? this.bestStreak,
      totalCompleted: totalCompleted ?? this.totalCompleted,
      error: error,
    );
  }
}

/// Calendar notifier
class CalendarNotifier extends StateNotifier<CalendarState> {
  CalendarNotifier() : super(const CalendarState()) {
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final userId = SupabaseService.currentUser?.id;
      if (userId == null) {
        state = state.copyWith(isLoading: false);
        return;
      }

      // Tamamlanan görevleri al
      final response = await SupabaseService.client
          .from('daily_tasks')
          .select('date')
          .eq('user_id', userId)
          .eq('status', 'completed')
          .order('date', ascending: false);

      final completedDates = (response as List)
          .map((e) => DateTime.parse(e['date'] as String))
          .toSet();

      // Streak hesapla
      final streakData = _calculateStreak(completedDates);

      state = state.copyWith(
        isLoading: false,
        completedDates: completedDates,
        currentStreak: streakData['current'] ?? 0,
        bestStreak: streakData['best'] ?? 0,
        totalCompleted: completedDates.length,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Map<String, int> _calculateStreak(Set<DateTime> completedDates) {
    if (completedDates.isEmpty) {
      return {'current': 0, 'best': 0};
    }

    // Tarihleri sırala
    final sortedDates = completedDates.toList()
      ..sort((a, b) => b.compareTo(a));

    final today = DateTime.now();
    final todayDate = DateTime(today.year, today.month, today.day);

    // Current streak
    int currentStreak = 0;
    var checkDate = todayDate;

    // Bugün tamamlanmadıysa dünden başla
    if (!_containsDate(sortedDates, checkDate)) {
      checkDate = checkDate.subtract(const Duration(days: 1));
    }

    while (_containsDate(sortedDates, checkDate)) {
      currentStreak++;
      checkDate = checkDate.subtract(const Duration(days: 1));
    }

    // Best streak
    int bestStreak = 0;
    int tempStreak = 0;
    DateTime? prevDate;

    for (final date in sortedDates.reversed) {
      if (prevDate == null) {
        tempStreak = 1;
      } else {
        final diff = date.difference(prevDate).inDays;
        if (diff == 1) {
          tempStreak++;
        } else {
          if (tempStreak > bestStreak) {
            bestStreak = tempStreak;
          }
          tempStreak = 1;
        }
      }
      prevDate = date;
    }

    if (tempStreak > bestStreak) {
      bestStreak = tempStreak;
    }

    return {'current': currentStreak, 'best': bestStreak};
  }

  bool _containsDate(List<DateTime> dates, DateTime date) {
    return dates.any(
      (d) => d.year == date.year && d.month == date.month && d.day == date.day,
    );
  }
}

/// Calendar provider
final calendarProvider = StateNotifierProvider<CalendarNotifier, CalendarState>(
  (ref) => CalendarNotifier(),
);

