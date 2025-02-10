import 'package:book_chat/feature/book_comment/provider/readComments_notifier.dart';
import 'package:book_chat/feature/book_comment/provider/writeComment_notifier.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
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

  // @override
  // void initState() {
  //   super.initState();
  //   // 3초마다 자동으로 댓글 목록을 새로고침하는 타이머 설정
  //   _timer = Timer.periodic(Duration(seconds: 3), (_) {
  //     ref.refresh(commentsProvider(widget.bookId));
  //   });
  // }

  @override
  void dispose() {
    _timer?.cancel();
    _commentController.dispose();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    final comments = ref.watch(commentsReadProvider(widget.bookId));
    final createCommentState = ref.watch(commentWriteProvider);
    final replyingTo = ref.watch(replyingToProvider); // 답글 작성 중인 댓글 ID

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

                  if(comment.parentId!=null) return Container(); // 답글인 경우 건너뛰기 (답글은 부모 댓글 아래에 표시됨)

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // main comment
                      ListTile(
                    title: Text(comment.content),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("user: "+comment.userName),  // 사용자 이름 표시
                        Text(DateFormat('yyyy-MM-dd HH:mm').format(comment.createdAt)),
                      ],
                    ),
                    trailing: IconButton( // 답글 작성 버튼
                      icon: Icon(Icons.reply),
                      onPressed: () => ref.read(replyingToProvider.notifier).state =
                  replyingTo == comment.id ? null: comment.id,
                  ),
                  ),
                      if (replyingTo == comment.id) // 답글 작성 폼 (선택된 댓글에만 표시)
                        Padding(
                          padding: EdgeInsets.only(left: 32),
                          child: Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: _commentController,
                                  decoration: InputDecoration(hintText: 'Reply...'),
                                ),
                              ),
                              IconButton( // 답글 저장 버튼
                                icon: Icon(Icons.send),
                                onPressed: () async {
                                  if (_commentController.text.isEmpty) return;
                                  await ref.read(commentWriteProvider.notifier)
                                      .createComment(widget.bookId, _commentController.text, parentId: replyingTo);
                                  _commentController.clear();
                                  ref.read(replyingToProvider.notifier).state = null;
                                  ref.refresh(commentsReadProvider(widget.bookId));
                                },
                              ),
                            ],
                          ),
                        ),
                      // 대댓글 목록
                      if (comment.replies.isNotEmpty)
                        Padding(
                          padding: EdgeInsets.only(left: 32),
                          child: Column(
                            children: comment.replies
                                .map((reply) => ListTile(
                              title: Text(reply.content),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text("replyuser: "+reply.userName),  // 사용자 이름 표시
                                  Text(DateFormat('yyyy-MM-dd HH:mm').format(reply.createdAt)),
                                ],
                              ),
                            )).toList(),
                          ),
                        ),
                    ],
                  );
                },
              ),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => Center(child: Text('Error: $error')),
            ),
          ),
          // main comment input form
          if(replyingTo == null)
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
                    await ref.read(commentWriteProvider.notifier).createComment(
                      widget.bookId,  // Change here
                      _commentController.text,
                    );
                    _commentController.clear();
                    ref.refresh(commentsReadProvider(widget.bookId));  // And here
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