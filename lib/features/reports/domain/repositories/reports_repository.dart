import '../../../../core/utils/result.dart';
import '../entities/sales_summary.dart';
import '../entities/expense_summary.dart';

abstract class ReportsRepository {
  Future<Result<SalesSummary>> getSalesSummary({
    DateTime? start,
    DateTime? end,
  });
  Future<Result<List<DailySalesSummary>>> getDailySales({
    DateTime? start,
    DateTime? end,
  });
  Future<Result<ExpenseSummary>> getExpenseSummary({
    DateTime? start,
    DateTime? end,
  });
  Future<Result<List<CategoryExpenseSummary>>> getExpensesByCategory({
    DateTime? start,
    DateTime? end,
  });
  Future<Result<double>> getProfit({DateTime? start, DateTime? end});
}
