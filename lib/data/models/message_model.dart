import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/message.dart';
import 'user_model.dart';

part 'message_model.g.dart';

@JsonSerializable(explicitToJson: true)
class MessageModel {
  @JsonKey(name: '_id')
  final String id;
  final UserModel sender;
  final UserModel receiver;
  final String content;
  final bool read;
  final DateTime createdAt;
  final DateTime updatedAt;

  const MessageModel({
    required this.id,
    required this.sender,
    required this.receiver,
    required this.content,
    required this.read,
    required this.createdAt,
    required this.updatedAt,
  });

  factory MessageModel.fromJson(Map<String, dynamic> json) =>
      _$MessageModelFromJson(json);

  Map<String, dynamic> toJson() => _$MessageModelToJson(this);

  MessageModel copyWith({
    String? id,
    UserModel? sender,
    UserModel? receiver,
    String? content,
    bool? read,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return MessageModel(
      id: id ?? this.id,
      sender: sender ?? this.sender,
      receiver: receiver ?? this.receiver,
      content: content ?? this.content,
      read: read ?? this.read,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Message toEntity() {
    return Message(
      id: id,
      sender: sender.toEntity(),
      receiver: receiver.toEntity(),
      content: content,
      read: read,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  factory MessageModel.fromEntity(Message message) {
    return MessageModel(
      id: message.id,
      sender: UserModel(
        id: message.sender.id,
        username: message.sender.username,
        email: message.sender.email,
        avatar: message.sender.avatar,
        status: message.sender.status,
        token: message.sender.token,
        createdAt: message.sender.createdAt,
        updatedAt: message.sender.updatedAt,
      ),
      receiver: UserModel(
        id: message.receiver.id,
        username: message.receiver.username,
        email: message.receiver.email,
        avatar: message.receiver.avatar,
        status: message.receiver.status,
        token: message.receiver.token,
        createdAt: message.receiver.createdAt,
        updatedAt: message.receiver.updatedAt,
      ),
      content: message.content,
      read: message.read,
      createdAt: message.createdAt,
      updatedAt: message.updatedAt,
    );
  }
}
