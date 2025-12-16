import 'package:equatable/equatable.dart';
import '../../domain/entities/user.dart';

abstract class UsersState extends Equatable {
  const UsersState();

  @override
  List<Object?> get props => [];
}

class UsersInitial extends UsersState {}

class UsersLoading extends UsersState {}

class AllUsersLoaded extends UsersState {
  final List<User> users;
  final List<User> filteredUsers;
  final String searchQuery;

  const AllUsersLoaded({
    required this.users,
    required this.filteredUsers,
    this.searchQuery = '',
  });

  @override
  List<Object?> get props => [users, filteredUsers, searchQuery];

  AllUsersLoaded copyWith({
    List<User>? users,
    List<User>? filteredUsers,
    String? searchQuery,
  }) {
    return AllUsersLoaded(
      users: users ?? this.users,
      filteredUsers: filteredUsers ?? this.filteredUsers,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }
}

class SelectedUsersLoaded extends UsersState {
  final List<User> users;
  final List<User> filteredUsers;
  final String searchQuery;

  const SelectedUsersLoaded({
    required this.users,
    List<User>? filteredUsers,
    this.searchQuery = '',
  }) : filteredUsers = filteredUsers ?? users;

  @override
  List<Object?> get props => [users, filteredUsers, searchQuery];

  SelectedUsersLoaded copyWith({
    List<User>? users,
    List<User>? filteredUsers,
    String? searchQuery,
  }) {
    return SelectedUsersLoaded(
      users: users ?? this.users,
      filteredUsers: filteredUsers ?? this.filteredUsers,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }
}

class UsersError extends UsersState {
  final String message;

  const UsersError({required this.message});

  @override
  List<Object?> get props => [message];
}
