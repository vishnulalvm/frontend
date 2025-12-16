import '../repositories/chat_repository.dart';

class MarkMessagesReadUseCase {
  final ChatRepository repository;

  MarkMessagesReadUseCase({required this.repository});

  void call(List<String> messageIds) {
    repository.markAsRead(messageIds);
  }
}
