import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/datasources/settings_local_datasource.dart';
import '../../data/repositories/settings_repository_impl.dart';
import '../../domain/repositories/settings_repository.dart';
import '../../domain/entities/receipt_settings.dart' as domain;
import '../../../../core/database/app_database.dart';

final settingsDataSourceProvider = Provider<SettingsLocalDataSource>((ref) {
  return SettingsLocalDataSource(ref.watch(databaseProvider));
});

final settingsRepositoryProvider = Provider<SettingsRepository>((ref) {
  return SettingsRepositoryImpl(ref.watch(settingsDataSourceProvider));
});

final receiptSettingsProvider = FutureProvider<domain.ReceiptSettings>((
  ref,
) async {
  final result = await ref
      .watch(settingsRepositoryProvider)
      .getReceiptSettings();
  return result.when(
    success: (d) => d,
    error: (f) => throw Exception(f.message),
  );
});
