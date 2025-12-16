import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/repositories/profile_repository.dart';
import '../datasources/profile_local_data_source.dart';
import '../datasources/profile_remote_data_source.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  final ProfileRemoteDataSource remoteDataSource;
  final ProfileLocalDataSource localDataSource;
  final AuthRepository authRepository;

  ProfileRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.authRepository,
  });

  @override
  Future<User> getProfile({bool forceRefresh = false}) async {
    try {
      // Check if we should use cached data
      if (!forceRefresh) {
        final isCacheValid = await localDataSource.isCacheValid();
        if (isCacheValid) {
          final cachedProfile = await localDataSource.getCachedProfile();
          if (cachedProfile != null) {
            return cachedProfile.toEntity();
          }
        }
      }

      // Get token from auth repository
      final token = await authRepository.getToken();
      if (token == null || token.isEmpty) {
        throw Exception('No authentication token found. Please login again.');
      }

      // Fetch from API
      final profileModel = await remoteDataSource.getProfile(token);

      // Cache the profile
      await localDataSource.cacheProfile(profileModel);

      return profileModel.toEntity();
    } catch (e) {
      // If API call fails, try to return cached data
      if (!forceRefresh) {
        final cachedProfile = await localDataSource.getCachedProfile();
        if (cachedProfile != null) {
          return cachedProfile.toEntity();
        }
      }
      rethrow;
    }
  }

  @override
  Future<void> clearProfileCache() async {
    try {
      await localDataSource.clearCache();
    } catch (e) {
      rethrow;
    }
  }
}
