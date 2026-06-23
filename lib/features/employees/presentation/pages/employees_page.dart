import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../providers/employee_providers.dart';

class EmployeesPage extends ConsumerWidget {
  const EmployeesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final employeesAsync = ref.watch(employeesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Employees'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => context.push('/employees/add'),
          ),
        ],
      ),
      body: employeesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (employees) {
          if (employees.isEmpty) {
            return const Center(child: Text('No employees yet. Tap + to add one.'));
          }
          return RefreshIndicator(
            onRefresh: () async => ref.invalidate(employeesProvider),
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: employees.length,
              itemBuilder: (context, index) {
                final emp = employees[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: AppColors.primaryLight,
                      child: Text(
                        emp.position.isNotEmpty ? emp.position[0].toUpperCase() : '?',
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ),
                    title: Text(emp.position, style: const TextStyle(fontWeight: FontWeight.w600)),
                    subtitle: Text(
                      'Salary: \$${emp.salary.toStringAsFixed(2)}${emp.isActive ? '' : ' (Inactive)'}',
                    ),
                    trailing: PopupMenuButton<String>(
                      onSelected: (value) {
                        if (value == 'edit') {
                          context.push('/employees/${emp.id}/edit');
                        }
                      },
                      itemBuilder: (_) => [
                        const PopupMenuItem(value: 'edit', child: Text('Edit')),
                      ],
                    ),
                    isThreeLine: false,
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
