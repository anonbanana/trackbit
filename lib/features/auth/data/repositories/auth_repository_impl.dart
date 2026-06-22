import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/errors/failure.dart';
import '../../../../core/utils/result.dart';
import '../../domain/entities/app_user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_local_datasource.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthLocalDataSource _dataSource;
  final _uuid = const Uuid();

  AuthRepositoryImpl(this._dataSource);

  @override
  Future<Result<AppUser>> login(String username, String password) async {
    try {
      final user = await _dataSource.getUserByUsername(username);
      if (user == null) {
        return Error(const AuthFailure('User not found'));
      }
      final passwordHash = _hashPassword(password);
      if (passwordHash != user.passwordHash) {
        return Error(const AuthFailure('Invalid password'));
      }
      if (!user.isActive) {
        return Error(const AuthFailure('User account is disabled'));
      }
      await _dataSource.saveSession(user.id);
      return Success(user);
    } catch (e) {
      return Error(AuthFailure('Login failed: $e'));
    }
  }

  @override
  Future<Result<AppUser>> register({
    required String username,
    required String password,
    required String fullName,
    required String roleId,
  }) async {
    try {
      final existing = await _dataSource.getUserByUsername(username);
      if (existing != null) {
        return Error(const AuthFailure('Username already exists'));
      }
      final id = _uuid.v4();
      final passwordHash = _hashPassword(password);
      await _dataSource.insertUser(
        id: id,
        username: username,
        passwordHash: passwordHash,
        fullName: fullName,
        roleId: roleId,
      );
      final user = await _dataSource.getUserById(id);
      return Success(user!);
    } catch (e) {
      return Error(AuthFailure('Registration failed: $e'));
    }
  }

  @override
  Future<Result<void>> logout() async {
    try {
      await _dataSource.clearSession();
      return const Success(null);
    } catch (e) {
      return Error(AuthFailure('Logout failed: $e'));
    }
  }

  @override
  Future<Result<AppUser?>> getCurrentUser() async {
    try {
      final userId = await _dataSource.getSessionUserId();
      if (userId == null) {
        return const Success(null);
      }
      final user = await _dataSource.getUserById(userId);
      return Success(user);
    } catch (e) {
      return Error(AuthFailure('Failed to get current user: $e'));
    }
  }

  @override
  Future<Result<bool>> isLoggedIn() async {
    try {
      final userId = await _dataSource.getSessionUserId();
      return Success(userId != null);
    } catch (e) {
      return Error(AuthFailure('Failed to check login status: $e'));
    }
  }

  @override
  Future<Result<List<AppUser>>> getAllUsers() async {
    try {
      final users = await _dataSource.getAllUsers();
      return Success(users);
    } catch (e) {
      return Error(AuthFailure('Failed to get users: $e'));
    }
  }

  @override
  Future<Result<void>> updateUser(AppUser user) async {
    try {
      await _dataSource.updateUser(user);
      return const Success(null);
    } catch (e) {
      return Error(AuthFailure('Failed to update user: $e'));
    }
  }

  @override
  Future<Result<void>> deleteUser(String id) async {
    try {
      await _dataSource.deleteUser(id);
      return const Success(null);
    } catch (e) {
      return Error(AuthFailure('Failed to delete user: $e'));
    }
  }

  String _hashPassword(String password) {
    final bytes = utf8.encode(password);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }
}
