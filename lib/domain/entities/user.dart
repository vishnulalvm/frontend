import 'package:equatable/equatable.dart';

class User extends Equatable {
  final String id;
  final String username;
  final String email;
  final String avatar;
  final String status;
  final String token;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const User({
    required this.id,
    required this.username,
    required this.email,
    required this.avatar,
    required this.status,
    required this.token,
    this.createdAt,
    this.updatedAt,
  });

  @override
  List<Object?> get props => [id, username, email, avatar, status, token, createdAt, updatedAt];
}
