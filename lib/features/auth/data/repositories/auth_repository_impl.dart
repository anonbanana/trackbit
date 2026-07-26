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
        return const Error(AuthFailure('Invalid username or password'));
      }
      final passwordHash = _hashPassword(password);
      final storedHash = await _dataSource.getPasswordHash(user.id);
      if (storedHash == null || passwordHash != storedHash) {
        return const Error(AuthFailure('Invalid username or password'));
      }
      if (!user.isActive) {
        return const Error(AuthFailure('User account is disabled'));
      }
      await _dataSource.saveSession(user.id);
      return Success(user);
    } catch (e) {
      return const Error(AuthFailure('Login failed'));
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
        return const Error(AuthFailure('Username already exists'));
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
      if (user == null) {
        return const Error(AuthFailure('Registration failed'));
      }
      return Success(user);
    } catch (e) {
      return const Error(AuthFailure('Registration failed'));
    }
  }

  @override
  Future<Result<void>> logout() async {
    try {
      await _dataSource.clearSession();
      return const Success(null);
    } catch (e) {
      return const Error(AuthFailure('Logout failed'));
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
      return const Error(AuthFailure('Failed to get current user'));
    }
  }

  @override
  Future<Result<bool>> isLoggedIn() async {
    try {
      final userId = await _dataSource.getSessionUserId();
      return Success(userId != null);
    } catch (e) {
      return const Error(AuthFailure('Failed to check login status'));
    }
  }

  @override
  Future<Result<List<AppUser>>> getAllUsers() async {
    try {
      final users = await _dataSource.getAllUsers();
      return Success(users);
    } catch (e) {
      return const Error(AuthFailure('Failed to get users'));
    }
  }

  @override
  Future<Result<void>> updateUser(AppUser user) async {
    try {
      await _dataSource.updateUser(user);
      return const Success(null);
    } catch (e) {
      return const Error(AuthFailure('Failed to update user'));
    }
  }

  @override
  Future<Result<void>> deleteUser(String id) async {
    try {
      await _dataSource.deleteUser(id);
      return const Success(null);
    } catch (e) {
      return const Error(AuthFailure('Failed to delete user'));
    }
  }

  @override
  Future<Result<void>> changePassword(
    String userId,
    String currentPassword,
    String newPassword,
  ) async {
    try {
      final storedHash = await _dataSource.getPasswordHash(userId);
      if (storedHash == null) {
        return const Error(AuthFailure('User not found'));
      }
      if (_hashPassword(currentPassword) != storedHash) {
        return const Error(AuthFailure('Current password is incorrect'));
      }
      final newHash = _hashPassword(newPassword);
      await _dataSource.updatePasswordHash(userId, newHash);
      return const Success(null);
    } catch (e) {
      return const Error(AuthFailure('Failed to change password'));
    }
  }

  String _hashPassword(String password) {
    final bytes = utf8.encode(password);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }
}
