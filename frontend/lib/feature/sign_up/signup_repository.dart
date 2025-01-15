import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:book_chat/feature/sign_up/signup_dto.dart';
import 'package:book_chat/common/repository/api_repository.dart';

// Repository interface
abstract class IAuthRepository {
  Future<void> signUp(SignUpDto signUpDto);
}

// Repository implementation
class AuthRepository implements IAuthRepository {
  final ApiRepository _apiRepository;

  AuthRepository({ApiRepository? apiRepository})
      : _apiRepository = apiRepository ?? ApiRepository();

  @override
  Future<void> signUp(SignUpDto signUpDto) async {
    try {
      final response = await _apiRepository.post(
        '/bookchat/signup/',
        body: signUpDto.toJson(),
      );

      if (response.statusCode == 201) {
        return; // 성공
      }

      final errorData = jsonDecode(response.body);
      throw AuthException(
        message: errorData['message'] ?? '회원가입 실패',
        statusCode: response.statusCode,
      );
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