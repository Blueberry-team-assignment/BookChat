import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiRepository {
  static const baseUrl = 'https://drf-bookchat-test-d3b5e19f0ff5.herokuapp.com';
  final http.Client _client;

  ApiRepository({http.Client? client}) : _client = client ?? http.Client();

  Future<http.Response> post(
      String endpoint, {
        required Map<String, dynamic> body,
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
      return response;
    } catch (e) {
      throw NetworkException('네트워크 오류: $e');
    }
  }
}

class NetworkException implements Exception {
  final String message;
  NetworkException(this.message);
}