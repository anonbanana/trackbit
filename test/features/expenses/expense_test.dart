import 'package:flutter_test/flutter_test.dart';
import 'package:trackbit/features/expenses/domain/entities/expense.dart';

void main() {
  group('Expense', () {
    final now = DateTime(2026, 7, 26);

    test('creates with required fields', () {
      final expense = Expense(
        id: '1',
        title: 'Office Supplies',
        category: 'Supplies',
        amount: 50.00,
        paidBy: 'user-1',
        createdAt: now,
      );

      expect(expense.id, '1');
      expect(expense.title, 'Office Supplies');
      expect(expense.category, 'Supplies');
      expect(expense.amount, 50.00);
      expect(expense.paidBy, 'user-1');
      expect(expense.receiptImage, isNull);
      expect(expense.note, isNull);
    });

    test('creates with optional fields', () {
      final expense = Expense(
        id: '1',
        title: 'Office Supplies',
        category: 'Supplies',
        amount: 50.00,
        paidBy: 'user-1',
        paidByName: 'John Doe',
        receiptImage: '/path/to/receipt.jpg',
        note: 'Monthly supplies',
        createdAt: now,
      );

      expect(expense.paidByName, 'John Doe');
      expect(expense.receiptImage, '/path/to/receipt.jpg');
      expect(expense.note, 'Monthly supplies');
    });

    test('equality based on props', () {
      final expense1 = Expense(
        id: '1',
        title: 'Office Supplies',
        category: 'Supplies',
        amount: 50.00,
        paidBy: 'user-1',
        createdAt: now,
      );

      final expense2 = Expense(
        id: '1',
        title: 'Office Supplies',
        category: 'Supplies',
        amount: 50.00,
        paidBy: 'user-1',
        createdAt: now,
      );

      expect(expense1, equals(expense2));
    });

    test('inequality with different data', () {
      final expense1 = Expense(
        id: '1',
        title: 'Office Supplies',
        category: 'Supplies',
        amount: 50.00,
        paidBy: 'user-1',
        createdAt: now,
      );

      final expense2 = Expense(
        id: '2',
        title: 'Travel',
        category: 'Travel',
        amount: 200.00,
        paidBy: 'user-2',
        createdAt: now,
      );

      expect(expense1, isNot(equals(expense2)));
    });
  });
}
