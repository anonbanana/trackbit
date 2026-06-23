import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../providers/invoicing_providers.dart';
import '../../../../core/constants/app_colors.dart';
import '../../domain/entities/invoice.dart' as domain;
import '../../../sales/presentation/providers/sales_providers.dart';

class InvoicingPage extends ConsumerWidget {
  const InvoicingPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final invoicesAsync = ref.watch(invoicesProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Invoices')),
      body: invoicesAsync.when(
        data: (invoices) {
          if (invoices.isEmpty) {
            return const Center(child: Text('No invoices yet'));
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: invoices.length,
            itemBuilder: (context, index) {
              final invoice = invoices[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: _statusColor(invoice.status),
                    child: Text(invoice.status[0].toUpperCase(),
                        style: const TextStyle(color: Colors.white, fontSize: 16)),
                  ),
                  title: Text(invoice.invoiceNumber, style: const TextStyle(fontWeight: FontWeight.w600)),
                  subtitle: Text(
                    invoice.customerName ?? 'No customer',
                    style: const TextStyle(fontSize: 12),
                  ),
                  trailing: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(NumberFormat.currency(symbol: '\$', decimalDigits: 2).format(invoice.total),
                          style: const TextStyle(fontWeight: FontWeight.bold)),
                      Text(invoice.status.toUpperCase(),
                          style: TextStyle(fontSize: 10, color: _statusColor(invoice.status))),
                    ],
                  ),
                  onTap: () => _showInvoiceDetail(context, ref, invoice),
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showGenerateDialog(context, ref),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showInvoiceDetail(BuildContext context, WidgetRef ref, domain.Invoice invoice) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => _InvoiceDetailSheet(invoice: invoice),
    );
  }

  void _showGenerateDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (ctx) => _GenerateInvoiceDialog(),
    );
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'pending': return AppColors.warning;
      case 'paid': return AppColors.success;
      case 'overdue': return AppColors.error;
      case 'cancelled': return AppColors.textHint;
      default: return AppColors.info;
    }
  }
}

class _GenerateInvoiceDialog extends ConsumerStatefulWidget {
  @override
  ConsumerState<_GenerateInvoiceDialog> createState() => _GenerateInvoiceDialogState();
}

class _GenerateInvoiceDialogState extends ConsumerState<_GenerateInvoiceDialog> {
  String? _selectedOrderId;

  @override
  Widget build(BuildContext context) {
    final ordersAsync = ref.watch(ordersProvider);

    return AlertDialog(
      title: const Text('Generate Invoice from Order'),
      content: SizedBox(
        width: double.maxFinite,
        child: ordersAsync.when(
          data: (orders) {
            if (orders.isEmpty) return const Text('No completed orders found');
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ...orders.map((order) => RadioListTile<String>(
                  title: Text('${order.orderNumber} - ${NumberFormat.currency(symbol: '\$').format(order.total)}'),
                  subtitle: Text(order.customerName ?? 'Walk-in'),
                  value: order.id,
                  groupValue: _selectedOrderId,
                  onChanged: (v) => setState(() => _selectedOrderId = v),
                )),
              ],
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Text('Error: $e'),
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
        ElevatedButton(
          onPressed: _selectedOrderId == null ? null : () => _generate(context),
          child: const Text('Generate'),
        ),
      ],
    );
  }

  Future<void> _generate(BuildContext context) async {
    final repo = ref.read(invoicingRepositoryProvider);
    final result = await repo.generateFromOrder(_selectedOrderId!);
    result.when(
      success: (_) {
        ref.invalidate(invoicesProvider);
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Invoice generated')));
      },
      error: (f) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: ${f.message}'))),
    );
  }
}

class _InvoiceDetailSheet extends ConsumerWidget {
  final domain.Invoice invoice;
  const _InvoiceDetailSheet({required this.invoice});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final itemsAsync = ref.watch(invoiceItemsProvider(invoice.id));

    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      minChildSize: 0.4,
      maxChildSize: 0.9,
      expand: false,
      builder: (context, scrollController) {
        return Padding(
          padding: const EdgeInsets.all(16),
          child: ListView(
            controller: scrollController,
            children: [
              Center(child: Text(invoice.invoiceNumber,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold))),
              const Divider(height: 16),
              if (invoice.customerName != null)
                _Row(label: 'Customer', value: invoice.customerName!),
              if (invoice.dueDate != null)
                _Row(label: 'Due Date', value: DateFormat('MMM dd, yyyy').format(invoice.dueDate!)),
              _Row(label: 'Status', value: invoice.status.toUpperCase()),
              _Row(label: 'Total', value: NumberFormat.currency(symbol: '\$', decimalDigits: 2).format(invoice.total)),
              const Divider(),
              Text('Items', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              itemsAsync.when(
                data: (List<domain.InvoiceItem> items) => Column(
                  children: items.map((item) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      children: [
                        Expanded(child: Text(item.description, style: const TextStyle(fontSize: 13))),
                        Text('${item.quantity.toStringAsFixed(0)} x ${NumberFormat.currency(symbol: '\$').format(item.unitPrice)}',
                            style: const TextStyle(fontSize: 12)),
                        const SizedBox(width: 8),
                        Text(NumberFormat.currency(symbol: '\$').format(item.total),
                            style: const TextStyle(fontWeight: FontWeight.bold)),
                      ],
                    ),
                  )).toList(),
                ),
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => Text('Error: $e'),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _Row extends StatelessWidget {
  final String label;
  final String value;
  const _Row({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: AppColors.textSecondary)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}
