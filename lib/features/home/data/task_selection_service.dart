import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

import '../../../core/services/supabase_service.dart';
import '../../../shared/models/daily_task.dart';
import '../../../shared/models/room.dart';
import '../../../shared/models/task_catalog.dart';

/// Akıllı görev seçim servisi
class TaskSelectionService {
  final _uuid = const Uuid();
  final _random = Random();

  /// Bugünün görevini al veya oluştur
  /// [blacklist]: Gösterilmemesi gereken task_catalog_id'leri (kullanıcı blacklist'i)
  Future<DailyTask?> getOrCreateTodayTask(String userId, {List<String>? blacklist}) async {
    final today = _getTodayInIstanbul();
    final todayStr = today.toIso8601String().split('T').first;

    try {
      // Bugün için mevcut görev var mı?
      final existingResponse = await SupabaseService.client
          .from('daily_tasks')
          .select()
          .eq('user_id', userId)
          .eq('date', todayStr)
          .maybeSingle();

      if (existingResponse != null) {
        return DailyTask.fromJson(existingResponse);
      }

      // Yoksa yeni görev oluştur
      return await _createTodayTask(userId, today, blacklist: blacklist);
    } catch (e) {
      debugPrint('Görev alınamadı: $e');
      return null;
    }
  }

  /// Yeni günlük görev oluştur
  Future<DailyTask?> _createTodayTask(String userId, DateTime today, {List<String>? blacklist}) async {
    try {
      // Kullanıcının odalarını al
      final roomsResponse = await SupabaseService.client
          .from('rooms')
          .select()
          .eq('user_id', userId)
          .order('sort_order');

      final rooms = (roomsResponse as List)
          .map((e) => Room.fromJson(e))
          .toList();

      if (rooms.isEmpty) {
        debugPrint('Kullanıcının odası yok');
        return null;
      }

      // Görev katalogunu al
      final catalogResponse = await SupabaseService.client
          .from('tasks_catalog')
          .select();

      final catalog = (catalogResponse as List)
          .map((e) => TaskCatalog.fromJson(e))
          .toList();

      if (catalog.isEmpty) {
        debugPrint('Görev katalogu boş');
        return null;
      }

      // Son görevleri al (kural kontrolü için)
      final recentTasksResponse = await SupabaseService.client
          .from('daily_tasks')
          .select()
          .eq('user_id', userId)
          .order('date', ascending: false)
          .limit(7);

      final recentTasks = (recentTasksResponse as List)
          .map((e) => DailyTask.fromJson(e))
          .toList();

      // Blacklist'i al (dışarıdan inject edilebilir, yoksa boş)
      final blacklistedIds = blacklist ?? [];

      // Akıllı seçim yap
      final selection = _selectTask(
        catalog: catalog,
        rooms: rooms,
        recentTasks: recentTasks,
        blacklistedIds: blacklistedIds,
      );

      if (selection == null) {
        debugPrint('Görev seçilemedi');
        return null;
      }

      // Yeni görevi oluştur
      final newTask = DailyTask(
        id: _uuid.v4(),
        userId: userId,
        date: today,
        taskCatalogId: selection.task.id,
        roomId: selection.room?.id,
        status: DailyTaskStatus.assigned,
        assignedAt: DateTime.now(),
      );

      // Supabase'e kaydet
      await SupabaseService.client
          .from('daily_tasks')
          .insert(newTask.toJson());

      return newTask;
    } catch (e) {
      debugPrint('Görev oluşturulamadı: $e');
      return null;
    }
  }

  /// Akıllı görev seçimi
  _TaskSelection? _selectTask({
    required List<TaskCatalog> catalog,
    required List<Room> rooms,
    required List<DailyTask> recentTasks,
    List<String> blacklistedIds = const [],
  }) {
    // Son 1 günde kullanılan oda ve görev tiplerini bul
    final yesterday = _getTodayInIstanbul().subtract(const Duration(days: 1));

    final recentRoomIds = <String>{};
    final recentTaskTypes = <String>{};

    for (final task in recentTasks) {
      if (task.date.isAfter(yesterday) || task.date.isAtSameMomentAs(yesterday)) {
        if (task.roomId != null) {
          recentRoomIds.add(task.roomId!);
        }
        // Task type'ı catalog'dan bul
        final taskCatalog = catalog.where((c) => c.id == task.taskCatalogId).firstOrNull;
        if (taskCatalog != null) {
          recentTaskTypes.add(taskCatalog.taskType.name);
        }
      }
    }

    // Uygun görevleri filtrele — önce blacklist'teki görevleri çıkar
    var availableTasks = blacklistedIds.isNotEmpty
        ? catalog.where((t) => !blacklistedIds.contains(t.id)).toList()
        : catalog.toList();

    // Tüm görevler blacklist'teyse blacklist'i görmezden gel (fallback)
    if (availableTasks.isEmpty) {
      debugPrint('Tüm görevler blacklist\'te, blacklist görmezden geliniyor');
      availableTasks = catalog.toList();
    }

    var availableRooms = rooms.toList();

    // Kural 1: Son 1 günde kullanılmayan task type'ları tercih et
    var filteredTasks = availableTasks
        .where((t) => !recentTaskTypes.contains(t.taskType.name))
        .toList();

    if (filteredTasks.isEmpty) {
      // Kural gevşetme: task type kuralını kaldır
      filteredTasks = availableTasks;
    }

    // Kural 2: Son 1 günde kullanılmayan odaları tercih et (oda sayısı 2+ ise)
    if (rooms.length > 1) {
      var filteredRooms = availableRooms
          .where((r) => !recentRoomIds.contains(r.id))
          .toList();

      if (filteredRooms.isEmpty) {
        // Kural gevşetme: oda kuralını kaldır
        filteredRooms = availableRooms;
      }
      availableRooms = filteredRooms;
    }

    // Rastgele seç
    if (filteredTasks.isEmpty || availableRooms.isEmpty) {
      return null;
    }

    final selectedTask = filteredTasks[_random.nextInt(filteredTasks.length)];
    
    // Oda seç (room_scope'a göre)
    Room? selectedRoom;
    if (selectedTask.roomScope == RoomScope.roomRequired) {
      selectedRoom = availableRooms[_random.nextInt(availableRooms.length)];
    } else {
      // Room optional ise %50 ihtimalle oda ata
      if (_random.nextBool() && availableRooms.isNotEmpty) {
        selectedRoom = availableRooms[_random.nextInt(availableRooms.length)];
      }
    }

    return _TaskSelection(task: selectedTask, room: selectedRoom);
  }

  /// Kullanıcının cihaz timezone'una göre bugünün tarihini al
  /// Hardcoded UTC+3 yerine sistem saati kullanılır — global kullanıcılar için doğru davranış
  DateTime _getTodayLocal() {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day);
  }

  // Geriye dönük uyumluluk için alias
  DateTime _getTodayInIstanbul() => _getTodayLocal();
}

/// Görev seçim sonucu
class _TaskSelection {
  final TaskCatalog task;
  final Room? room;

  _TaskSelection({required this.task, this.room});
}

