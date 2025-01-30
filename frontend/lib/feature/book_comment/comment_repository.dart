import 'package:book_chat/common/repository/token_repository.dart';
import 'package:dio/dio.dart';
import 'package:book_chat/model/book_comment_model.dart';

// comment_repository.dart
class CommentRepository {
  late final Dio _dio;

  CommentRepository() {
    _dio = Dio(BaseOptions(
      baseUrl: 'https://drf-bookchat-test-d3b5e19f0ff5.herokuapp.com/bookchat',
      connectTimeout: const Duration(seconds: 5),
      receiveTimeout: const Duration(seconds: 3),
    ));
    _initializeToken();
  }

  Future<void> _initializeToken() async {
    final tokenRepository = SecureStorageTokenRepository();
    final token = await tokenRepository.getToken();
    if (token != null) {
      _dio.options.headers['Authorization'] = 'Token $token';
      _dio.options.headers['Content-Type'] = 'application/json';
    }
  }

  Future<List<Comment>> getComments(String bookId) async {
    await _initializeToken();
    try {
      final response = await _dio.get('/books/$bookId/comments/');
      print('Response data: ${response.data}'); // 데이터 확인
      return (response.data as List)
          .map((json) => Comment.fromJson(json))
          .toList();
    } catch (e, stackTrace) {
      print('Error: $e');  // 상세 에러 확인
      print('Stack trace: $stackTrace');
      throw Exception('댓글을 불러오는데 실패했습니다');
    }
  }

  Future<Comment> createComment(String bookId, String content) async {
    await _initializeToken();
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
