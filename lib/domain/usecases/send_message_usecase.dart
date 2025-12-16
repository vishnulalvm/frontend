import '../repositories/chat_repository.dart';

class SendMessageUseCase {
  final ChatRepository repository;

  SendMessageUseCase({required this.repository});

  void call({
    required String receiverId,
    required String content,
  }) {
    repository.sendMessage(
      receiverId: receiverId,
      content: content,
    );
  }
}
