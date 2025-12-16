import '../../core/services/websocket_service.dart';
import '../../domain/entities/message.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/repositories/chat_repository.dart';
import '../datasources/chat_local_data_source.dart';
import '../datasources/chat_remote_data_source.dart';
import '../models/message_model.dart';

class ChatRepositoryImpl implements ChatRepository {
  final ChatRemoteDataSource remoteDataSource;
  final ChatLocalDataSource localDataSource;
  final WebSocketService webSocketService;
  final AuthRepository authRepository;

  String? _nextCursor;
  bool _hasMore = true;

  ChatRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.webSocketService,
    required this.authRepository,
  });

  @override
  Future<List<Message>> getChatHistory({
    required String userId,
    String? cursor,
    int limit = 50,
  }) async {
    print('🗄️ ChatRepository.getChatHistory: userId=$userId, cursor=$cursor, limit=$limit');

    try {
      // Get token from auth repository
      final user = await authRepository.getCurrentUser();
      if (user == null) {
        throw Exception('User not authenticated');
      }
      final token = user.token;
      print('🔑 Got auth token: ${token.substring(0, 20)}...');

      // Try to get cached messages first (cache-first strategy for initial load)
      if (cursor == null) {
        final cachedMessages = await localDataSource.getCachedMessages(userId);
        final isCacheValid = await localDataSource.isCacheValid(userId);

        if (cachedMessages.isNotEmpty) {
          print('📦 Using cached messages: ${cachedMessages.length} messages (valid: $isCacheValid)');

          // Return cached data immediately for fast UI load
          final cachedEntities = cachedMessages.map((model) => model.toEntity()).toList();

          // If cache is invalid, trigger background sync (fire and forget)
          if (!isCacheValid) {
            print('🔄 Cache expired, triggering background sync...');
            _syncCacheInBackground(userId, token, limit);
          }

          return cachedEntities;
        }
        print('📦 No cached messages found');
      }

      // Fetch from remote
      print('🌐 Fetching from remote API...');
      final response = await remoteDataSource.getChatHistory(
        userId: userId,
        token: token,
        cursor: cursor,
        limit: limit,
      );

      _nextCursor = response.nextCursor;
      _hasMore = response.hasMore;

      print('✅ Remote API response: ${response.messages.length} messages, hasMore=${response.hasMore}, nextCursor=${response.nextCursor}');

      // Cache messages with metadata
      if (cursor == null) {
        // Initial load - cache with metadata
        await localDataSource.cacheMessagesWithMetadata(
          userId,
          response.messages,
          nextCursor: response.nextCursor,
          hasMore: response.hasMore,
        );
        print('💾 Cached ${response.messages.length} messages with metadata');
      } else {
        // Pagination - add to existing cache
        await localDataSource.addMessagesToCache(userId, response.messages);
        print('💾 Added ${response.messages.length} messages to cache');
      }

      return response.messages.map((model) => model.toEntity()).toList();
    } catch (e) {
      print('❌ ChatRepository Error: $e');
      // If remote fetch fails, return cached messages (offline support)
      final cachedMessages = await localDataSource.getCachedMessages(userId);
      print('📦 Returning ${cachedMessages.length} cached messages after error (offline mode)');
      return cachedMessages.map((model) => model.toEntity()).toList();
    }
  }

  /// Background sync to refresh cache without blocking UI
  Future<void> _syncCacheInBackground(String userId, String token, int limit) async {
    try {
      final response = await remoteDataSource.getChatHistory(
        userId: userId,
        token: token,
        cursor: null,
        limit: limit,
      );

      _nextCursor = response.nextCursor;
      _hasMore = response.hasMore;

      await localDataSource.cacheMessagesWithMetadata(
        userId,
        response.messages,
        nextCursor: response.nextCursor,
        hasMore: response.hasMore,
      );
      print('🔄 Background sync completed: ${response.messages.length} messages');
    } catch (e) {
      print('⚠️ Background sync failed: $e');
    }
  }

  /// Cache received message for persistence
  Future<void> cacheReceivedMessage(String userId, Message message) async {
    try {
      // Convert entity to model
      final messageModel = _messageEntityToModel(message);
      await localDataSource.prependMessageToCache(userId, messageModel);
      print('💾 Cached received message: ${message.id}');
    } catch (e) {
      print('⚠️ Failed to cache received message: $e');
    }
  }

  /// Cache sent message for persistence
  Future<void> cacheSentMessage(String userId, Message message) async {
    try {
      // Convert entity to model
      final messageModel = _messageEntityToModel(message);
      await localDataSource.prependMessageToCache(userId, messageModel);
      print('💾 Cached sent message: ${message.id}');
    } catch (e) {
      print('⚠️ Failed to cache sent message: $e');
    }
  }

  /// Update read status in cache
  Future<void> updateCachedReadStatus(String userId, List<String> messageIds) async {
    try {
      await localDataSource.updateMessageReadStatus(userId, messageIds);
      print('💾 Updated read status in cache for ${messageIds.length} messages');
    } catch (e) {
      print('⚠️ Failed to update read status in cache: $e');
    }
  }

  /// Helper method to convert Message entity to MessageModel
  MessageModel _messageEntityToModel(Message message) {
    return MessageModel.fromEntity(message);
  }

  @override
  bool hasMoreMessages() => _hasMore;

  @override
  String? getNextCursor() => _nextCursor;

  @override
  Stream<Message> get onMessageReceived =>
      webSocketService.onMessageReceived.map((model) => model.toEntity());

  @override
  Stream<Message> get onMessageSent =>
      webSocketService.onMessageSent.map((model) => model.toEntity());

  @override
  Stream<Map<String, dynamic>> get onMessagesRead =>
      webSocketService.onMessagesRead;

  @override
  Stream<Map<String, dynamic>> get onUserTyping =>
      webSocketService.onUserTyping;

  @override
  Stream<String> get onUserStopTyping =>
      webSocketService.onUserStopTyping;

  @override
  Stream<List<String>> get onlineUsers =>
      webSocketService.onlineUsers;

  @override
  Stream<Map<String, dynamic>> get onUserStatusChange =>
      webSocketService.onUserStatusChange;

  @override
  Stream<bool> get connectionState =>
      webSocketService.connectionState;

  @override
  Stream<String> get onError =>
      webSocketService.onError;

  @override
  bool get isConnected => webSocketService.isConnected;

  @override
  Future<void> connectWebSocket(String token) async {
    await webSocketService.connect(token);
  }

  @override
  void sendMessage({
    required String receiverId,
    required String content,
  }) {
    webSocketService.sendMessage(
      receiverId: receiverId,
      content: content,
    );
  }

  @override
  void markAsRead(List<String> messageIds) {
    webSocketService.markAsRead(messageIds);
  }

  @override
  void typing(String receiverId) {
    webSocketService.typing(receiverId);
  }

  @override
  void stopTyping(String receiverId) {
    webSocketService.stopTyping(receiverId);
  }

  @override
  Future<void> disconnectWebSocket() async {
    await webSocketService.disconnect();
  }
}
