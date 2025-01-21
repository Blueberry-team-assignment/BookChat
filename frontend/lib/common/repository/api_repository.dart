import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiRepository {
  static var baseUrl = dotenv.env['BASE_URL'];
  final http.Client _client;

  ApiRepository({http.Client? client}) : _client = client ?? http.Client();

  Future<dynamic> post(
      String endpoint, {
        required dynamic body,
        Map<String, String>? headers,
      }) async {
    final defaultHeaders = {
      'Content-Type': 'application/json',
    };

    try {
      final response = await _client.post(
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