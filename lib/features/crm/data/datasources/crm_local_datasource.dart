import 'package:drift/drift.dart';
import '../../../../core/database/app_database.dart' as db;

class CrmLocalDataSource {
  final db.AppDatabase _database;
  CrmLocalDataSource(this._database);

  Future<List<db.Customer>> getAllCustomers({String? searchQuery}) async {
    var query = _database.select(_database.customers)
      ..orderBy([(t) => OrderingTerm(expression: t.name)]);
    if (searchQuery != null && searchQuery.isNotEmpty) {
      final pattern = '%$searchQuery%';
      query = query..where((t) => t.name.like(pattern));
    }
    return await query.get();
  }

  Future<db.Customer?> getCustomerById(String id) async {
    return await (_database.select(_database.customers)
      ..where((t) => t.id.equals(id))
    ).getSingleOrNull();
  }

  Future<void> insertCustomer(db.CustomersCompanion customer) async {
    await _database.into(_database.customers).insert(customer);
  }

  Future<void> updateCustomer(db.CustomersCompanion customer, String id) async {
    await (_database.update(_database.customers)
      ..where((t) => t.id.equals(id))
    ).write(customer);
  }

  Future<void> deleteCustomer(String id) async {
    await (_database.delete(_database.customers)
      ..where((t) => t.id.equals(id))
    ).go();
  }

  Future<List<Map<String, dynamic>>> getCustomerPurchaseHistory(String customerId) async {
    final orders = await (_database.select(_database.orders)
      ..where((t) => t.customerId.equals(customerId))
      ..orderBy([(t) => OrderingTerm(expression: t.createdAt, mode: OrderingMode.desc)])
    ).get();

    return orders.map((o) => {
      'id': o.id,
      'orderNumber': o.orderNumber,
      'total': o.total,
      'status': o.status,
      'createdAt': o.createdAt,
    }).toList();
  }

  Future<void> addLoyaltyPoints(String customerId, double points) async {
    final customer = await getCustomerById(customerId);
    if (customer == null) return;
    final newPoints = customer.loyaltyPoints + points;
    await (_database.update(_database.customers)
      ..where((t) => t.id.equals(customerId))
    ).write(db.CustomersCompanion(
      loyaltyPoints: Value(newPoints),
      updatedAt: Value(DateTime.now()),
    ));
  }
}
