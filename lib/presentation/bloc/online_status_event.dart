import 'package:equatable/equatable.dart';

abstract class OnlineStatusEvent extends Equatable {
  const OnlineStatusEvent();

  @override
  List<Object?> get props => [];
}

class InitializeOnlineStatusEvent extends OnlineStatusEvent {
  final String token;

  const InitializeOnlineStatusEvent({required this.token});

  @override
  List<Object?> get props => [token];
}

class OnlineUsersUpdatedEvent extends OnlineStatusEvent {
  final List<String> userIds;

  const OnlineUsersUpdatedEvent({required this.userIds});

  @override
  List<Object?> get props => [userIds];
}

class UserStatusChangedEvent extends OnlineStatusEvent {
  final String userId;
  final String status;

  const UserStatusChangedEvent({
    required this.userId,
    required this.status,
  });

  @override
  List<Object?> get props => [userId, status];
}

class DisposeOnlineStatusEvent extends OnlineStatusEvent {
  const DisposeOnlineStatusEvent();
}
