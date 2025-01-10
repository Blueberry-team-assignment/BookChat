// comment_model.dart
class Comment {
  final String id;
  final String content;
  final String userId;
  final DateTime createdAt;

  Comment({
    required this.id,
    required this.content,
    required this.userId,
    required this.createdAt,
  });

  factory Comment.fromJson(Map<String, dynamic> json) {
    return Comment(
      id: json['id'],
      content: json['content'],
      userId: json['user_id'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }
}
