import 'package:freezed_annotation/freezed_annotation.dart';

part 'bookcomment_model.freezed.dart';
part 'bookcomment_model.g.dart';

@freezed
class Comment with _$Comment {
  const factory Comment({
    required int id,
    required String content,
    @JsonKey(name: 'user_name') required String userName,
    @JsonKey(name: 'created_at') required DateTime createdAt,
    @JsonKey(name: 'parent') int? parentId,
    @Default([]) List<Comment> replies,
  }) = _Comment;

  factory Comment.fromJson(Map<String, dynamic> json) => _$CommentFromJson(json);
}