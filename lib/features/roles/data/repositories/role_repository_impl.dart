import 'package:uuid/uuid.dart';
import '../../../../core/errors/failure.dart';
import '../../../../core/utils/result.dart';
import '../../domain/entities/role.dart';
import '../../domain/entities/permission.dart';
import '../../domain/repositories/role_repository.dart';
import '../datasources/role_local_datasource.dart';

class RoleRepositoryImpl implements RoleRepository {
  final RoleLocalDataSource _dataSource;
  final _uuid = const Uuid();

  RoleRepositoryImpl(this._dataSource);

  @override
  Future<Result<List<Role>>> getAllRoles() async {
    try {
      final roles = await _dataSource.getAllRoles();
      return Success(roles);
    } catch (e) {
      return Error(DatabaseFailure('Failed to load roles: $e'));
    }
  }

  @override
  Future<Result<Role?>> getRoleById(String id) async {
    try {
      final role = await _dataSource.getRoleById(id);
      return Success(role);
    } catch (e) {
      return Error(DatabaseFailure('Failed to load role: $e'));
    }
  }

  @override
  Future<Result<Role>> createRole(Role role) async {
    try {
      await _dataSource.insertRole(role);
      return Success(role);
    } catch (e) {
      return Error(DatabaseFailure('Failed to create role: $e'));
    }
  }

  @override
  Future<Result<Role>> updateRole(Role role) async {
    try {
      await _dataSource.updateRole(role);
      return Success(role);
    } catch (e) {
      return Error(DatabaseFailure('Failed to update role: $e'));
    }
  }

  @override
  Future<Result<void>> deleteRole(String id) async {
    try {
      await _dataSource.deleteRole(id);
      return const Success(null);
    } catch (e) {
      return Error(DatabaseFailure('Failed to delete role: $e'));
    }
  }

  @override
  Future<Result<List<Permission>>> getAllPermissions() async {
    try {
      final permissions = await _dataSource.getAllPermissions();
      return Success(permissions);
    } catch (e) {
      return Error(DatabaseFailure('Failed to load permissions: $e'));
    }
  }

  @override
  Future<Result<List<String>>> getRolePermissionIds(String roleId) async {
    try {
      final ids = await _dataSource.getRolePermissionIds(roleId);
      return Success(ids);
    } catch (e) {
      return Error(DatabaseFailure('Failed to load role permissions: $e'));
    }
  }

  @override
  Future<Result<void>> assignPermissionsToRole(String roleId, List<String> permissionIds) async {
    try {
      await _dataSource.assignPermissionsToRole(roleId, permissionIds);
      return const Success(null);
    } catch (e) {
      return Error(DatabaseFailure('Failed to assign permissions: $e'));
    }
  }

  @override
  Future<Result<void>> initializeDefaultRoles() async {
    try {
      final count = await _dataSource.getRolesCount();
      if (count > 0) {
        return const Success(null);
      }
      final now = DateTime.now();

      final superAdminId = _uuid.v4();
      await _dataSource.insertRole(Role(
        id: superAdminId,
        name: 'super_admin',
        label: 'Super Admin',
        description: 'System administrator with all permissions',
        isSystem: true,
        isCustomizable: false,
        level: 0,
        createdAt: now,
        updatedAt: now,
      ));

      final bossOwnerId = _uuid.v4();
      await _dataSource.insertRole(Role(
        id: bossOwnerId,
        name: 'boss_owner',
        label: 'Boss Owner',
        description: 'Business owner with full access',
        isSystem: true,
        isCustomizable: true,
        level: 1,
        createdAt: now,
        updatedAt: now,
      ));

      final bossCoOwnerId = _uuid.v4();
      await _dataSource.insertRole(Role(
        id: bossCoOwnerId,
        name: 'boss_co_owner',
        label: 'Boss Co-Owner',
        description: 'Co-owner with nearly full access',
        parentRoleId: bossOwnerId,
        isSystem: true,
        isCustomizable: true,
        level: 1,
        createdAt: now,
        updatedAt: now,
      ));

      final storeManagerId = _uuid.v4();
      await _dataSource.insertRole(Role(
        id: storeManagerId,
        name: 'store_manager',
        label: 'Store Manager',
        description: 'Manages day-to-day store operations',
        isSystem: true,
        isCustomizable: true,
        level: 2,
        createdAt: now,
        updatedAt: now,
      ));

      final branchManagerId = _uuid.v4();
      await _dataSource.insertRole(Role(
        id: branchManagerId,
        name: 'branch_manager',
        label: 'Branch Manager',
        description: 'Manages a specific branch',
        isSystem: true,
        isCustomizable: true,
        level: 2,
        createdAt: now,
        updatedAt: now,
      ));

      final accountantId = _uuid.v4();
      await _dataSource.insertRole(Role(
        id: accountantId,
        name: 'employee_accountant',
        label: 'Employee Accountant',
        description: 'Handles accounting and finances',
        isSystem: true,
        isCustomizable: true,
        level: 3,
        createdAt: now,
        updatedAt: now,
      ));

      final cashierId = _uuid.v4();
      await _dataSource.insertRole(Role(
        id: cashierId,
        name: 'employee_cashier',
        label: 'Employee Cashier',
        description: 'Operates the POS and handles sales',
        isSystem: true,
        isCustomizable: true,
        level: 3,
        createdAt: now,
        updatedAt: now,
      ));

      final warehouseId = _uuid.v4();
      await _dataSource.insertRole(Role(
        id: warehouseId,
        name: 'employee_warehouse',
        label: 'Employee Warehouse',
        description: 'Manages inventory and stock',
        isSystem: true,
        isCustomizable: true,
        level: 3,
        createdAt: now,
        updatedAt: now,
      ));

      final salesId = _uuid.v4();
      await _dataSource.insertRole(Role(
        id: salesId,
        name: 'employee_sales',
        label: 'Employee Sales',
        description: 'Handles sales and customer relations',
        isSystem: true,
        isCustomizable: true,
        level: 3,
        createdAt: now,
        updatedAt: now,
      ));

      return const Success(null);
    } catch (e) {
      return Error(DatabaseFailure('Failed to initialize roles: $e'));
    }
  }
}
