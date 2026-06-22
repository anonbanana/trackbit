import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app.dart';
import 'core/database/app_database.dart';
import 'core/database/default_permissions.dart';
import 'features/roles/presentation/providers/role_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final container = ProviderContainer();
  final db = container.read(databaseProvider);

  try {
    await DefaultPermissions.initialize(db);
    await container.read(initializeDefaultRolesProvider.future);
  } catch (e) {
    debugPrint('Initialization error: $e');
  }

  runApp(
    UncontrolledProviderScope(
      container: container,
      child: const TrackBitApp(),
    ),
  );
}
