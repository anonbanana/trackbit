import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart';
import '../providers/crm_providers.dart';
import '../../domain/entities/customer.dart' as domain;
import '../../../../core/constants/app_colors.dart';

class CrmPage extends ConsumerWidget {
  const CrmPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final customersAsync = ref.watch(customersProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Customers')),
      body: customersAsync.when(
        data: (customers) {
          if (customers.isEmpty) {
            return const Center(child: Text('No customers yet'));
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: customers.length,
            itemBuilder: (context, index) {
              final customer = customers[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                    child: const Icon(Icons.person, color: AppColors.primary),
                  ),
                  title: Text(customer.name, style: const TextStyle(fontWeight: FontWeight.w600)),
                  subtitle: Text(
                    [customer.phone ?? '', customer.email ?? ''].where((e) => e.isNotEmpty).join(' • '),
                    style: const TextStyle(fontSize: 12),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (customer.loyaltyPoints > 0)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.warning.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text('${customer.loyaltyPoints.toStringAsFixed(0)} pts',
                              style: const TextStyle(fontSize: 10, color: AppColors.warning)),
                        ),
                      const SizedBox(width: 4),
                      PopupMenuButton(
                        itemBuilder: (context) => [
                          const PopupMenuItem(value: 'edit', child: Text('Edit')),
                          const PopupMenuItem(value: 'history', child: Text('Purchase History')),
                          const PopupMenuItem(value: 'delete', child: Text('Delete')),
                        ],
                        onSelected: (v) {
                          if (v == 'edit') _showCustomerForm(context, ref, customer);
                          if (v == 'history') _showPurchaseHistory(context, ref, customer);
                          if (v == 'delete') _deleteCustomer(context, ref, customer.id);
                        },
                      ),
                    ],
                  ),
                  onTap: () => _showCustomerForm(context, ref, customer),
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showCustomerForm(context, ref, null),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showCustomerForm(BuildContext context, WidgetRef ref, domain.Customer? customer) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => _CustomerFormSheet(customer: customer),
    );
  }

  void _showPurchaseHistory(BuildContext context, WidgetRef ref, domain.Customer customer) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => _PurchaseHistorySheet(customer: customer),
    );
  }

  Future<void> _deleteCustomer(BuildContext context, WidgetRef ref, String id) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Customer'),
        content: const Text('Delete this customer?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Delete')),
        ],
      ),
    );
    if (confirmed == true) {
      final repo = ref.read(crmRepositoryProvider);
      final result = await repo.deleteCustomer(id);
      result.when(
        success: (_) => ref.invalidate(customersProvider),
        error: (f) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: ${f.message}'))),
      );
    }
  }
}

class _CustomerFormSheet extends ConsumerStatefulWidget {
  final domain.Customer? customer;
  const _CustomerFormSheet({this.customer});

  @override
  ConsumerState<_CustomerFormSheet> createState() => _CustomerFormSheetState();
}

class _CustomerFormSheetState extends ConsumerState<_CustomerFormSheet> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  final _uuid = const Uuid();

  bool get _isEditing => widget.customer != null;

  @override
  void initState() {
    super.initState();
    if (_isEditing) {
      _nameCtrl.text = widget.customer!.name;
      _phoneCtrl.text = widget.customer!.phone ?? '';
      _emailCtrl.text = widget.customer!.email ?? '';
      _addressCtrl.text = widget.customer!.address ?? '';
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _emailCtrl.dispose();
    _addressCtrl.dispose();
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
            Text(_isEditing ? 'Edit Customer' : 'Add Customer',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            TextFormField(controller: _nameCtrl, decoration: const InputDecoration(labelText: 'Name'),
                validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null),
            const SizedBox(height: 12),
            TextFormField(controller: _phoneCtrl, decoration: const InputDecoration(labelText: 'Phone')),
            const SizedBox(height: 12),
            TextFormField(controller: _emailCtrl, decoration: const InputDecoration(labelText: 'Email')),
            const SizedBox(height: 12),
            TextFormField(controller: _addressCtrl, decoration: const InputDecoration(labelText: 'Address'), maxLines: 2),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _save,
              child: Text(_isEditing ? 'Update' : 'Create'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final customer = domain.Customer(
      id: _isEditing ? widget.customer!.id : _uuid.v4(),
      name: _nameCtrl.text.trim(),
      phone: _phoneCtrl.text.trim().isEmpty ? null : _phoneCtrl.text.trim(),
      email: _emailCtrl.text.trim().isEmpty ? null : _emailCtrl.text.trim(),
      address: _addressCtrl.text.trim().isEmpty ? null : _addressCtrl.text.trim(),
      createdAt: _isEditing ? widget.customer!.createdAt : DateTime.now(),
      updatedAt: DateTime.now(),
    );
    final repo = ref.read(crmRepositoryProvider);
    final result = _isEditing ? await repo.updateCustomer(customer) : await repo.createCustomer(customer);
    result.when(
      success: (_) {
        ref.invalidate(customersProvider);
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(_isEditing ? 'Customer updated' : 'Customer created')),
        );
      },
      error: (f) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: ${f.message}'))),
    );
  }
}

class _PurchaseHistorySheet extends ConsumerWidget {
  final domain.Customer customer;
  const _PurchaseHistorySheet({required this.customer});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final historyAsync = ref.watch(customerPurchaseHistoryProvider(customer.id));

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
              Text(customer.name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text('${customer.loyaltyPoints.toStringAsFixed(0)} loyalty points',
                  style: const TextStyle(color: AppColors.warning)),
              const Divider(height: 16),
              Text('Purchase History', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              historyAsync.when(
                data: (orders) {
                  if (orders.isEmpty) return const Text('No purchases yet');
                  return Column(
                    children: orders.map((o) => ListTile(
                      title: Text(o['orderNumber'] as String),
                      subtitle: Text(DateFormat('MMM dd, yyyy').format(o['createdAt'] as DateTime)),
                      trailing: Text(NumberFormat.currency(symbol: '\$').format(o['total']),
                          style: const TextStyle(fontWeight: FontWeight.bold)),
                    )).toList(),
                  );
                },
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
