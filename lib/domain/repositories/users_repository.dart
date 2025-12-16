import '../entities/user.dart';

abstract class UsersRepository {
  Future<List<User>> getAllUsers({bool forceRefresh = false});
  Future<List<User>> getSelectedUsers();
  Future<void> selectUser(String userId);
  Future<void> unselectUser(String userId);
  Future<bool> isUserSelected(String userId);
}
