import '../../../../core/utils/result.dart';
import '../entities/customer.dart';

abstract class CrmRepository {
  Future<Result<List<Customer>>> getAllCustomers({String? searchQuery});
  Future<Result<Customer?>> getCustomerById(String id);
  Future<Result<Customer>> createCustomer(Customer customer);
  Future<Result<Customer>> updateCustomer(Customer customer);
  Future<Result<void>> deleteCustomer(String id);
  Future<Result<List<Map<String, dynamic>>>> getCustomerPurchaseHistory(String customerId);
  Future<Result<void>> addLoyaltyPoints(String customerId, double points);
}
