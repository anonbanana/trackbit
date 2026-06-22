import 'package:equatable/equatable.dart';

class Permission extends Equatable {
  final String id;
  final String label;
  final String groupName;
  final String? description;

  const Permission({
    required this.id,
    required this.label,
    required this.groupName,
    this.description,
  });

  @override
  List<Object?> get props => [id, label, groupName];
}
