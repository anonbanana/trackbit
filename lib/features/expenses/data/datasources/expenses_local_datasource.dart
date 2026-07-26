import 'package:drift/drift.dart';
import '../../../../core/database/app_database.dart' as db;

class ExpensesLocalDataSource {
  final db.AppDatabase _database;
  ExpensesLocalDataSource(this._database);

  Future<List<db.Expense>> getAllExpenses({String? category}) async {
    var query = _database.select(_database.expenses)
      ..orderBy([
        (t) => OrderingTerm(expression: t.createdAt, mode: OrderingMode.desc),
      ]);
    if (category != null && category.isNotEmpty) {
      query = query..where((t) => t.category.equals(category));
    }
    return await query.get();
  }

  Future<db.Expense?> getExpenseById(String id) async {
    return await (_database.select(
      _database.expenses,
    )..where((t) => t.id.equals(id))).getSingleOrNull();
  }

  Future<void> insertExpense(db.ExpensesCompanion expense) async {
    await _database.into(_database.expenses).insert(expense);
  }

  Future<void> updateExpense(db.ExpensesCompanion expense, String id) async {
    await (_database.update(
      _database.expenses,
    )..where((t) => t.id.equals(id))).write(expense);
  }

  Future<void> deleteExpense(String id) async {
    await (_database.delete(
      _database.expenses,
    )..where((t) => t.id.equals(id))).go();
  }

  Future<List<String>> getCategories() async {
    final data = await _database.select(_database.expenses).get();
    final cats = data.map((e) => e.category).toSet().toList()..sort();
    return cats;
  }

  Future<double> getTotalByCategory(String category) async {
    final expenses = await (_database.select(
      _database.expenses,
    )..where((t) => t.category.equals(category))).get();
    double total = 0;
    for (final e in expenses) {
      total += e.amount;
    }
    return total;
  }

  Future<String?> getUserName(String userId) async {
    final user = await (_database.select(
      _database.users,
    )..where((t) => t.id.equals(userId))).getSingleOrNull();
    return user?.fullName;
  }
}
