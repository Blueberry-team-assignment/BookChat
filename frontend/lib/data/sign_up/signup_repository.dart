import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:book_chat/dto/signup_dto.dart';
import 'package:book_chat/common/repository/api_repository.dart';
// Repository interface
abstract class IAuthRepository {
  Future<dynamic> signUp({
    required SignUpDto signupDto
  });
}

// Provider 정의
final authRepositoryProvider = Provider<IAuthRepository>((ref) {
  return AuthRepository();
});

// Repository implementation
class AuthRepository implements IAuthRepository {
  final ApiRepository _apiRepository;

  AuthRepository({ApiRepository? apiRepository})
      : _apiRepository = apiRepository ?? ApiRepository();

  @override
  Future<dynamic> signUp({
    required SignUpDto signupDto
  }) async {
    try {
      final response = await _apiRepository.post(
        '/bookchat/signup/',
        body: signupDto.toJson(),
      );

    } catch (e) {
      if (e is AuthException) rethrow;
      throw AuthException(message: '회원가입 처리 중 오류 발생: $e');
    }
  }
}



