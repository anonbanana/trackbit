import 'package:equatable/equatable.dart';

class Employee extends Equatable {
  final String id;
  final String? userId;
  final String position;
  final double salary;
  final DateTime? hireDate;
  final String? phone;
  final String? address;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Employee({
    required this.id,
    this.userId,
    required this.position,
    this.salary = 0,
    this.hireDate,
    this.phone,
    this.address,
    this.isActive = true,
    required this.createdAt,
    required this.updatedAt,
  });

  Employee copyWith({
    String? id,
    String? userId,
    String? position,
    double? salary,
    DateTime? hireDate,
    String? phone,
    String? address,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Employee(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      position: position ?? this.position,
      salary: salary ?? this.salary,
      hireDate: hireDate ?? this.hireDate,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [id, userId, position, isActive];
}
