import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/message_model.dart';
import '../models/chat_cache_metadata.dart';

abstract class ChatLocalDataSource {
  Future<void> cacheMessages(String chatKey, List<MessageModel> messages);
  Future<List<MessageModel>> getCachedMessages(String chatKey);
  Future<void> clearCachedMessages(String chatKey);
  Future<void> updateMessageReadStatus(String chatKey, List<String> messageIds);

  // New methods for enhanced caching
  Future<void> cacheMessagesWithMetadata(
    String chatKey,
    List<MessageModel> messages,
    {String? nextCursor, bool? hasMore}
  );
  Future<void> addMessagesToCache(String chatKey, List<MessageModel> newMessages);
  Future<void> prependMessageToCache(String chatKey, MessageModel message);
  Future<ChatCacheMetadata?> getCacheMetadata(String chatKey);
  Future<bool> isCacheValid(String chatKey, {Duration ttl = const Duration(minutes: 5)});
}

class ChatLocalDataSourceImpl implements ChatLocalDataSource {
  final SharedPreferences sharedPreferences;
  static const String _chatCachePrefix = 'CACHED_CHAT_';
  static const String _metadataSuffix = '_METADATA';

  ChatLocalDataSourceImpl({required this.sharedPreferences});

  String _getCacheKey(String chatKey) => '$_chatCachePrefix$chatKey';
  String _getMetadataKey(String chatKey) => '$_chatCachePrefix$chatKey$_metadataSuffix';

  @override
  Future<void> cacheMessages(String chatKey, List<MessageModel> messages) async {
    try {
      final jsonList = messages.map((message) => message.toJson()).toList();
      final jsonString = json.encode(jsonList);
      await sharedPreferences.setString(_getCacheKey(chatKey), jsonString);
    } catch (e) {
      throw Exception('Failed to cache messages: $e');
    }
  }

  @override
  Future<List<MessageModel>> getCachedMessages(String chatKey) async {
    try {
      final jsonString = sharedPreferences.getString(_getCacheKey(chatKey));
      if (jsonString == null) {
        return [];
      }

      final jsonList = json.decode(jsonString) as List<dynamic>;
      return jsonList
          .map((json) => MessageModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Failed to get cached messages: $e');
    }
  }

  @override
  Future<void> clearCachedMessages(String chatKey) async {
    try {
      await sharedPreferences.remove(_getCacheKey(chatKey));
    } catch (e) {
      throw Exception('Failed to clear cached messages: $e');
    }
  }

  @override
  Future<void> updateMessageReadStatus(String chatKey, List<String> messageIds) async {
    try {
      final messages = await getCachedMessages(chatKey);
      final updatedMessages = messages.map((message) {
        if (messageIds.contains(message.id)) {
          return message.copyWith(read: true);
        }
        return message;
      }).toList();

      await cacheMessages(chatKey, updatedMessages);
    } catch (e) {
      throw Exception('Failed to update message read status: $e');
    }
  }

  @override
  Future<void> cacheMessagesWithMetadata(
    String chatKey,
    List<MessageModel> messages, {
    String? nextCursor,
    bool? hasMore,
  }) async {
    try {
      // Cache the messages
      await cacheMessages(chatKey, messages);

      // Create and cache metadata
      final metadata = ChatCacheMetadata(
        timestamp: DateTime.now(),
        messageCount: messages.length,
        nextCursor: nextCursor,
        hasMore: hasMore ?? false,
      );

      final metadataJson = json.encode(metadata.toJson());
      await sharedPreferences.setString(_getMetadataKey(chatKey), metadataJson);
    } catch (e) {
      throw Exception('Failed to cache messages with metadata: $e');
    }
  }

  @override
  Future<void> addMessagesToCache(String chatKey, List<MessageModel> newMessages) async {
    try {
      if (newMessages.isEmpty) return;

      // Get existing cached messages
      final existingMessages = await getCachedMessages(chatKey);

      // Merge messages (append new messages to the end)
      // Remove duplicates based on message ID
      final existingIds = existingMessages.map((m) => m.id).toSet();
      final uniqueNewMessages = newMessages.where((m) => !existingIds.contains(m.id)).toList();

      final mergedMessages = [...existingMessages, ...uniqueNewMessages];

      // Update cache
      await cacheMessages(chatKey, mergedMessages);

      // Update metadata
      final metadata = await getCacheMetadata(chatKey);
      if (metadata != null) {
        final updatedMetadata = metadata.copyWith(
          timestamp: DateTime.now(),
          messageCount: mergedMessages.length,
        );
        final metadataJson = json.encode(updatedMetadata.toJson());
        await sharedPreferences.setString(_getMetadataKey(chatKey), metadataJson);
      }
    } catch (e) {
      throw Exception('Failed to add messages to cache: $e');
    }
  }

  @override
  Future<void> prependMessageToCache(String chatKey, MessageModel message) async {
    try {
      // Get existing cached messages
      final existingMessages = await getCachedMessages(chatKey);

      // Check if message already exists
      final existingIds = existingMessages.map((m) => m.id).toSet();
      if (existingIds.contains(message.id)) {
        return; // Message already cached
      }

      // Prepend new message to the beginning (newest first)
      final updatedMessages = [message, ...existingMessages];

      // Update cache
      await cacheMessages(chatKey, updatedMessages);

      // Update metadata
      final metadata = await getCacheMetadata(chatKey);
      if (metadata != null) {
        final updatedMetadata = metadata.copyWith(
          timestamp: DateTime.now(),
          messageCount: updatedMessages.length,
        );
        final metadataJson = json.encode(updatedMetadata.toJson());
        await sharedPreferences.setString(_getMetadataKey(chatKey), metadataJson);
      }
    } catch (e) {
      throw Exception('Failed to prepend message to cache: $e');
    }
  }

  @override
  Future<ChatCacheMetadata?> getCacheMetadata(String chatKey) async {
    try {
      final metadataJson = sharedPreferences.getString(_getMetadataKey(chatKey));
      if (metadataJson == null) {
        return null;
      }

      final metadataMap = json.decode(metadataJson) as Map<String, dynamic>;
      return ChatCacheMetadata.fromJson(metadataMap);
    } catch (e) {
      // Return null if metadata is corrupted or missing
      return null;
    }
  }

  @override
  Future<bool> isCacheValid(String chatKey, {Duration ttl = const Duration(minutes: 5)}) async {
    try {
      final metadata = await getCacheMetadata(chatKey);
      if (metadata == null) {
        return false;
      }

      return metadata.isValid(ttl: ttl);
    } catch (e) {
      return false;
    }
  }
}
