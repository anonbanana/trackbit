import 'package:drift/drift.dart';
import '../../../../core/database/app_database.dart' as db;

class EmployeeLocalDataSource {
  final db.AppDatabase _database;
  EmployeeLocalDataSource(this._database);

  Future<List<db.Employee>> getAllEmployees() async {
    return await (_database.select(_database.employees)..orderBy([
          (t) => OrderingTerm(expression: t.createdAt, mode: OrderingMode.desc),
        ]))
        .get();
  }

  Future<db.Employee?> getEmployeeById(String id) async {
    return await (_database.select(
      _database.employees,
    )..where((t) => t.id.equals(id))).getSingleOrNull();
  }

  Future<void> insertEmployee(db.EmployeesCompanion employee) async {
    await _database.into(_database.employees).insert(employee);
  }

  Future<void> updateEmployee(db.EmployeesCompanion employee, String id) async {
    await (_database.update(
      _database.employees,
    )..where((t) => t.id.equals(id))).write(employee);
  }

  Future<void> deleteEmployee(String id) async {
    await (_database.delete(
      _database.employees,
    )..where((t) => t.id.equals(id))).go();
  }
}
