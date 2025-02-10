import 'package:book_chat/common/repository/api_repository.dart';
import 'package:book_chat/common/repository/token_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final commentWriteProvider = StateNotifierProvider<CommentWriteNotifier, AsyncValue<void>>((ref){
  return CommentWriteNotifier(
      ref.watch(apiRepositoryProvider),
      ref.watch(tokenRepositoryProvider)
  );
});

final replyingToProvider = StateProvider<int?>((ref) => null);

class CommentWriteNotifier extends StateNotifier<AsyncValue<void>>{
  final ApiRepository _repository;
  final TokenRepository _tokenRepository;

  CommentWriteNotifier(this._repository, this._tokenRepository)
      : super(const AsyncValue.data(null));

  Future<void> createComment(String bookId, String content, {int? parentId}) async{
    state = const AsyncValue.loading();

    try{
      final token = await _tokenRepository.getToken("auth_token");
      final headers = token!=null?{'Authorization':'Token $token'} : null;

      final body = {
        'content': content,
        if(parentId != null) 'parent_id' : parentId,
      };

      await _repository.post(
          '/bookchat/books/$bookId/comments/create/',
          body: body,
          headers: headers
      );

      if (!mounted) return;
      state = const AsyncValue.data(null);
    } catch (error, stackTrace){
      if (!mounted) return;
      state = AsyncValue.error(error, stackTrace);
    }
  }
}