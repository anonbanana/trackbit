import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/inventory_providers.dart';
import '../../../../core/constants/app_colors.dart';

class LowStockPage extends ConsumerWidget {
  const LowStockPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lowStockAsync = ref.watch(lowStockProductsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Low Stock Alerts')),
      body: lowStockAsync.when(
        data: (products) {
          if (products.isEmpty) {
            return const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.check_circle, size: 64, color: AppColors.success),
                  SizedBox(height: 16),
                  Text(
                    'All products are well-stocked!',
                    style: TextStyle(fontSize: 16),
                  ),
                ],
              ),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: products.length,
            itemBuilder: (context, index) {
              final product = products[index];
              final ratio = product.minStock > 0
                  ? (product.stockQty / product.minStock * 100).toStringAsFixed(
                      0,
                    )
                  : '0';
              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: AppColors.warning.withValues(alpha: 0.1),
                    child: const Icon(
                      Icons.warning_amber,
                      color: AppColors.warning,
                    ),
                  ),
                  title: Text(product.name),
                  subtitle: Text(
                    'Stock: ${product.stockQty.toStringAsFixed(0)} ${product.unit} | Min: ${product.minStock.toStringAsFixed(0)} | $ratio%',
                    style: const TextStyle(fontSize: 12),
                  ),
                  trailing: TextButton(
                    onPressed: () =>
                        context.push('/inventory/stock/add', extra: product.id),
                    child: const Text('Add Stock'),
                  ),
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }
}
