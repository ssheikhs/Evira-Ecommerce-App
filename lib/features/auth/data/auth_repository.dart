import '../../../core/network/api_exceptions.dart';
import '../../../core/storage/preference_service.dart';
import '../models/user_model.dart';
import 'auth_remote_datasource.dart';

abstract class AuthRepository {
  /// The user saved on the device, if any (no network call).
  UserModel? getSavedUser();

  Future<UserModel> login({required String username, required String password});

  /// Checks the saved token with the server and returns the fresh profile.
  /// Returns `null` when the session has expired.
  Future<UserModel?> refreshSession();

  Future<void> logout();
}

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  final PreferenceService preferenceService;

  AuthRepositoryImpl({
    required this.remoteDataSource,
    required this.preferenceService,
  });

  @override
  UserModel? getSavedUser() {
    final token = preferenceService.getAuthToken();
    final data = preferenceService.getUser();
    if (token == null || token.isEmpty || data == null) return null;
    return UserModel.fromMap(data);
  }

  @override
  Future<UserModel> login({
    required String username,
    required String password,
  }) async {
    final data = await remoteDataSource.login(
      username: username,
      password: password,
    );

    final token = data['accessToken']?.toString() ?? '';
    if (token.isEmpty) {
      throw const ServerException('Sign-in failed: no access token received.');
    }
    await preferenceService.saveAuthToken(token);

    var user = UserModel.fromMap(data);
    // Login has no address or phone, so fetch the full profile once.
    try {
      final profile = UserModel.fromMap(
        await remoteDataSource.getCurrentUser(),
      );
      user = profile.mergeMissing(user);
    } catch (_) {
      // The basic profile from login is still enough to continue.
    }

    await preferenceService.saveUser(user.toMap());
    return user;
  }

  @override
  Future<UserModel?> refreshSession() async {
    final saved = getSavedUser();
    if (saved == null) return null;

    try {
      final fresh = UserModel.fromMap(await remoteDataSource.getCurrentUser());
      final merged = fresh.mergeMissing(saved);
      await preferenceService.saveUser(merged.toMap());
      return merged;
    } on UnauthorizedException {
      await logout();
      return null;
    } catch (_) {
      // Offline or server problem: keep the user signed in with saved data.
      return saved;
    }
  }

  @override
  Future<void> logout() => preferenceService.clearSession();
}
