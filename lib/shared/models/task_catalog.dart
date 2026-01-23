import 'package:equatable/equatable.dart';

/// Görev tipi enum
enum TaskType {
  vacuum,   // Süpürme
  wipe,     // Silme
  tidy,     // Toparlama
  trash,    // Çöp çıkarma
  kitchen,  // Mutfak işleri
  laundry,  // Çamaşır
  bath,     // Banyo
  dust,     // Toz alma
}

/// Oda gereksinimi
enum RoomScope {
  roomRequired,   // Oda gerekli
  roomOptional,   // Oda opsiyonel (genel görev)
}

/// Görev katalog modeli (seed data)
class TaskCatalog extends Equatable {
  final String id;
  final String title;
  final String description;
  final int estimatedMinutes;
  final TaskType taskType;
  final RoomScope roomScope;
  final int difficulty;
  final String? audioKey;
  final String iconKey;

  const TaskCatalog({
    required this.id,
    required this.title,
    required this.description,
    required this.estimatedMinutes,
    required this.taskType,
    required this.roomScope,
    this.difficulty = 1,
    this.audioKey,
    this.iconKey = 'cleaning',
  });

  /// JSON'dan oluştur
  factory TaskCatalog.fromJson(Map<String, dynamic> json) {
    return TaskCatalog(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      estimatedMinutes: json['estimated_minutes'] as int,
      taskType: TaskType.values.firstWhere(
        (e) => e.name == json['task_type'],
        orElse: () => TaskType.tidy,
      ),
      roomScope: json['room_scope'] == 'ROOM_REQUIRED'
          ? RoomScope.roomRequired
          : RoomScope.roomOptional,
      difficulty: json['difficulty'] as int? ?? 1,
      audioKey: json['audio_key'] as String?,
      iconKey: json['icon_key'] as String? ?? 'cleaning',
    );
  }

  /// JSON'a dönüştür
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'estimated_minutes': estimatedMinutes,
      'task_type': taskType.name,
      'room_scope': roomScope == RoomScope.roomRequired ? 'ROOM_REQUIRED' : 'ROOM_OPTIONAL',
      'difficulty': difficulty,
      'audio_key': audioKey,
      'icon_key': iconKey,
    };
  }

  /// Task type için Türkçe isim
  String get taskTypeDisplayName {
    switch (taskType) {
      case TaskType.vacuum:
        return 'Süpürme';
      case TaskType.wipe:
        return 'Silme';
      case TaskType.tidy:
        return 'Toparlama';
      case TaskType.trash:
        return 'Çöp';
      case TaskType.kitchen:
        return 'Mutfak';
      case TaskType.laundry:
        return 'Çamaşır';
      case TaskType.bath:
        return 'Banyo';
      case TaskType.dust:
        return 'Toz Alma';
    }
  }

  /// Task type için ikon
  String get taskTypeIcon {
    switch (taskType) {
      case TaskType.vacuum:
        return '🧹';
      case TaskType.wipe:
        return '🧽';
      case TaskType.tidy:
        return '📦';
      case TaskType.trash:
        return '🗑️';
      case TaskType.kitchen:
        return '🍳';
      case TaskType.laundry:
        return '👕';
      case TaskType.bath:
        return '🚿';
      case TaskType.dust:
        return '✨';
    }
  }

  @override
  List<Object?> get props => [
        id,
        title,
        description,
        estimatedMinutes,
        taskType,
        roomScope,
        difficulty,
        audioKey,
        iconKey,
      ];
}

