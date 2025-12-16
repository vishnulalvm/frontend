import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/services/websocket_service.dart';
import 'online_status_event.dart';
import 'online_status_state.dart';

class OnlineStatusBloc extends Bloc<OnlineStatusEvent, OnlineStatusState> {
  final WebSocketService webSocketService;

  StreamSubscription? _onlineUsersSubscription;
  StreamSubscription? _userStatusChangeSubscription;

  OnlineStatusBloc({required this.webSocketService})
      : super(const OnlineStatusState()) {
    on<InitializeOnlineStatusEvent>(_onInitialize);
    on<OnlineUsersUpdatedEvent>(_onOnlineUsersUpdated);
    on<UserStatusChangedEvent>(_onUserStatusChanged);
    on<DisposeOnlineStatusEvent>(_onDispose);
  }

  Future<void> _onInitialize(
    InitializeOnlineStatusEvent event,
    Emitter<OnlineStatusState> emit,
  ) async {
    // Connect to WebSocket if not already connected
    if (!webSocketService.isConnected) {
      await webSocketService.connect(event.token);
    }

    // Subscribe to online users stream
    _onlineUsersSubscription = webSocketService.onlineUsers.listen(
      (userIds) => add(OnlineUsersUpdatedEvent(userIds: userIds)),
    );

    // Subscribe to user status change stream
    _userStatusChangeSubscription = webSocketService.onUserStatusChange.listen(
      (data) {
        final userId = data['userId'] as String;
        final status = data['status'] as String;
        add(UserStatusChangedEvent(userId: userId, status: status));
      },
    );

    emit(state.copyWith(isInitialized: true));
  }

  void _onOnlineUsersUpdated(
    OnlineUsersUpdatedEvent event,
    Emitter<OnlineStatusState> emit,
  ) {
    emit(state.copyWith(onlineUserIds: event.userIds.toSet()));
  }

  void _onUserStatusChanged(
    UserStatusChangedEvent event,
    Emitter<OnlineStatusState> emit,
  ) {
    final updatedOnlineUsers = Set<String>.from(state.onlineUserIds);

    if (event.status == 'online') {
      updatedOnlineUsers.add(event.userId);
    } else if (event.status == 'offline') {
      updatedOnlineUsers.remove(event.userId);
    }

    emit(state.copyWith(onlineUserIds: updatedOnlineUsers));
  }

  Future<void> _onDispose(
    DisposeOnlineStatusEvent event,
    Emitter<OnlineStatusState> emit,
  ) async {
    await _onlineUsersSubscription?.cancel();
    await _userStatusChangeSubscription?.cancel();
  }

  @override
  Future<void> close() async {
    await _onlineUsersSubscription?.cancel();
    await _userStatusChangeSubscription?.cancel();
    return super.close();
  }
}
