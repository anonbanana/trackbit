import '../../../../core/utils/result.dart';
import '../entities/app_user.dart';

abstract class AuthRepository {
  Future<Result<AppUser>> login(String username, String password);
  Future<Result<AppUser>> register({
    required String username,
    required String password,
    required String fullName,
    required String roleId,
  });
  Future<Result<void>> logout();
  Future<Result<AppUser?>> getCurrentUser();
  Future<Result<bool>> isLoggedIn();
  Future<Result<List<AppUser>>> getAllUsers();
  Future<Result<void>> updateUser(AppUser user);
  Future<Result<void>> deleteUser(String id);
  Future<Result<void>> changePassword(
    String userId,
    String currentPassword,
    String newPassword,
  );
}
