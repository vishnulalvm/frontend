// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chat_cache_metadata.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ChatCacheMetadata _$ChatCacheMetadataFromJson(Map<String, dynamic> json) =>
    ChatCacheMetadata(
      timestamp: DateTime.parse(json['timestamp'] as String),
      messageCount: (json['messageCount'] as num).toInt(),
      nextCursor: json['nextCursor'] as String?,
      hasMore: json['hasMore'] as bool,
      cacheVersion: json['cacheVersion'] as String? ?? '1.0',
    );

Map<String, dynamic> _$ChatCacheMetadataToJson(ChatCacheMetadata instance) =>
    <String, dynamic>{
      'timestamp': instance.timestamp.toIso8601String(),
      'messageCount': instance.messageCount,
      'nextCursor': instance.nextCursor,
      'hasMore': instance.hasMore,
      'cacheVersion': instance.cacheVersion,
    };
