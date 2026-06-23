import '../../../../core/utils/result.dart';
import '../entities/expense.dart';

abstract class ExpensesRepository {
  Future<Result<List<Expense>>> getAllExpenses({String? category});
  Future<Result<Expense?>> getExpenseById(String id);
  Future<Result<Expense>> createExpense(Expense expense);
  Future<Result<Expense>> updateExpense(Expense expense);
  Future<Result<void>> deleteExpense(String id);
  Future<Result<List<String>>> getExpenseCategories();
  Future<Result<double>> getTotalByCategory(String category);
}
