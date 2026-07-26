import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/inventory_providers.dart';
import '../../../../core/constants/app_colors.dart';

class InventoryPage extends ConsumerWidget {
  const InventoryPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lowStockAsync = ref.watch(lowStockProductsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Inventory')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _InventoryCard(
              icon: Icons.category,
              title: 'Categories',
              subtitle: 'Manage product categories & types',
              color: AppColors.primary,
              onTap: () => context.push('/inventory/categories'),
            ),
            const SizedBox(height: 12),
            _InventoryCard(
              icon: Icons.inventory_2,
              title: 'Products',
              subtitle: 'Add and manage products',
              color: AppColors.secondary,
              onTap: () => context.push('/inventory/products'),
            ),
            const SizedBox(height: 12),
            _InventoryCard(
              icon: Icons.swap_vert,
              title: 'Stock Movements',
              subtitle: 'Record stock in/out/adjustments',
              color: AppColors.accent,
              onTap: () => context.push('/inventory/stock'),
            ),
            const SizedBox(height: 12),
            _InventoryCard(
              icon: Icons.warning_amber,
              title: 'Low Stock Alerts',
              subtitle: 'Products below minimum stock',
              color: AppColors.warning,
              badge: lowStockAsync.when(
                data: (products) =>
                    products.isNotEmpty ? '${products.length}' : null,
                loading: () => null,
                error: (_, __) => null,
              ),
              onTap: () => context.push('/inventory/alerts'),
            ),
          ],
        ),
      ),
    );
  }
}

class _InventoryCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final String? badge;
  final VoidCallback onTap;

  const _InventoryCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    this.badge,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: CircleAvatar(
          backgroundColor: color.withValues(alpha: 0.1),
          child: Icon(icon, color: color),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(subtitle, style: const TextStyle(fontSize: 12)),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (badge != null)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.warning,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  badge!,
                  style: const TextStyle(color: Colors.white, fontSize: 12),
                ),
              ),
            const SizedBox(width: 8),
            const Icon(Icons.arrow_forward_ios, size: 16),
          ],
        ),
        onTap: onTap,
      ),
    );
  }
}
