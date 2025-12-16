import '../entities/message.dart';
import '../repositories/chat_repository.dart';

class GetChatHistoryUseCase {
  final ChatRepository repository;

  GetChatHistoryUseCase({required this.repository});

  Future<List<Message>> call({
    required String userId,
    String? cursor,
    int limit = 50,
  }) async {
    return await repository.getChatHistory(
      userId: userId,
      cursor: cursor,
      limit: limit,
    );
  }
}
