import 'package:book_chat/common/repository/token_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:book_chat/model/book_model.dart';

final bookDetailProvider = NotifierProvider.family<BookDetailNotifier, Book, Book>((){
  return BookDetailNotifier();
});

class BookDetailNotifier extends FamilyNotifier<Book, Book>{
  @override
  Book build(Book arg){
    return arg;
  }

  Future<void> toggleLike() async {
    final tokenRepository = SecureStorageTokenRepository();
    final token = await tokenRepository.getToken("auth_token");
    final url = Uri.parse('https://drf-bookchat-test-d3b5e19f0ff5.herokuapp.com/bookchat/book_like/');

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Token $token',
        },
        body: json.encode({'book_id': state.id}),
      );
      print('Response: ${response.statusCode}, ${response.body}');
      if (response.statusCode == 200) {
        final result = json.decode(response.body);
        state = state.copyWith(like: result['like']);
      }
    } catch (e) {
      print('Error toggling like: $e');
    }
  }
}
