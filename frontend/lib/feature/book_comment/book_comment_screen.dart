import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import 'package:intl/intl.dart';
import 'package:book_chat/model/book_comment.dart';

// comment_repository.dart
class CommentRepository {
  final Dio _dio;

  CommentRepository() : _dio = Dio(BaseOptions(
    baseUrl: 'https://drf-bookchat-test-d3b5e19f0ff5.herokuapp.com/bookchat',
    connectTimeout: const Duration(seconds: 5),
    receiveTimeout: const Duration(seconds: 3),
  ));

  Future<List<Comment>> getComments(String bookId) async {
    try {
      final response = await _dio.get('/books/$bookId/comments/');
      return (response.data as List)
          .map((json) => Comment.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('댓글을 불러오는데 실패했습니다');
    }
  }

  Future<Comment> createComment(String bookId, String content) async {
    try {
      final response = await _dio.post(
        '/books/$bookId/comments/create/',
        data: {'content': content},
      );
      return Comment.fromJson(response.data);
    } catch (e) {
      throw Exception('댓글 작성에 실패했습니다');
    }
  }
}

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

// comment_screen.dart
class CommentScreen extends ConsumerWidget {
  final String bookId;
  final TextEditingController _commentController = TextEditingController();

  CommentScreen({required this.bookId, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final comments = ref.watch(commentsProvider(bookId));
    final createCommentState = ref.watch(createCommentProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Comment')),
      body: Column(
        children: [
          Expanded(
            child: comments.when(
              data: (comments) => ListView.builder(
                itemCount: comments.length,
                itemBuilder: (context, index) {
                  final comment = comments[index];
                  return ListTile(
                    title: Text(comment.content),
                    subtitle: Text(
                      DateFormat('yyyy-MM-dd HH:mm').format(comment.createdAt),
                    ),
                  );
                },
              ),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => Center(child: Text('Error: $error')),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _commentController,
                    decoration: const InputDecoration(
                      hintText: 'Leave comments',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: createCommentState.isLoading
                      ? null
                      : () async {
                    if (_commentController.text.isEmpty) return;

                    await ref.read(createCommentProvider.notifier).createComment(
                      bookId,
                      _commentController.text,
                    );

                    _commentController.clear();
                    ref.refresh(commentsProvider(bookId));
                  },
                  child: createCommentState.isLoading
                      ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                      : const Text('Save'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}