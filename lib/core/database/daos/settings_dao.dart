import 'package:drift/drift.dart';
import '../app_database.dart';

class SettingsDao {
  final AppDatabase _db;
  SettingsDao(this._db);

  Future<String?> getSetting(String key) async {
    final result = await (_db.select(_db.appSettings)
      ..where((t) => t.key.equals(key)))
      .getSingleOrNull();
    return result?.value;
  }

  Future<void> setSetting(String key, String value) async {
    await (_db.into(_db.appSettings).insertOnConflictUpdate(
      AppSettingsCompanion(key: Value(key), value: Value(value)),
    ));
  }

  Future<void> deleteSetting(String key) async {
    await (_db.delete(_db.appSettings)
      ..where((t) => t.key.equals(key)))
      .go();
  }
}
