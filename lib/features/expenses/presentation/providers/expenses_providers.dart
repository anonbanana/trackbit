import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/datasources/expenses_local_datasource.dart';
import '../../data/repositories/expenses_repository_impl.dart';
import '../../domain/repositories/expenses_repository.dart';
import '../../domain/entities/expense.dart' as domain;
import '../../../../core/database/app_database.dart' as db;

final expensesDataSourceProvider = Provider<ExpensesLocalDataSource>((ref) {
  return ExpensesLocalDataSource(ref.watch(db.databaseProvider));
});

final expensesRepositoryProvider = Provider<ExpensesRepository>((ref) {
  return ExpensesRepositoryImpl(ref.watch(expensesDataSourceProvider));
});

final expensesProvider = FutureProvider<List<domain.Expense>>((ref) async {
  final result = await ref.watch(expensesRepositoryProvider).getAllExpenses();
  return result.when(
    success: (d) => d,
    error: (f) => throw Exception(f.message),
  );
});

final expenseCategoriesProvider = FutureProvider<List<String>>((ref) async {
  final result = await ref
      .watch(expensesRepositoryProvider)
      .getExpenseCategories();
  return result.when(
    success: (d) => d,
    error: (f) => throw Exception(f.message),
  );
});
