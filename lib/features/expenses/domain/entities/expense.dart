import 'package:equatable/equatable.dart';

class Expense extends Equatable {
  final String id;
  final String title;
  final String category;
  final double amount;
  final String paidBy;
  final String? paidByName;
  final String? receiptImage;
  final String? note;
  final DateTime createdAt;

  const Expense({
    required this.id,
    required this.title,
    required this.category,
    required this.amount,
    required this.paidBy,
    this.paidByName,
    this.receiptImage,
    this.note,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [id, title, category, amount];
}
