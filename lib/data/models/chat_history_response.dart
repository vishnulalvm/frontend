import 'package:json_annotation/json_annotation.dart';
import 'message_model.dart';

part 'chat_history_response.g.dart';

@JsonSerializable(explicitToJson: true)
class ChatHistoryResponse {
  final List<MessageModel> messages;
  final bool hasMore;
  final String? nextCursor;

  const ChatHistoryResponse({
    required this.messages,
    required this.hasMore,
    this.nextCursor,
  });

  factory ChatHistoryResponse.fromJson(Map<String, dynamic> json) =>
      _$ChatHistoryResponseFromJson(json);

  Map<String, dynamic> toJson() => _$ChatHistoryResponseToJson(this);
}
