import 'package:drift/drift.dart';
import '../../../../core/errors/failure.dart';
import '../../../../core/utils/result.dart';
import '../../domain/repositories/employee_repository.dart';
import '../../domain/entities/employee.dart';
import '../datasources/employee_local_datasource.dart';
import '../../../../core/database/app_database.dart' as db;

class EmployeeRepositoryImpl implements EmployeeRepository {
  final EmployeeLocalDataSource _dataSource;
  EmployeeRepositoryImpl(this._dataSource);

  @override
  Future<Result<List<Employee>>> getAllEmployees() async {
    try {
      final data = await _dataSource.getAllEmployees();
      return Success(data.map((e) => _mapEmployee(e)).toList());
    } catch (e) {
      return Error(DatabaseFailure('Failed to load employees: $e'));
    }
  }

  @override
  Future<Result<Employee?>> getEmployeeById(String id) async {
    try {
      final data = await _dataSource.getEmployeeById(id);
      if (data == null) return const Success(null);
      return Success(_mapEmployee(data));
    } catch (e) {
      return Error(DatabaseFailure('Failed to load employee: $e'));
    }
  }

  @override
  Future<Result<Employee>> createEmployee(Employee employee) async {
    try {
      await _dataSource.insertEmployee(db.EmployeesCompanion(
        id: Value(employee.id),
        userId: Value(employee.userId),
        position: Value(employee.position),
        salary: Value(employee.salary),
        hireDate: Value(employee.hireDate),
        phone: Value(employee.phone),
        address: Value(employee.address),
        isActive: Value(employee.isActive),
        createdAt: Value(employee.createdAt),
        updatedAt: Value(employee.updatedAt),
      ));
      return Success(employee);
    } catch (e) {
      return Error(DatabaseFailure('Failed to create employee: $e'));
    }
  }

  @override
  Future<Result<Employee>> updateEmployee(Employee employee) async {
    try {
      await _dataSource.updateEmployee(db.EmployeesCompanion(
        userId: Value(employee.userId),
        position: Value(employee.position),
        salary: Value(employee.salary),
        hireDate: Value(employee.hireDate),
        phone: Value(employee.phone),
        address: Value(employee.address),
        isActive: Value(employee.isActive),
        updatedAt: Value(DateTime.now()),
      ), employee.id);
      return Success(employee);
    } catch (e) {
      return Error(DatabaseFailure('Failed to update employee: $e'));
    }
  }

  @override
  Future<Result<void>> deleteEmployee(String id) async {
    try {
      await _dataSource.deleteEmployee(id);
      return const Success(null);
    } catch (e) {
      return Error(DatabaseFailure('Failed to delete employee: $e'));
    }
  }

  Employee _mapEmployee(db.Employee row) {
    return Employee(
      id: row.id,
      userId: row.userId,
      position: row.position,
      salary: row.salary,
      hireDate: row.hireDate,
      phone: row.phone,
      address: row.address,
      isActive: row.isActive,
      createdAt: row.createdAt,
      updatedAt: row.updatedAt,
    );
  }
}
