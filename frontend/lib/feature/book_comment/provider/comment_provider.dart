import 'package:book_chat/model/book_comment_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:book_chat/feature/book_comment/comment_repository.dart';
// comment_provider.dart
final commentRepositoryProvider = Provider((ref) => CommentRepository());

final commentsProvider = FutureProvider.family<List<Comment>, String>((ref, bookId) async {
  final repository = ref.watch(commentRepositoryProvider);
  return repository.getComments(bookId);
});

final createCommentProvider = StateNotifierProvider<CreateCommentNotifier, AsyncValue<void>>((ref) {
  return CreateCommentNotifier(ref.watch(commentRepositoryProvider));
});

class CreateCommentNotifier extends StateNotifier<AsyncValue<void>> {
  final CommentRepository _repository;

  CreateCommentNotifier(this._repository) : super(const AsyncValue.data(null));

  Future<void> createComment(String bookId, String content) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _repository.createComment(bookId, content));
  }
}
