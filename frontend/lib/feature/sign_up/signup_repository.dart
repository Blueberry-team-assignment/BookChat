import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:book_chat/feature/sign_up/signup_dto.dart';
import 'package:book_chat/common/repository/api_repository.dart';

// Repository interface
abstract class IAuthRepository {
  Future<dynamic> signUp({
    required SignUpDto signupDto
  });
}

// Repository implementation
class AuthRepository implements IAuthRepository {
  final ApiRepository _apiRepository;

  AuthRepository({ApiRepository? apiRepository})
      : _apiRepository = apiRepository ?? ApiRepository();

  dynamic _handleResponse(dynamic response) {
    if (response.statusCode == 201 || response.statusCode == 200) {
      // Response body가 있다면 파싱하여 반환, 없다면 null 반환
      if (response.body.isNotEmpty) {
        return jsonDecode(response.body);
      }
      return null;
    }

    final errorData = jsonDecode(response.body);
    throw AuthException(
      message: errorData['message'] ?? '요청 처리 실패',
      statusCode: response.statusCode,
    );
  }

  @override
  Future<dynamic> signUp({
    required SignUpDto signupDto
  }) async {
    try {
      final response = await _apiRepository.post(
        '/bookchat/signup/',
        body: signupDto.toJson(),
      );

      // dynamic _handleResponse로 로직 분리
      return _handleResponse(response);
    } catch (e) {
      if (e is AuthException) rethrow;
      throw AuthException(message: '회원가입 처리 중 오류 발생: $e');
    }
  }
}

// Provider 정의
final authRepositoryProvider = Provider<IAuthRepository>((ref) {
  return AuthRepository();
});

// Exception handling
class AuthException implements Exception {
  final String message;
  final int? statusCode;

  AuthException({
    required this.message,
    this.statusCode,
  });

  @override
  String toString() => message;
}

