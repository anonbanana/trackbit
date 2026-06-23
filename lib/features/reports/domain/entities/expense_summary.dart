import 'package:equatable/equatable.dart';

class ExpenseSummary extends Equatable {
  final double totalExpenses;
  final int totalEntries;
  final double averageExpense;

  const ExpenseSummary({
    this.totalExpenses = 0,
    this.totalEntries = 0,
    this.averageExpense = 0,
  });

  @override
  List<Object?> get props => [totalExpenses, totalEntries, averageExpense];
}

class CategoryExpenseSummary extends Equatable {
  final String category;
  final double total;

  const CategoryExpenseSummary({required this.category, required this.total});

  @override
  List<Object?> get props => [category, total];
}
