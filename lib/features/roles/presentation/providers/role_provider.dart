import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/datasources/role_local_datasource.dart';
import '../../data/repositories/role_repository_impl.dart';
import '../../domain/entities/role.dart' as domain;
import '../../domain/entities/permission.dart' as domain;
import '../../domain/repositories/role_repository.dart';
import '../../../../core/database/app_database.dart';

final roleDataSourceProvider = Provider<RoleLocalDataSource>((ref) {
  return RoleLocalDataSource(ref.watch(databaseProvider));
});

final roleRepositoryProvider = Provider<RoleRepository>((ref) {
  return RoleRepositoryImpl(ref.watch(roleDataSourceProvider));
});

final rolesProvider = FutureProvider<List<domain.Role>>((ref) async {
  final result = await ref.watch(roleRepositoryProvider).getAllRoles();
  return result.when(
    success: (roles) => roles,
    error: (failure) => throw Exception(failure.message),
  );
});

final permissionsProvider = FutureProvider<List<domain.Permission>>((ref) async {
  final result = await ref.watch(roleRepositoryProvider).getAllPermissions();
  return result.when(
    success: (permissions) => permissions,
    error: (failure) => throw Exception(failure.message),
  );
});

final rolePermissionIdsProvider = FutureProvider.family<List<String>, String>((ref, roleId) async {
  final result = await ref.watch(roleRepositoryProvider).getRolePermissionIds(roleId);
  return result.when(
    success: (ids) => ids,
    error: (failure) => throw Exception(failure.message),
  );
});

final initializeDefaultRolesProvider = FutureProvider<void>((ref) async {
  final result = await ref.watch(roleRepositoryProvider).initializeDefaultRoles();
  result.when(
    success: (_) {},
    error: (failure) => throw Exception(failure.message),
  );
});
