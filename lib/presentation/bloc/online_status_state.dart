import 'package:equatable/equatable.dart';

class OnlineStatusState extends Equatable {
  final Set<String> onlineUserIds;
  final bool isInitialized;

  const OnlineStatusState({
    this.onlineUserIds = const {},
    this.isInitialized = false,
  });

  OnlineStatusState copyWith({
    Set<String>? onlineUserIds,
    bool? isInitialized,
  }) {
    return OnlineStatusState(
      onlineUserIds: onlineUserIds ?? this.onlineUserIds,
      isInitialized: isInitialized ?? this.isInitialized,
    );
  }

  bool isUserOnline(String userId) => onlineUserIds.contains(userId);

  @override
  List<Object?> get props => [onlineUserIds, isInitialized];
}
