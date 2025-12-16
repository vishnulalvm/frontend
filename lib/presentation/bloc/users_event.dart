import 'package:equatable/equatable.dart';

abstract class UsersEvent extends Equatable {
  const UsersEvent();

  @override
  List<Object?> get props => [];
}

class LoadAllUsersEvent extends UsersEvent {
  final bool forceRefresh;

  const LoadAllUsersEvent({this.forceRefresh = false});

  @override
  List<Object?> get props => [forceRefresh];
}

class LoadSelectedUsersEvent extends UsersEvent {}

class SelectUserEvent extends UsersEvent {
  final String userId;

  const SelectUserEvent(this.userId);

  @override
  List<Object?> get props => [userId];
}

class SearchUsersEvent extends UsersEvent {
  final String query;

  const SearchUsersEvent(this.query);

  @override
  List<Object?> get props => [query];
}

class SearchSelectedUsersEvent extends UsersEvent {
  final String query;

  const SearchSelectedUsersEvent(this.query);

  @override
  List<Object?> get props => [query];
}
