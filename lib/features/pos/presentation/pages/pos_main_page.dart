import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/pos_providers.dart';
import '../../domain/entities/cart_item.dart';
import '../../../../core/constants/app_colors.dart';
import 'package:intl/intl.dart';

class PosMainPage extends ConsumerStatefulWidget {
  const PosMainPage({super.key});

  @override
  ConsumerState<PosMainPage> createState() => _PosMainPageState();
}

class _PosMainPageState extends ConsumerState<PosMainPage> {
  final _searchController = TextEditingController();
  final _barcodeController = TextEditingController();
  final _quantityController = TextEditingController(text: '1');
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    _barcodeController.dispose();
    _quantityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cart = ref.watch(cartProvider);
    final productsAsync = ref.watch(
      _searchQuery.isEmpty
          ? searchedPosProductsProvider('')
          : searchedPosProductsProvider(_searchQuery),
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Point of Sale'),
        actions: [
          IconButton(
            icon: const Icon(Icons.receipt_long),
            onPressed: cart.items.isNotEmpty
                ? () => context.go('/pos/checkout')
                : null,
            tooltip: 'Checkout',
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: const InputDecoration(
                      hintText: 'Search products...',
                      prefixIcon: Icon(Icons.search),
                    ),
                    onChanged: (v) => setState(() => _searchQuery = v),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.qr_code_scanner),
                  onPressed: _showBarcodeDialog,
                  tooltip: 'Scan Barcode',
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: Row(
              children: [
                Expanded(
                  flex: 3,
                  child: productsAsync.when(
                    data: (products) {
                      if (_searchQuery.isEmpty) {
                        return const Center(
                          child: Text('Search for products to start selling',
                              style: TextStyle(color: AppColors.textHint)),
                        );
                      }
                      if (products.isEmpty) {
                        return const Center(child: Text('No products found'));
                      }
                      return GridView.builder(
                        padding: const EdgeInsets.all(8),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          childAspectRatio: 1.1,
                          crossAxisSpacing: 8,
                          mainAxisSpacing: 8,
                        ),
                        itemCount: products.length,
                        itemBuilder: (context, index) {
                          final product = products[index];
                          final stockQty = (product['stockQty'] as num).toDouble();
                          final isOutOfStock = stockQty <= 0;
                          return Card(
                            color: isOutOfStock ? Colors.grey.shade100 : null,
                            child: InkWell(
                              onTap: isOutOfStock ? null : () => _addToCart(product),
                              borderRadius: BorderRadius.circular(12),
                              child: Padding(
                                padding: const EdgeInsets.all(8),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      isOutOfStock ? Icons.inventory : Icons.shopping_bag,
                                      size: 32,
                                      color: isOutOfStock ? AppColors.textHint : AppColors.primary,
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      product['name'] as String,
                                      textAlign: TextAlign.center,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      NumberFormat.currency(symbol: '\$', decimalDigits: 2)
                                          .format(product['price']),
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: AppColors.success,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    if (isOutOfStock)
                                      const Text('Out of Stock',
                                          style: TextStyle(fontSize: 10, color: AppColors.error)),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      );
                    },
                    loading: () => const Center(child: CircularProgressIndicator()),
                    error: (e, _) => Center(child: Text('Error: $e')),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColors.surfaceVariant,
                      border: Border(left: BorderSide(color: AppColors.border)),
                    ),
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(12),
                          child: Text('Cart (${cart.itemCount})',
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        ),
                        const Divider(height: 1),
                        Expanded(
                          child: cart.items.isEmpty
                              ? const Center(
                                  child: Text('Cart is empty',
                                      style: TextStyle(color: AppColors.textHint)),
                                )
                              : ListView.builder(
                                  itemCount: cart.items.length,
                                  itemBuilder: (context, index) {
                                    final item = cart.items[index];
                                    return _CartItemTile(
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
                              _SummaryRow(label: 'Subtotal', value: cart.subtotal),
                              if (cart.discount > 0)
                                _SummaryRow(label: 'Discount (${cart.discount.toStringAsFixed(0)}%)',
                                    value: -cart.discountAmount, color: AppColors.error),
                              if (cart.taxRate > 0)
                                _SummaryRow(label: 'Tax (${cart.taxRate.toStringAsFixed(0)}%)',
                                    value: cart.taxAmount),
                              const Divider(height: 8),
                              _SummaryRow(label: 'Total', value: cart.total,
                                  bold: true, fontSize: 18),
                              const SizedBox(height: 8),
                              ElevatedButton(
                                onPressed: cart.items.isEmpty
                                    ? null
                                    : () => context.go('/pos/checkout'),
                                child: const Text('Checkout'),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _addToCart(Map<String, dynamic> product) {
    final qty = double.tryParse(_quantityController.text) ?? 1;
    ref.read(cartProvider.notifier).addItem(CartItem(
      productId: product['id'] as String,
      productName: product['name'] as String,
      sku: product['sku'] as String,
      unitPrice: (product['price'] as num).toDouble(),
      quantity: qty,
      unit: product['unit'] as String? ?? 'Piece',
      barcode: product['barcode'] as String?,
    ));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Added ${product['name']}'),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  void _showBarcodeDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Enter Barcode'),
        content: TextField(
          controller: _barcodeController,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'Scan or type barcode...',
            prefixIcon: Icon(Icons.qr_code),
          ),
          onSubmitted: (v) async {
            if (v.isNotEmpty) {
              final repo = ref.read(posRepositoryProvider);
              final result = await repo.getProductByBarcode(v);
              result.when(
                success: (product) {
                  if (product != null) {
                    _addToCart(product);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Product not found')),
                    );
                  }
                },
                error: (f) => ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Error: ${f.message}')),
                ),
              );
            }
            if (ctx.mounted) Navigator.pop(ctx);
          },
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
        ],
      ),
    );
  }
}

class _CartItemTile extends StatelessWidget {
  final CartItem item;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;
  final VoidCallback onRemove;

  const _CartItemTile({
    required this.item,
    required this.onIncrement,
    required this.onDecrement,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(item.productName,
                      style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13),
                      maxLines: 1, overflow: TextOverflow.ellipsis),
                ),
                IconButton(
                  icon: const Icon(Icons.close, size: 16),
                  onPressed: onRemove,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.remove_circle_outline, size: 18),
                      onPressed: onDecrement,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                    Text('${item.quantity.toStringAsFixed(0)}',
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                    IconButton(
                      icon: const Icon(Icons.add_circle_outline, size: 18),
                      onPressed: onIncrement,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
                Text(
                  NumberFormat.currency(symbol: '\$', decimalDigits: 2).format(item.subtotal),
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final double value;
  final bool bold;
  final double fontSize;
  final Color? color;

  const _SummaryRow({
    required this.label,
    required this.value,
    this.bold = false,
    this.fontSize = 14,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: fontSize, fontWeight: bold ? FontWeight.bold : FontWeight.normal)),
          Text(
            NumberFormat.currency(symbol: '\$', decimalDigits: 2).format(value),
            style: TextStyle(
              fontSize: fontSize,
              fontWeight: bold ? FontWeight.bold : FontWeight.normal,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
