import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

class DashboardPage extends ConsumerWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text('Hi, ${authState.user?.fullName ?? 'User'}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              ref.read(authProvider.notifier).logout();
              context.go('/login');
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Dashboard',
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Welcome to TrackBit',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 24),
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final crossAxisCount = constraints.maxWidth > 600
                      ? 4
                      : constraints.maxWidth > 400
                      ? 3
                      : 2;
                  return GridView.count(
                    crossAxisCount: crossAxisCount,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    children: [
                      _DashboardTile(
                        icon: Icons.point_of_sale,
                        label: 'POS',
                        color: AppColors.primary,
                        onTap: () => context.push('/pos'),
                      ),
                      _DashboardTile(
                        icon: Icons.inventory_2,
                        label: 'Inventory',
                        color: AppColors.success,
                        onTap: () => context.push('/inventory'),
                      ),
                      _DashboardTile(
                        icon: Icons.receipt_long,
                        label: 'Sales',
                        color: AppColors.accent,
                        onTap: () => context.push('/sales'),
                      ),
                      _DashboardTile(
                        icon: Icons.description,
                        label: 'Invoices',
                        color: AppColors.secondary,
                        onTap: () => context.push('/invoicing'),
                      ),
                      _DashboardTile(
                        icon: Icons.money_off,
                        label: 'Expenses',
                        color: AppColors.warning,
                        onTap: () => context.push('/expenses'),
                      ),
                      _DashboardTile(
                        icon: Icons.people,
                        label: 'Customers',
                        color: AppColors.primaryLight,
                        onTap: () => context.push('/crm'),
                      ),
                      _DashboardTile(
                        icon: Icons.badge,
                        label: 'Employees',
                        color: AppColors.info,
                        onTap: () => context.push('/employees'),
                      ),
                      _DashboardTile(
                        icon: Icons.admin_panel_settings,
                        label: 'Roles',
                        color: AppColors.error,
                        onTap: () => context.push('/roles'),
                      ),
                      _DashboardTile(
                        icon: Icons.assessment,
                        label: 'Reports',
                        color: AppColors.secondary,
                        onTap: () => context.push('/reports'),
                      ),
                      _DashboardTile(
                        icon: Icons.sync,
                        label: 'Sync',
                        color: AppColors.accent,
                        onTap: () => context.push('/sync'),
                      ),
                      _DashboardTile(
                        icon: Icons.settings,
                        label: 'Settings',
                        color: AppColors.textHint,
                        onTap: () => context.push('/settings'),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DashboardTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _DashboardTile({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: color, size: 28),
              const SizedBox(height: 6),
              Text(
                label,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
