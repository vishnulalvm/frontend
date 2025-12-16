// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'message_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MessageModel _$MessageModelFromJson(Map<String, dynamic> json) => MessageModel(
  id: json['_id'] as String,
  sender: UserModel.fromJson(json['sender'] as Map<String, dynamic>),
  receiver: UserModel.fromJson(json['receiver'] as Map<String, dynamic>),
  content: json['content'] as String,
  read: json['read'] as bool,
  createdAt: DateTime.parse(json['createdAt'] as String),
  updatedAt: DateTime.parse(json['updatedAt'] as String),
);

Map<String, dynamic> _$MessageModelToJson(MessageModel instance) =>
    <String, dynamic>{
      '_id': instance.id,
      'sender': instance.sender.toJson(),
      'receiver': instance.receiver.toJson(),
      'content': instance.content,
      'read': instance.read,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
    };
