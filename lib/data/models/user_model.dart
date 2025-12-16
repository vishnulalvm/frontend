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
    DateTime? createdAt,
    DateTime? updatedAt,
  }) : super(
          id: id,
          username: username,
          email: email,
          avatar: avatar,
          status: status,
          token: token,
          createdAt: createdAt,
          updatedAt: updatedAt,
        );

  factory UserModel.fromJson(Map<String, dynamic> json) {
    // Handle the response format from your API
    return UserModel(
      id: (json['_id'] ?? json['id'] ?? '') as String,
      username: (json['username'] ?? '') as String,
      email: (json['email'] ?? '') as String,
      avatar: (json['avatar'] ?? 'https://ui-avatars.com/api/?name=${json['username'] ?? 'User'}&background=4A8FFF&color=fff') as String,
      status: (json['status'] ?? 'offline') as String,
      token: (json['token'] ?? '') as String,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : null,
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
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}
