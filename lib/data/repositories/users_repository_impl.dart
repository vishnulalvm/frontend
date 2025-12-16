import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/repositories/users_repository.dart';
import '../datasources/users_local_data_source.dart';
import '../datasources/users_remote_data_source.dart';

class UsersRepositoryImpl implements UsersRepository {
  final UsersRemoteDataSource remoteDataSource;
  final UsersLocalDataSource localDataSource;
  final AuthRepository authRepository;

  UsersRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.authRepository,
  });

  @override
  Future<List<User>> getAllUsers({bool forceRefresh = false}) async {
    try {
      // Always try to fetch fresh data in background
      final token = await authRepository.getToken();
      if (token == null || token.isEmpty) {
        throw Exception('No authentication token found. Please login again.');
      }

      // If not force refresh, return cached data first
      if (!forceRefresh) {
        final cachedUsers = await localDataSource.getCachedUsers();
        if (cachedUsers != null && cachedUsers.isNotEmpty) {
          // Return cached data immediately and fetch in background
          _fetchAndCacheInBackground(token);
          return cachedUsers.map((model) => model.toEntity()).toList();
        }
      }

      // Fetch from API
      final usersModel = await remoteDataSource.getAllUsers(token);

      // Cache the users
      await localDataSource.cacheUsers(usersModel);

      return usersModel.map((model) => model.toEntity()).toList();
    } catch (e) {
      // If API call fails, try to return cached data
      if (!forceRefresh) {
        final cachedUsers = await localDataSource.getCachedUsers();
        if (cachedUsers != null && cachedUsers.isNotEmpty) {
          return cachedUsers.map((model) => model.toEntity()).toList();
        }
      }
      rethrow;
    }
  }

  Future<void> _fetchAndCacheInBackground(String token) async {
    try {
      final usersModel = await remoteDataSource.getAllUsers(token);
      await localDataSource.cacheUsers(usersModel);
    } catch (e) {
      // Silently fail background refresh
    }
  }

  @override
  Future<List<User>> getSelectedUsers() async {
    try {
      final selectedIds = await localDataSource.getSelectedUserIds();
      final allUsers = await localDataSource.getCachedUsers();

      if (allUsers == null) return [];

      final selectedUsers = allUsers
          .where((user) => selectedIds.contains(user.id))
          .map((model) => model.toEntity())
          .toList();

      return selectedUsers;
    } catch (e) {
      return [];
    }
  }

  @override
  Future<void> selectUser(String userId) async {
    try {
      await localDataSource.saveSelectedUserId(userId);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> unselectUser(String userId) async {
    try {
      await localDataSource.removeSelectedUserId(userId);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<bool> isUserSelected(String userId) async {
    try {
      return await localDataSource.isUserSelected(userId);
    } catch (e) {
      return false;
    }
  }
}
