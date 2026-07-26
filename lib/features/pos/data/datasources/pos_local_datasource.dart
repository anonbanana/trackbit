import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/database/app_database.dart' as db;

class PosLocalDataSource {
  final db.AppDatabase _database;

  PosLocalDataSource(this._database);

  Future<List<Map<String, dynamic>>> searchProducts(String query) async {
    final pattern = '%$query%';
    final results =
        await (_database.select(_database.products)
              ..where(
                (t) =>
                    t.name.like(pattern) |
                    t.sku.like(pattern) |
                    t.barcode.like(pattern),
              )
              ..where((t) => t.isActive.equals(true))
              ..orderBy([(t) => OrderingTerm(expression: t.name)]))
            .get();
    return results
        .map(
          (p) => {
            'id': p.id,
            'sku': p.sku,
            'name': p.name,
            'barcode': p.barcode,
            'price': p.price,
            'stockQty': p.stockQty,
            'unit': p.unit,
          },
        )
        .toList();
  }

  Future<Map<String, dynamic>?> getProductByBarcode(String barcode) async {
    final result =
        await (_database.select(_database.products)
              ..where((t) => t.barcode.equals(barcode))
              ..where((t) => t.isActive.equals(true)))
            .getSingleOrNull();
    if (result == null) return null;
    return {
      'id': result.id,
      'sku': result.sku,
      'name': result.name,
      'barcode': result.barcode,
      'price': result.price,
      'stockQty': result.stockQty,
      'unit': result.unit,
    };
  }

  Future<void> insertOrder(db.OrdersCompanion order) async {
    await _database.into(_database.orders).insert(order);
  }

  Future<void> insertOrderItem(db.OrderItemsCompanion item) async {
    await _database.into(_database.orderItems).insert(item);
  }

  Future<void> insertPayment(db.PaymentsCompanion payment) async {
    await _database.into(_database.payments).insert(payment);
  }

  Future<String?> insertCustomer(String name, String? phone) async {
    final existing = await (_database.select(
      _database.customers,
    )..where((t) => t.name.equals(name))).getSingleOrNull();
    if (existing != null) return existing.id;

    final id = _generateId();
    await _database
        .into(_database.customers)
        .insert(
          db.CustomersCompanion(
            id: Value(id),
            name: Value(name),
            phone: Value(phone),
            createdAt: Value(DateTime.now()),
            updatedAt: Value(DateTime.now()),
          ),
        );
    return id;
  }

  Future<void> updateProductStock(String productId, double quantity) async {
    final product = await (_database.select(
      _database.products,
    )..where((t) => t.id.equals(productId))).getSingleOrNull();
    if (product == null) return;

    final newQty = product.stockQty - quantity;
    await (_database.update(
      _database.products,
    )..where((t) => t.id.equals(productId))).write(
      db.ProductsCompanion(
        stockQty: Value(newQty < 0 ? 0 : newQty),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  Future<void> insertStockMovement(db.StockMovementsCompanion movement) async {
    await _database.into(_database.stockMovements).insert(movement);
  }

  Future<Map<String, dynamic>?> getReceiptSettings() async {
    final result = await (_database.select(
      _database.receiptSettings,
    )..where((t) => t.id.equals('default'))).getSingleOrNull();
    if (result == null) return null;
    return {
      'storeName': result.storeName,
      'storeAddress': result.storeAddress,
      'storePhone': result.storePhone,
      'taxRate': result.taxRate,
      'paperWidth': result.paperWidth,
      'headerText': result.headerText,
      'footerText': result.footerText,
      'showTax': result.showTax,
      'showDiscount': result.showDiscount,
    };
  }

  Future<String> getNextOrderNumber() async {
    final now = DateTime.now();
    final year = now.year;
    final month = now.month.toString().padLeft(2, '0');
    final prefix = 'ORD-$year$month-';
    final orders = await (_database.select(
      _database.orders,
    )..where((t) => t.orderNumber.like('$prefix%'))).get();
    final nextNum = orders.length + 1;
    return '$prefix${nextNum.toString().padLeft(4, '0')}';
  }

  String _generateId() {
    return const Uuid().v4();
  }
}
