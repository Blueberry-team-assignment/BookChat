import 'dart:async';

import 'package:book_chat/common/repository/api_repository.dart';
import 'package:book_chat/common/repository/token_repository.dart';
import 'package:book_chat/models/bookcomment_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/*
  댓글에 대한 답글 작성 상태 관리 프로바이더입니다.
  UI에서 답글 아이콘 클릭 여부에 따라 (이를 실시간으로 읽어서)

  답글 아이콘을 한번 누르면, 댓글(답글의 부모) id를 부여하고 (답글 상태로 만들고)
  답글 아이콘을 한번 더 누르면, null id를 부여하여 댓글로 만듭니다.
*/
final replyingToProvider = StateProvider<int?>((ref)=>null);

/*
  백엔드 API 통신 프로바이더입니다.
  백엔드에서 댓글의 목록을 가져오고, 작성하여 등록하는 2가지 로직을 가지기 때문에 Service로 명명했습니다.

  http 통신의 get, post 요청을 보낼 때 사용자 인증을 거치기 때문에
  서버와 의존성을 가지는 api repository와 인증 의존성을 가지는 token repository를 생성자에 주입하여 사용합니다.
*/
final commentServiceProvider = Provider<CommentService>((ref){
  final apiRepository = ref.watch(apiRepositoryProvider);
  final tokenRepository = ref.watch(tokenRepositoryProvider);
  return CommentService(apiRepository, tokenRepository);
});

/*
  댓글 목록 상태 관리 프로바이더입니다.

  Service 로직과는 다르게 목록을 3초마다 갱신해서 실시간 상태를 관리하여 목록을 가져오는 역할입니다.
 */
final commentsProvider = FutureProvider.family<List<Comment>, String>((ref, bookId) async{
  Timer? timer;

  ref.onDispose(() => timer?.cancel()); // Provider 내부에서 자동 갱신 로직 처리

  timer = Timer.periodic(Duration(seconds: 3), (_) async {
  ref.invalidateSelf();  // Provider 자신을 갱신
  });

  final commentService = ref.watch(commentServiceProvider); //
  return commentService.getComments(bookId);
});

/*
  댓글 작성 상태 관리 프로바이더입니다.

  AsyncValue로 댓글 작성 시 성공, 로딩, 에러와 같은 댓글 작성 상태를 관리합니다.
 */
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
      // null 체크 추가
      if (response == null) {
        return []; // Return empty list instead of throwing error
      }

      return (response as List).map((json) => Comment.fromJson(json)).toList();
    } catch (e) {
      print('Comments Error: $e'); //
      throw ApiException(message: '댓글을 불러오는데 실패했습니다');
    }
  }

  Future<Comment> createComment(String bookId, String content, {int? parentId}) async{
    try {
      final token = await _tokenRepository.getToken("auth_token");
      final headers = token != null ? {
        'Authorization': 'Token $token'} : null;
      final body = {
        'content': content,
        if (parentId != null) 'parent_id': parentId,
      };

      final response = await _apiRepository.post(
        '/bookchat/books/$bookId/comments/create/',
        body: body,
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

  Future<void> createComment(String bookId, String content, {int? parentId}) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() =>
        _commentService.createComment(bookId, content, parentId: parentId)  // parentId 파라미터 추가
    );
  }
}