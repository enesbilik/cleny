import 'package:equatable/equatable.dart';

/// Oda modeli
class Room extends Equatable {
  final String id;
  final String userId;
  final String name;
  final int sortOrder;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const Room({
    required this.id,
    required this.userId,
    required this.name,
    this.sortOrder = 0,
    required this.createdAt,
    this.updatedAt,
  });

  /// JSON'dan oluştur
  factory Room.fromJson(Map<String, dynamic> json) {
    return Room(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      name: json['name'] as String,
      sortOrder: json['sort_order'] as int? ?? 0,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
    );
  }

  /// JSON'a dönüştür
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'name': name,
      'sort_order': sortOrder,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  /// Kopyala ve güncelle
  Room copyWith({
    String? id,
    String? userId,
    String? name,
    int? sortOrder,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Room(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      sortOrder: sortOrder ?? this.sortOrder,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [id, userId, name, sortOrder, createdAt, updatedAt];
}

