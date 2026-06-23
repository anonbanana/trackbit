import 'package:drift/drift.dart';
import '../../../../core/database/app_database.dart' as db;

class SyncLocalDataSource {
  final db.AppDatabase _database;
  SyncLocalDataSource(this._database);

  Future<List<db.SyncQueueData>> getPendingEntries() async {
    return await (_database.select(_database.syncQueue)
      ..where((t) => t.status.equals('PENDING'))
      ..orderBy([(t) => OrderingTerm(expression: t.createdAt, mode: OrderingMode.asc)])
    ).get();
  }

  Future<List<db.SyncQueueData>> getAllEntries() async {
    return await (_database.select(_database.syncQueue)
      ..orderBy([(t) => OrderingTerm(expression: t.createdAt, mode: OrderingMode.desc)])
    ).get();
  }

  Future<void> insertEntry(db.SyncQueueCompanion entry) async {
    await _database.into(_database.syncQueue).insert(entry);
  }

  Future<void> updateStatus(int id) async {
    await (_database.update(_database.syncQueue)
      ..where((t) => t.id.equals(id))
    ).write(db.SyncQueueCompanion(
      status: const Value('SYNCED'),
      syncedAt: Value(DateTime.now()),
    ));
  }

  Future<void> deleteSynced() async {
    await (_database.delete(_database.syncQueue)
      ..where((t) => t.status.equals('SYNCED'))
    ).go();
  }

  Future<List<db.SyncPeer>> getPeers() async {
    return await _database.select(_database.syncPeers).get();
  }

  Future<void> upsertPeer(db.SyncPeersCompanion peer) async {
    await _database.into(_database.syncPeers).insertOnConflictUpdate(peer);
  }
}
