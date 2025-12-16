import 'package:json_annotation/json_annotation.dart';

part 'chat_cache_metadata.g.dart';

@JsonSerializable()
class ChatCacheMetadata {
  final DateTime timestamp;
  final int messageCount;
  final String? nextCursor;
  final bool hasMore;
  final String cacheVersion;

  ChatCacheMetadata({
    required this.timestamp,
    required this.messageCount,
    this.nextCursor,
    required this.hasMore,
    this.cacheVersion = '1.0',
  });

  factory ChatCacheMetadata.fromJson(Map<String, dynamic> json) =>
      _$ChatCacheMetadataFromJson(json);

  Map<String, dynamic> toJson() => _$ChatCacheMetadataToJson(this);

  /// Check if cache is still valid based on TTL (default: 5 minutes)
  bool isValid({Duration ttl = const Duration(minutes: 5)}) {
    final now = DateTime.now();
    return now.difference(timestamp) < ttl;
  }

  /// Check if cache is empty
  bool get isEmpty => messageCount == 0;

  /// Create a copy with updated values
  ChatCacheMetadata copyWith({
    DateTime? timestamp,
    int? messageCount,
    String? nextCursor,
    bool? hasMore,
    String? cacheVersion,
  }) {
    return ChatCacheMetadata(
      timestamp: timestamp ?? this.timestamp,
      messageCount: messageCount ?? this.messageCount,
      nextCursor: nextCursor ?? this.nextCursor,
      hasMore: hasMore ?? this.hasMore,
      cacheVersion: cacheVersion ?? this.cacheVersion,
    );
  }

  /// Create initial metadata
  static ChatCacheMetadata initial() {
    return ChatCacheMetadata(
      timestamp: DateTime.now(),
      messageCount: 0,
      hasMore: false,
    );
  }
}
