import 'dart:async';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import '../../data/models/message_model.dart';

class WebSocketService {
  IO.Socket? _socket;
  final String baseUrl;

  // Stream controllers for real-time events
  final _messageReceivedController = StreamController<MessageModel>.broadcast();
  final _messageSentController = StreamController<MessageModel>.broadcast();
  final _messagesReadController = StreamController<Map<String, dynamic>>.broadcast();
  final _userTypingController = StreamController<Map<String, dynamic>>.broadcast();
  final _userStopTypingController = StreamController<String>.broadcast();
  final _onlineUsersController = StreamController<List<String>>.broadcast();
  final _userStatusChangeController = StreamController<Map<String, dynamic>>.broadcast();
  final _connectionStateController = StreamController<bool>.broadcast();
  final _errorController = StreamController<String>.broadcast();

  // Streams
  Stream<MessageModel> get onMessageReceived => _messageReceivedController.stream;
  Stream<MessageModel> get onMessageSent => _messageSentController.stream;
  Stream<Map<String, dynamic>> get onMessagesRead => _messagesReadController.stream;
  Stream<Map<String, dynamic>> get onUserTyping => _userTypingController.stream;
  Stream<String> get onUserStopTyping => _userStopTypingController.stream;
  Stream<List<String>> get onlineUsers => _onlineUsersController.stream;
  Stream<Map<String, dynamic>> get onUserStatusChange => _userStatusChangeController.stream;
  Stream<bool> get connectionState => _connectionStateController.stream;
  Stream<String> get onError => _errorController.stream;

  bool get isConnected => _socket?.connected ?? false;

  WebSocketService({required this.baseUrl});

  // Connect to WebSocket server
  Future<void> connect(String token) async {
    if (_socket?.connected == true) {
      return;
    }


    _socket = IO.io(
      baseUrl,
      IO.OptionBuilder()
          .setTransports(['websocket'])
          .disableAutoConnect()
          .setAuth({'token': token})
          .enableReconnection()
          .setReconnectionDelay(1000)
          .setReconnectionDelayMax(5000)
          .setReconnectionAttempts(5)
          .build(),
    );

    _setupEventHandlers();
    _socket!.connect();
  }

  // Setup event handlers
  void _setupEventHandlers() {
    // Connection events
    _socket!.onConnect((_) {
      print('WebSocket connected');
      _connectionStateController.add(true);
    });

    _socket!.onDisconnect((_) {
      print('WebSocket disconnected');
      _connectionStateController.add(false);
    });

    _socket!.onConnectError((error) {
      print('Connection error: $error');
      _errorController.add(error.toString());
      _connectionStateController.add(false);
    });

    _socket!.onError((error) {
      print('Socket error: $error');
      _errorController.add(error.toString());
    });

    // Message events
    _socket!.on('receive-message', (data) {
      try {
        final message = MessageModel.fromJson(data as Map<String, dynamic>);
        _messageReceivedController.add(message);
      } catch (e) {
        print('Error parsing received message: $e');
        _errorController.add('Failed to parse message: $e');
      }
    });

    _socket!.on('message-sent', (data) {
      try {
        final message = MessageModel.fromJson(data as Map<String, dynamic>);
        _messageSentController.add(message);
      } catch (e) {
        print('Error parsing sent message: $e');
        _errorController.add('Failed to parse sent message: $e');
      }
    });

    _socket!.on('messages-read', (data) {
      try {
        _messagesReadController.add(data as Map<String, dynamic>);
      } catch (e) {
        print('Error parsing messages-read event: $e');
      }
    });

    // Typing indicators
    _socket!.on('user-typing', (data) {
      try {
        _userTypingController.add(data as Map<String, dynamic>);
      } catch (e) {
        print('Error parsing user-typing event: $e');
      }
    });

    _socket!.on('user-stop-typing', (data) {
      try {
        final userId = (data as Map<String, dynamic>)['userId'] as String;
        _userStopTypingController.add(userId);
      } catch (e) {
        print('Error parsing user-stop-typing event: $e');
      }
    });

    // User status events
    _socket!.on('online-users', (data) {
      try {
        final userIds = List<String>.from(data as List);
        _onlineUsersController.add(userIds);
      } catch (e) {
        print('Error parsing online-users event: $e');
      }
    });

    _socket!.on('user-status-change', (data) {
      try {
        _userStatusChangeController.add(data as Map<String, dynamic>);
      } catch (e) {
        print('Error parsing user-status-change event: $e');
      }
    });

    // Error event
    _socket!.on('error', (data) {
      try {
        final message = (data as Map<String, dynamic>)['message'] as String;
        _errorController.add(message);
      } catch (e) {
        print('Error parsing error event: $e');
      }
    });
  }

  // Send message
  void sendMessage({
    required String receiverId,
    required String content,
  }) {
    if (_socket?.connected != true) {
      _errorController.add('Not connected to server');
      return;
    }

    _socket!.emit('send-message', {
      'receiverId': receiverId,
      'content': content,
    });
  }

  // Mark messages as read
  void markAsRead(List<String> messageIds) {
    if (_socket?.connected != true) {
      return;
    }

    _socket!.emit('mark-as-read', {
      'messageIds': messageIds,
    });
  }

  // Typing indicator
  void typing(String receiverId) {
    if (_socket?.connected != true) {
      return;
    }

    _socket!.emit('typing', {
      'receiverId': receiverId,
    });
  }

  // Stop typing indicator
  void stopTyping(String receiverId) {
    if (_socket?.connected != true) {
      return;
    }

    _socket!.emit('stop-typing', {
      'receiverId': receiverId,
    });
  }

  // Disconnect
  Future<void> disconnect() async {
    _socket?.disconnect();
    _socket?.dispose();
    _socket = null;
  }

  // Dispose all controllers
  void dispose() {
    disconnect();
    _messageReceivedController.close();
    _messageSentController.close();
    _messagesReadController.close();
    _userTypingController.close();
    _userStopTypingController.close();
    _onlineUsersController.close();
    _userStatusChangeController.close();
    _connectionStateController.close();
    _errorController.close();
  }
}
