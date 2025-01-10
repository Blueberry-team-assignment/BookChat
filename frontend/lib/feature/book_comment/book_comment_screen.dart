import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:book_chat/feature/book_comment/provider/comment_provider.dart';
import 'dart:async';
// comment_screen.dart
class CommentScreen extends ConsumerStatefulWidget {
  final String bookId;

  CommentScreen({required this.bookId, Key? key}) : super(key: key);

  @override
  ConsumerState<CommentScreen> createState() => _CommentScreenState();
}

class _CommentScreenState extends ConsumerState<CommentScreen> {
  final TextEditingController _commentController = TextEditingController();
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(Duration(seconds: 3), (_) {
      ref.refresh(commentsProvider(widget.bookId));
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _commentController.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    final comments = ref.watch(commentsProvider(widget.bookId));
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
                      widget.bookId,  // Change here
                      _commentController.text,
                    );
                    _commentController.clear();
                    ref.refresh(commentsProvider(widget.bookId));  // And here
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