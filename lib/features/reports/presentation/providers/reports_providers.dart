import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/datasources/reports_local_datasource.dart';
import '../../data/repositories/reports_repository_impl.dart';
import '../../domain/repositories/reports_repository.dart';
import '../../domain/entities/sales_summary.dart';
import '../../domain/entities/expense_summary.dart';
import '../../../../core/database/app_database.dart';

class ReportDateRange {
  final DateTime start;
  final DateTime end;
  const ReportDateRange({required this.start, required this.end});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ReportDateRange && start == other.start && end == other.end;

  @override
  int get hashCode => Object.hash(start, end);
}

final reportsDataSourceProvider = Provider<ReportsLocalDataSource>((ref) {
  return ReportsLocalDataSource(ref.watch(databaseProvider));
});

final reportsRepositoryProvider = Provider<ReportsRepository>((ref) {
  return ReportsRepositoryImpl(ref.watch(reportsDataSourceProvider));
});

final salesSummaryProvider =
    FutureProvider.family<SalesSummary, ReportDateRange>((ref, range) async {
      final result = await ref
          .watch(reportsRepositoryProvider)
          .getSalesSummary(start: range.start, end: range.end);
      return result.when(
        success: (d) => d,
        error: (f) => throw Exception(f.message),
      );
    });

final dailySalesProvider =
    FutureProvider.family<List<DailySalesSummary>, ReportDateRange>((
      ref,
      range,
    ) async {
      final result = await ref
          .watch(reportsRepositoryProvider)
          .getDailySales(start: range.start, end: range.end);
      return result.when(
        success: (d) => d,
        error: (f) => throw Exception(f.message),
      );
    });

final expenseSummaryProvider =
    FutureProvider.family<ExpenseSummary, ReportDateRange>((ref, range) async {
      final result = await ref
          .watch(reportsRepositoryProvider)
          .getExpenseSummary(start: range.start, end: range.end);
      return result.when(
        success: (d) => d,
        error: (f) => throw Exception(f.message),
      );
    });

final expensesByCategoryProvider =
    FutureProvider.family<List<CategoryExpenseSummary>, ReportDateRange>((
      ref,
      range,
    ) async {
      final result = await ref
          .watch(reportsRepositoryProvider)
          .getExpensesByCategory(start: range.start, end: range.end);
      return result.when(
        success: (d) => d,
        error: (f) => throw Exception(f.message),
      );
    });

final profitProvider = FutureProvider.family<double, ReportDateRange>((
  ref,
  range,
) async {
  final result = await ref
      .watch(reportsRepositoryProvider)
      .getProfit(start: range.start, end: range.end);
  return result.when(
    success: (d) => d,
    error: (f) => throw Exception(f.message),
  );
});
