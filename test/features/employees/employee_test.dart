import 'package:flutter_test/flutter_test.dart';
import 'package:trackbit/features/employees/domain/entities/employee.dart';

void main() {
  group('Employee', () {
    final now = DateTime(2026, 7, 26);

    test('creates with required fields', () {
      final employee = Employee(
        id: '1',
        position: 'Cashier',
        createdAt: now,
        updatedAt: now,
      );

      expect(employee.id, '1');
      expect(employee.position, 'Cashier');
      expect(employee.salary, 0);
      expect(employee.isActive, true);
      expect(employee.userId, isNull);
      expect(employee.hireDate, isNull);
    });

    test('creates with optional fields', () {
      final employee = Employee(
        id: '1',
        userId: 'user-1',
        position: 'Manager',
        salary: 50000,
        hireDate: DateTime(2025, 1, 15),
        phone: '+1234567890',
        address: '123 Main St',
        isActive: true,
        createdAt: now,
        updatedAt: now,
      );

      expect(employee.userId, 'user-1');
      expect(employee.salary, 50000);
      expect(employee.hireDate, DateTime(2025, 1, 15));
      expect(employee.phone, '+1234567890');
    });

    test('copyWith creates new instance with changes', () {
      final employee = Employee(
        id: '1',
        position: 'Cashier',
        salary: 30000,
        createdAt: now,
        updatedAt: now,
      );

      final updated = employee.copyWith(position: 'Manager', salary: 50000);
      expect(updated.position, 'Manager');
      expect(updated.salary, 50000);
      expect(employee.position, 'Cashier'); // original unchanged
    });

    test('equality based on props', () {
      final employee1 = Employee(
        id: '1',
        userId: 'user-1',
        position: 'Cashier',
        isActive: true,
        createdAt: now,
        updatedAt: now,
      );

      final employee2 = Employee(
        id: '1',
        userId: 'user-1',
        position: 'Cashier',
        isActive: true,
        createdAt: now,
        updatedAt: now,
      );

      expect(employee1, equals(employee2));
    });
  });
}
