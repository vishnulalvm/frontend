import '../repositories/chat_repository.dart';

class ConnectWebSocketUseCase {
  final ChatRepository repository;

  ConnectWebSocketUseCase({required this.repository});

  Future<void> call(String token) async {
    await repository.connectWebSocket(token);
  }
}
