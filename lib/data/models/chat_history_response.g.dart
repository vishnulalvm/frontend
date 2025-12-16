// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chat_history_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ChatHistoryResponse _$ChatHistoryResponseFromJson(Map<String, dynamic> json) =>
    ChatHistoryResponse(
      messages: (json['messages'] as List<dynamic>)
          .map((e) => MessageModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      hasMore: json['hasMore'] as bool,
      nextCursor: json['nextCursor'] as String?,
    );

Map<String, dynamic> _$ChatHistoryResponseToJson(
  ChatHistoryResponse instance,
) => <String, dynamic>{
  'messages': instance.messages.map((e) => e.toJson()).toList(),
  'hasMore': instance.hasMore,
  'nextCursor': instance.nextCursor,
};
