import 'package:flutter_test/flutter_test.dart';
import 'package:trackbit/features/inventory/domain/entities/product.dart';

void main() {
  group('Product', () {
    final now = DateTime(2026, 7, 26);

    test('creates with required fields', () {
      final product = Product(
        id: '1',
        sku: 'SKU001',
        name: 'Widget',
        categoryId: 'cat-1',
        unit: 'pcs',
        price: 19.99,
        cost: 10.00,
        createdAt: now,
        updatedAt: now,
      );

      expect(product.id, '1');
      expect(product.sku, 'SKU001');
      expect(product.name, 'Widget');
      expect(product.price, 19.99);
      expect(product.cost, 10.00);
      expect(product.stockQty, 0);
      expect(product.isActive, true);
    });

    test('isLowStock returns true when stock <= minStock', () {
      final product = Product(
        id: '1',
        sku: 'SKU001',
        name: 'Widget',
        categoryId: 'cat-1',
        unit: 'pcs',
        price: 19.99,
        cost: 10.00,
        stockQty: 5,
        minStock: 10,
        createdAt: now,
        updatedAt: now,
      );

      expect(product.isLowStock, true);
    });

    test('isLowStock returns false when stock > minStock', () {
      final product = Product(
        id: '1',
        sku: 'SKU001',
        name: 'Widget',
        categoryId: 'cat-1',
        unit: 'pcs',
        price: 19.99,
        cost: 10.00,
        stockQty: 15,
        minStock: 10,
        createdAt: now,
        updatedAt: now,
      );

      expect(product.isLowStock, false);
    });

    test('copyWith creates new instance with changes', () {
      final product = Product(
        id: '1',
        sku: 'SKU001',
        name: 'Widget',
        categoryId: 'cat-1',
        unit: 'pcs',
        price: 19.99,
        cost: 10.00,
        createdAt: now,
        updatedAt: now,
      );

      final updated = product.copyWith(price: 24.99, stockQty: 50);
      expect(updated.price, 24.99);
      expect(updated.stockQty, 50);
      expect(product.price, 19.99); // original unchanged
    });

    test('equality based on props', () {
      final product1 = Product(
        id: '1',
        sku: 'SKU001',
        name: 'Widget',
        categoryId: 'cat-1',
        unit: 'pcs',
        price: 19.99,
        cost: 10.00,
        createdAt: now,
        updatedAt: now,
      );

      final product2 = Product(
        id: '1',
        sku: 'SKU001',
        name: 'Widget',
        categoryId: 'cat-1',
        unit: 'pcs',
        price: 19.99,
        cost: 10.00,
        createdAt: now,
        updatedAt: now,
      );

      expect(product1, equals(product2));
    });
  });
}
