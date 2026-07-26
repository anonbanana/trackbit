import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/constants/app_colors.dart';
import '../providers/sync_providers.dart';

class SyncPage extends ConsumerStatefulWidget {
  const SyncPage({super.key});

  @override
  ConsumerState<SyncPage> createState() => _SyncPageState();
}

class _SyncPageState extends ConsumerState<SyncPage> {
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializeSync();
  }

  Future<void> _initializeSync() async {
    if (_isInitialized) return;
    _isInitialized = true;

    final prefs = await SharedPreferences.getInstance();
    var deviceId = prefs.getString('sync_device_id');
    if (deviceId == null) {
      deviceId = const Uuid().v4();
      await prefs.setString('sync_device_id', deviceId);
    }

    final syncService = ref.read(syncServiceProvider);
    await syncService.initialize(deviceId, 'TrackBit Device');
  }

  @override
  Widget build(BuildContext context) {
    final pendingAsync = ref.watch(pendingSyncEntriesProvider);
    final allAsync = ref.watch(allSyncEntriesProvider);
    final peersAsync = ref.watch(discoveredPeersProvider);
    final syncStatus = ref.watch(syncStatusProvider);

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
                          const Text(
                            'Pending Entries',
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                          Text('${pending.length} records waiting to sync'),
                        ],
                      ),
                    ),
                    if (syncStatus == SyncStatus.syncing)
                      const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    else
                      FilledButton.tonal(
                        onPressed: pending.isEmpty
                            ? null
                            : () => _syncPendingEntries(pending),
                        child: const Text('Sync Now'),
                      ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.wifi_find, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        'Network Peers',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const Spacer(),
                      if (syncStatus == SyncStatus.discovering)
                        const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  peersAsync.when(
                    loading: () => const Text('Starting discovery...'),
                    error: (e, _) => Text('Discovery error: $e'),
                    data: (peers) {
                      if (peers.isEmpty) {
                        return const Text(
                          'No peers found on the network.\nMake sure other TrackBit instances are running.',
                          style: TextStyle(color: Colors.grey, fontSize: 13),
                        );
                      }
                      return Column(
                        children: peers.map((peer) {
                          final isSyncing =
                              syncStatus == SyncStatus.connecting ||
                              syncStatus == SyncStatus.syncing;
                          return ListTile(
                            contentPadding: EdgeInsets.zero,
                            leading: CircleAvatar(
                              backgroundColor: AppColors.success.withValues(
                                alpha: 0.1,
                              ),
                              child: const Icon(
                                Icons.computer,
                                color: AppColors.success,
                                size: 20,
                              ),
                            ),
                            title: Text(
                              peer.deviceName.isNotEmpty
                                  ? peer.deviceName
                                  : 'TrackBit Device',
                            ),
                            subtitle: Text(peer.ipAddress ?? 'Unknown IP'),
                            trailing: isSyncing
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  )
                                : FilledButton.tonal(
                                    onPressed: () => _syncWithPeer(peer),
                                    child: const Text('Sync'),
                                  ),
                          );
                        }).toList(),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Sync History',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
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
                        e.status == 'SYNCED'
                            ? Icons.check_circle
                            : Icons.pending,
                        color: e.status == 'SYNCED'
                            ? AppColors.success
                            : AppColors.warning,
                      ),
                      title: Text('${e.operation} - ${e.entityTable}'),
                      subtitle: Text('Record: ${e.recordId}'),
                      trailing: Text(
                        '${e.createdAt.month}/${e.createdAt.day} ${e.createdAt.hour}:${e.createdAt.minute}',
                        style: const TextStyle(fontSize: 12),
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

  Future<void> _syncPendingEntries(List<dynamic> pending) async {
    ref.read(syncStatusProvider.notifier).state = SyncStatus.syncing;

    try {
      final syncService = ref.read(syncServiceProvider);
      final peers = syncService.peerDiscovery.currentPeers;

      if (peers.isNotEmpty) {
        await syncService.syncWithPeer(peers.first);
      }

      ref.read(syncStatusProvider.notifier).state = SyncStatus.success;
      ref.invalidate(pendingSyncEntriesProvider);
      ref.invalidate(allSyncEntriesProvider);

      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Sync completed')));
      }
    } catch (e) {
      ref.read(syncStatusProvider.notifier).state = SyncStatus.error;
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Sync failed')));
      }
    }
  }

  Future<void> _syncWithPeer(dynamic peer) async {
    ref.read(syncStatusProvider.notifier).state = SyncStatus.connecting;

    try {
      final syncService = ref.read(syncServiceProvider);
      await syncService.syncWithPeer(peer);

      ref.read(syncStatusProvider.notifier).state = SyncStatus.syncing;
      await Future.delayed(const Duration(seconds: 1));

      ref.read(syncStatusProvider.notifier).state = SyncStatus.success;
      ref.invalidate(pendingSyncEntriesProvider);
      ref.invalidate(allSyncEntriesProvider);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Synced with ${peer.deviceName}')),
        );
      }
    } catch (e) {
      ref.read(syncStatusProvider.notifier).state = SyncStatus.error;
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Sync failed')));
      }
    }
  }
}
