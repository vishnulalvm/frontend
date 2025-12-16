import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../core/di/injection.dart';
import '../../domain/entities/user.dart';
import '../bloc/chat_bloc.dart';
import '../bloc/chat_event.dart';
import '../bloc/chat_state.dart';
import '../bloc/online_status_bloc.dart';
import '../bloc/online_status_state.dart';
import '../widgets/user_avatar.dart';

class ChatScreen extends StatefulWidget {
  final User receiver;
  final String token;

  const ChatScreen({
    Key? key,
    required this.receiver,
    required this.token,
  }) : super(key: key);

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  late ChatBloc _chatBloc;

  @override
  void initState() {
    super.initState();
    _chatBloc = Injection.chatBloc;
    _chatBloc.add(InitializeChatEvent(
      receiver: widget.receiver,
      token: widget.token,
    ));

    _scrollController.addListener(_onScroll);
    _messageController.addListener(_onTextChanged);
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent * 0.9) {
      if (!_chatBloc.state.isLoadingMore && _chatBloc.state.hasMore) {
        _chatBloc.add(const LoadChatHistoryEvent(loadMore: true));
      }
    }
  }

  void _onTextChanged() {
    if (_messageController.text.isNotEmpty) {
      _chatBloc.add(const TypingEvent());
    } else {
      _chatBloc.add(const StopTypingEvent());
    }
  }

  void _sendMessage() {
    final content = _messageController.text.trim();
    if (content.isNotEmpty) {
      _chatBloc.add(SendMessageEvent(content: content));
      _messageController.clear();
    }
  }
  

  @override
  void dispose() {
    _chatBloc.add(const DisposeChatEvent());
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: _chatBloc),
        BlocProvider.value(value: Injection.onlineStatusBloc),
      ],
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F5F7),
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Color(0xFF1C1C1E)),
            onPressed: () => Navigator.pop(context),
          ),
          title: Row(
            children: [
              UserAvatar(
                avatarUrl: widget.receiver.avatar,
                username: widget.receiver.username,
                radius: 20,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.receiver.username,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1C1C1E),
                      ),
                    ),
                    BlocBuilder<ChatBloc, ChatState>(
                      builder: (context, chatState) {
                        if (chatState.isTyping) {
                          return Text(
                            'typing...',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.green[600],
                              fontStyle: FontStyle.italic,
                            ),
                          );
                        }
                        return BlocBuilder<OnlineStatusBloc, OnlineStatusState>(
                          builder: (context, onlineState) {
                            final isOnline = onlineState.isUserOnline(widget.receiver.id);
                            return Text(
                              chatState.isConnected
                                  ? (isOnline ? 'online' : 'offline')
                                  : 'Connecting...',
                              style: TextStyle(
                                fontSize: 12,
                                color: chatState.isConnected
                                    ? (isOnline
                                        ? const Color(0xFF34C759)
                                        : const Color(0xFF8E8E93))
                                    : Colors.orange[600],
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        body: Column(
          children: [
            Expanded(
              child: BlocConsumer<ChatBloc, ChatState>(
                listener: (context, state) {
                  if (state.error != null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(state.error!),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                },
                builder: (context, state) {
                  if (state.isLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (state.messages.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.chat_bubble_outline,
                            size: 64,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No messages yet',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Start a conversation with ${widget.receiver.username}',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[500],
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  return ListView.builder(
                    controller: _scrollController,
                    reverse: true,
                    padding: const EdgeInsets.all(16),
                    itemCount: state.messages.length +
                        (state.isLoadingMore ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (state.isLoadingMore && index == state.messages.length) {
                        return const Center(
                          child: Padding(
                            padding: EdgeInsets.all(8.0),
                            child: CircularProgressIndicator(),
                          ),
                        );
                      }

                      final message = state.messages[index];
                      final isMe = message.sender.id != widget.receiver.id;

                      return _MessageBubble(
                        message: message,
                        isMe: isMe,
                        isRead: state.readReceipts[message.id] ?? message.read,
                      );
                    },
                  );
                },
              ),
            ),
            _buildMessageInput(),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageInput() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(16),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _messageController,
                decoration: const InputDecoration(
                  hintText: 'Type a message...',
                  hintStyle: TextStyle(
                    color: Color(0xFFC7C7CC),
                  ),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.zero,
                ),
                maxLines: null,
                textCapitalization: TextCapitalization.sentences,
              ),
            ),
            const SizedBox(width: 8),
            BlocBuilder<ChatBloc, ChatState>(
              builder: (context, state) {
                return Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: state.isConnected
                        ? const Color(0xFF4A8FFF)
                        : const Color(0xFF8E8E93),
                    borderRadius: BorderRadius.circular(22),
                  ),
                  child: IconButton(
                    icon: const Icon(
                      Icons.send,
                      color: Colors.white,
                      size: 20,
                    ),
                    onPressed: state.isConnected ? _sendMessage : null,
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  final dynamic message;
  final bool isMe;
  final bool isRead;

  const _MessageBubble({
    Key? key,
    required this.message,
    required this.isMe,
    required this.isRead,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment:
            isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Flexible(
            child: Column(
              crossAxisAlignment:
                  isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: isMe ? const Color(0xFF4A8FFF) : Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    message.content,
                    style: TextStyle(
                      fontSize: 15,
                      color: isMe ? Colors.white : const Color(0xFF1C1C1E),
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _formatTime(message.createdAt),
                      style: const TextStyle(
                        fontSize: 11,
                        color: Color(0xFF8E8E93),
                      ),
                    ),
                    if (isMe) ...[
                      const SizedBox(width: 4),
                      Icon(
                        isRead ? Icons.done_all : Icons.check,
                        size: 14,
                        color: isRead ? const Color(0xFF4A8FFF) : const Color(0xFF8E8E93),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final messageDate = DateTime(dateTime.year, dateTime.month, dateTime.day);

    if (messageDate == today) {
      return DateFormat('HH:mm').format(dateTime);
    } else if (messageDate == today.subtract(const Duration(days: 1))) {
      return 'Yesterday ${DateFormat('HH:mm').format(dateTime)}';
    } else if (now.difference(messageDate).inDays < 7) {
      return DateFormat('EEE HH:mm').format(dateTime);
    } else {
      return DateFormat('MMM d, HH:mm').format(dateTime);
    }
  }
}
