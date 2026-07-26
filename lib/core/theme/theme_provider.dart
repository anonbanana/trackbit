import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/settings/data/datasources/settings_local_datasource.dart';
import '../../core/database/app_database.dart';

final themeModeProvider = StateNotifierProvider<ThemeModeNotifier, ThemeMode>((
  ref,
) {
  return ThemeModeNotifier(ref);
});

class ThemeModeNotifier extends StateNotifier<ThemeMode> {
  final Ref _ref;
  ThemeModeNotifier(this._ref) : super(ThemeMode.light) {
    _load();
  }

  Future<void> _load() async {
    try {
      final ds = SettingsLocalDataSource(_ref.read(databaseProvider));
      final value = await ds.getSetting('theme_mode');
      if (value == 'dark') {
        state = ThemeMode.dark;
      } else {
        state = ThemeMode.light;
      }
    } catch (_) {
      state = ThemeMode.light;
    }
  }

  Future<void> toggle() async {
    final newMode = state == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    state = newMode;
    try {
      final ds = SettingsLocalDataSource(_ref.read(databaseProvider));
      await ds.setSetting(
        'theme_mode',
        newMode == ThemeMode.dark ? 'dark' : 'light',
      );
    } catch (_) {}
  }
}
