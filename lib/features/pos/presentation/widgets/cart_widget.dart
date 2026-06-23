import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/pos_providers.dart';
import '../../domain/entities/cart_item.dart';
import 'package:intl/intl.dart';

class CartWidget extends ConsumerWidget {
  const CartWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cart = ref.watch(cartProvider);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(12),
          child: Text('Cart (${cart.itemCount})',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        ),
        const Divider(height: 1),
        Expanded(
          child: cart.items.isEmpty
              ? const Center(child: Text('Cart is empty'))
              : ListView.builder(
                  itemCount: cart.items.length,
                  itemBuilder: (context, index) {
                    final item = cart.items[index];
                    return _CartItemWidget(
                      item: item,
                      onIncrement: () => ref.read(cartProvider.notifier)
                          .updateQuantity(item.productId, item.quantity + 1),
                      onDecrement: () => ref.read(cartProvider.notifier)
                          .updateQuantity(item.productId, item.quantity - 1),
                      onRemove: () => ref.read(cartProvider.notifier)
                          .removeItem(item.productId),
                    );
                  },
                ),
        ),
        const Divider(height: 1),
        Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Subtotal', style: TextStyle(fontSize: 14)),
                  Text(NumberFormat.currency(symbol: '\$', decimalDigits: 2).format(cart.subtotal)),
                ],
              ),
              if (cart.discount > 0)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Discount (${cart.discount.toStringAsFixed(0)}%)',
                        style: const TextStyle(color: Colors.red)),
                    Text('-${NumberFormat.currency(symbol: '\$', decimalDigits: 2).format(cart.discountAmount)}',
                        style: const TextStyle(color: Colors.red)),
                  ],
                ),
              if (cart.taxRate > 0)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Tax (${cart.taxRate.toStringAsFixed(0)}%)'),
                    Text(NumberFormat.currency(symbol: '\$', decimalDigits: 2).format(cart.taxAmount)),
                  ],
                ),
              const Divider(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Total', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                  Text(NumberFormat.currency(symbol: '\$', decimalDigits: 2).format(cart.total),
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _CartItemWidget extends StatelessWidget {
  final CartItem item;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;
  final VoidCallback onRemove;

  const _CartItemWidget({
    required this.item,
    required this.onIncrement,
    required this.onDecrement,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: ListTile(
        title: Text(item.productName, maxLines: 1, overflow: TextOverflow.ellipsis),
        subtitle: Row(
          children: [
            IconButton(
              icon: const Icon(Icons.remove_circle_outline, size: 18),
              onPressed: onDecrement,
            ),
            Text(item.quantity.toStringAsFixed(0)),
            IconButton(
              icon: const Icon(Icons.add_circle_outline, size: 18),
              onPressed: onIncrement,
            ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(NumberFormat.currency(symbol: '\$', decimalDigits: 2).format(item.subtotal)),
            IconButton(
              icon: const Icon(Icons.close, size: 16),
              onPressed: onRemove,
            ),
          ],
        ),
      ),
    );
  }
}
