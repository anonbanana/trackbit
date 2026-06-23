import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../providers/sync_providers.dart';

class SyncPage extends ConsumerWidget {
  const SyncPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pendingAsync = ref.watch(pendingSyncEntriesProvider);
    final allAsync = ref.watch(allSyncEntriesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Sync'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              ref.invalidate(pendingSyncEntriesProvider);
              ref.invalidate(allSyncEntriesProvider);
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          pendingAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Text('Error: $e'),
            data: (pending) => Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.warning.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.sync, color: AppColors.warning),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Pending Entries', style: TextStyle(fontWeight: FontWeight.w600)),
                          Text('${pending.length} records waiting to sync',
                              style: const TextStyle(color: AppColors.textSecondary)),
                        ],
                      ),
                    ),
                    FilledButton.tonal(
                      onPressed: pending.isEmpty
                          ? null
                          : () async {
                              for (final entry in pending) {
                                await ref.read(syncRepositoryProvider).markSynced(entry.id);
                              }
                              ref.invalidate(pendingSyncEntriesProvider);
                              ref.invalidate(allSyncEntriesProvider);
                            },
                      child: const Text('Sync Now'),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text('Sync History', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          allAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Text('Error: $e'),
            data: (entries) {
              if (entries.isEmpty) return const Text('No sync history.');
              return Column(
                children: entries.map((e) {
                  return Card(
                    margin: const EdgeInsets.only(bottom: 4),
                    child: ListTile(
                      leading: Icon(
                        e.status == 'SYNCED' ? Icons.check_circle : Icons.pending,
                        color: e.status == 'SYNCED' ? AppColors.success : AppColors.warning,
                      ),
                      title: Text('${e.operation} - ${e.entityTable}'),
                      subtitle: Text('Record: ${e.recordId}'),
                      trailing: Text(
                        '${e.createdAt.month}/${e.createdAt.day} ${e.createdAt.hour}:${e.createdAt.minute}',
                        style: const TextStyle(fontSize: 12, color: AppColors.textHint),
                      ),
                    ),
                  );
                }).toList(),
              );
            },
          ),
        ],
      ),
    );
  }
}
