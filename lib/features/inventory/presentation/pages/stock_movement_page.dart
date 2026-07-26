import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../providers/inventory_providers.dart';
import '../../domain/entities/stock_movement.dart';
import '../../domain/enums/movement_type.dart';
import 'package:intl/intl.dart';

class StockMovementPage extends ConsumerStatefulWidget {
  final String? productId;

  const StockMovementPage({super.key, this.productId});

  @override
  ConsumerState<StockMovementPage> createState() => _StockMovementPageState();
}

class _StockMovementPageState extends ConsumerState<StockMovementPage> {
  final _formKey = GlobalKey<FormState>();
  final _quantityController = TextEditingController();
  final _noteController = TextEditingController();
  final _uuid = const Uuid();

  MovementType _movementType = MovementType.stockIn;
  String? _selectedProductId;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _selectedProductId = widget.productId;
  }

  @override
  void dispose() {
    _quantityController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final productsAsync = ref.watch(productsProvider);
    final movementsAsync = ref.watch(stockMovementsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Stock Movements')),
      body: Column(
        children: [
          Card(
            margin: const EdgeInsets.all(16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'New Movement',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 16),
                    productsAsync.when(
                      data: (products) => DropdownButtonFormField<String>(
                        initialValue: _selectedProductId,
                        decoration: const InputDecoration(labelText: 'Product'),
                        items: products
                            .map(
                              (p) => DropdownMenuItem(
                                value: p.id,
                                child: Text('${p.name} (${p.sku})'),
                              ),
                            )
                            .toList(),
                        onChanged: (v) =>
                            setState(() => _selectedProductId = v),
                        validator: (v) => v == null ? 'Required' : null,
                      ),
                      loading: () => const SizedBox(),
                      error: (_, __) => const SizedBox(),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<MovementType>(
                      initialValue: _movementType,
                      decoration: const InputDecoration(
                        labelText: 'Movement Type',
                      ),
                      items: MovementType.values
                          .map(
                            (t) => DropdownMenuItem(
                              value: t,
                              child: Text(t.label),
                            ),
                          )
                          .toList(),
                      onChanged: (v) => setState(
                        () => _movementType = v ?? MovementType.stockIn,
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _quantityController,
                      decoration: InputDecoration(
                        labelText: _movementType == MovementType.adjustment
                            ? 'New Stock Qty'
                            : 'Quantity',
                      ),
                      keyboardType: TextInputType.number,
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) return 'Required';
                        final qty = double.tryParse(v);
                        if (qty == null || qty <= 0) return 'Must be positive';
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _noteController,
                      decoration: const InputDecoration(
                        labelText: 'Note (optional)',
                      ),
                      maxLines: 2,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _isSubmitting ? null : _submitMovement,
                      child: _isSubmitting
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : Text('Record ${_movementType.label}'),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: movementsAsync.when(
              data: (movements) {
                if (movements.isEmpty) {
                  return const Center(child: Text('No movements yet'));
                }
                final products = productsAsync.valueOrNull ?? [];
                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: movements.length,
                  itemBuilder: (context, index) {
                    final movement = movements[index];
                    final productName =
                        products
                            .where((p) => p.id == movement.productId)
                            .map((p) => p.name)
                            .firstOrNull ??
                        'Unknown Product';
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundColor: _getMovementColor(
                          movement.type,
                        ).withValues(alpha: 0.1),
                        child: Icon(
                          _getMovementIcon(movement.type),
                          color: _getMovementColor(movement.type),
                          size: 20,
                        ),
                      ),
                      title: Text(
                        productName,
                        style: const TextStyle(fontWeight: FontWeight.w500),
                      ),
                      subtitle: Text(
                        '${movement.type.label}: ${movement.quantity} • ${DateFormat('MMM dd, yyyy HH:mm').format(movement.createdAt)}',
                        style: const TextStyle(fontSize: 12),
                      ),
                      trailing: movement.note != null
                          ? Text(
                              movement.note!,
                              style: const TextStyle(
                                fontSize: 11,
                                color: Colors.grey,
                              ),
                            )
                          : null,
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Error: $e')),
            ),
          ),
        ],
      ),
    );
  }

  Color _getMovementColor(MovementType type) {
    switch (type) {
      case MovementType.stockIn:
        return Colors.green;
      case MovementType.stockOut:
        return Colors.red;
      case MovementType.adjustment:
        return Colors.orange;
    }
  }

  IconData _getMovementIcon(MovementType type) {
    switch (type) {
      case MovementType.stockIn:
        return Icons.add_circle_outline;
      case MovementType.stockOut:
        return Icons.remove_circle_outline;
      case MovementType.adjustment:
        return Icons.tune;
    }
  }

  Future<void> _submitMovement() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    final movement = StockMovement(
      id: _uuid.v4(),
      productId: _selectedProductId!,
      type: _movementType,
      quantity: double.parse(_quantityController.text.trim()),
      referenceType: 'manual',
      note: _noteController.text.trim().isEmpty
          ? null
          : _noteController.text.trim(),
      createdAt: DateTime.now(),
    );

    final repo = ref.read(stockMovementRepositoryProvider);
    final result = await repo.createMovement(movement);

    result.when(
      success: (_) {
        if (mounted) {
          ref.invalidate(stockMovementsProvider);
          ref.invalidate(productsProvider);
          ref.invalidate(lowStockProductsProvider);
          _quantityController.clear();
          _noteController.clear();
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('Movement recorded')));
        }
      },
      error: (failure) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Error: ${failure.message}')));
        }
      },
    );

    setState(() => _isSubmitting = false);
  }
}
