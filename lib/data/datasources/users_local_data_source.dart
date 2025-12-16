import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';

abstract class UsersLocalDataSource {
  Future<List<UserModel>?> getCachedUsers();
  Future<void> cacheUsers(List<UserModel> users);
  Future<void> clearCache();

  Future<List<String>> getSelectedUserIds();
  Future<void> saveSelectedUserId(String userId);
  Future<void> removeSelectedUserId(String userId);
  Future<bool> isUserSelected(String userId);
}

class UsersLocalDataSourceImpl implements UsersLocalDataSource {
  final SharedPreferences sharedPreferences;
  static const String _cachedUsersKey = 'cached_users_list';
  static const String _selectedUsersKey = 'selected_user_ids';

  UsersLocalDataSourceImpl({required this.sharedPreferences});

  @override
  Future<List<UserModel>?> getCachedUsers() async {
    try {
      final usersJson = sharedPreferences.getString(_cachedUsersKey);
      if (usersJson != null) {
        final List<dynamic> usersList = json.decode(usersJson);
        return usersList
            .map((json) => UserModel.fromJson(json as Map<String, dynamic>))
            .toList();
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  @override
  Future<void> cacheUsers(List<UserModel> users) async {
    final usersJson = json.encode(users.map((u) => u.toJson()).toList());
    await sharedPreferences.setString(_cachedUsersKey, usersJson);
  }

  @override
  Future<void> clearCache() async {
    await sharedPreferences.remove(_cachedUsersKey);
  }

  @override
  Future<List<String>> getSelectedUserIds() async {
    return sharedPreferences.getStringList(_selectedUsersKey) ?? [];
  }

  @override
  Future<void> saveSelectedUserId(String userId) async {
    final selectedIds = await getSelectedUserIds();
    if (!selectedIds.contains(userId)) {
      selectedIds.add(userId);
      await sharedPreferences.setStringList(_selectedUsersKey, selectedIds);
    }
  }

  @override
  Future<void> removeSelectedUserId(String userId) async {
    final selectedIds = await getSelectedUserIds();
    selectedIds.remove(userId);
    await sharedPreferences.setStringList(_selectedUsersKey, selectedIds);
  }

  @override
  Future<bool> isUserSelected(String userId) async {
    final selectedIds = await getSelectedUserIds();
    return selectedIds.contains(userId);
  }
}
