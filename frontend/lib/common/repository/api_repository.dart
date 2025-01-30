import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiRepository {
  static var baseUrl = dotenv.env['BASE_URL'];

  Future<dynamic> post(
    String endpoint, {
      required dynamic body,
      Map<String, String>? headers,
    }) async {
  final defaultHeaders = {
    'Content-Type': 'application/json',
  };

    try {
      final response = await http.post(
        Uri.parse('$baseUrl$endpoint'),
        body: jsonEncode(body),
        headers: {...defaultHeaders, ...?headers},
      );
      return _handleResponse(response);
    } catch (e) {
      if (e is AuthException) rethrow;
      throw AuthException(message: '회원가입 처리 중 오류 발생: $e');
    }
  }

  dynamic _handleResponse(dynamic response) {
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
        message: errorData['email'][0],  // "user with this email already exists"
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