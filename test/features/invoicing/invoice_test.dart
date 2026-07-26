import 'package:flutter_test/flutter_test.dart';
import 'package:trackbit/features/invoicing/domain/entities/invoice.dart';

void main() {
  group('Invoice', () {
    final now = DateTime(2026, 7, 26);
    final dueDate = DateTime(2026, 8, 26);

    test('creates with required fields', () {
      final invoice = Invoice(
        id: '1',
        invoiceNumber: 'INV-202607-0001',
        status: 'pending',
        total: 150.00,
        createdAt: now,
        updatedAt: now,
      );

      expect(invoice.id, '1');
      expect(invoice.invoiceNumber, 'INV-202607-0001');
      expect(invoice.status, 'pending');
      expect(invoice.total, 150.00);
      expect(invoice.orderId, isNull);
      expect(invoice.customerId, isNull);
    });

    test('creates with optional fields', () {
      final invoice = Invoice(
        id: '1',
        invoiceNumber: 'INV-001',
        orderId: 'order-1',
        customerId: 'cust-1',
        customerName: 'John Doe',
        dueDate: dueDate,
        status: 'paid',
        total: 150.00,
        createdAt: now,
        updatedAt: now,
      );

      expect(invoice.orderId, 'order-1');
      expect(invoice.customerId, 'cust-1');
      expect(invoice.customerName, 'John Doe');
      expect(invoice.dueDate, dueDate);
    });

    test('copyWith creates new instance with changes', () {
      final invoice = Invoice(
        id: '1',
        invoiceNumber: 'INV-001',
        status: 'pending',
        total: 150.00,
        createdAt: now,
        updatedAt: now,
      );

      final updated = invoice.copyWith(status: 'paid');
      expect(updated.status, 'paid');
      expect(invoice.status, 'pending'); // original unchanged
    });

    test('equality based on props', () {
      final invoice1 = Invoice(
        id: '1',
        invoiceNumber: 'INV-001',
        status: 'pending',
        total: 150.00,
        createdAt: now,
        updatedAt: now,
      );

      final invoice2 = Invoice(
        id: '1',
        invoiceNumber: 'INV-001',
        status: 'pending',
        total: 150.00,
        createdAt: now,
        updatedAt: now,
      );

      expect(invoice1, equals(invoice2));
    });
  });

  group('InvoiceItem', () {
    test('creates with required fields', () {
      final item = InvoiceItem(
        id: '1',
        invoiceId: 'inv-1',
        description: 'Widget',
        quantity: 5,
        unitPrice: 19.99,
        total: 99.95,
      );

      expect(item.id, '1');
      expect(item.invoiceId, 'inv-1');
      expect(item.description, 'Widget');
      expect(item.quantity, 5);
      expect(item.unitPrice, 19.99);
      expect(item.total, 99.95);
    });

    test('equality based on props', () {
      final item1 = InvoiceItem(
        id: '1',
        invoiceId: 'inv-1',
        description: 'Widget',
        quantity: 5,
        unitPrice: 19.99,
        total: 99.95,
      );

      final item2 = InvoiceItem(
        id: '1',
        invoiceId: 'inv-1',
        description: 'Widget',
        quantity: 5,
        unitPrice: 19.99,
        total: 99.95,
      );

      expect(item1, equals(item2));
    });
  });
}
