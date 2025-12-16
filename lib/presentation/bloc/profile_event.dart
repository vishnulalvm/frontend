import 'package:equatable/equatable.dart';

abstract class ProfileEvent extends Equatable {
  const ProfileEvent();

  @override
  List<Object?> get props => [];
}

class LoadProfileEvent extends ProfileEvent {
  final bool forceRefresh;

  const LoadProfileEvent({this.forceRefresh = false});

  @override
  List<Object?> get props => [forceRefresh];
}

class ClearProfileCacheEvent extends ProfileEvent {}
