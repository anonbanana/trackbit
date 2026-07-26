import '../../../../core/utils/result.dart';
import '../entities/order_summary.dart';
import '../entities/order_detail.dart';

abstract class SalesRepository {
  Future<Result<List<OrderSummary>>> getAllOrders({
    String? status,
    String? searchQuery,
  });
  Future<Result<OrderDetail?>> getOrderDetail(String orderId);
  Future<Result<double>> getDailySalesTotal(DateTime date);
  Future<Result<double>> getMonthlySalesTotal(int year, int month);
  Future<Result<int>> getOrderCount({String? status});
}
