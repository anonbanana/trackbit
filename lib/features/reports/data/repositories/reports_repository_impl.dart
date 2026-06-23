import '../../../../core/errors/failure.dart';
import '../../../../core/utils/result.dart';
import '../../domain/repositories/reports_repository.dart';
import '../../domain/entities/sales_summary.dart';
import '../../domain/entities/expense_summary.dart';
import '../datasources/reports_local_datasource.dart';

class ReportsRepositoryImpl implements ReportsRepository {
  final ReportsLocalDataSource _dataSource;
  ReportsRepositoryImpl(this._dataSource);

  @override
  Future<Result<SalesSummary>> getSalesSummary({DateTime? start, DateTime? end}) async {
    try {
      final orders = await _dataSource.getOrdersInRange(start: start, end: end);
      double totalRevenue = 0;
      int refundedCount = 0;
      double refundedAmount = 0;
      for (final o in orders) {
        if (o.status == 'Refunded' || o.status == 'Partially Refunded') {
          refundedCount++;
          refundedAmount += o.total;
        } else if (o.status == 'Completed') {
          totalRevenue += o.total;
        }
      }
      final totalOrders = orders.length;
      return Success(SalesSummary(
        totalRevenue: totalRevenue,
        totalOrders: totalOrders,
        averageOrderValue: totalOrders > 0 ? totalRevenue / totalOrders : 0,
        refundedOrders: refundedCount,
        refundedAmount: refundedAmount,
      ));
    } catch (e) {
      return Error(DatabaseFailure('Failed to get sales summary: $e'));
    }
  }

  @override
  Future<Result<List<DailySalesSummary>>> getDailySales({DateTime? start, DateTime? end}) async {
    try {
      final orders = await _dataSource.getOrdersInRange(start: start, end: end);
      final Map<String, DailySalesSummary> dayMap = {};
      for (final o in orders) {
        if (o.status != 'Completed') continue;
        final key = '${o.createdAt.year}-${o.createdAt.month}-${o.createdAt.day}';
        final existing = dayMap[key];
        if (existing != null) {
          dayMap[key] = DailySalesSummary(
            date: o.createdAt,
            revenue: existing.revenue + o.total,
            orders: existing.orders + 1,
          );
        } else {
          dayMap[key] = DailySalesSummary(
            date: o.createdAt,
            revenue: o.total,
            orders: 1,
          );
        }
      }
      final list = dayMap.values.toList();
      list.sort((a, b) => a.date.compareTo(b.date));
      return Success(list);
    } catch (e) {
      return Error(DatabaseFailure('Failed to get daily sales: $e'));
    }
  }

  @override
  Future<Result<ExpenseSummary>> getExpenseSummary({DateTime? start, DateTime? end}) async {
    try {
      final expenses = await _dataSource.getExpensesInRange(start: start, end: end);
      double total = 0;
      for (final e in expenses) {
        total += e.amount;
      }
      return Success(ExpenseSummary(
        totalExpenses: total,
        totalEntries: expenses.length,
        averageExpense: expenses.isNotEmpty ? total / expenses.length : 0,
      ));
    } catch (e) {
      return Error(DatabaseFailure('Failed to get expense summary: $e'));
    }
  }

  @override
  Future<Result<List<CategoryExpenseSummary>>> getExpensesByCategory({DateTime? start, DateTime? end}) async {
    try {
      final expenses = await _dataSource.getExpensesInRange(start: start, end: end);
      final Map<String, double> catMap = {};
      for (final e in expenses) {
        catMap[e.category] = (catMap[e.category] ?? 0) + e.amount;
      }
      return Success(
        catMap.entries.map((e) => CategoryExpenseSummary(category: e.key, total: e.value)).toList(),
      );
    } catch (e) {
      return Error(DatabaseFailure('Failed to get expense categories: $e'));
    }
  }

  @override
  Future<Result<double>> getProfit({DateTime? start, DateTime? end}) async {
    try {
      final salesResult = await getSalesSummary(start: start, end: end);
      final expenseResult = await getExpenseSummary(start: start, end: end);
      double revenue = 0;
      double expenses = 0;
      salesResult.when(success: (s) => revenue = s.totalRevenue, error: (_) {});
      expenseResult.when(success: (e) => expenses = e.totalExpenses, error: (_) {});
      return Success(revenue - expenses);
    } catch (e) {
      return Error(DatabaseFailure('Failed to calculate profit: $e'));
    }
  }
}
