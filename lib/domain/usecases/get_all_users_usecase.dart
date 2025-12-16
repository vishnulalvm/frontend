import '../entities/user.dart';
import '../repositories/users_repository.dart';

class GetAllUsersUseCase {
  final UsersRepository repository;

  GetAllUsersUseCase({required this.repository});

  Future<List<User>> call({bool forceRefresh = false}) async {
    return await repository.getAllUsers(forceRefresh: forceRefresh);
  }
}
