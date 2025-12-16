import 'package:equatable/equatable.dart';
import 'user.dart';

class Message extends Equatable {
  final String id;
  final User sender;
  final User receiver;
  final String content;
  final bool read;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Message({
    required this.id,
    required this.sender,
    required this.receiver,
    required this.content,
    required this.read,
    required this.createdAt,
    required this.updatedAt,
  });

  Message copyWith({
    String? id,
    User? sender,
    User? receiver,
    String? content,
    bool? read,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Message(
      id: id ?? this.id,
      sender: sender ?? this.sender,
      receiver: receiver ?? this.receiver,
      content: content ?? this.content,
      read: read ?? this.read,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [id, sender, receiver, content, read, createdAt, updatedAt];
}
