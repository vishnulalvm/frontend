import '../entities/user.dart';

abstract class ProfileRepository {
  Future<User> getProfile({bool forceRefresh = false});
  Future<void> clearProfileCache();
}
