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
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Welcome to TrackBit',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: GridView.count(
                crossAxisCount: 3,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                children: [
                  _DashboardTile(
                    icon: Icons.point_of_sale,
                    label: 'POS',
                    color: AppColors.primary,
                    onTap: () => context.go('/pos'),
                  ),
                  _DashboardTile(
                    icon: Icons.inventory_2,
                    label: 'Inventory',
                    color: AppColors.success,
                    onTap: () => context.go('/inventory'),
                  ),
                  _DashboardTile(
                    icon: Icons.receipt_long,
                    label: 'Sales',
                    color: AppColors.accent,
                    onTap: () => context.go('/sales'),
                  ),
                  _DashboardTile(
                    icon: Icons.description,
                    label: 'Invoices',
                    color: AppColors.secondary,
                    onTap: () => context.go('/invoicing'),
                  ),
                  _DashboardTile(
                    icon: Icons.money_off,
                    label: 'Expenses',
                    color: AppColors.warning,
                    onTap: () => context.go('/expenses'),
                  ),
                  _DashboardTile(
                    icon: Icons.people,
                    label: 'Customers',
                    color: AppColors.primaryLight,
                    onTap: () => context.go('/crm'),
                  ),
                  _DashboardTile(
                    icon: Icons.badge,
                    label: 'Employees',
                    color: AppColors.info,
                    onTap: () => context.go('/employees'),
                  ),
                  _DashboardTile(
                    icon: Icons.admin_panel_settings,
                    label: 'Roles',
                    color: AppColors.error,
                    onTap: () => context.go('/roles'),
                  ),
                  _DashboardTile(
                    icon: Icons.assessment,
                    label: 'Reports',
                    color: AppColors.secondary,
                    onTap: () => context.go('/reports'),
                  ),
                  _DashboardTile(
                    icon: Icons.sync,
                    label: 'Sync',
                    color: AppColors.accent,
                    onTap: () => context.go('/sync'),
                  ),
                  _DashboardTile(
                    icon: Icons.settings,
                    label: 'Settings',
                    color: AppColors.textSecondary,
                    onTap: () {},
                  ),
                ],
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
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
