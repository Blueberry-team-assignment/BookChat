// lib/feature/chat_screen/model/chat_message_model.dart
class ChatMessage {
  final int id;
  final String content;
  final String senderId;
  final String senderName;
  final DateTime timestamp;

  ChatMessage({
    required this.id,
    required this.content,
    required this.senderId,
    required this.senderName,
    required this.timestamp,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: json['id'],
      content: json['message'],  // df-chat uses 'message' instead of 'content'
      senderId: json['created_by']['id'].toString(),
      senderName: json['created_by']['username'],  // df-chat user model
      timestamp: DateTime.parse(json['created_at']),
    );
  }
}