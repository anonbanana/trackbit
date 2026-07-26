import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/datasources/sync_local_datasource.dart';
import '../../data/repositories/sync_repository_impl.dart';
import '../../data/services/sync_service.dart';
import '../../domain/repositories/sync_repository.dart';
import '../../domain/entities/sync_entry.dart' as domain;
import '../../../../core/database/app_database.dart';

final syncDataSourceProvider = Provider<SyncLocalDataSource>((ref) {
  return SyncLocalDataSource(ref.watch(databaseProvider));
});

final syncRepositoryProvider = Provider<SyncRepository>((ref) {
  return SyncRepositoryImpl(ref.watch(syncDataSourceProvider));
});

final syncServiceProvider = Provider.autoDispose<SyncService>((ref) {
  final service = SyncService(ref.watch(databaseProvider));
  ref.onDispose(() => service.dispose());
  return service;
});

final pendingSyncEntriesProvider = FutureProvider<List<domain.SyncEntry>>((
  ref,
) async {
  final result = await ref.watch(syncRepositoryProvider).getPendingEntries();
  return result.when(
    success: (d) => d,
    error: (f) => throw Exception(f.message),
  );
});

final allSyncEntriesProvider = FutureProvider<List<domain.SyncEntry>>((
  ref,
) async {
  final result = await ref.watch(syncRepositoryProvider).getAllEntries();
  return result.when(
    success: (d) => d,
    error: (f) => throw Exception(f.message),
  );
});

final discoveredPeersProvider = StreamProvider<List<domain.SyncPeer>>((ref) {
  final syncService = ref.watch(syncServiceProvider);
  return syncService.peerDiscovery.peersStream;
});

final syncStatusProvider = StateProvider<SyncStatus>((ref) => SyncStatus.idle);

enum SyncStatus { idle, discovering, connecting, syncing, success, error }
