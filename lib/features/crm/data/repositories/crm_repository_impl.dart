import 'package:drift/drift.dart';
import '../../../../core/errors/failure.dart';
import '../../../../core/utils/result.dart';
import '../../domain/repositories/crm_repository.dart';
import '../../domain/entities/customer.dart';
import '../datasources/crm_local_datasource.dart';
import '../../../../core/database/app_database.dart' as db;

class CrmRepositoryImpl implements CrmRepository {
  final CrmLocalDataSource _dataSource;
  CrmRepositoryImpl(this._dataSource);

  @override
  Future<Result<List<Customer>>> getAllCustomers({String? searchQuery}) async {
    try {
      final data = await _dataSource.getAllCustomers(searchQuery: searchQuery);
      return Success(data.map(_mapCustomer).toList());
    } catch (e) {
      return Error(DatabaseFailure('Failed to load customers: $e'));
    }
  }

  @override
  Future<Result<Customer?>> getCustomerById(String id) async {
    try {
      final data = await _dataSource.getCustomerById(id);
      return Success(data != null ? _mapCustomer(data) : null);
    } catch (e) {
      return Error(DatabaseFailure('Failed to load customer: $e'));
    }
  }

  @override
  Future<Result<Customer>> createCustomer(Customer customer) async {
    try {
      await _dataSource.insertCustomer(
        db.CustomersCompanion(
          id: Value(customer.id),
          name: Value(customer.name),
          phone: Value(customer.phone),
          email: Value(customer.email),
          address: Value(customer.address),
          loyaltyPoints: Value(customer.loyaltyPoints),
          createdAt: Value(customer.createdAt),
          updatedAt: Value(customer.updatedAt),
        ),
      );
      return Success(customer);
    } catch (e) {
      return Error(DatabaseFailure('Failed to create customer: $e'));
    }
  }

  @override
  Future<Result<Customer>> updateCustomer(Customer customer) async {
    try {
      await _dataSource.updateCustomer(
        db.CustomersCompanion(
          name: Value(customer.name),
          phone: Value(customer.phone),
          email: Value(customer.email),
          address: Value(customer.address),
          loyaltyPoints: Value(customer.loyaltyPoints),
          updatedAt: Value(DateTime.now()),
        ),
        customer.id,
      );
      return Success(customer);
    } catch (e) {
      return Error(DatabaseFailure('Failed to update customer: $e'));
    }
  }

  @override
  Future<Result<void>> deleteCustomer(String id) async {
    try {
      await _dataSource.deleteCustomer(id);
      return const Success(null);
    } catch (e) {
      return Error(DatabaseFailure('Failed to delete customer: $e'));
    }
  }

  @override
  Future<Result<List<Map<String, dynamic>>>> getCustomerPurchaseHistory(
    String customerId,
  ) async {
    try {
      final history = await _dataSource.getCustomerPurchaseHistory(customerId);
      return Success(history);
    } catch (e) {
      return Error(DatabaseFailure('Failed to load purchase history: $e'));
    }
  }

  @override
  Future<Result<void>> addLoyaltyPoints(
    String customerId,
    double points,
  ) async {
    try {
      await _dataSource.addLoyaltyPoints(customerId, points);
      return const Success(null);
    } catch (e) {
      return Error(DatabaseFailure('Failed to add loyalty points: $e'));
    }
  }

  Customer _mapCustomer(db.Customer row) {
    return Customer(
      id: row.id,
      name: row.name,
      phone: row.phone,
      email: row.email,
      address: row.address,
      loyaltyPoints: row.loyaltyPoints,
      createdAt: row.createdAt,
      updatedAt: row.updatedAt,
    );
  }
}
