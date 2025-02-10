import 'dart:async';

import 'package:book_chat/common/repository/api_repository.dart';
import 'package:book_chat/common/repository/token_repository.dart';
import 'package:book_chat/models/bookcomment_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final commentsReadProvider = StateNotifierProvider.family<CommentsNotifier, AsyncValue<List<Comment>>, String>((ref, bookId){
  final notifier = CommentsNotifier(
      ref.watch(apiRepositoryProvider),
      ref.watch(tokenRepositoryProvider)
  );
  notifier.startFetching(bookId);
  return notifier;
});

class CommentsNotifier extends StateNotifier<AsyncValue<List<Comment>>>{
  final ApiRepository _repository;
  final TokenRepository _tokenRepository;

  Timer? _timer;
  String? _currentBookId;

  CommentsNotifier(this._repository, this._tokenRepository)
      : super(const AsyncValue.loading());

  void startFetching(String bookId){
    _currentBookId = bookId;
    _fetchComments();
    _timer = Timer.periodic(const Duration(seconds: 3), (_){
      _fetchComments();
    });
  }

  Future<void> _fetchComments() async{
    if (_currentBookId == null) return;

    try{
      final token = await _tokenRepository.getToken("auth_token");
      final headers = token != null ? {'Authorization': 'Token $token'} : null;

      final response = await _repository.get(
        '/bookchat/books/$_currentBookId/comments/',
        headers: headers,
      );

      final comments = response != null
          ? (response as List).map((json) => Comment.fromJson(json)).toList()
          : <Comment>[];

      if (!mounted) return;
      state = AsyncValue.data(comments);
    } catch(error, stackTrace){// stackTrace: 에러 발생 경로와 위치 추적 가능

      if (!mounted) return;
      state = AsyncValue.error(error, stackTrace);
    }
  }

  @override
  void dispose(){
    _timer?.cancel();
    super.dispose();
  }
}