import 'package:drift/drift.dart';
import '../../../../core/database/app_database.dart' as db;
import '../../domain/entities/role.dart' as domain;
import '../../domain/entities/permission.dart' as domain;

class RoleLocalDataSource {
  final db.AppDatabase _database;

  RoleLocalDataSource(this._database);

  Future<List<domain.Role>> getAllRoles() async {
    final results = await _database.select(_database.roles).get();
    return results.map(_mapRole).toList();
  }

  Future<domain.Role?> getRoleById(String id) async {
    final result = await (_database.select(_database.roles)
      ..where((t) => t.id.equals(id)))
      .getSingleOrNull();
    return result != null ? _mapRole(result) : null;
  }

  Future<void> insertRole(domain.Role role) async {
    await _database.into(_database.roles).insert(db.RolesCompanion(
      id: Value(role.id),
      name: Value(role.name),
      label: Value(role.label),
      description: Value(role.description),
      parentRoleId: Value(role.parentRoleId),
      isSystem: Value(role.isSystem),
      isCustomizable: Value(role.isCustomizable),
      level: Value(role.level),
      createdAt: Value(role.createdAt),
      updatedAt: Value(role.updatedAt),
    ));
  }

  Future<void> updateRole(domain.Role role) async {
    await (_database.update(_database.roles)
      ..where((t) => t.id.equals(role.id)))
      .write(db.RolesCompanion(
        name: Value(role.name),
        label: Value(role.label),
        description: Value(role.description),
        parentRoleId: Value(role.parentRoleId),
        isCustomizable: Value(role.isCustomizable),
        level: Value(role.level),
        updatedAt: Value(DateTime.now()),
      ));
  }

  Future<void> deleteRole(String id) async {
    await (_database.delete(_database.roles)
      ..where((t) => t.id.equals(id)))
      .go();
  }

  Future<List<domain.Permission>> getAllPermissions() async {
    final results = await _database.select(_database.permissions).get();
    return results.map((p) => domain.Permission(
      id: p.id,
      label: p.label,
      groupName: p.groupName,
      description: p.description,
    )).toList();
  }

  Future<List<String>> getRolePermissionIds(String roleId) async {
    final results = await (_database.select(_database.rolePermissions)
      ..where((t) => t.roleId.equals(roleId)))
      .get();
    return results.map((rp) => rp.permissionId).toList();
  }

  Future<void> assignPermissionsToRole(String roleId, List<String> permissionIds) async {
    await _database.transaction(() async {
      await (_database.delete(_database.rolePermissions)
        ..where((t) => t.roleId.equals(roleId)))
        .go();
      for (final permId in permissionIds) {
        await _database.into(_database.rolePermissions).insert(db.RolePermissionsCompanion(
          roleId: Value(roleId),
          permissionId: Value(permId),
        ));
      }
    });
  }

  Future<int> getRolesCount() async {
    return await _database.select(_database.roles).get().then((r) => r.length);
  }

  domain.Role _mapRole(db.Role row) {
    return domain.Role(
      id: row.id,
      name: row.name,
      label: row.label,
      description: row.description,
      parentRoleId: row.parentRoleId,
      isSystem: row.isSystem,
      isCustomizable: row.isCustomizable,
      level: row.level,
      createdAt: row.createdAt,
      updatedAt: row.updatedAt,
    );
  }
}
