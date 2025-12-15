import 'package:shared_preferences/shared_preferences.dart';
import '../../core/constants/storage_keys.dart';
import '../models/user_model.dart';

abstract class AuthLocalDataSource {
  Future<void> saveUser(UserModel user);
  Future<String?> getToken();
  Future<void> clearUser();
  Future<bool> isLoggedIn();
}

class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  final SharedPreferences sharedPreferences;

  AuthLocalDataSourceImpl({required this.sharedPreferences});

  @override
  Future<void> saveUser(UserModel user) async {
    await sharedPreferences.setString(StorageKeys.token, user.token);
    await sharedPreferences.setString(StorageKeys.userId, user.id);
    await sharedPreferences.setString(StorageKeys.username, user.username);
    await sharedPreferences.setString(StorageKeys.userEmail, user.email);
    await sharedPreferences.setString(StorageKeys.userAvatar, user.avatar);
    await sharedPreferences.setString(StorageKeys.userStatus, user.status);
  }

  @override
  Future<String?> getToken() async {
    return sharedPreferences.getString(StorageKeys.token);
  }

  @override
  Future<void> clearUser() async {
    await sharedPreferences.remove(StorageKeys.token);
    await sharedPreferences.remove(StorageKeys.userId);
    await sharedPreferences.remove(StorageKeys.username);
    await sharedPreferences.remove(StorageKeys.userEmail);
    await sharedPreferences.remove(StorageKeys.userAvatar);
    await sharedPreferences.remove(StorageKeys.userStatus);
  }

  @override
  Future<bool> isLoggedIn() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }
}
