import '../../../../core/database/app_database.dart' as db;

class ReportsLocalDataSource {
  final db.AppDatabase _database;
  ReportsLocalDataSource(this._database);

  Future<List<db.Order>> getOrdersInRange({DateTime? start, DateTime? end}) async {
    final all = await _database.select(_database.orders).get();
    if (start == null && end == null) return all;
    return all.where((o) {
      if (start != null && o.createdAt.isBefore(start)) return false;
      if (end != null && o.createdAt.isAfter(end)) return false;
      return true;
    }).toList();
  }

  Future<List<db.Expense>> getExpensesInRange({DateTime? start, DateTime? end}) async {
    final all = await _database.select(_database.expenses).get();
    if (start == null && end == null) return all;
    return all.where((e) {
      if (start != null && e.createdAt.isBefore(start)) return false;
      if (end != null && e.createdAt.isAfter(end)) return false;
      return true;
    }).toList();
  }
}
