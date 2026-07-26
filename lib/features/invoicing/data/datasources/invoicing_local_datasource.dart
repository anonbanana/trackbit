import 'package:drift/drift.dart';
import '../../../../core/database/app_database.dart' as db;

class InvoicingLocalDataSource {
  final db.AppDatabase _database;
  InvoicingLocalDataSource(this._database);

  Future<List<db.Invoice>> getAllInvoices() async {
    return await (_database.select(_database.invoices)..orderBy([
          (t) => OrderingTerm(expression: t.createdAt, mode: OrderingMode.desc),
        ]))
        .get();
  }

  Future<db.Invoice?> getInvoiceById(String id) async {
    return await (_database.select(
      _database.invoices,
    )..where((t) => t.id.equals(id))).getSingleOrNull();
  }

  Future<void> insertInvoice(db.InvoicesCompanion invoice) async {
    await _database.into(_database.invoices).insert(invoice);
  }

  Future<void> updateInvoice(db.InvoicesCompanion invoice, String id) async {
    await (_database.update(
      _database.invoices,
    )..where((t) => t.id.equals(id))).write(invoice);
  }

  Future<void> deleteInvoice(String id) async {
    await (_database.delete(
      _database.invoices,
    )..where((t) => t.id.equals(id))).go();
    await (_database.delete(
      _database.invoiceItems,
    )..where((t) => t.invoiceId.equals(id))).go();
  }

  Future<List<db.InvoiceItem>> getInvoiceItems(String invoiceId) async {
    return await (_database.select(
      _database.invoiceItems,
    )..where((t) => t.invoiceId.equals(invoiceId))).get();
  }

  Future<void> insertInvoiceItem(db.InvoiceItemsCompanion item) async {
    await _database.into(_database.invoiceItems).insert(item);
  }

  Future<Map<String, dynamic>?> getOrderWithDetails(String orderId) async {
    final order = await (_database.select(
      _database.orders,
    )..where((t) => t.id.equals(orderId))).getSingleOrNull();
    if (order == null) return null;

    String? customerName;
    if (order.customerId != null) {
      final customer = await (_database.select(
        _database.customers,
      )..where((t) => t.id.equals(order.customerId!))).getSingleOrNull();
      customerName = customer?.name;
    }

    final items = await (_database.select(
      _database.orderItems,
    )..where((t) => t.orderId.equals(orderId))).get();

    return {'order': order, 'customerName': customerName, 'items': items};
  }

  Future<int> getInvoiceCount() async {
    return await _database
        .select(_database.invoices)
        .get()
        .then((r) => r.length);
  }

  Future<String?> getProductName(String productId) async {
    final product = await (_database.select(
      _database.products,
    )..where((t) => t.id.equals(productId))).getSingleOrNull();
    return product?.name;
  }
}
