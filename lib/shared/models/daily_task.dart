import 'package:equatable/equatable.dart';

/// Günlük görev durumu
enum DailyTaskStatus {
  assigned,   // Atandı
  completed,  // Tamamlandı
  skipped,    // Atlandı
}

/// Günlük görev modeli
class DailyTask extends Equatable {
  final String id;
  final String userId;
  final DateTime date;
  final String taskCatalogId;
  final String? roomId;
  final DailyTaskStatus status;
  final DateTime assignedAt;
  final DateTime? completedAt;
  final String? completionMethod;
  final int? durationSeconds;

  const DailyTask({
    required this.id,
    required this.userId,
    required this.date,
    required this.taskCatalogId,
    this.roomId,
    this.status = DailyTaskStatus.assigned,
    required this.assignedAt,
    this.completedAt,
    this.completionMethod,
    this.durationSeconds,
  });

  /// Görev tamamlandı mı?
  bool get isCompleted => status == DailyTaskStatus.completed;

  /// Görev atlandı mı?
  bool get isSkipped => status == DailyTaskStatus.skipped;

  /// Görev beklemede mi?
  bool get isPending => status == DailyTaskStatus.assigned;

  /// JSON'dan oluştur
  factory DailyTask.fromJson(Map<String, dynamic> json) {
    return DailyTask(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      date: DateTime.parse(json['date'] as String),
      taskCatalogId: json['task_catalog_id'] as String,
      roomId: json['room_id'] as String?,
      status: DailyTaskStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => DailyTaskStatus.assigned,
      ),
      assignedAt: DateTime.parse(json['assigned_at'] as String),
      completedAt: json['completed_at'] != null
          ? DateTime.parse(json['completed_at'] as String)
          : null,
      completionMethod: json['completion_method'] as String?,
      durationSeconds: json['duration_seconds'] as int?,
    );
  }

  /// JSON'a dönüştür
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'date': date.toIso8601String().split('T').first,
      'task_catalog_id': taskCatalogId,
      'room_id': roomId,
      'status': status.name,
      'assigned_at': assignedAt.toIso8601String(),
      'completed_at': completedAt?.toIso8601String(),
      'completion_method': completionMethod,
      'duration_seconds': durationSeconds,
    };
  }

  /// Kopyala ve güncelle
  DailyTask copyWith({
    String? id,
    String? userId,
    DateTime? date,
    String? taskCatalogId,
    String? roomId,
    DailyTaskStatus? status,
    DateTime? assignedAt,
    DateTime? completedAt,
    String? completionMethod,
    int? durationSeconds,
  }) {
    return DailyTask(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      date: date ?? this.date,
      taskCatalogId: taskCatalogId ?? this.taskCatalogId,
      roomId: roomId ?? this.roomId,
      status: status ?? this.status,
      assignedAt: assignedAt ?? this.assignedAt,
      completedAt: completedAt ?? this.completedAt,
      completionMethod: completionMethod ?? this.completionMethod,
      durationSeconds: durationSeconds ?? this.durationSeconds,
    );
  }

  @override
  List<Object?> get props => [
        id,
        userId,
        date,
        taskCatalogId,
        roomId,
        status,
        assignedAt,
        completedAt,
        completionMethod,
        durationSeconds,
      ];
}

