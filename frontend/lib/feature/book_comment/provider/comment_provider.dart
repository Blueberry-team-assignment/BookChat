import 'package:book_chat/common/repository/api_repository.dart';
import 'package:book_chat/common/repository/token_repository.dart';
import 'package:book_chat/model/book_comment_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final commentServiceProvider = Provider<CommentService>((ref){
  final apiRepository = ref.watch(apiRepositoryProvider);
  final tokenRepository = ref.watch(tokenRepositoryProvider);
  return CommentService(apiRepository, tokenRepository);
});

final commentsProvider = FutureProvider.family<List<Comment>, String>((ref, bookId) async{
  final commentService = ref.watch(commentServiceProvider);
  return commentService.getComments(bookId);
});

final createCommentProvider = StateNotifierProvider<CreateCommentNotifier, AsyncValue<void>>((ref){
  return CreateCommentNotifier(ref.watch(commentServiceProvider));
});

class CommentService{
  final ApiRepository _apiRepository;
  final TokenRepository _tokenRepository;

  CommentService(this._apiRepository, this._tokenRepository);

  Future<List<Comment>> getComments(String bookId) async{
    try {
      final token = await _tokenRepository.getToken("auth_token");
      final headers = token != null ? {'Authorization': 'Token $token'} : null;

      final response = await _apiRepository.get(
        '/bookchat/books/$bookId/comments/',
        headers: headers,
      );

      print('Comments API Response: $response'); // 디버깅용 로그 추가
      return (response as List).map((json) => Comment.fromJson(json)).toList();
    } catch (e) {
      print('Comments Error: $e'); //
      throw ApiException(message: '댓글을 불러오는데 실패했습니다');
    }
  }

  Future<Comment> createComment(String bookId, String content) async{
    try {
      final token = await _tokenRepository.getToken("auth_token");
      final headers = token != null ? {'Authorization': 'Token $token'} : null;

      final response = await _apiRepository.post(
        '/bookchat/books/$bookId/comments/create/',
        body: {'content': content},
        headers: headers,
      );
      return Comment.fromJson(response);
    } catch (e) {
      throw ApiException(message: '댓글 작성에 실패했습니다');
    }
  }
}

class CreateCommentNotifier extends StateNotifier<AsyncValue<void>> {
  final CommentService _commentService;

  CreateCommentNotifier(this._commentService): super(const AsyncValue.data(null));

  Future<void> createComment(String bookId, String content) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(()=> _commentService.createComment(bookId, content));
  }
}