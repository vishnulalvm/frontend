import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repositories/chat_repository_impl.dart';
import '../../domain/repositories/chat_repository.dart';
import '../../domain/usecases/connect_websocket_usecase.dart';
import '../../domain/usecases/get_chat_history_usecase.dart';
import '../../domain/usecases/mark_messages_read_usecase.dart';
import '../../domain/usecases/send_message_usecase.dart';
import 'chat_event.dart';
import 'chat_state.dart';

class ChatBloc extends Bloc<ChatEvent, ChatState> {
  final GetChatHistoryUseCase getChatHistoryUseCase;
  final SendMessageUseCase sendMessageUseCase;
  final MarkMessagesReadUseCase markMessagesReadUseCase;
  final ConnectWebSocketUseCase connectWebSocketUseCase;
  final ChatRepository chatRepository;

  StreamSubscription? _messageReceivedSubscription;
  StreamSubscription? _messageSentSubscription;
  StreamSubscription? _messagesReadSubscription;
  StreamSubscription? _userTypingSubscription;
  StreamSubscription? _userStopTypingSubscription;
  StreamSubscription? _connectionStateSubscription;
  StreamSubscription? _errorSubscription;

  Timer? _typingTimer;

  ChatBloc({
    required this.getChatHistoryUseCase,
    required this.sendMessageUseCase,
    required this.markMessagesReadUseCase,
    required this.connectWebSocketUseCase,
    required this.chatRepository,
  }) : super(const ChatState()) {
    on<InitializeChatEvent>(_onInitializeChat);
    on<LoadChatHistoryEvent>(_onLoadChatHistory);
    on<SendMessageEvent>(_onSendMessage);
    on<MessageReceivedEvent>(_onMessageReceived);
    on<MessageSentEvent>(_onMessageSent);
    on<MarkMessagesReadEvent>(_onMarkMessagesRead);
    on<MessagesReadEvent>(_onMessagesRead);
    on<TypingEvent>(_onTyping);
    on<StopTypingEvent>(_onStopTyping);
    on<UserTypingEvent>(_onUserTyping);
    on<UserStopTypingEvent>(_onUserStopTyping);
    on<ConnectionStateChangedEvent>(_onConnectionStateChanged);
    on<ChatErrorEvent>(_onChatError);
    on<DisposeChatEvent>(_onDisposeChat);
  }

  Future<void> _onInitializeChat(
    InitializeChatEvent event,
    Emitter<ChatState> emit,
  ) async {
    try {
      emit(state.copyWith(
        receiver: event.receiver,
        isLoading: true,
        error: null,
      ));

      // Connect to WebSocket
      await connectWebSocketUseCase(event.token);

      // Setup stream subscriptions
      _setupStreamSubscriptions();

      // Load chat history
      add(const LoadChatHistoryEvent());
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        error: 'Failed to initialize chat: $e',
      ));
    }
  }

  void _setupStreamSubscriptions() {
    _messageReceivedSubscription = chatRepository.onMessageReceived.listen(
      (message) => add(MessageReceivedEvent(message: message)),
    );

    _messageSentSubscription = chatRepository.onMessageSent.listen(
      (message) => add(MessageSentEvent(message: message)),
    );

    _messagesReadSubscription = chatRepository.onMessagesRead.listen(
      (data) {
        final messageIds = List<String>.from(data['messageIds'] as List);
        add(MessagesReadEvent(messageIds: messageIds));
      },
    );

    _userTypingSubscription = chatRepository.onUserTyping.listen(
      (data) => add(UserTypingEvent(
        userId: data['userId'] as String,
        username: data['username'] as String,
      )),
    );

    _userStopTypingSubscription = chatRepository.onUserStopTyping.listen(
      (userId) => add(UserStopTypingEvent(userId: userId)),
    );

    _connectionStateSubscription = chatRepository.connectionState.listen(
      (isConnected) => add(ConnectionStateChangedEvent(isConnected: isConnected)),
    );

    _errorSubscription = chatRepository.onError.listen(
      (error) => add(ChatErrorEvent(error: error)),
    );
  }

  Future<void> _onLoadChatHistory(
    LoadChatHistoryEvent event,
    Emitter<ChatState> emit,
  ) async {
    print('📥 LoadChatHistory: receiver=${state.receiver?.id}, loadMore=${event.loadMore}');

    if (state.receiver == null) {
      print('❌ LoadChatHistory: No receiver set!');
      return;
    }

    if (event.loadMore && !state.hasMore) {
      print('⏸️ LoadChatHistory: No more messages to load');
      return;
    }

    try {
      if (event.loadMore) {
        emit(state.copyWith(isLoadingMore: true));
      } else {
        emit(state.copyWith(isLoading: true));
      }

      final cursor = event.loadMore ? chatRepository.getNextCursor() : null;
      print('🔍 LoadChatHistory: cursor=$cursor, userId=${state.receiver!.id}');

      final messages = await getChatHistoryUseCase(
        userId: state.receiver!.id,
        cursor: cursor,
      );

      print('✅ LoadChatHistory: Received ${messages.length} messages');
      print('   hasMore: ${chatRepository.hasMoreMessages()}');
      print('   nextCursor: ${chatRepository.getNextCursor()}');

      final updatedMessages = event.loadMore
          ? [...state.messages, ...messages]
          : messages;

      emit(state.copyWith(
        messages: updatedMessages,
        isLoading: false,
        isLoadingMore: false,
        hasMore: chatRepository.hasMoreMessages(),
        error: null,
      ));

      print('📊 LoadChatHistory: Total messages in state: ${updatedMessages.length}');

      // Mark unread messages as read
      final unreadMessageIds = messages
          .where((m) => !m.read && m.receiver.id != state.receiver!.id)
          .map((m) => m.id)
          .toList();

      if (unreadMessageIds.isNotEmpty) {
        print('📬 Marking ${unreadMessageIds.length} messages as read');
        add(MarkMessagesReadEvent(messageIds: unreadMessageIds));
      }
    } catch (e) {
      print('❌ LoadChatHistory Error: $e');
      emit(state.copyWith(
        isLoading: false,
        isLoadingMore: false,
        error: 'Failed to load chat history: $e',
      ));
    }
  }

  void _onSendMessage(
    SendMessageEvent event,
    Emitter<ChatState> emit,
  ) {
    if (state.receiver == null) return;

    sendMessageUseCase(
      receiverId: state.receiver!.id,
      content: event.content,
    );

    // Stop typing indicator
    add(const StopTypingEvent());
  }

  void _onMessageReceived(
    MessageReceivedEvent event,
    Emitter<ChatState> emit,
  ) {
    if (state.receiver == null) return;

    // Only add message if it's from the current chat
    if (event.message.sender.id == state.receiver!.id) {
      final updatedMessages = [event.message, ...state.messages];
      emit(state.copyWith(
        messages: updatedMessages,
        error: null,
      ));

      // Cache the received message for persistence
      if (chatRepository is ChatRepositoryImpl) {
        (chatRepository as ChatRepositoryImpl).cacheReceivedMessage(
          state.receiver!.id,
          event.message,
        );
      }

      // Mark as read
      add(MarkMessagesReadEvent(messageIds: [event.message.id]));
    }
  }

  void _onMessageSent(
    MessageSentEvent event,
    Emitter<ChatState> emit,
  ) {
    if (state.receiver == null) return;

    // Only add message if it's for the current chat
    if (event.message.receiver.id == state.receiver!.id) {
      final updatedMessages = [event.message, ...state.messages];
      emit(state.copyWith(
        messages: updatedMessages,
        error: null,
      ));

      // Cache the sent message for persistence
      if (chatRepository is ChatRepositoryImpl) {
        (chatRepository as ChatRepositoryImpl).cacheSentMessage(
          state.receiver!.id,
          event.message,
        );
      }
    }
  }

  void _onMarkMessagesRead(
    MarkMessagesReadEvent event,
    Emitter<ChatState> emit,
  ) {
    markMessagesReadUseCase(event.messageIds);
  }

  void _onMessagesRead(
    MessagesReadEvent event,
    Emitter<ChatState> emit,
  ) {
    final updatedMessages = state.messages.map((message) {
      if (event.messageIds.contains(message.id)) {
        return message.copyWith(read: true);
      }
      return message;
    }).toList();

    final updatedReceipts = Map<String, bool>.from(state.readReceipts);
    for (final messageId in event.messageIds) {
      updatedReceipts[messageId] = true;
    }

    emit(state.copyWith(
      messages: updatedMessages,
      readReceipts: updatedReceipts,
    ));

    // Update read status in cache
    if (state.receiver != null && chatRepository is ChatRepositoryImpl) {
      (chatRepository as ChatRepositoryImpl).updateCachedReadStatus(
        state.receiver!.id,
        event.messageIds,
      );
    }
  }

  void _onTyping(
    TypingEvent event,
    Emitter<ChatState> emit,
  ) {
    if (state.receiver == null) return;

    chatRepository.typing(state.receiver!.id);

    // Cancel previous timer
    _typingTimer?.cancel();

    // Auto stop typing after 3 seconds
    _typingTimer = Timer(const Duration(seconds: 3), () {
      add(const StopTypingEvent());
    });
  }

  void _onStopTyping(
    StopTypingEvent event,
    Emitter<ChatState> emit,
  ) {
    if (state.receiver == null) return;

    chatRepository.stopTyping(state.receiver!.id);
    _typingTimer?.cancel();
  }

  void _onUserTyping(
    UserTypingEvent event,
    Emitter<ChatState> emit,
  ) {
    if (state.receiver == null) return;

    // Only show typing indicator for current chat receiver
    if (event.userId == state.receiver!.id) {
      emit(state.copyWith(
        isTyping: true,
        typingUsername: event.username,
      ));
    }
  }

  void _onUserStopTyping(
    UserStopTypingEvent event,
    Emitter<ChatState> emit,
  ) {
    if (state.receiver == null) return;

    // Only hide typing indicator for current chat receiver
    if (event.userId == state.receiver!.id) {
      emit(state.copyWith(
        isTyping: false,
        typingUsername: null,
      ));
    }
  }

  void _onConnectionStateChanged(
    ConnectionStateChangedEvent event,
    Emitter<ChatState> emit,
  ) {
    emit(state.copyWith(isConnected: event.isConnected));
  }

  void _onChatError(
    ChatErrorEvent event,
    Emitter<ChatState> emit,
  ) {
    emit(state.copyWith(error: event.error));
  }

  Future<void> _onDisposeChat(
    DisposeChatEvent event,
    Emitter<ChatState> emit,
  ) async {
    await _cancelSubscriptions();
    _typingTimer?.cancel();
    await chatRepository.disconnectWebSocket();
  }

  Future<void> _cancelSubscriptions() async {
    await _messageReceivedSubscription?.cancel();
    await _messageSentSubscription?.cancel();
    await _messagesReadSubscription?.cancel();
    await _userTypingSubscription?.cancel();
    await _userStopTypingSubscription?.cancel();
    await _connectionStateSubscription?.cancel();
    await _errorSubscription?.cancel();
  }

  @override
  Future<void> close() async {
    await _cancelSubscriptions();
    _typingTimer?.cancel();
    return super.close();
  }
}
