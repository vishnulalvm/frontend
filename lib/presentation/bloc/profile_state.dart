import 'package:equatable/equatable.dart';
import '../../domain/entities/user.dart';

abstract class ProfileState extends Equatable {
  const ProfileState();

  @override
  List<Object?> get props => [];
}

class ProfileInitial extends ProfileState {}

class ProfileLoading extends ProfileState {}

class ProfileLoaded extends ProfileState {
  final User user;
  final bool isFromCache;

  const ProfileLoaded({
    required this.user,
    this.isFromCache = false,
  });

  @override
  List<Object?> get props => [user, isFromCache];
}

class ProfileError extends ProfileState {
  final String message;

  const ProfileError({required this.message});

  @override
  List<Object?> get props => [message];
}
