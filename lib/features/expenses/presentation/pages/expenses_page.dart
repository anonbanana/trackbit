import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart';
import '../providers/expenses_providers.dart';
import '../../domain/entities/expense.dart' as domain;
import '../../../../core/constants/app_colors.dart';

class ExpensesPage extends ConsumerWidget {
  const ExpensesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final expensesAsync = ref.watch(expensesProvider);
    final categoriesAsync = ref.watch(expenseCategoriesProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Expenses')),
      body: expensesAsync.when(
        data: (expenses) {
          if (expenses.isEmpty) {
            return const Center(child: Text('No expenses recorded'));
          }
          double total = 0;
          for (final e in expenses) { total += e.amount; }
          return Column(
            children: [
              Container(
                width: double.infinity,
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.error.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.account_balance, color: AppColors.error, size: 32),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Total Expenses', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                        Text(NumberFormat.currency(symbol: '\$', decimalDigits: 2).format(total),
                            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.error)),
                      ],
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: expenses.length,
                  itemBuilder: (context, index) {
                    final expense = expenses[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: _categoryColor(expense.category).withValues(alpha: 0.1),
                          child: Icon(_categoryIcon(expense.category),
                              color: _categoryColor(expense.category), size: 20),
                        ),
                        title: Text(expense.title, style: const TextStyle(fontWeight: FontWeight.w600)),
                        subtitle: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                              decoration: BoxDecoration(
                                color: _categoryColor(expense.category).withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(expense.category,
                                  style: TextStyle(fontSize: 10, color: _categoryColor(expense.category))),
                            ),
                            if (expense.paidByName != null) ...[
                              const SizedBox(width: 8),
                              Text('by ${expense.paidByName}',
                                  style: const TextStyle(fontSize: 11, color: AppColors.textHint)),
                            ],
                          ],
                        ),
                        trailing: Text(NumberFormat.currency(symbol: '\$', decimalDigits: 2).format(expense.amount),
                            style: const TextStyle(fontWeight: FontWeight.bold)),
                        onTap: () => _showExpenseForm(context, ref, expense, categoriesAsync),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showExpenseForm(context, ref, null, categoriesAsync),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showExpenseForm(BuildContext context, WidgetRef ref, domain.Expense? expense,
      AsyncValue<List<String>> categoriesAsync) {
    categoriesAsync.whenData((categories) {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        builder: (ctx) => _ExpenseFormSheet(expense: expense, categories: categories),
      );
    });
  }

  Color _categoryColor(String category) {
    switch (category) {
      case 'Rent': return AppColors.primary;
      case 'Utilities': return AppColors.accent;
      case 'Salaries': return AppColors.secondary;
      case 'Supplies': return AppColors.info;
      case 'Marketing': return AppColors.warning;
      case 'Maintenance': return AppColors.textSecondary;
      default: return AppColors.textHint;
    }
  }

  IconData _categoryIcon(String category) {
    switch (category) {
      case 'Rent': return Icons.home;
      case 'Utilities': return Icons.bolt;
      case 'Salaries': return Icons.people;
      case 'Supplies': return Icons.inventory;
      case 'Marketing': return Icons.campaign;
      case 'Maintenance': return Icons.build;
      default: return Icons.receipt;
    }
  }
}

class _ExpenseFormSheet extends ConsumerStatefulWidget {
  final domain.Expense? expense;
  final List<String> categories;
  const _ExpenseFormSheet({this.expense, required this.categories});

  @override
  ConsumerState<_ExpenseFormSheet> createState() => _ExpenseFormSheetState();
}

class _ExpenseFormSheetState extends ConsumerState<_ExpenseFormSheet> {
  final _formKey = GlobalKey<FormState>();
  final _titleCtrl = TextEditingController();
  final _amountCtrl = TextEditingController();
  final _noteCtrl = TextEditingController();
  final _uuid = const Uuid();

  String _selectedCategory = 'Other';
  String? _receiptImage;
  bool get _isEditing => widget.expense != null;

  @override
  void initState() {
    super.initState();
    if (_isEditing) {
      _titleCtrl.text = widget.expense!.title;
      _amountCtrl.text = widget.expense!.amount.toString();
      _noteCtrl.text = widget.expense!.note ?? '';
      _selectedCategory = widget.expense!.category;
      _receiptImage = widget.expense!.receiptImage;
    }
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _amountCtrl.dispose();
    _noteCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 16, right: 16, top: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(_isEditing ? 'Edit Expense' : 'Add Expense',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            TextFormField(controller: _titleCtrl, decoration: const InputDecoration(labelText: 'Title'),
                validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null),
            const SizedBox(height: 12),
            TextFormField(controller: _amountCtrl, decoration: const InputDecoration(labelText: 'Amount', prefixText: '\$ '),
                keyboardType: TextInputType.number,
                validator: (v) => v == null || double.tryParse(v) == null ? 'Invalid amount' : null),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              initialValue: _selectedCategory,
              decoration: const InputDecoration(labelText: 'Category'),
              items: widget.categories.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
              onChanged: (v) => setState(() => _selectedCategory = v ?? 'Other'),
            ),
            const SizedBox(height: 12),
            TextFormField(controller: _noteCtrl, decoration: const InputDecoration(labelText: 'Note'), maxLines: 2),
            const SizedBox(height: 12),
            Row(
              children: [
                OutlinedButton.icon(
                  icon: const Icon(Icons.receipt),
                  label: Text(_receiptImage != null ? 'Change Receipt' : 'Add Receipt'),
                  onPressed: () async {
                    final picker = ImagePicker();
                    final picked = await picker.pickImage(source: ImageSource.gallery, maxWidth: 1024);
                    if (picked != null) setState(() => _receiptImage = picked.path);
                  },
                ),
                if (_receiptImage != null) ...[
                  const SizedBox(width: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: Image.file(File(_receiptImage!), width: 48, height: 48, fit: BoxFit.cover),
                  ),
                  IconButton(
                    icon: const Icon(Icons.clear, size: 18, color: AppColors.error),
                    onPressed: () => setState(() => _receiptImage = null),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 16),
            ElevatedButton(onPressed: _save, child: Text(_isEditing ? 'Update' : 'Create')),
          ],
        ),
      ),
    );
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final expense = domain.Expense(
      id: _isEditing ? widget.expense!.id : _uuid.v4(),
      title: _titleCtrl.text.trim(),
      category: _selectedCategory,
      amount: double.parse(_amountCtrl.text.trim()),
      paidBy: _isEditing ? widget.expense!.paidBy : 'system',
      receiptImage: _receiptImage,
      note: _noteCtrl.text.trim().isEmpty ? null : _noteCtrl.text.trim(),
      createdAt: _isEditing ? widget.expense!.createdAt : DateTime.now(),
    );
    final repo = ref.read(expensesRepositoryProvider);
    final result = _isEditing ? await repo.updateExpense(expense) : await repo.createExpense(expense);
    result.when(
      success: (_) {
        ref.invalidate(expensesProvider);
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(_isEditing ? 'Expense updated' : 'Expense created')),
        );
      },
      error: (f) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: ${f.message}'))),
    );
  }
}
