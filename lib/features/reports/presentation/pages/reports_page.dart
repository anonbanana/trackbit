import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../providers/reports_providers.dart';

class ReportsPage extends ConsumerStatefulWidget {
  const ReportsPage({super.key});

  @override
  ConsumerState<ReportsPage> createState() => _ReportsPageState();
}

class _ReportsPageState extends ConsumerState<ReportsPage> {
  ReportDateRange _selectedRange = ReportDateRange(
    start: DateTime.now().subtract(const Duration(days: 30)),
    end: DateTime.now(),
  );

  Future<void> _pickDateRange() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: DateTimeRange(
        start: _selectedRange.start,
        end: _selectedRange.end,
      ),
    );
    if (picked != null) {
      setState(() => _selectedRange = ReportDateRange(start: picked.start, end: picked.end));
    }
  }

  @override
  Widget build(BuildContext context) {
    final salesAsync = ref.watch(salesSummaryProvider(_selectedRange));
    final expenseAsync = ref.watch(expenseSummaryProvider(_selectedRange));
    final profitAsync = ref.watch(profitProvider(_selectedRange));
    final dailyAsync = ref.watch(dailySalesProvider(_selectedRange));
    final catExpenseAsync = ref.watch(expensesByCategoryProvider(_selectedRange));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Reports'),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(salesSummaryProvider);
          ref.invalidate(expenseSummaryProvider);
          ref.invalidate(profitProvider);
          ref.invalidate(dailySalesProvider);
          ref.invalidate(expensesByCategoryProvider);
        },
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    '${_selectedRange.start.month}/${_selectedRange.start.day}/${_selectedRange.start.year} - '
                    '${_selectedRange.end.month}/${_selectedRange.end.day}/${_selectedRange.end.year}',
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
                TextButton.icon(
                  icon: const Icon(Icons.date_range),
                  label: const Text('Change'),
                  onPressed: _pickDateRange,
                ),
              ],
            ),
            const SizedBox(height: 16),

            salesAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Text('Error: $e'),
              data: (sales) => _buildSummaryCard('Sales Revenue', '\$${sales.totalRevenue.toStringAsFixed(2)}',
                  '${sales.totalOrders} orders', AppColors.success, Icons.trending_up),
            ),
            const SizedBox(height: 8),

            expenseAsync.when(
              loading: () => const SizedBox.shrink(),
              error: (e, _) => Text('Error: $e'),
              data: (expense) => _buildSummaryCard('Total Expenses', '\$${expense.totalExpenses.toStringAsFixed(2)}',
                  '${expense.totalEntries} entries', AppColors.warning, Icons.money_off),
            ),
            const SizedBox(height: 8),

            profitAsync.when(
              loading: () => const SizedBox.shrink(),
              error: (e, _) => Text('Error: $e'),
              data: (profit) {
                final isPositive = profit >= 0;
                return _buildSummaryCard(
                  'Net Profit',
                  '\$${profit.toStringAsFixed(2)}',
                  isPositive ? 'Profitable' : 'Loss',
                  isPositive ? AppColors.success : AppColors.error,
                  isPositive ? Icons.arrow_upward : Icons.arrow_downward,
                );
              },
            ),
            const SizedBox(height: 24),

            Text('Daily Sales', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            dailyAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Text('Error: $e'),
              data: (days) {
                if (days.isEmpty) return const Text('No sales data.');
                return Card(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: days.reversed.take(7).toList().reversed.map((d) {
                        final label =
                            '${d.date.month}/${d.date.day}';
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Row(
                            children: [
                              SizedBox(width: 80, child: Text(label, style: const TextStyle(fontWeight: FontWeight.w500))),
                              const SizedBox(width: 8),
                              Expanded(
                                child: LinearProgressIndicator(
                                  value: days.isNotEmpty ? d.revenue / (days.first.revenue > 0 ? days.first.revenue : 1) : 0,
                                  backgroundColor: AppColors.surfaceVariant,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text('\$${d.revenue.toStringAsFixed(0)}'),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 24),

            Text('Expenses by Category', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            catExpenseAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Text('Error: $e'),
              data: (cats) {
                if (cats.isEmpty) return const Text('No expenses.');
                return Card(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      children: cats.map((c) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(c.category, style: const TextStyle(fontWeight: FontWeight.w500)),
                              Text('\$${c.total.toStringAsFixed(2)}'),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCard(String title, String value, String subtitle, Color color, IconData icon) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
              child: Icon(icon, color: color),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                  const SizedBox(height: 4),
                  Text(value, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                  Text(subtitle, style: const TextStyle(color: AppColors.textHint, fontSize: 12)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
