import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:book_chat/feature/book_memo/provider/memo_provider.dart';

class BookMemoScreen extends ConsumerStatefulWidget {
  final int bookId;
  
  BookMemoScreen({required this.bookId});
  
  @override
  _BookMemoScreenState createState() => _BookMemoScreenState();
}

class _BookMemoScreenState extends ConsumerState<BookMemoScreen> {
  final TextEditingController _memoController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(memoProvider(widget.bookId).notifier).loadMemo();
    });
  }

  @override
  void dispose() {
    _memoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final memoState = ref.watch(memoProvider(widget.bookId));

    // 상태가 변경될 때 컨트롤러 텍스트 업데이트
    if (_memoController.text != memoState.content) {
      _memoController.text = memoState.content;
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Notes'),
        actions: [
          IconButton(
            icon: Icon(memoState.isEditing ? Icons.save : Icons.edit),
            onPressed: memoState.isLoading
                ? null
                : () {
                    final notifier = ref.read(memoProvider(widget.bookId).notifier);
                    if (memoState.isEditing) {
                      notifier.saveMemo(_memoController.text);
                    } else {
                      notifier.toggleEditing();
                    }
                  },
          ),
        ],
      ),
      body: memoState.isLoading
          ? Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                controller: _memoController,
                enabled: memoState.isEditing,
                maxLines: null,
                decoration: InputDecoration(
                  hintText: 'You can note your thoughts..',
                  border: InputBorder.none,
                ),
                style: TextStyle(
                  fontSize: 16,
                  height: 1.5,
                ),
              ),
            ),
    );
  }
}