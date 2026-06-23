import 'package:drift/drift.dart';
import '../../../../core/errors/failure.dart';
import '../../../../core/utils/result.dart';
import '../../domain/repositories/sync_repository.dart';
import '../../domain/entities/sync_entry.dart';
import '../datasources/sync_local_datasource.dart';
import '../../../../core/database/app_database.dart' as db;

class SyncRepositoryImpl implements SyncRepository {
  final SyncLocalDataSource _dataSource;
  SyncRepositoryImpl(this._dataSource);

  @override
  Future<Result<List<SyncEntry>>> getPendingEntries() async {
    try {
      final data = await _dataSource.getPendingEntries();
      return Success(data.map(_mapEntry).toList());
    } catch (e) {
      return Error(DatabaseFailure('Failed to get pending entries: $e'));
    }
  }

  @override
  Future<Result<List<SyncEntry>>> getAllEntries() async {
    try {
      final data = await _dataSource.getAllEntries();
      return Success(data.map(_mapEntry).toList());
    } catch (e) {
      return Error(DatabaseFailure('Failed to get sync entries: $e'));
    }
  }

  @override
  Future<Result<void>> addEntry(SyncEntry entry) async {
    try {
      await _dataSource.insertEntry(db.SyncQueueCompanion(
        entityTable: Value(entry.entityTable),
        recordId: Value(entry.recordId),
        operation: Value(entry.operation),
        payloadJson: Value(entry.payloadJson ?? ''),
        status: const Value('PENDING'),
        deviceId: Value(entry.deviceId),
        createdAt: Value(entry.createdAt),
      ));
      return const Success(null);
    } catch (e) {
      return Error(DatabaseFailure('Failed to add sync entry: $e'));
    }
  }

  @override
  Future<Result<void>> markSynced(int id) async {
    try {
      await _dataSource.updateStatus(id);
      return const Success(null);
    } catch (e) {
      return Error(DatabaseFailure('Failed to mark synced: $e'));
    }
  }

  @override
  Future<Result<void>> clearSynced() async {
    try {
      await _dataSource.deleteSynced();
      return const Success(null);
    } catch (e) {
      return Error(DatabaseFailure('Failed to clear synced: $e'));
    }
  }

  SyncEntry _mapEntry(db.SyncQueueData row) {
    return SyncEntry(
      id: row.id,
      entityTable: row.entityTable,
      recordId: row.recordId,
      operation: row.operation,
      payloadJson: row.payloadJson,
      status: row.status,
      deviceId: row.deviceId,
      createdAt: row.createdAt,
      syncedAt: row.syncedAt,
    );
  }
}
