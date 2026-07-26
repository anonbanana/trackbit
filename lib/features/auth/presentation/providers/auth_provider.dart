import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/app_user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../data/datasources/auth_local_datasource.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../../../core/database/app_database.dart';
import '../../../../core/utils/storage_service.dart';

final _storage = PlatformStorage();

final authDataSourceProvider = Provider<AuthLocalDataSource>((ref) {
  return AuthLocalDataSource(ref.watch(databaseProvider), _storage);
});

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoryImpl(ref.watch(authDataSourceProvider));
});

enum AuthStatus { initial, loading, authenticated, unauthenticated, error }

class AuthState {
  final AuthStatus status;
  final AppUser? user;
  final String? errorMessage;

  const AuthState({
    this.status = AuthStatus.initial,
    this.user,
    this.errorMessage,
  });

  AuthState copyWith({
    AuthStatus? status,
    AppUser? user,
    String? errorMessage,
  }) {
    return AuthState(
      status: status ?? this.status,
      user: user ?? this.user,
      errorMessage: errorMessage,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  final AuthRepository _authRepository;

  AuthNotifier(this._authRepository) : super(const AuthState()) {
    _checkSession();
  }

  Future<void> _checkSession() async {
    final result = await _authRepository.isLoggedIn();
    result.when(
      success: (loggedIn) async {
        if (loggedIn) {
          final userResult = await _authRepository.getCurrentUser();
          userResult.when(
            success: (user) {
              if (user != null) {
                state = AuthState(status: AuthStatus.authenticated, user: user);
              } else {
                state = const AuthState(status: AuthStatus.unauthenticated);
              }
            },
            error: (failure) {
              state = AuthState(
                status: AuthStatus.error,
                errorMessage: failure.message,
              );
            },
          );
        } else {
          state = const AuthState(status: AuthStatus.unauthenticated);
        }
      },
      error: (failure) {
        state = AuthState(
          status: AuthStatus.error,
          errorMessage: failure.message,
        );
      },
    );
  }

  Future<void> login(String username, String password) async {
    state = state.copyWith(status: AuthStatus.loading);
    final result = await _authRepository.login(username, password);
    result.when(
      success: (user) {
        state = AuthState(status: AuthStatus.authenticated, user: user);
      },
      error: (failure) {
        state = AuthState(
          status: AuthStatus.error,
          errorMessage: failure.message,
        );
      },
    );
  }

  Future<void> register({
    required String username,
    required String password,
    required String fullName,
    required String roleId,
  }) async {
    state = state.copyWith(status: AuthStatus.loading);
    final result = await _authRepository.register(
      username: username,
      password: password,
      fullName: fullName,
      roleId: roleId,
    );
    result.when(
      success: (user) {
        state = AuthState(status: AuthStatus.authenticated, user: user);
      },
      error: (failure) {
        state = AuthState(
          status: AuthStatus.error,
          errorMessage: failure.message,
        );
      },
    );
  }

  Future<void> logout() async {
    await _authRepository.logout();
    state = const AuthState(status: AuthStatus.unauthenticated);
  }

  void clearError() {
    state = state.copyWith(
      errorMessage: null,
      status: AuthStatus.unauthenticated,
    );
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(ref.watch(authRepositoryProvider));
});
