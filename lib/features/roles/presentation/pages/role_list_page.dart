import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/role_provider.dart';
import '../../../../core/constants/app_colors.dart';

class RoleListPage extends ConsumerWidget {
  const RoleListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final rolesAsync = ref.watch(rolesProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Roles & Permissions')),
      body: rolesAsync.when(
        data: (roles) {
          if (roles.isEmpty) {
            return const Center(child: Text('No roles defined yet'));
          }
          final grouped = _groupByLevel(roles);
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: grouped.length,
            itemBuilder: (context, index) {
              final entry = grouped.entries.elementAt(index);
              return _RoleLevelCard(level: entry.key, roles: entry.value);
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/roles/add'),
        child: const Icon(Icons.add),
      ),
    );
  }

  Map<int, List<dynamic>> _groupByLevel(List<dynamic> roles) {
    final map = <int, List<dynamic>>{};
    for (final role in roles) {
      map.putIfAbsent(role.level, () => []).add(role);
    }
    final sortedKeys = map.keys.toList()..sort();
    return {for (final k in sortedKeys) k: map[k]!};
  }
}

class _RoleLevelCard extends StatelessWidget {
  final int level;
  final List roles;

  const _RoleLevelCard({required this.level, required this.roles});

  String get _levelLabel {
    switch (level) {
      case 0:
        return 'System';
      case 1:
        return 'Boss';
      case 2:
        return 'Manager';
      case 3:
        return 'Employee';
      default:
        return 'Level $level';
    }
  }

  Color get _levelColor {
    switch (level) {
      case 0:
        return AppColors.error;
      case 1:
        return AppColors.primary;
      case 2:
        return AppColors.secondary;
      case 3:
        return AppColors.accent;
      default:
        return AppColors.info;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: _levelColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    _levelLabel,
                    style: TextStyle(
                      color: _levelColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...roles.map(
              (role) => ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Icon(
                  role.isSystem ? Icons.shield : Icons.person,
                  color: _levelColor,
                ),
                title: Text(role.label),
                subtitle: Text(role.name, style: const TextStyle(fontSize: 12)),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (role.isSystem) const Icon(Icons.lock_outline, size: 16),
                    if (!role.isSystem)
                      IconButton(
                        icon: const Icon(Icons.edit, size: 18),
                        onPressed: () => context.push('/roles/${role.id}/edit'),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
