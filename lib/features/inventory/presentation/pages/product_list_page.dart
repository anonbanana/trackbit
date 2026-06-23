import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/inventory_providers.dart';
import '../../../../core/constants/app_colors.dart';
class ProductListPage extends ConsumerStatefulWidget {
  const ProductListPage({super.key});

  @override
  ConsumerState<ProductListPage> createState() => _ProductListPageState();
}

class _ProductListPageState extends ConsumerState<ProductListPage> {
  final _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final productsAsync = ref.watch(
      _searchQuery.isEmpty ? productsProvider : searchedProductsProvider(_searchQuery),
    );
    final lowStockAsync = ref.watch(lowStockProductsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Products'),
        actions: [
          IconButton(
            icon: const Icon(Icons.inventory_2),
            onPressed: () => context.go('/inventory/stock'),
            tooltip: 'Stock Movements',
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search products...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _searchQuery = '');
                        },
                      )
                    : null,
              ),
              onChanged: (v) => setState(() => _searchQuery = v),
            ),
          ),
          lowStockAsync.when(
            data: (lowStock) {
              if (lowStock.isEmpty) return const SizedBox.shrink();
              return GestureDetector(
                onTap: () => context.go('/inventory/alerts'),
                child: Container(
                  width: double.infinity,
                  margin: const EdgeInsets.all(16),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.warning.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.warning.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.warning_amber, color: AppColors.warning),
                      const SizedBox(width: 8),
                      Text(
                        '${lowStock.length} product(s) low on stock',
                        style: const TextStyle(color: AppColors.warning, fontWeight: FontWeight.w500),
                      ),
                      const Spacer(),
                      const Icon(Icons.arrow_forward_ios, size: 14, color: AppColors.warning),
                    ],
                  ),
                ),
              );
            },
            loading: () => const SizedBox.shrink(),
            error: (_, __) => const SizedBox.shrink(),
          ),
          Expanded(
            child: productsAsync.when(
              data: (products) {
                if (products.isEmpty) {
                  return const Center(child: Text('No products found'));
                }
                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: products.length,
                  itemBuilder: (context, index) {
                    final product = products[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: product.isActive
                              ? AppColors.primary.withValues(alpha: 0.1)
                              : AppColors.textHint.withValues(alpha: 0.1),
                          child: Icon(
                            Icons.inventory_2,
                            color: product.isActive ? AppColors.primary : AppColors.textHint,
                          ),
                        ),
                        title: Text(product.name),
                        subtitle: Text(
                          'SKU: ${product.sku} | Stock: ${_formatQty(product.stockQty)} ${product.unit}',
                          style: const TextStyle(fontSize: 12),
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (product.isLowStock)
                              const Icon(Icons.warning_amber, size: 18, color: AppColors.warning),
                            if (!product.isActive)
                              const Icon(Icons.visibility_off, size: 18, color: AppColors.textHint),
                            const SizedBox(width: 8),
                            PopupMenuButton(
                              itemBuilder: (context) => [
                                const PopupMenuItem(value: 'edit', child: Text('Edit')),
                                const PopupMenuItem(value: 'stock', child: Text('Stock Movement')),
                                const PopupMenuItem(value: 'delete', child: Text('Delete')),
                              ],
                              onSelected: (v) async {
                                if (v == 'edit') {
                                  context.go('/inventory/products/${product.id}/edit');
                                } else if (v == 'stock') {
                                  context.go('/inventory/stock/add', extra: product.id);
                                } else if (v == 'delete') {
                                  await _deleteProduct(product.id);
                                }
                              },
                            ),
                          ],
                        ),
                        onTap: () => context.go('/inventory/products/${product.id}/edit'),
                      ),
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
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.go('/inventory/products/add'),
        child: const Icon(Icons.add),
      ),
    );
  }

  Future<void> _deleteProduct(String id) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Product'),
        content: const Text('Delete this product?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Delete')),
        ],
      ),
    );
    if (confirmed == true) {
      final repo = ref.read(productRepositoryProvider);
      final result = await repo.deleteProduct(id);
      result.when(
        success: (_) => ref.invalidate(productsProvider),
        error: (f) => ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${f.message}')),
        ),
      );
    }
  }

  String _formatQty(double qty) {
    return qty == qty.roundToDouble() ? qty.toInt().toString() : qty.toStringAsFixed(2);
  }
}
