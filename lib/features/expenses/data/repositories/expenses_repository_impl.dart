import 'package:drift/drift.dart';
import '../../../../core/errors/failure.dart';
import '../../../../core/utils/result.dart';
import '../../domain/repositories/expenses_repository.dart';
import '../../domain/entities/expense.dart';
import '../datasources/expenses_local_datasource.dart';
import '../../../../core/database/app_database.dart' as db;

class ExpensesRepositoryImpl implements ExpensesRepository {
  final ExpensesLocalDataSource _dataSource;
  ExpensesRepositoryImpl(this._dataSource);

  @override
  Future<Result<List<Expense>>> getAllExpenses({String? category}) async {
    try {
      final data = await _dataSource.getAllExpenses(category: category);
      final expenses = <Expense>[];
      for (final e in data) {
        final userName = await _dataSource.getUserName(e.paidBy);
        expenses.add(_mapExpense(e, userName));
      }
      return Success(expenses);
    } catch (e) {
      return Error(DatabaseFailure('Failed to load expenses: $e'));
    }
  }

  @override
  Future<Result<Expense?>> getExpenseById(String id) async {
    try {
      final data = await _dataSource.getExpenseById(id);
      if (data == null) return const Success(null);
      final userName = await _dataSource.getUserName(data.paidBy);
      return Success(_mapExpense(data, userName));
    } catch (e) {
      return Error(DatabaseFailure('Failed to load expense: $e'));
    }
  }

  @override
  Future<Result<Expense>> createExpense(Expense expense) async {
    try {
      await _dataSource.insertExpense(db.ExpensesCompanion(
        id: Value(expense.id),
        title: Value(expense.title),
        category: Value(expense.category),
        amount: Value(expense.amount),
        paidBy: Value(expense.paidBy),
        receiptImage: Value(expense.receiptImage),
        note: Value(expense.note),
        createdAt: Value(expense.createdAt),
      ));
      return Success(expense);
    } catch (e) {
      return Error(DatabaseFailure('Failed to create expense: $e'));
    }
  }

  @override
  Future<Result<Expense>> updateExpense(Expense expense) async {
    try {
      await _dataSource.updateExpense(db.ExpensesCompanion(
        title: Value(expense.title),
        category: Value(expense.category),
        amount: Value(expense.amount),
        paidBy: Value(expense.paidBy),
        receiptImage: Value(expense.receiptImage),
        note: Value(expense.note),
      ), expense.id);
      return Success(expense);
    } catch (e) {
      return Error(DatabaseFailure('Failed to update expense: $e'));
    }
  }

  @override
  Future<Result<void>> deleteExpense(String id) async {
    try {
      await _dataSource.deleteExpense(id);
      return const Success(null);
    } catch (e) {
      return Error(DatabaseFailure('Failed to delete expense: $e'));
    }
  }

  @override
  Future<Result<List<String>>> getExpenseCategories() async {
    try {
      final categories = await _dataSource.getCategories();
      final all = ['Rent', 'Utilities', 'Salaries', 'Supplies', 'Marketing', 'Maintenance', 'Other'];
      for (final c in categories) {
        if (!all.contains(c)) all.add(c);
      }
      return Success(all);
    } catch (e) {
      return Error(DatabaseFailure('Failed to load categories: $e'));
    }
  }

  @override
  Future<Result<double>> getTotalByCategory(String category) async {
    try {
      final total = await _dataSource.getTotalByCategory(category);
      return Success(total);
    } catch (e) {
      return Error(DatabaseFailure('Failed to get total: $e'));
    }
  }

  Expense _mapExpense(db.Expense row, String? userName) {
    return Expense(
      id: row.id,
      title: row.title,
      category: row.category,
      amount: row.amount,
      paidBy: row.paidBy,
      paidByName: userName,
      receiptImage: row.receiptImage,
      note: row.note,
      createdAt: row.createdAt,
    );
  }
}
