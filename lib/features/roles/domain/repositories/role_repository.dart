import '../../../../core/utils/result.dart';
import '../entities/role.dart';
import '../entities/permission.dart';

abstract class RoleRepository {
  Future<Result<List<Role>>> getAllRoles();
  Future<Result<Role?>> getRoleById(String id);
  Future<Result<Role>> createRole(Role role);
  Future<Result<Role>> updateRole(Role role);
  Future<Result<void>> deleteRole(String id);
  Future<Result<List<Permission>>> getAllPermissions();
  Future<Result<List<String>>> getRolePermissionIds(String roleId);
  Future<Result<void>> assignPermissionsToRole(String roleId, List<String> permissionIds);
  Future<Result<void>> initializeDefaultRoles();
}
