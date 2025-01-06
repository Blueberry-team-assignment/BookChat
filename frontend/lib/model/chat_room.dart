// lib/model/chat_room.dart
// lib/model/chat_room.dart
class ChatRoom {
  final int id;
  final String name;
  final List<String> participants;
  final int bookId;
  final DateTime createdAt;

  ChatRoom({
    required this.id,
    required this.name,
    required this.participants,
    required this.bookId,
    required this.createdAt,
  });

  factory ChatRoom.fromJson(Map<String, dynamic> json) {
    return ChatRoom(
      id: json['id'] as int,
      name: json['name'],
      participants: List<String>.from(json['participants']),
      bookId: json['book_id'] as int,
      createdAt: DateTime.parse(json['created_at']),
    );
  }
}