import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/user.dart';

part 'user_model.g.dart';

@JsonSerializable()
class UserModel extends User {
  const UserModel({
    required String id,
    required String username,
    required String email,
    required String avatar,
    required String status,
    required String token,
  }) : super(
          id: id,
          username: username,
          email: email,
          avatar: avatar,
          status: status,
          token: token,
        );

  factory UserModel.fromJson(Map<String, dynamic> json) {
    // Handle the response format from your API
    return UserModel(
      id: json['_id'] as String,
      username: json['username'] as String,
      email: json['email'] as String,
      avatar: json['avatar'] as String,
      status: json['status'] as String? ?? 'offline',
      token: json['token'] as String,
    );
  }

  Map<String, dynamic> toJson() => _$UserModelToJson(this);

  User toEntity() {
    return User(
      id: id,
      username: username,
      email: email,
      avatar: avatar,
      status: status,
      token: token,
    );
  }
}
