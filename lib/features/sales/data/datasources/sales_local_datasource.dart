import 'package:drift/drift.dart';
import '../../../../core/database/app_database.dart' as db;

class SalesLocalDataSource {
  final db.AppDatabase _database;
  SalesLocalDataSource(this._database);

  Future<List<Map<String, dynamic>>> getAllOrders({String? status, String? searchQuery}) async {
    var query = _database.select(_database.orders)
      ..orderBy([(t) => OrderingTerm(expression: t.createdAt, mode: OrderingMode.desc)]);

    if (status != null && status.isNotEmpty) {
      query = query..where((t) => t.status.equals(status));
    }

    final orders = await query.get();
    final results = <Map<String, dynamic>>[];

    for (final order in orders) {
      final items = await (_database.select(_database.orderItems)
        ..where((t) => t.orderId.equals(order.id)))
        .get();
      final itemCount = items.length;

      String? customerName;
      if (order.customerId != null) {
        final customer = await (_database.select(_database.customers)
          ..where((t) => t.id.equals(order.customerId!)))
          .getSingleOrNull();
        customerName = customer?.name;
      }

      if (searchQuery != null && searchQuery.isNotEmpty) {
        final q = searchQuery.toLowerCase();
        if (!order.orderNumber.toLowerCase().contains(q) &&
            !(customerName?.toLowerCase().contains(q) ?? false)) {
          continue;
        }
      }

      results.add({
        'id': order.id,
        'orderNumber': order.orderNumber,
        'customerName': customerName,
        'total': order.total,
        'paymentMethod': order.paymentMethod,
        'status': order.status,
        'itemCount': itemCount,
        'createdAt': order.createdAt,
      });
    }
    return results;
  }

  Future<Map<String, dynamic>?> getOrderDetail(String orderId) async {
    final order = await (_database.select(_database.orders)
      ..where((t) => t.id.equals(orderId)))
      .getSingleOrNull();
    if (order == null) return null;

    String? customerName;
    String? customerPhone;
    if (order.customerId != null) {
      final customer = await (_database.select(_database.customers)
        ..where((t) => t.id.equals(order.customerId!)))
        .getSingleOrNull();
      customerName = customer?.name;
      customerPhone = customer?.phone;
    }

    final orderItems = await (_database.select(_database.orderItems)
      ..where((t) => t.orderId.equals(orderId)))
      .get();

    final items = <Map<String, dynamic>>[];
    for (final item in orderItems) {
      final product = await (_database.select(_database.products)
        ..where((t) => t.id.equals(item.productId)))
        .getSingleOrNull();
      items.add({
        'id': item.id,
        'productName': product?.name ?? 'Unknown',
        'quantity': item.quantity,
        'unit': product?.unit ?? 'pc',
        'unitPrice': item.unitPrice,
        'subtotal': item.subtotal,
      });
    }

    return {
      'id': order.id,
      'orderNumber': order.orderNumber,
      'customerId': order.customerId,
      'customerName': customerName,
      'customerPhone': customerPhone,
      'userId': order.userId,
      'subtotal': order.subtotal,
      'tax': order.tax,
      'discount': order.discount,
      'total': order.total,
      'paymentMethod': order.paymentMethod,
      'status': order.status,
      'items': items,
      'createdAt': order.createdAt,
    };
  }

  Future<double> getDailySalesTotal(DateTime date) async {
    final start = DateTime(date.year, date.month, date.day);
    final end = start.add(const Duration(days: 1));
    final orders = await (_database.select(_database.orders)
      ..where((t) => t.createdAt.isBetweenValues(start, end))
      ..where((t) => t.status.equals('completed'))
    ).get();
    double total = 0;
    for (final o in orders) {
      total += o.total;
    }
    return total;
  }

  Future<double> getMonthlySalesTotal(int year, int month) async {
    final start = DateTime(year, month, 1);
    final end = DateTime(year, month + 1, 1);
    final orders = await (_database.select(_database.orders)
      ..where((t) => t.createdAt.isBetweenValues(start, end))
      ..where((t) => t.status.equals('completed'))
    ).get();
    double total = 0;
    for (final o in orders) {
      total += o.total;
    }
    return total;
  }

  Future<int> getOrderCount({String? status}) async {
    if (status != null) {
      final orders = await (_database.select(_database.orders)
        ..where((t) => t.status.equals(status)))
        .get();
      return orders.length;
    }
    return await _database.select(_database.orders).get().then((r) => r.length);
  }
}
