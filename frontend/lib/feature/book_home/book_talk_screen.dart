import 'package:flutter/material.dart';
import 'package:book_chat/model/model_book.dart';
import 'package:book_chat/model/api_adapter.dart';
import 'package:book_chat/feature/book_home/widget/carousel_slider.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final refreshProvider = StateProvider<int>((ref) => 0);

// 책 목록을 관리할 Provider
final booksProvider = StateNotifierProvider<BooksNotifier, AsyncValue<List<Book>>>((ref) {
  ref.watch(refreshProvider);

  final notifier = BooksNotifier();
  notifier.fetchBooks();
  return notifier;
});

// 책 목록 상태 관리 클래스 (비즈니스 로직)
class BooksNotifier extends StateNotifier<AsyncValue<List<Book>>> {
  BooksNotifier() : super(const AsyncValue.loading());

  Future<void> fetchBooks() async {
    state = const AsyncValue.loading();
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      final response = await http.get(
          Uri.parse('https://drf-bookchat-test-d3b5e19f0ff5.herokuapp.com/bookchat/myList/'),
          headers: {
            'Authorization': 'Token $token',
          }
      );

      print("Response: ${response.statusCode}, ${response.body}");
      if (response.statusCode == 200) {
        final parsedBooks = parseBook(utf8.decode(response.bodyBytes));
        state = AsyncValue.data(parsedBooks);
      }
    } catch (e) {
      print('Error: $e');
      state = AsyncValue.error(e, StackTrace.current);
    }
  }
}

// UI
class BookTalkScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final booksState = ref.watch(booksProvider);
    return ListView(
      children: <Widget>[
        Stack(
          children: <Widget>[
            booksState.when(
              loading: () => Container(
                height: 400,
                child: Center(child: CircularProgressIndicator())
              ),
              error: (error, stack) => Container(
                height: 400,
                child: Center(child: Text('Error: ${error.toString()}'))
              ),
              data: (books) => books.isEmpty
                ? Container(
                    height: 400,
                    child: Center(child: Text('Please add your favorite books!'))
                  )
                : CarouselImage(
                  books: books,
                  onNavigate: () async {
                    await ref.read(booksProvider.notifier).fetchBooks();
                  }
                ),
            ),
            TopBar(),
          ]
        )
      ]
    );
  }
}

class TopBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(20, 7, 20, 7),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          Image.asset(
            'images/nousb.png',
            fit: BoxFit.contain,
            height: 25,
          ),
          Text(
            'NOUS:B',
            style: TextStyle(fontSize: 14, color: Colors.black),
          ),
        ],
      ),
    );
  }
}