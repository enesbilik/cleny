import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/services/supabase_service.dart';
import '../../../core/services/cache_service.dart';
import '../../../shared/models/daily_task.dart';
import '../../../shared/models/room.dart';
import '../../../shared/models/task_catalog.dart';
import '../../home/data/task_selection_service.dart';

/// Tamamlanan görev detayı
class CompletedTask {
  final String id;
  final String title;
  final DateTime completedAt;
  final String? roomName;

  CompletedTask({
    required this.id,
    required this.title,
    required this.completedAt,
    this.roomName,
  });
}

/// Home durumu
class HomeState {
  final bool isLoading;
  final DailyTask? todayTask;
  final TaskCatalog? taskCatalog;
  final Room? taskRoom;
  final bool isTaskRevealed;
  final int cleanlinessLevel;
  final int currentStreak;
  final int bestStreak;
  final int totalCompleted;
  final List<CompletedTask> recentCleans;
  final Set<DateTime> completedDates;
  final String? error;

  const HomeState({
    this.isLoading = true,
    this.todayTask,
    this.taskCatalog,
    this.taskRoom,
    this.isTaskRevealed = false,
    this.cleanlinessLevel = 0,
    this.currentStreak = 0,
    this.bestStreak = 0,
    this.totalCompleted = 0,
    this.recentCleans = const [],
    this.completedDates = const {},
    this.error,
  });

  HomeState copyWith({
    bool? isLoading,
    DailyTask? todayTask,
    TaskCatalog? taskCatalog,
    Room? taskRoom,
    bool? isTaskRevealed,
    int? cleanlinessLevel,
    int? currentStreak,
    int? bestStreak,
    int? totalCompleted,
    List<CompletedTask>? recentCleans,
    Set<DateTime>? completedDates,
    String? error,
  }) {
    return HomeState(
      isLoading: isLoading ?? this.isLoading,
      todayTask: todayTask ?? this.todayTask,
      taskCatalog: taskCatalog ?? this.taskCatalog,
      taskRoom: taskRoom ?? this.taskRoom,
      isTaskRevealed: isTaskRevealed ?? this.isTaskRevealed,
      cleanlinessLevel: cleanlinessLevel ?? this.cleanlinessLevel,
      currentStreak: currentStreak ?? this.currentStreak,
      bestStreak: bestStreak ?? this.bestStreak,
      totalCompleted: totalCompleted ?? this.totalCompleted,
      recentCleans: recentCleans ?? this.recentCleans,
      completedDates: completedDates ?? this.completedDates,
      error: error,
    );
  }
}

/// Home notifier
class HomeNotifier extends StateNotifier<HomeState> {
  HomeNotifier() : super(const HomeState()) {
    _initialize();
  }

  final _taskSelectionService = TaskSelectionService();

  Future<void> _initialize() async {
    await loadData();
  }

  /// Verileri yükle (cache destekli)
  Future<void> loadData({bool forceRefresh = false}) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final userId = SupabaseService.currentUser?.id;
      if (userId == null) {
        state = state.copyWith(isLoading: false);
        return;
      }

      // Önce cache'den yükle (hızlı UI güncellemesi)
      if (!forceRefresh) {
        final cachedData = _loadFromCache();
        if (cachedData != null) {
          state = state.copyWith(
            isLoading: false,
            currentStreak: cachedData['currentStreak'] as int,
            bestStreak: cachedData['bestStreak'] as int,
            totalCompleted: cachedData['totalCompleted'] as int,
            cleanlinessLevel: cachedData['cleanlinessLevel'] as int,
            completedDates: cachedData['completedDates'] as Set<DateTime>,
            recentCleans: cachedData['recentCleans'] as List<CompletedTask>,
          );
          // Arka planda güncelleme yap
          _refreshInBackground(userId);
          return;
        }
      }

      // Cache yoksa veya force refresh ise Supabase'den al
      await _loadFromNetwork(userId);
    } catch (e) {
      debugPrint('LoadData error: $e');
      
      // Hata durumunda cache'den yükle (offline mod)
      final cachedData = _loadFromCache();
      if (cachedData != null) {
        state = state.copyWith(
          isLoading: false,
          error: 'Offline mod - Cache\'den yüklendi',
          currentStreak: cachedData['currentStreak'] as int,
          bestStreak: cachedData['bestStreak'] as int,
          totalCompleted: cachedData['totalCompleted'] as int,
          cleanlinessLevel: cachedData['cleanlinessLevel'] as int,
          completedDates: cachedData['completedDates'] as Set<DateTime>,
          recentCleans: cachedData['recentCleans'] as List<CompletedTask>,
        );
      } else {
        state = state.copyWith(
          isLoading: false,
          error: e.toString(),
        );
      }
    }
  }

  /// Cache'den veri yükle
  Map<String, dynamic>? _loadFromCache() {
    final cachedStats = cacheService.getCachedStats();
    
    if (cachedStats == null) return null;
    
    // Tarih listesini parse et
    final datesRaw = cachedStats['dates'] as List? ?? [];
    final completedDates = datesRaw
        .map((d) => DateTime.tryParse(d.toString()))
        .whereType<DateTime>()
        .toSet();

    // Recent cleans parse et
    final recentRaw = cachedStats['recentCleans'] as List? ?? [];
    final recentCleans = recentRaw.map((item) => CompletedTask(
      id: item['id'] ?? '',
      title: item['title'] ?? 'Temizlik Görevi',
      completedAt: DateTime.tryParse(item['completedAt'] ?? '') ?? DateTime.now(),
      roomName: item['roomName'],
    )).toList();

    return {
      'currentStreak': cachedStats['current'] ?? 0,
      'bestStreak': cachedStats['best'] ?? 0,
      'totalCompleted': cachedStats['total'] ?? 0,
      'cleanlinessLevel': cachedStats['cleanlinessLevel'] ?? 0,
      'completedDates': completedDates,
      'recentCleans': recentCleans,
    };
  }

  /// Arka planda güncelleme yap
  Future<void> _refreshInBackground(String userId) async {
    try {
      await _loadFromNetwork(userId, silent: true);
    } catch (e) {
      debugPrint('Background refresh failed: $e');
    }
  }

  /// Network'ten veri yükle ve cache'e kaydet
  Future<void> _loadFromNetwork(String userId, {bool silent = false}) async {
    // Bugünün görevini al veya oluştur
    final todayTask = await _taskSelectionService.getOrCreateTodayTask(userId);

    // Görev kataloğunu al
    TaskCatalog? taskCatalog;
    if (todayTask != null) {
      taskCatalog = await _getTaskCatalog(todayTask.taskCatalogId);
    }

    // Odayı al
    Room? taskRoom;
    if (todayTask?.roomId != null) {
      taskRoom = await _getRoom(todayTask!.roomId!);
    }

    // Streak ve istatistikleri hesapla
    final statsData = await _calculateStats(userId);

    // Son tamamlanan görevleri al
    final recentCleans = await _getRecentCleans(userId);

    // Temizlik seviyesi hesapla
    final cleanlinessLevel = await _calculateCleanlinessLevel(userId);

    // Cache'e kaydet
    await _saveToCache(statsData, recentCleans, cleanlinessLevel, todayTask);

    if (!silent) {
      state = state.copyWith(
        isLoading: false,
        todayTask: todayTask,
        taskCatalog: taskCatalog,
        taskRoom: taskRoom,
        isTaskRevealed: todayTask?.isCompleted == true,
        cleanlinessLevel: cleanlinessLevel,
        currentStreak: statsData['current'] ?? 0,
        bestStreak: statsData['best'] ?? 0,
        totalCompleted: statsData['total'] ?? 0,
        recentCleans: recentCleans,
        completedDates: statsData['dates'] ?? <DateTime>{},
      );
    } else {
      // Silent update - sadece değişen verileri güncelle
      state = state.copyWith(
        todayTask: todayTask,
        taskCatalog: taskCatalog,
        taskRoom: taskRoom,
        isTaskRevealed: todayTask?.isCompleted == true,
        cleanlinessLevel: cleanlinessLevel,
        currentStreak: statsData['current'] ?? 0,
        bestStreak: statsData['best'] ?? 0,
        totalCompleted: statsData['total'] ?? 0,
        recentCleans: recentCleans,
        completedDates: statsData['dates'] ?? <DateTime>{},
      );
    }
  }

  /// Cache'e kaydet
  Future<void> _saveToCache(
    Map<String, dynamic> statsData,
    List<CompletedTask> recentCleans,
    int cleanlinessLevel,
    DailyTask? todayTask,
  ) async {
    // İstatistikleri cache'le
    final dates = (statsData['dates'] as Set<DateTime>?)?.map((d) => d.toIso8601String()).toList() ?? [];
    await cacheService.cacheStats({
      'current': statsData['current'],
      'best': statsData['best'],
      'total': statsData['total'],
      'cleanlinessLevel': cleanlinessLevel,
      'dates': dates,
      'recentCleans': recentCleans.map((t) => {
        'id': t.id,
        'title': t.title,
        'completedAt': t.completedAt.toIso8601String(),
        'roomName': t.roomName,
      }).toList(),
    });

    // Bugünün görevini cache'le
    if (todayTask != null) {
      await cacheService.cacheTodayTask(todayTask.toJson());
    }

    // Son sync zamanını güncelle
    await cacheService.setLastSync();
  }

  /// Görevi açığa çıkar
  Future<void> revealTask() async {
    state = state.copyWith(isTaskRevealed: true);
  }

  /// Görevi tamamla
  Future<void> completeTask() async {
    if (state.todayTask == null) {
      debugPrint('completeTask: todayTask is null');
      return;
    }

    try {
      debugPrint('completeTask: Starting task completion for ${state.todayTask!.id}');
      
      final now = DateTime.now();
      final completedTask = state.todayTask!.copyWith(
        status: DailyTaskStatus.completed,
        completedAt: now,
        completionMethod: 'hold_clean',
      );

      // Supabase'e sadece güncellenen alanları gönder
      final updateData = {
        'status': 'completed',
        'completed_at': now.toIso8601String(),
        'completion_method': 'hold_clean',
      };
      
      debugPrint('completeTask: Updating with data: $updateData');

      await SupabaseService.client
          .from('daily_tasks')
          .update(updateData)
          .eq('id', completedTask.id);

      debugPrint('completeTask: Supabase update successful');

      // State güncelle
      state = state.copyWith(todayTask: completedTask);

      // Verileri yeniden yükle (streak ve seviye güncellemesi için)
      await loadData(forceRefresh: true);
      
      debugPrint('completeTask: Task completed successfully');
    } catch (e) {
      debugPrint('completeTask ERROR: $e');
      state = state.copyWith(error: e.toString());
    }
  }

  Future<TaskCatalog?> _getTaskCatalog(String id) async {
    try {
      final response = await SupabaseService.client
          .from('tasks_catalog')
          .select()
          .eq('id', id)
          .single();
      return TaskCatalog.fromJson(response);
    } catch (e) {
      return null;
    }
  }

  Future<Room?> _getRoom(String id) async {
    try {
      final response = await SupabaseService.client
          .from('rooms')
          .select()
          .eq('id', id)
          .single();
      return Room.fromJson(response);
    } catch (e) {
      return null;
    }
  }

  Future<Map<String, dynamic>> _calculateStats(String userId) async {
    try {
      // Tüm tamamlanan görevleri al
      final response = await SupabaseService.client
          .from('daily_tasks')
          .select('date')
          .eq('user_id', userId)
          .eq('status', 'completed')
          .order('date', ascending: false);

      final allDates = (response as List)
          .map((e) => DateTime.parse(e['date'] as String))
          .toList();

      final completedDatesSet = allDates.toSet();
      final totalCompleted = allDates.length;

      // Current streak hesapla
      final now = DateTime.now();
      int currentStreak = 0;
      var checkDate = DateTime(now.year, now.month, now.day);

      // Bugün tamamlanmadıysa dünden başla
      if (!completedDatesSet.any((d) =>
          d.year == checkDate.year &&
          d.month == checkDate.month &&
          d.day == checkDate.day)) {
        checkDate = checkDate.subtract(const Duration(days: 1));
      }

      while (completedDatesSet.any((d) =>
          d.year == checkDate.year &&
          d.month == checkDate.month &&
          d.day == checkDate.day)) {
        currentStreak++;
        checkDate = checkDate.subtract(const Duration(days: 1));
      }

      // Best streak hesapla
      int bestStreak = 0;
      int tempStreak = 0;
      final sortedDates = allDates.toList()..sort();

      for (int i = 0; i < sortedDates.length; i++) {
        if (i == 0) {
          tempStreak = 1;
        } else {
          final diff = sortedDates[i].difference(sortedDates[i - 1]).inDays;
          if (diff == 1) {
            tempStreak++;
          } else {
            if (tempStreak > bestStreak) bestStreak = tempStreak;
            tempStreak = 1;
          }
        }
      }
      if (tempStreak > bestStreak) bestStreak = tempStreak;

      return {
        'current': currentStreak,
        'best': bestStreak,
        'total': totalCompleted,
        'dates': completedDatesSet,
      };
    } catch (e) {
      return {'current': 0, 'best': 0, 'total': 0, 'dates': <DateTime>{}};
    }
  }

  Future<List<CompletedTask>> _getRecentCleans(String userId) async {
    try {
      debugPrint('_getRecentCleans: Fetching for user $userId');
      
      final response = await SupabaseService.client
          .from('daily_tasks')
          .select('id, date, completed_at, task_catalog_id, room_id')
          .eq('user_id', userId)
          .eq('status', 'completed')
          .not('completed_at', 'is', null)
          .order('completed_at', ascending: false)
          .limit(10);

      debugPrint('_getRecentCleans: Found ${(response as List).length} completed tasks');

      final tasks = <CompletedTask>[];

      for (final item in response) {
        // completed_at null kontrolü
        if (item['completed_at'] == null) continue;
        
        // Görev başlığını al
        String title = 'Temizlik Görevi';
        try {
          final catalogResponse = await SupabaseService.client
              .from('tasks_catalog')
              .select('title')
              .eq('id', item['task_catalog_id'])
              .single();
          title = catalogResponse['title'] ?? title;
        } catch (_) {}

        // Oda adını al
        String? roomName;
        if (item['room_id'] != null) {
          try {
            final roomResponse = await SupabaseService.client
                .from('rooms')
                .select('name')
                .eq('id', item['room_id'])
                .single();
            roomName = roomResponse['name'];
          } catch (_) {}
        }

        tasks.add(CompletedTask(
          id: item['id'],
          title: title,
          completedAt: DateTime.parse(item['completed_at']),
          roomName: roomName,
        ));
      }

      debugPrint('_getRecentCleans: Returning ${tasks.length} tasks');
      return tasks;
    } catch (e) {
      debugPrint('_getRecentCleans ERROR: $e');
      return [];
    }
  }

  Future<int> _calculateCleanlinessLevel(String userId) async {
    try {
      // Son 7 günde tamamlanan gün sayısı
      final now = DateTime.now();
      final sevenDaysAgo = now.subtract(
        Duration(days: AppConstants.streakCalculationDays),
      );

      final response = await SupabaseService.client
          .from('daily_tasks')
          .select('date')
          .eq('user_id', userId)
          .eq('status', 'completed')
          .gte('date', sevenDaysAgo.toIso8601String().split('T').first);

      final completedCount = (response as List).length;

      // Seviye hesapla (0-4)
      if (completedCount <= 1) return 0;
      if (completedCount == 2) return 1;
      if (completedCount <= 4) return 2;
      if (completedCount == 5) return 3;
      return AppConstants.maxCleanlinessLevel;
    } catch (e) {
      return 0;
    }
  }
}

/// Home provider
final homeProvider = StateNotifierProvider<HomeNotifier, HomeState>(
  (ref) => HomeNotifier(),
);
