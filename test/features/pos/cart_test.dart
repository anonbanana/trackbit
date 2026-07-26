import 'package:flutter_test/flutter_test.dart';
import 'package:trackbit/features/pos/domain/entities/cart.dart';
import 'package:trackbit/features/pos/domain/entities/cart_item.dart';

void main() {
  group('CartItem', () {
    test('creates with required fields', () {
      final item = CartItem(
        productId: '1',
        productName: 'Widget',
        sku: 'SKU001',
        unitPrice: 19.99,
        unit: 'pcs',
      );

      expect(item.productId, '1');
      expect(item.productName, 'Widget');
      expect(item.unitPrice, 19.99);
      expect(item.quantity, 1);
    });

    test('subtotal calculates correctly', () {
      final item = CartItem(
        productId: '1',
        productName: 'Widget',
        sku: 'SKU001',
        unitPrice: 19.99,
        quantity: 3,
        unit: 'pcs',
      );

      expect(item.subtotal, closeTo(59.97, 0.01));
    });

    test('copyWith preserves all fields except quantity', () {
      final item = CartItem(
        productId: '1',
        productName: 'Widget',
        sku: 'SKU001',
        unitPrice: 19.99,
        quantity: 1,
        unit: 'pcs',
        barcode: '123456',
      );

      final updated = item.copyWith(quantity: 5);
      expect(updated.quantity, 5);
      expect(updated.productId, item.productId);
      expect(updated.productName, item.productName);
      expect(updated.barcode, item.barcode);
    });
  });

  group('Cart', () {
    test('creates empty cart', () {
      final cart = Cart();
      expect(cart.items, isEmpty);
      expect(cart.subtotal, 0);
      expect(cart.total, 0);
    });

    test('subtotal sums item subtotals', () {
      final items = [
        CartItem(
          productId: '1',
          productName: 'Widget',
          sku: 'SKU001',
          unitPrice: 10.00,
          quantity: 2,
          unit: 'pcs',
        ),
        CartItem(
          productId: '2',
          productName: 'Gadget',
          sku: 'SKU002',
          unitPrice: 25.00,
          quantity: 1,
          unit: 'pcs',
        ),
      ];

      final cart = Cart(items: items);
      expect(cart.subtotal, 45.00);
      expect(cart.itemCount, 2);
    });

    test('discount calculates correctly', () {
      final items = [
        CartItem(
          productId: '1',
          productName: 'Widget',
          sku: 'SKU001',
          unitPrice: 100.00,
          quantity: 1,
          unit: 'pcs',
        ),
      ];

      final cart = Cart(items: items, discount: 10);
      expect(cart.discountAmount, 10.00);
      expect(cart.taxableAmount, 90.00);
    });

    test('tax calculates correctly', () {
      final items = [
        CartItem(
          productId: '1',
          productName: 'Widget',
          sku: 'SKU001',
          unitPrice: 100.00,
          quantity: 1,
          unit: 'pcs',
        ),
      ];

      final cart = Cart(items: items, taxRate: 10);
      expect(cart.taxAmount, 10.00);
      expect(cart.total, 110.00);
    });

    test('total with discount and tax', () {
      final items = [
        CartItem(
          productId: '1',
          productName: 'Widget',
          sku: 'SKU001',
          unitPrice: 100.00,
          quantity: 1,
          unit: 'pcs',
        ),
      ];

      final cart = Cart(items: items, discount: 10, taxRate: 10);
      // subtotal = 100, discount = 10, taxable = 90, tax = 9, total = 99
      expect(cart.total, closeTo(99.00, 0.01));
    });

    test('copyWith creates new instance', () {
      final cart = Cart(discount: 5);
      final updated = cart.copyWith(taxRate: 10);
      expect(updated.discount, 5);
      expect(updated.taxRate, 10);
      expect(cart.taxRate, 0); // original unchanged
    });
  });
}
