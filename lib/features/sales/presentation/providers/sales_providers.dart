import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/datasources/sales_local_datasource.dart';
import '../../data/repositories/sales_repository_impl.dart';
import '../../domain/repositories/sales_repository.dart';
import '../../domain/entities/order_summary.dart';
import '../../domain/entities/order_detail.dart';
import '../../../../core/database/app_database.dart';

final salesDataSourceProvider = Provider<SalesLocalDataSource>((ref) {
  return SalesLocalDataSource(ref.watch(databaseProvider));
});

final salesRepositoryProvider = Provider<SalesRepository>((ref) {
  return SalesRepositoryImpl(ref.watch(salesDataSourceProvider));
});

final ordersProvider = FutureProvider<List<OrderSummary>>((ref) async {
  final result = await ref.watch(salesRepositoryProvider).getAllOrders();
  return result.when(success: (d) => d, error: (f) => throw Exception(f.message));
});

final orderDetailProvider = FutureProvider.family<OrderDetail?, String>((ref, orderId) async {
  final result = await ref.watch(salesRepositoryProvider).getOrderDetail(orderId);
  return result.when(success: (d) => d, error: (f) => throw Exception(f.message));
});

final dailySalesTotalProvider = FutureProvider.family<double, DateTime>((ref, date) async {
  final result = await ref.watch(salesRepositoryProvider).getDailySalesTotal(date);
  return result.when(success: (d) => d, error: (f) => throw Exception(f.message));
});
