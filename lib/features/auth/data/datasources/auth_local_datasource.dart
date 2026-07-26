import 'package:drift/drift.dart';
import '../../../../core/database/app_database.dart' as db;
import '../../../../core/utils/storage_service.dart';
import '../../domain/entities/app_user.dart';

class AuthLocalDataSource {
  final db.AppDatabase _database;
  final StorageService _storage;

  AuthLocalDataSource(this._database, this._storage);

  Future<AppUser?> getUserByUsername(String username) async {
    final result = await (_database.select(
      _database.users,
    )..where((t) => t.username.equals(username))).getSingleOrNull();
    if (result == null) return null;
    return _mapUser(result);
  }

  Future<AppUser?> getUserById(String id) async {
    final result = await (_database.select(
      _database.users,
    )..where((t) => t.id.equals(id))).getSingleOrNull();
    if (result == null) return null;
    return _mapUser(result);
  }

  Future<void> insertUser({
    required String id,
    required String username,
    required String passwordHash,
    required String fullName,
    required String roleId,
  }) async {
    await _database
        .into(_database.users)
        .insert(
          db.UsersCompanion(
            id: Value(id),
            username: Value(username),
            passwordHash: Value(passwordHash),
            fullName: Value(fullName),
            roleId: Value(roleId),
            createdAt: Value(DateTime.now()),
            updatedAt: Value(DateTime.now()),
          ),
        );
  }

  Future<List<AppUser>> getAllUsers() async {
    final results = await _database.select(_database.users).get();
    return results.map(_mapUser).toList();
  }

  Future<void> updateUser(AppUser user) async {
    await (_database.update(
      _database.users,
    )..where((t) => t.id.equals(user.id))).write(
      db.UsersCompanion(
        username: Value(user.username),
        fullName: Value(user.fullName),
        roleId: Value(user.roleId),
        isActive: Value(user.isActive),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  Future<void> deleteUser(String id) async {
    await (_database.delete(
      _database.users,
    )..where((t) => t.id.equals(id))).go();
  }

  Future<void> saveSession(String userId) async {
    await _storage.write('session_user_id', userId);
  }

  Future<String?> getSessionUserId() async {
    return await _storage.read('session_user_id');
  }

  Future<void> clearSession() async {
    await _storage.delete('session_user_id');
  }

  Future<String?> getPasswordHash(String userId) async {
    final result = await (_database.select(
      _database.users,
    )..where((t) => t.id.equals(userId))).getSingleOrNull();
    return result?.passwordHash;
  }

  Future<void> updatePasswordHash(String userId, String hash) async {
    await (_database.update(
      _database.users,
    )..where((t) => t.id.equals(userId))).write(
      db.UsersCompanion(
        passwordHash: Value(hash),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  AppUser _mapUser(db.User row) {
    return AppUser(
      id: row.id,
      username: row.username,
      fullName: row.fullName,
      roleId: row.roleId,
      isActive: row.isActive,
      createdAt: row.createdAt,
      updatedAt: row.updatedAt,
    );
  }
}
