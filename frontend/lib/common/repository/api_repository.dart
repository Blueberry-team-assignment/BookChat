import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

final apiRepositoryProvider = Provider<ApiRepository>((ref) {
  return ApiRepository();
});

class ApiRepository {
  static var baseUrl = dotenv.env['BASE_URL'];

  Future<dynamic> get(String endpoint, {Map<String, String>? headers}) async {
    final defaultHeaders = {
      'Content-Type': 'application/json',
    };

    try {
      final response = await http.get(
        Uri.parse('$baseUrl$endpoint'),
        headers: {...defaultHeaders, ...?headers},
      );
      return _handleResponse(response);
    } catch (e) {
      throw Exception('API 요청 중 오류 발생: $e');
    }
  }
  Future<dynamic> post(String endpoint, {required dynamic body, Map<String, String>? headers,}) async {
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
      throw Exception('API 요청 중 오류 발생: $e');
    }
  }

  // Future<dynamic> post_multipart(String endpoint, String filePath) async {
  //   try {
  //     var request = http.MultipartRequest(
  //       'POST',
  //       Uri.parse('$baseUrl$endpoint'),
  //     );
  //
  //     request.files.add(
  //       await http.MultipartFile.fromPath('image', filePath),
  //     );
  //
  //     final streamedResponse = await request.send();
  //     final response = await http.Response.fromStream(streamedResponse);
  //
  //     return _handleResponse(response);
  //   } catch (e) {
  //     throw ApiException(message: '파일 업로드 중 오류 발생: $e');
  //   }
  // }

  dynamic _handleResponse(http.Response response) {
    if (response.statusCode == 201 || response.statusCode == 200) {
      if (response.body.isNotEmpty) {
        return jsonDecode(response.body);
      }
      return null;
    }

    final errorData = jsonDecode(response.body);
    throw ApiException(
      message: errorData['message'] ?? '요청 처리 중 오류가 발생했습니다',
      statusCode: response.statusCode,
    );
  }
}
// Base Exception
class ApiException implements Exception {
  final String message;
  final int? statusCode;

  ApiException({
    required this.message,
    this.statusCode,
  });

  @override
  String toString() => message;
}
