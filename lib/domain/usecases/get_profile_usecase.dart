import '../entities/user.dart';
import '../repositories/profile_repository.dart';

class GetProfileUseCase {
  final ProfileRepository repository;

  GetProfileUseCase({required this.repository});

  Future<User> call({bool forceRefresh = false}) async {
    return await repository.getProfile(forceRefresh: forceRefresh);
  }
}
