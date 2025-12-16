import '../repositories/users_repository.dart';

class SelectUserUseCase {
  final UsersRepository repository;

  SelectUserUseCase({required this.repository});

  Future<void> call(String userId) async {
    return await repository.selectUser(userId);
  }
}
