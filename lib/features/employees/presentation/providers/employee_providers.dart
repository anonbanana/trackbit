import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/datasources/employee_local_datasource.dart';
import '../../data/repositories/employee_repository_impl.dart';
import '../../domain/repositories/employee_repository.dart';
import '../../domain/entities/employee.dart' as domain;
import '../../../../core/database/app_database.dart';

final employeeDataSourceProvider = Provider<EmployeeLocalDataSource>((ref) {
  return EmployeeLocalDataSource(ref.watch(databaseProvider));
});

final employeeRepositoryProvider = Provider<EmployeeRepository>((ref) {
  return EmployeeRepositoryImpl(ref.watch(employeeDataSourceProvider));
});

final employeesProvider = FutureProvider<List<domain.Employee>>((ref) async {
  final result = await ref.watch(employeeRepositoryProvider).getAllEmployees();
  return result.when(
    success: (d) => d,
    error: (f) => throw Exception(f.message),
  );
});
