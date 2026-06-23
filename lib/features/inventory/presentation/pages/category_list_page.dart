import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/inventory_providers.dart';
import '../../../../core/constants/app_colors.dart';
import '../../domain/enums/category_type.dart';

class CategoryListPage extends ConsumerWidget {
  const CategoryListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoriesAsync = ref.watch(categoriesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Categories'),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () => _showTypeInfo(context),
            tooltip: 'Category Types',
          ),
        ],
      ),
      body: categoriesAsync.when(
        data: (categories) {
          if (categories.isEmpty) {
            return const Center(child: Text('No categories yet'));
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: categories.length,
            itemBuilder: (context, index) {
              final category = categories[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: _getCategoryColor(category.type).withValues(alpha: 0.1),
                    child: Icon(
                      _getCategoryIcon(category.type),
                      color: _getCategoryColor(category.type),
                    ),
                  ),
                  title: Text(category.name),
                  subtitle: Text(
                    category.type.label,
                    style: TextStyle(
                      color: _getCategoryColor(category.type),
                      fontSize: 12,
                    ),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, size: 18),
                        onPressed: () => context.go('/inventory/categories/${category.id}/edit'),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete_outline, size: 18),
                        onPressed: category.isSystem ? null : () => _deleteCategory(context, ref, category),
                      ),
                    ],
                  ),
                  onTap: () => context.go('/inventory/categories/${category.id}/edit'),
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.go('/inventory/categories/add'),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _deleteCategory(BuildContext context, WidgetRef ref, category) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Category'),
        content: Text('Delete "${category.name}"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Delete')),
        ],
      ),
    );
    if (confirmed == true) {
      final repo = ref.read(categoryRepositoryProvider);
      final result = await repo.deleteCategory(category.id);
      result.when(
        success: (_) => ref.invalidate(categoriesProvider),
        error: (f) => ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${f.message}')),
        ),
      );
    }
  }

  void _showTypeInfo(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Category Types'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: CategoryType.values.map((t) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              children: [
                Icon(_getCategoryIcon(t), size: 18, color: _getCategoryColor(t)),
                const SizedBox(width: 8),
                Text(t.label),
              ],
            ),
          )).toList(),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('OK')),
        ],
      ),
    );
  }

  Color _getCategoryColor(CategoryType type) {
    switch (type) {
      case CategoryType.food: return AppColors.success;
      case CategoryType.clothing: return AppColors.secondary;
      case CategoryType.electronics: return AppColors.primary;
      case CategoryType.gaming: return AppColors.accent;
      case CategoryType.optical: return AppColors.info;
      case CategoryType.luggage: return AppColors.warning;
      case CategoryType.custom: return AppColors.textSecondary;
    }
  }

  IconData _getCategoryIcon(CategoryType type) {
    switch (type) {
      case CategoryType.food: return Icons.restaurant;
      case CategoryType.clothing: return Icons.checkroom;
      case CategoryType.electronics: return Icons.devices;
      case CategoryType.gaming: return Icons.sports_esports;
      case CategoryType.optical: return Icons.visibility;
      case CategoryType.luggage: return Icons.luggage;
      case CategoryType.custom: return Icons.category;
    }
  }
}
