import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/constants/api_constants.dart';
import '../models/user_model.dart';

abstract class ProfileLocalDataSource {
  Future<UserModel?> getCachedProfile();
  Future<void> cacheProfile(UserModel profile);
  Future<void> clearCache();
  Future<bool> isCacheValid();
}

class ProfileLocalDataSourceImpl implements ProfileLocalDataSource {
  final SharedPreferences sharedPreferences;
  static const String _cachedProfileKey = 'cached_profile';
  static const String _cacheTimeKey = 'profile_cache_time';

  ProfileLocalDataSourceImpl({required this.sharedPreferences});

  @override
  Future<UserModel?> getCachedProfile() async {
    try {
      final profileJson = sharedPreferences.getString(_cachedProfileKey);
      if (profileJson != null) {
        final Map<String, dynamic> profileMap = json.decode(profileJson);
        return UserModel.fromJson(profileMap);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  @override
  Future<void> cacheProfile(UserModel profile) async {
    final profileJson = json.encode(profile.toJson());
    await sharedPreferences.setString(_cachedProfileKey, profileJson);
    await sharedPreferences.setString(
      _cacheTimeKey,
      DateTime.now().toIso8601String(),
    );
  }

  @override
  Future<void> clearCache() async {
    await sharedPreferences.remove(_cachedProfileKey);
    await sharedPreferences.remove(_cacheTimeKey);
  }

  @override
  Future<bool> isCacheValid() async {
    final cacheTimeString = sharedPreferences.getString(_cacheTimeKey);
    if (cacheTimeString == null) return false;

    try {
      final cacheTime = DateTime.parse(cacheTimeString);
      final now = DateTime.now();
      final difference = now.difference(cacheTime);

      return difference < ApiConstants.cacheValidDuration;
    } catch (e) {
      return false;
    }
  }
}
