import 'package:flutter_test/flutter_test.dart';
import 'package:trackbit/features/crm/domain/entities/customer.dart';

void main() {
  group('Customer', () {
    final now = DateTime(2026, 7, 26);

    test('creates with required fields', () {
      final customer = Customer(
        id: '1',
        name: 'John Doe',
        createdAt: now,
        updatedAt: now,
      );

      expect(customer.id, '1');
      expect(customer.name, 'John Doe');
      expect(customer.phone, isNull);
      expect(customer.email, isNull);
      expect(customer.address, isNull);
      expect(customer.loyaltyPoints, 0);
    });

    test('creates with optional fields', () {
      final customer = Customer(
        id: '1',
        name: 'John Doe',
        phone: '+1234567890',
        email: 'john@example.com',
        address: '123 Main St',
        loyaltyPoints: 100,
        createdAt: now,
        updatedAt: now,
      );

      expect(customer.phone, '+1234567890');
      expect(customer.email, 'john@example.com');
      expect(customer.address, '123 Main St');
      expect(customer.loyaltyPoints, 100);
    });

    test('copyWith creates new instance with changes', () {
      final customer = Customer(
        id: '1',
        name: 'John Doe',
        createdAt: now,
        updatedAt: now,
      );

      final updated = customer.copyWith(name: 'Jane Doe', loyaltyPoints: 50);
      expect(updated.name, 'Jane Doe');
      expect(updated.loyaltyPoints, 50);
      expect(customer.name, 'John Doe'); // original unchanged
    });

    test('equality based on props', () {
      final customer1 = Customer(
        id: '1',
        name: 'John Doe',
        phone: '+1234567890',
        createdAt: now,
        updatedAt: now,
      );

      final customer2 = Customer(
        id: '1',
        name: 'John Doe',
        phone: '+1234567890',
        createdAt: now,
        updatedAt: now,
      );

      expect(customer1, equals(customer2));
    });

    test('handles international characters in name', () {
      final customer = Customer(
        id: '1',
        name: 'Caf\u00e9 \u00d1o\u00f1o',
        createdAt: now,
        updatedAt: now,
      );

      expect(customer.name, 'Caf\u00e9 \u00d1o\u00f1o');
    });
  });
}
