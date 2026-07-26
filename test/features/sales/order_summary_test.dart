import 'package:flutter_test/flutter_test.dart';
import 'package:trackbit/features/sales/domain/entities/order_summary.dart';
import 'package:trackbit/features/sales/domain/entities/order_detail.dart';

void main() {
  group('OrderSummary', () {
    final now = DateTime(2026, 7, 26);

    test('creates with required fields', () {
      final order = OrderSummary(
        id: '1',
        orderNumber: 'ORD-202607-0001',
        total: 99.99,
        paymentMethod: 'cash',
        status: 'completed',
        itemCount: 3,
        createdAt: now,
      );

      expect(order.id, '1');
      expect(order.orderNumber, 'ORD-202607-0001');
      expect(order.total, 99.99);
      expect(order.paymentMethod, 'cash');
      expect(order.status, 'completed');
      expect(order.itemCount, 3);
      expect(order.customerName, isNull);
    });

    test('creates with customer name', () {
      final order = OrderSummary(
        id: '1',
        orderNumber: 'ORD-202607-0001',
        customerName: 'John Doe',
        total: 99.99,
        paymentMethod: 'cash',
        status: 'completed',
        itemCount: 3,
        createdAt: now,
      );

      expect(order.customerName, 'John Doe');
    });

    test('equality based on props', () {
      final order1 = OrderSummary(
        id: '1',
        orderNumber: 'ORD-001',
        total: 99.99,
        paymentMethod: 'cash',
        status: 'completed',
        itemCount: 3,
        createdAt: now,
      );

      final order2 = OrderSummary(
        id: '1',
        orderNumber: 'ORD-001',
        total: 99.99,
        paymentMethod: 'cash',
        status: 'completed',
        itemCount: 3,
        createdAt: now,
      );

      expect(order1, equals(order2));
    });
  });
}
