import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _Tile(
            icon: Icons.receipt,
            label: 'Receipt Settings',
            subtitle: 'Store name, tax rate, printer',
            color: AppColors.primary,
            onTap: () => context.push('/settings/receipt'),
          ),
          _Tile(
            icon: Icons.person,
            label: 'User Profile',
            subtitle: 'View and edit your profile',
            color: AppColors.success,
            onTap: () => context.push('/settings/profile'),
          ),
          _Tile(
            icon: Icons.lock,
            label: 'Change Password',
            subtitle: 'Update your login password',
            color: AppColors.warning,
            onTap: () => context.push('/settings/password'),
          ),
          _Tile(
            icon: Icons.palette,
            label: 'Appearance',
            subtitle: 'Dark mode toggle',
            color: AppColors.accent,
            onTap: () => context.push('/settings/appearance'),
          ),
        ],
      ),
    );
  }
}

class _Tile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _Tile({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withValues(alpha: 0.1),
          child: Icon(icon, color: color),
        ),
        title: Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}
