import '../../../../core/utils/result.dart';
import '../entities/receipt_settings.dart';

abstract class SettingsRepository {
  Future<Result<ReceiptSettings>> getReceiptSettings();
  Future<Result<void>> saveReceiptSettings(ReceiptSettings settings);
  Future<Result<String?>> getSetting(String key);
  Future<Result<void>> setSetting(String key, String value);
}
