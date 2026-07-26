import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/datasources/crm_local_datasource.dart';
import '../../data/repositories/crm_repository_impl.dart';
import '../../domain/repositories/crm_repository.dart';
import '../../domain/entities/customer.dart' as domain;
import '../../../../core/database/app_database.dart' as db;

final crmDataSourceProvider = Provider<CrmLocalDataSource>((ref) {
  return CrmLocalDataSource(ref.watch(db.databaseProvider));
});

final crmRepositoryProvider = Provider<CrmRepository>((ref) {
  return CrmRepositoryImpl(ref.watch(crmDataSourceProvider));
});

final customersProvider = FutureProvider<List<domain.Customer>>((ref) async {
  final result = await ref.watch(crmRepositoryProvider).getAllCustomers();
  return result.when(
    success: (d) => d,
    error: (f) => throw Exception(f.message),
  );
});

final customerPurchaseHistoryProvider =
    FutureProvider.family<List<Map<String, dynamic>>, String>((
      ref,
      customerId,
    ) async {
      final result = await ref
          .watch(crmRepositoryProvider)
          .getCustomerPurchaseHistory(customerId);
      return result.when(
        success: (d) => d,
        error: (f) => throw Exception(f.message),
      );
    });
