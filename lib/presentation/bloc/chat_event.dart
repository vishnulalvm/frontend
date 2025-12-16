import 'package:equatable/equatable.dart';
import '../../domain/entities/message.dart';
import '../../domain/entities/user.dart';

abstract class ChatEvent extends Equatable {
  const ChatEvent();

  @override
  List<Object?> get props => [];
}

class InitializeChatEvent extends ChatEvent {
  final User receiver;
  final String token;

  const InitializeChatEvent({
    required this.receiver,
    required this.token,
  });

  @override
  List<Object?> get props => [receiver, token];
}

class LoadChatHistoryEvent extends ChatEvent {
  final bool loadMore;

  const LoadChatHistoryEvent({this.loadMore = false});

  @override
  List<Object?> get props => [loadMore];
}

class SendMessageEvent extends ChatEvent {
  final String content;

  const SendMessageEvent({required this.content});

  @override
  List<Object?> get props => [content];
}

class MessageReceivedEvent extends ChatEvent {
  final Message message;

  const MessageReceivedEvent({required this.message});

  @override
  List<Object?> get props => [message];
}

class MessageSentEvent extends ChatEvent {
  final Message message;

  const MessageSentEvent({required this.message});

  @override
  List<Object?> get props => [message];
}

class MarkMessagesReadEvent extends ChatEvent {
  final List<String> messageIds;

  const MarkMessagesReadEvent({required this.messageIds});

  @override
  List<Object?> get props => [messageIds];
}

class MessagesReadEvent extends ChatEvent {
  final List<String> messageIds;

  const MessagesReadEvent({required this.messageIds});

  @override
  List<Object?> get props => [messageIds];
}

class TypingEvent extends ChatEvent {
  const TypingEvent();
}

class StopTypingEvent extends ChatEvent {
  const StopTypingEvent();
}

class UserTypingEvent extends ChatEvent {
  final String userId;
  final String username;

  const UserTypingEvent({
    required this.userId,
    required this.username,
  });

  @override
  List<Object?> get props => [userId, username];
}

class UserStopTypingEvent extends ChatEvent {
  final String userId;

  const UserStopTypingEvent({required this.userId});

  @override
  List<Object?> get props => [userId];
}

class ConnectionStateChangedEvent extends ChatEvent {
  final bool isConnected;

  const ConnectionStateChangedEvent({required this.isConnected});

  @override
  List<Object?> get props => [isConnected];
}

class ChatErrorEvent extends ChatEvent {
  final String error;

  const ChatErrorEvent({required this.error});

  @override
  List<Object?> get props => [error];
}

class DisposeChatEvent extends ChatEvent {
  const DisposeChatEvent();
}
