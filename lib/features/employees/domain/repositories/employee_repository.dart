import '../../../../core/utils/result.dart';
import '../entities/employee.dart';

abstract class EmployeeRepository {
  Future<Result<List<Employee>>> getAllEmployees();
  Future<Result<Employee?>> getEmployeeById(String id);
  Future<Result<Employee>> createEmployee(Employee employee);
  Future<Result<Employee>> updateEmployee(Employee employee);
  Future<Result<void>> deleteEmployee(String id);
}
