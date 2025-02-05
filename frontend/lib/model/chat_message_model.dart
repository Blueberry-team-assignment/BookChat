// lib/model/chat_message_model.dart
class ChatMessage {
  final int id;
  final String content;
  final String senderId;
  final DateTime timestamp;
  final int chatRoomId;

  ChatMessage({
    required this.id,
    required this.content,
    required this.senderId,
    required this.timestamp,
    required this.chatRoomId,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: json['id'] as int,
      content: json['content'],
      senderId: json['sender_id'],
      timestamp: DateTime.parse(json['timestamp']),
      chatRoomId: json['chat_room_id'] as int,
    );
  }
}