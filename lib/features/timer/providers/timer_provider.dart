import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_constants.dart';
import '../../home/providers/home_provider.dart';

/// Timer durumu
class TimerState {
  final int totalSeconds;
  final int remainingSeconds;
  final bool isRunning;
  final bool isTimerCompleted;
  final bool isTaskCompleted;
  final String taskTitle;

  const TimerState({
    this.totalSeconds = 600,
    this.remainingSeconds = 600,
    this.isRunning = false,
    this.isTimerCompleted = false,
    this.isTaskCompleted = false,
    this.taskTitle = '',
  });

  TimerState copyWith({
    int? totalSeconds,
    int? remainingSeconds,
    bool? isRunning,
    bool? isTimerCompleted,
    bool? isTaskCompleted,
    String? taskTitle,
  }) {
    return TimerState(
      totalSeconds: totalSeconds ?? this.totalSeconds,
      remainingSeconds: remainingSeconds ?? this.remainingSeconds,
      isRunning: isRunning ?? this.isRunning,
      isTimerCompleted: isTimerCompleted ?? this.isTimerCompleted,
      isTaskCompleted: isTaskCompleted ?? this.isTaskCompleted,
      taskTitle: taskTitle ?? this.taskTitle,
    );
  }
}

/// Timer notifier
class TimerNotifier extends StateNotifier<TimerState> {
  final Ref _ref;
  Timer? _timer;

  TimerNotifier(this._ref) : super(const TimerState()) {
    _initialize();
  }

  void _initialize() {
    final homeState = _ref.read(homeProvider);
    final taskCatalog = homeState.taskCatalog;
    
    final minutes = taskCatalog?.estimatedMinutes ?? AppConstants.defaultTaskDuration;
    final totalSeconds = minutes * 60;

    state = state.copyWith(
      totalSeconds: totalSeconds,
      remainingSeconds: totalSeconds,
      taskTitle: taskCatalog?.title ?? 'Görev',
    );
  }

  /// Timer'ı başlat
  void start() {
    if (state.isTimerCompleted || state.isTaskCompleted) return;

    state = state.copyWith(isRunning: true);

    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (state.remainingSeconds > 0) {
        state = state.copyWith(remainingSeconds: state.remainingSeconds - 1);
      } else {
        _timer?.cancel();
        state = state.copyWith(
          isRunning: false,
          isTimerCompleted: true,
        );
      }
    });
  }

  /// Timer'ı durdur
  void pause() {
    _timer?.cancel();
    state = state.copyWith(isRunning: false);
  }

  /// Timer'ı sıfırla
  void reset() {
    _timer?.cancel();
    state = state.copyWith(
      remainingSeconds: state.totalSeconds,
      isRunning: false,
      isTimerCompleted: false,
    );
  }

  /// Timer'ı tamamlandı olarak işaretle (erken tamamlama)
  void markTimerCompleted() {
    _timer?.cancel();
    state = state.copyWith(
      isRunning: false,
      isTimerCompleted: true,
    );
  }

  /// Görevi tamamla
  Future<void> completeTask() async {
    state = state.copyWith(isTaskCompleted: true);
    
    // Home provider'daki görevi tamamla
    await _ref.read(homeProvider.notifier).completeTask();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}

/// Timer provider
final timerProvider = StateNotifierProvider.autoDispose<TimerNotifier, TimerState>(
  (ref) => TimerNotifier(ref),
);

