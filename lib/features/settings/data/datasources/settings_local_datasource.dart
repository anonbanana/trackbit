import 'package:drift/drift.dart';
import '../../../../core/database/app_database.dart' as db;

class SettingsLocalDataSource {
  final db.AppDatabase _database;
  SettingsLocalDataSource(this._database);

  Future<db.ReceiptSetting?> getReceiptSettings() async {
    return await (_database.select(
      _database.receiptSettings,
    )..where((t) => t.id.equals('default'))).getSingleOrNull();
  }

  Future<void> saveReceiptSettings(db.ReceiptSettingsCompanion settings) async {
    await _database
        .into(_database.receiptSettings)
        .insertOnConflictUpdate(settings);
  }

  Future<String?> getSetting(String key) async {
    final result = await (_database.select(
      _database.appSettings,
    )..where((t) => t.key.equals(key))).getSingleOrNull();
    return result?.value;
  }

  Future<void> setSetting(String key, String value) async {
    await _database
        .into(_database.appSettings)
        .insertOnConflictUpdate(
          db.AppSettingsCompanion(key: Value(key), value: Value(value)),
        );
  }
}
