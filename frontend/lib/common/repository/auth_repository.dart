import 'dart:convert';
import 'package:book_chat/common/repository/api_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository();
});

class AuthRepository extends ApiRepository {
  @override
  Future<dynamic> post(
      String endpoint, {
        required dynamic body,
        Map<String, String>? headers,
      }) async {
    try {
      final response = await super.post(endpoint, body: body, headers: headers);
      return response;
    } catch (e) {
      if (e is AuthException) rethrow;
      throw AuthException(message: '회원가입 처리 중 오류 발생: $e');
    }
  }

  @override
  dynamic _handleResponse(http.Response response) {
    if (response.statusCode == 201 || response.statusCode == 200) {
      if (response.body.isNotEmpty) {
        return jsonDecode(response.body);
      }
      return null;
    }

    final errorData = jsonDecode(response.body);
    // 이메일 관련 에러 메시지 처리
    if (errorData['email'] != null && errorData['email'] is List) {
      throw AuthException(
        message: errorData['email'][0],
        statusCode: response.statusCode,
      );
    }

    // 다른 필드의 에러 메시지도 처리
    if (errorData['password'] != null && errorData['password'] is List) {
      throw AuthException(
        message: errorData['password'][0],
        statusCode: response.statusCode,
      );
    }

    if (errorData['name'] != null && errorData['name'] is List) {
      throw AuthException(
        message: errorData['name'][0],
        statusCode: response.statusCode,
      );
    }

    // 기본 에러 메시지
    throw AuthException(
      message: errorData['message'] ?? '요청 처리 중 오류가 발생했습니다',
      statusCode: response.statusCode,
    );
  }
}

// Auth specific Exception
class AuthException extends ApiException {
  AuthException({
    required String message,
    int? statusCode,
  }) : super(message: message, statusCode: statusCode);
}