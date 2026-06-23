import '../../../../core/errors/failure.dart';
import '../../../../core/utils/result.dart';
import '../../domain/repositories/sales_repository.dart';
import '../../domain/entities/order_summary.dart';
import '../../domain/entities/order_detail.dart';
import '../datasources/sales_local_datasource.dart';

class SalesRepositoryImpl implements SalesRepository {
  final SalesLocalDataSource _dataSource;
  SalesRepositoryImpl(this._dataSource);

  @override
  Future<Result<List<OrderSummary>>> getAllOrders({String? status, String? searchQuery}) async {
    try {
      final data = await _dataSource.getAllOrders(status: status, searchQuery: searchQuery);
      final orders = data.map((d) => OrderSummary(
        id: d['id'] as String,
        orderNumber: d['orderNumber'] as String,
        customerName: d['customerName'] as String?,
        total: (d['total'] as num).toDouble(),
        paymentMethod: d['paymentMethod'] as String,
        status: d['status'] as String,
        itemCount: d['itemCount'] as int,
        createdAt: d['createdAt'] as DateTime,
      )).toList();
      return Success(orders);
    } catch (e) {
      return Error(DatabaseFailure('Failed to load orders: $e'));
    }
  }

  @override
  Future<Result<OrderDetail?>> getOrderDetail(String orderId) async {
    try {
      final data = await _dataSource.getOrderDetail(orderId);
      if (data == null) return const Success(null);

      final itemsData = data['items'] as List<dynamic>;
      final items = itemsData.map((i) => OrderDetailItem(
        id: i['id'] as String,
        productName: i['productName'] as String,
        quantity: (i['quantity'] as num).toDouble(),
        unit: i['unit'] as String,
        unitPrice: (i['unitPrice'] as num).toDouble(),
        subtotal: (i['subtotal'] as num).toDouble(),
      )).toList();

      final detail = OrderDetail(
        id: data['id'] as String,
        orderNumber: data['orderNumber'] as String,
        customerId: data['customerId'] as String?,
        customerName: data['customerName'] as String?,
        customerPhone: data['customerPhone'] as String?,
        userId: data['userId'] as String,
        subtotal: (data['subtotal'] as num).toDouble(),
        tax: (data['tax'] as num).toDouble(),
        discount: (data['discount'] as num).toDouble(),
        total: (data['total'] as num).toDouble(),
        paymentMethod: data['paymentMethod'] as String,
        status: data['status'] as String,
        items: items,
        createdAt: data['createdAt'] as DateTime,
      );
      return Success(detail);
    } catch (e) {
      return Error(DatabaseFailure('Failed to load order detail: $e'));
    }
  }

  @override
  Future<Result<double>> getDailySalesTotal(DateTime date) async {
    try {
      final total = await _dataSource.getDailySalesTotal(date);
      return Success(total);
    } catch (e) {
      return Error(DatabaseFailure('Failed to get daily total: $e'));
    }
  }

  @override
  Future<Result<double>> getMonthlySalesTotal(int year, int month) async {
    try {
      final total = await _dataSource.getMonthlySalesTotal(year, month);
      return Success(total);
    } catch (e) {
      return Error(DatabaseFailure('Failed to get monthly total: $e'));
    }
  }

  @override
  Future<Result<int>> getOrderCount({String? status}) async {
    try {
      final count = await _dataSource.getOrderCount(status: status);
      return Success(count);
    } catch (e) {
      return Error(DatabaseFailure('Failed to get order count: $e'));
    }
  }
}
