import 'package:equatable/equatable.dart';
import '../../domain/entities/message.dart';
import '../../domain/entities/user.dart';

class ChatState extends Equatable {
  final List<Message> messages;
  final User? receiver;
  final bool isLoading;
  final bool isLoadingMore;
  final bool hasMore;
  final bool isConnected;
  final String? error;
  final bool isTyping;
  final String? typingUsername;
  final Map<String, bool> readReceipts;

  const ChatState({
    this.messages = const [],
    this.receiver,
    this.isLoading = false,
    this.isLoadingMore = false,
    this.hasMore = true,
    this.isConnected = false,
    this.error,
    this.isTyping = false,
    this.typingUsername,
    this.readReceipts = const {},
  });

  ChatState copyWith({
    List<Message>? messages,
    User? receiver,
    bool? isLoading,
    bool? isLoadingMore,
    bool? hasMore,
    bool? isConnected,
    String? error,
    bool? isTyping,
    String? typingUsername,
    Map<String, bool>? readReceipts,
  }) {
    return ChatState(
      messages: messages ?? this.messages,
      receiver: receiver ?? this.receiver,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      hasMore: hasMore ?? this.hasMore,
      isConnected: isConnected ?? this.isConnected,
      error: error,
      isTyping: isTyping ?? this.isTyping,
      typingUsername: typingUsername,
      readReceipts: readReceipts ?? this.readReceipts,
    );
  }

  @override
  List<Object?> get props => [
        messages,
        receiver,
        isLoading,
        isLoadingMore,
        hasMore,
        isConnected,
        error,
        isTyping,
        typingUsername,
        readReceipts,
      ];
}
