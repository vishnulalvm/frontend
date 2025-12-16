import '../entities/user.dart';
import '../repositories/users_repository.dart';

class GetSelectedUsersUseCase {
  final UsersRepository repository;

  GetSelectedUsersUseCase({required this.repository});

  Future<List<User>> call() async {
    return await repository.getSelectedUsers();
  }
}
