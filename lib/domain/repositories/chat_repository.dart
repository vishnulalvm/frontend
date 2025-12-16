import '../entities/message.dart';

abstract class ChatRepository {
  Future<List<Message>> getChatHistory({
    required String userId,
    String? cursor,
    int limit = 50,
  });

  bool hasMoreMessages();

  String? getNextCursor();

  Stream<Message> get onMessageReceived;

  Stream<Message> get onMessageSent;

  Stream<Map<String, dynamic>> get onMessagesRead;

  Stream<Map<String, dynamic>> get onUserTyping;

  Stream<String> get onUserStopTyping;

  Stream<List<String>> get onlineUsers;

  Stream<Map<String, dynamic>> get onUserStatusChange;

  Stream<bool> get connectionState;

  Stream<String> get onError;

  bool get isConnected;

  Future<void> connectWebSocket(String token);

  void sendMessage({
    required String receiverId,
    required String content,
  });

  void markAsRead(List<String> messageIds);

  void typing(String receiverId);

  void stopTyping(String receiverId);

  Future<void> disconnectWebSocket();
}
