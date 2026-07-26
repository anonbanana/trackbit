import 'dart:convert';
import 'dart:developer' as developer;
import 'package:crypto/crypto.dart';
import 'package:drift/drift.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:uuid/uuid.dart';
import 'app.dart';
import 'core/constants/app_constants.dart';
import 'core/database/app_database.dart';
import 'core/database/default_permissions.dart';
import 'features/roles/presentation/providers/role_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SentryFlutter.init((options) {
    options.dsn = const String.fromEnvironment('SENTRY_DSN', defaultValue: '');
    options.tracesSampleRate = 1.0;
    options.profilesSampleRate = 1.0;
    options.debug = false;
  }, appRunner: () => _runApp());
}

Future<void> _runApp() async {
  final container = ProviderContainer();
  final db = container.read(databaseProvider);

  try {
    await DefaultPermissions.initialize(db);
    await container.read(initializeDefaultRolesProvider.future);
    await _seedAdminUser(db);
  } catch (e, stackTrace) {
    developer.log('Initialization error: $e');
    await Sentry.captureException(e, stackTrace: stackTrace);
  }

  runApp(
    UncontrolledProviderScope(container: container, child: const TrackBitApp()),
  );
}

Future<void> _seedAdminUser(AppDatabase db) async {
  final userCount = await db.select(db.users).get().then((r) => r.length);
  if (userCount > 0) return;

  final roles = await db.select(db.roles).get();
  final adminRole = roles.where((r) => r.name == 'super_admin').firstOrNull;
  if (adminRole == null) return;

  final bytes = utf8.encode(AppConstants.defaultAdminPassword);
  final hash = sha256.convert(bytes).toString();
  final now = DateTime.now().toUtc();

  await db
      .into(db.users)
      .insert(
        UsersCompanion(
          id: Value(const Uuid().v4()),
          username: const Value(AppConstants.defaultAdminUsername),
          passwordHash: Value(hash),
          fullName: const Value('Administrator'),
          roleId: Value(adminRole.id),
          isActive: const Value(true),
          createdAt: Value(now),
          updatedAt: Value(now),
        ),
      );
}
