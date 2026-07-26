import 'package:flutter_test/flutter_test.dart';
import 'package:trackbit/features/sales/domain/entities/order_detail.dart';

void main() {
  group('OrderDetailItem', () {
    test('creates with required fields', () {
      final item = OrderDetailItem(
        id: '1',
        productName: 'Widget',
        quantity: 3,
        unit: 'pcs',
        unitPrice: 19.99,
        subtotal: 59.97,
      );

      expect(item.id, '1');
      expect(item.productName, 'Widget');
      expect(item.quantity, 3);
      expect(item.unitPrice, 19.99);
      expect(item.subtotal, 59.97);
    });

    test('equality based on props', () {
      final item1 = OrderDetailItem(
        id: '1',
        productName: 'Widget',
        quantity: 3,
        unit: 'pcs',
        unitPrice: 19.99,
        subtotal: 59.97,
      );

      final item2 = OrderDetailItem(
        id: '1',
        productName: 'Widget',
        quantity: 3,
        unit: 'pcs',
        unitPrice: 19.99,
        subtotal: 59.97,
      );

      expect(item1, equals(item2));
    });
  });

  group('OrderDetail', () {
    final now = DateTime(2026, 7, 26);
    final items = [
      const OrderDetailItem(
        id: '1',
        productName: 'Widget',
        quantity: 2,
        unit: 'pcs',
        unitPrice: 19.99,
        subtotal: 39.98,
      ),
    ];

    test('creates with required fields', () {
      final order = OrderDetail(
        id: '1',
        orderNumber: 'ORD-001',
        userId: 'user-1',
        subtotal: 39.98,
        tax: 4.00,
        discount: 0,
        total: 43.98,
        paymentMethod: 'cash',
        status: 'completed',
        items: items,
        createdAt: now,
      );

      expect(order.id, '1');
      expect(order.orderNumber, 'ORD-001');
      expect(order.total, 43.98);
      expect(order.items.length, 1);
      expect(order.customerName, isNull);
    });

    test('creates with customer info', () {
      final order = OrderDetail(
        id: '1',
        orderNumber: 'ORD-001',
        customerId: 'cust-1',
        customerName: 'John Doe',
        customerPhone: '+1234567890',
        userId: 'user-1',
        subtotal: 39.98,
        tax: 4.00,
        discount: 5.00,
        total: 38.98,
        paymentMethod: 'card',
        status: 'pending',
        items: items,
        createdAt: now,
      );

      expect(order.customerId, 'cust-1');
      expect(order.customerName, 'John Doe');
      expect(order.discount, 5.00);
    });
  });
}
