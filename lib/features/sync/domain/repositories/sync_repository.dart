import '../../../../core/utils/result.dart';
import '../entities/sync_entry.dart';

abstract class SyncRepository {
  Future<Result<List<SyncEntry>>> getPendingEntries();
  Future<Result<List<SyncEntry>>> getAllEntries();
  Future<Result<void>> addEntry(SyncEntry entry);
  Future<Result<void>> markSynced(int id);
  Future<Result<void>> clearSynced();
}
