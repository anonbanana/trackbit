import 'package:drift/drift.dart';
import '../../../../core/errors/failure.dart';
import '../../../../core/utils/result.dart';
import '../../domain/repositories/settings_repository.dart';
import '../../domain/entities/receipt_settings.dart';
import '../datasources/settings_local_datasource.dart';
import '../../../../core/database/app_database.dart' as db;

class SettingsRepositoryImpl implements SettingsRepository {
  final SettingsLocalDataSource _dataSource;
  SettingsRepositoryImpl(this._dataSource);

  @override
  Future<Result<ReceiptSettings>> getReceiptSettings() async {
    try {
      final data = await _dataSource.getReceiptSettings();
      if (data == null) return Success(const ReceiptSettings());
      return Success(_mapSettings(data));
    } catch (e) {
      return Error(DatabaseFailure('Failed to load settings: $e'));
    }
  }

  @override
  Future<Result<void>> saveReceiptSettings(ReceiptSettings settings) async {
    try {
      await _dataSource.saveReceiptSettings(db.ReceiptSettingsCompanion(
        id: const Value('default'),
        storeName: Value(settings.storeName),
        storeAddress: Value(settings.storeAddress),
        storePhone: Value(settings.storePhone),
        taxRate: Value(settings.taxRate),
        paperWidth: Value(settings.paperWidth),
        headerText: Value(settings.headerText),
        footerText: Value(settings.footerText),
        logoPath: Value(settings.logoPath),
        showTax: Value(settings.showTax),
        showDiscount: Value(settings.showDiscount),
      ));
      return const Success(null);
    } catch (e) {
      return Error(DatabaseFailure('Failed to save settings: $e'));
    }
  }

  @override
  Future<Result<String?>> getSetting(String key) async {
    try {
      final value = await _dataSource.getSetting(key);
      return Success(value);
    } catch (e) {
      return Error(DatabaseFailure('Failed to get setting: $e'));
    }
  }

  @override
  Future<Result<void>> setSetting(String key, String value) async {
    try {
      await _dataSource.setSetting(key, value);
      return const Success(null);
    } catch (e) {
      return Error(DatabaseFailure('Failed to set setting: $e'));
    }
  }

  ReceiptSettings _mapSettings(db.ReceiptSetting row) {
    return ReceiptSettings(
      id: row.id,
      storeName: row.storeName,
      storeAddress: row.storeAddress,
      storePhone: row.storePhone,
      taxRate: row.taxRate,
      paperWidth: row.paperWidth,
      headerText: row.headerText,
      footerText: row.footerText,
      logoPath: row.logoPath,
      showTax: row.showTax,
      showDiscount: row.showDiscount,
    );
  }
}
