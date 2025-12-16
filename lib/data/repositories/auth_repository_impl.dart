import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_local_data_source.dart';
import '../datasources/auth_remote_data_source.dart';
import '../models/login_request.dart';
import '../models/register_request.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  final AuthLocalDataSource localDataSource;

  AuthRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  @override
  Future<User> login(String email, String password) async {
    try {
      final request = LoginRequest(email: email, password: password);
      final userModel = await remoteDataSource.login(request);

      // Save user data locally
      await localDataSource.saveUser(userModel);

      return userModel.toEntity();
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<User> register(String username, String email, String password) async {
    try {
      final request = RegisterRequest(
        username: username,
        email: email,
        password: password,
      );
      final userModel = await remoteDataSource.register(request);

      // Save user data locally
      await localDataSource.saveUser(userModel);

      return userModel.toEntity();
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> logout() async {
    try {
      await localDataSource.clearUser();
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<bool> isLoggedIn() async {
    try {
      return await localDataSource.isLoggedIn();
    } catch (e) {
      return false;
    }
  }

  @override
  Future<String?> getToken() async {
    try {
      return await localDataSource.getToken();
    } catch (e) {
      return null;
    }
  }

  @override
  Future<User?> getCurrentUser() async {
    try {
      final userModel = await localDataSource.getSavedUser();
      return userModel?.toEntity();
    } catch (e) {
      return null;
    }
  }
}
