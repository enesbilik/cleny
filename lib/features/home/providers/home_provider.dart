import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/services/supabase_service.dart';
import '../../../core/services/cache_service.dart';
import '../../../core/services/onesignal_service.dart';
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
  // Streak Freeze
  final int streakFreezeCount;
  final bool streakWasFrozenToday;

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
    this.streakFreezeCount = 0,
    this.streakWasFrozenToday = false,
  });

  /// Son temizlikten bu yana geçen gün sayısı.
  /// Bugün tamamlandıysa 0, hiç temizlik yoksa 999.
  int get daysSinceLastClean {
    if (todayTask?.isCompleted == true) return 0;
    if (completedDates.isEmpty) return 999;

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    int minDiff = 999;
    for (final d in completedDates) {
      final normalized = DateTime(d.year, d.month, d.day);
      final diff = today.difference(normalized).inDays;
      if (diff < minDiff) minDiff = diff;
    }
    return minDiff;
  }

  /// Ev fotoğrafı durumu: 'clean', 'medium', 'dirty'
  String get houseImageState {
    final days = daysSinceLastClean;
    if (days <= 1) return 'clean';
    if (days <= 2) return 'medium';
    return 'dirty';
  }

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
    int? streakFreezeCount,
    bool? streakWasFrozenToday,
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
      streakFreezeCount: streakFreezeCount ?? this.streakFreezeCount,
      streakWasFrozenToday: streakWasFrozenToday ?? this.streakWasFrozenToday,
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
            todayTask: cachedData['todayTask'] as DailyTask?,
            taskCatalog: cachedData['taskCatalog'] as TaskCatalog?,
            taskRoom: cachedData['taskRoom'] as Room?,
            isTaskRevealed: cachedData['isTaskRevealed'] as bool? ?? false,
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

    // Bugünün görevini cache'den yükle
    DailyTask? todayTask;
    TaskCatalog? taskCatalog;
    Room? taskRoom;
    bool isTaskRevealed = false;

    final cachedTodayTask = cacheService.getCachedTodayTask();
    if (cachedTodayTask != null) {
      try {
        todayTask = DailyTask.fromJson(cachedTodayTask);
        isTaskRevealed = todayTask.isRevealed;
        
        // Görev kataloğunu yükle
        if (todayTask.taskCatalogId.isNotEmpty) {
          final cachedCatalog = cacheService.getCachedTasksCatalog();
          if (cachedCatalog != null) {
            final catalogItem = cachedCatalog.firstWhere(
              (item) => item['id'] == todayTask!.taskCatalogId,
              orElse: () => {},
            );
            if (catalogItem.isNotEmpty) {
              taskCatalog = TaskCatalog.fromJson(catalogItem);
            }
          }
        }

        // Odayı yükle
        if (todayTask.roomId != null && todayTask.roomId!.isNotEmpty) {
          final cachedRooms = cacheService.getCachedRooms();
          if (cachedRooms != null) {
            final roomItem = cachedRooms.firstWhere(
              (item) => item['id'] == todayTask!.roomId,
              orElse: () => {},
            );
            if (roomItem.isNotEmpty) {
              taskRoom = Room.fromJson(roomItem);
            }
          }
        }
      } catch (e) {
        debugPrint('Cache parse error: $e');
      }
    }

    return {
      'currentStreak': cachedStats['current'] ?? 0,
      'bestStreak': cachedStats['best'] ?? 0,
      'totalCompleted': cachedStats['total'] ?? 0,
      'cleanlinessLevel': cachedStats['cleanlinessLevel'] ?? 0,
      'completedDates': completedDates,
      'recentCleans': recentCleans,
      'todayTask': todayTask,
      'taskCatalog': taskCatalog,
      'taskRoom': taskRoom,
      'isTaskRevealed': isTaskRevealed,
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
    // Bugünün görevini al veya oluştur (blacklist'i geçir)
    final blacklist = _getBlacklist();
    final todayTask = await _taskSelectionService.getOrCreateTodayTask(
      userId,
      blacklist: blacklist,
    );

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

    final newState = state.copyWith(
      isLoading: silent ? null : false,
      todayTask: todayTask,
      taskCatalog: taskCatalog,
      taskRoom: taskRoom,
      isTaskRevealed: todayTask?.isRevealed ?? false,
      cleanlinessLevel: cleanlinessLevel,
      currentStreak: statsData['current'] ?? 0,
      bestStreak: statsData['best'] ?? 0,
      totalCompleted: statsData['total'] ?? 0,
      recentCleans: recentCleans,
      completedDates: statsData['dates'] ?? <DateTime>{},
      streakFreezeCount: statsData['streakFreezeCount'] ?? 0,
      streakWasFrozenToday: statsData['streakWasFrozenToday'] ?? false,
    );
    if (!silent) {
      state = newState.copyWith(isLoading: false);
    } else {
      state = newState;
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

  /// Görevi açığa çıkar (Supabase'e kaydet)
  Future<void> revealTask() async {
    if (state.todayTask == null) {
      debugPrint('revealTask: todayTask is null');
      return;
    }

    try {
      final now = DateTime.now();
      
      // Supabase'e revealed_at'i kaydet
      await SupabaseService.client
          .from('daily_tasks')
          .update({'revealed_at': now.toIso8601String()})
          .eq('id', state.todayTask!.id);

      // State güncelle
      final updatedTask = state.todayTask!.copyWith(revealedAt: now);
      state = state.copyWith(
        todayTask: updatedTask,
        isTaskRevealed: true,
      );

      debugPrint('revealTask: Task revealed and saved to Supabase');
    } catch (e) {
      debugPrint('revealTask ERROR: $e');
      // Hata olsa bile state'i güncelle (offline mod)
      state = state.copyWith(isTaskRevealed: true);
    }
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

      // Anında UI feedback: görev completed + streak +1 optimistic update
      final optimisticStreak = state.currentStreak + 1;
      final today = DateTime(now.year, now.month, now.day);
      final updatedDates = {...state.completedDates, today};
      state = state.copyWith(
        todayTask: completedTask,
        currentStreak: optimisticStreak,
        totalCompleted: state.totalCompleted + 1,
        completedDates: updatedDates,
      );

      // Arka planda gerçek veriyi yükle (streak doğrulaması + cleanliness level)
      await loadData(forceRefresh: true);

      // OneSignal tag'lerini güncelle (push notification segmentasyonu için)
      await _updateOneSignalTags();
      
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

  /// OneSignal tag'lerini güncelle (push notification segmentasyonu için)
  Future<void> _updateOneSignalTags() async {
    try {
      // Görev durumu
      final isCompletedToday = state.todayTask?.status == DailyTaskStatus.completed;
      await OneSignalService.updateTaskStatus(
        completedToday: isCompletedToday,
        totalCompleted: state.recentCleans.length,
      );
      
      // Streak bilgisi
      await OneSignalService.updateStreakTag(state.currentStreak);
      
      // Son aktif zaman
      await OneSignalService.updateLastActive();
      
      debugPrint('OneSignal tags updated: completed=$isCompletedToday, streak=${state.currentStreak}');
    } catch (e) {
      debugPrint('OneSignal tag update error: $e');
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

      // Streak Freeze hakkını Hive'dan oku
      final freezeCount = _getStreakFreezeCount();

      // Current streak hesapla (freeze desteği ile)
      final now = DateTime.now();
      int currentStreak = 0;
      bool streakWasFrozenToday = false;
      var checkDate = DateTime(now.year, now.month, now.day);

      bool _isCompleted(DateTime d) => completedDatesSet.any((c) =>
          c.year == d.year && c.month == d.month && c.day == d.day);

      // Bugün tamamlanmadıysa dünden başla
      if (!_isCompleted(checkDate)) {
        checkDate = checkDate.subtract(const Duration(days: 1));
      }

      int freezesUsed = 0;
      while (true) {
        if (_isCompleted(checkDate)) {
          currentStreak++;
          checkDate = checkDate.subtract(const Duration(days: 1));
        } else if (freezesUsed < freezeCount) {
          // Freeze hakkı kullan: bu günü atla, streak korunur
          freezesUsed++;
          streakWasFrozenToday = true;
          checkDate = checkDate.subtract(const Duration(days: 1));
        } else {
          break;
        }
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
      if (currentStreak > bestStreak) bestStreak = currentStreak;

      return {
        'current': currentStreak,
        'best': bestStreak,
        'total': totalCompleted,
        'dates': completedDatesSet,
        'streakFreezeCount': freezeCount,
        'streakWasFrozenToday': streakWasFrozenToday,
      };
    } catch (e) {
      return {
        'current': 0,
        'best': 0,
        'total': 0,
        'dates': <DateTime>{},
        'streakFreezeCount': 0,
        'streakWasFrozenToday': false,
      };
    }
  }

  /// Görevi kalıcı olarak blacklist'e ekle ve bugün için yeni görev seç
  Future<void> skipTaskForever() async {
    final taskCatalogId = state.todayTask?.taskCatalogId;
    if (taskCatalogId == null || taskCatalogId.isEmpty) return;

    try {
      // Blacklist'e ekle (Hive cache)
      final blacklist = _getBlacklist();
      if (!blacklist.contains(taskCatalogId)) {
        blacklist.add(taskCatalogId);
        await cacheService.save(
          'task_blacklist',
          blacklist,
          validFor: const Duration(days: 365 * 10), // Kalıcı
        );
        debugPrint('Task blacklisted: $taskCatalogId. Total: ${blacklist.length}');
      }

      // Bugünkü görevi Supabase'den sil (yeni görev seçilecek)
      final userId = SupabaseService.currentUser?.id;
      if (userId != null && state.todayTask != null) {
        await SupabaseService.client
            .from('daily_tasks')
            .delete()
            .eq('id', state.todayTask!.id);
      }

      // State'i sıfırla ve yeniden yükle (yeni görev seçilecek)
      state = state.copyWith(
        todayTask: null,
        taskCatalog: null,
        taskRoom: null,
        isTaskRevealed: false,
        isLoading: true,
      );

      await loadData(forceRefresh: true);
    } catch (e) {
      debugPrint('skipTaskForever error: $e');
    }
  }

  /// Blacklist'teki görev ID'lerini oku
  List<String> _getBlacklist() {
    try {
      return cacheService.get<List<String>>(
            'task_blacklist',
            fromJson: (d) => (d as List).cast<String>(),
            ignoreExpiry: true,
          ) ??
          [];
    } catch (_) {
      return [];
    }
  }

  /// Görev seçimi için blacklist'i dışarı aç (TaskSelectionService için)
  List<String> getTaskBlacklist() => _getBlacklist();

  /// Streak freeze sayısını Hive'dan oku (ayda 2 hak, her ay sıfırlanır)
  int _getStreakFreezeCount() {
    try {
      final now = DateTime.now();
      final monthKey = 'streak_freeze_${now.year}_${now.month}';
      final used = cacheService.get<int>(monthKey,
              fromJson: (d) => d as int, ignoreExpiry: true) ??
          0;
      const maxPerMonth = 2;
      return (maxPerMonth - used).clamp(0, maxPerMonth);
    } catch (_) {
      return 0;
    }
  }

  /// Streak freeze hakkı kullan
  Future<void> useStreakFreeze() async {
    try {
      final now = DateTime.now();
      final monthKey = 'streak_freeze_${now.year}_${now.month}';
      final used = cacheService.get<int>(monthKey,
              fromJson: (d) => d as int, ignoreExpiry: true) ??
          0;
      await cacheService.save(monthKey, used + 1,
          validFor: const Duration(days: 35));
      debugPrint('Streak freeze kullanıldı. Kalan: ${_getStreakFreezeCount()}');
    } catch (e) {
      debugPrint('useStreakFreeze error: $e');
    }
  }

  /// Son tamamlanan görevleri tek sorguda (join ile) al — N+1 yok
  Future<List<CompletedTask>> _getRecentCleans(String userId) async {
    try {
      debugPrint('_getRecentCleans: Fetching for user $userId');

      // Tek sorguda daily_tasks + tasks_catalog + rooms join
      final response = await SupabaseService.client
          .from('daily_tasks')
          .select(
            'id, completed_at, '
            'tasks_catalog!task_catalog_id(title), '
            'rooms!room_id(name)',
          )
          .eq('user_id', userId)
          .eq('status', 'completed')
          .not('completed_at', 'is', null)
          .order('completed_at', ascending: false)
          .limit(10);

      debugPrint('_getRecentCleans: Found ${(response as List).length} tasks');

      final tasks = (response as List).map((item) {
        final catalogData = item['tasks_catalog'];
        final roomData = item['rooms'];
        final title = (catalogData is Map ? catalogData['title'] : null)
                as String? ??
            'Temizlik Görevi';
        final roomName =
            (roomData is Map ? roomData['name'] : null) as String?;

        return CompletedTask(
          id: item['id'] as String,
          title: title,
          completedAt: DateTime.parse(item['completed_at'] as String),
          roomName: roomName,
        );
      }).toList();

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
