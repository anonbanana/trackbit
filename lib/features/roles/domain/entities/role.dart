import 'package:equatable/equatable.dart';

class Role extends Equatable {
  final String id;
  final String name;
  final String label;
  final String? description;
  final String? parentRoleId;
  final bool isSystem;
  final bool isCustomizable;
  final int level;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Role({
    required this.id,
    required this.name,
    required this.label,
    this.description,
    this.parentRoleId,
    required this.isSystem,
    required this.isCustomizable,
    required this.level,
    required this.createdAt,
    required this.updatedAt,
  });

  Role copyWith({
    String? id,
    String? name,
    String? label,
    String? description,
    String? parentRoleId,
    bool? isSystem,
    bool? isCustomizable,
    int? level,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Role(
      id: id ?? this.id,
      name: name ?? this.name,
      label: label ?? this.label,
      description: description ?? this.description,
      parentRoleId: parentRoleId ?? this.parentRoleId,
      isSystem: isSystem ?? this.isSystem,
      isCustomizable: isCustomizable ?? this.isCustomizable,
      level: level ?? this.level,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [id, name, label, level];
}
