import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:book_chat/model/book_model.dart';
import 'package:book_chat/feature/book_memo/book_memo_screen.dart';
import 'package:book_chat/feature/chat_rooms/chat_rooms_screen.dart';
import 'package:book_chat/feature/book_comment/book_comment_screen.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_riverpod/flutter_riverpod.dart';

final currentPageProvider = StateProvider<int>((ref)=>0);
final carouselProvider = StateNotifierProvider<CarouselNotifier, CarouselState>((ref){
  return CarouselNotifier();
});

class CarouselState{
  final List<Book> books;
  final List<bool> likes;
  final List<String> keywords;
  final List<Widget> images;

  CarouselState({
    required this.books,
    required this.likes,
    required this.keywords,
    required this.images,
  });

  factory CarouselState.initial(){
    return CarouselState(
      books: [],
      likes: [],
      keywords: [],
      images: [],
    );
  }

  CarouselState copyWith({
    List<Book>? books,
    List<bool>? likes,
    List<String>? keywords,
    List<Widget>? images,
  }) {
    return CarouselState(
      books: books ?? this.books,
      likes: likes ?? this.likes,
      keywords: keywords ?? this.keywords,
      images: images ?? this.images,
    );
  }
}

class CarouselNotifier extends StateNotifier<CarouselState> {
  CarouselNotifier() : super(CarouselState.initial());

  // CarouselNotifier 수정
  void initializeState(List<Book> books) async {
    // final prefs = await SharedPreferences.getInstance();
    // final token = prefs.getString('auth_token');
    const storage = FlutterSecureStorage();
    final token = await storage.read(key: 'auth_token');
    final url = Uri.parse('https://drf-bookchat-test-d3b5e19f0ff5.herokuapp.com/bookchat/myList/');

    try {
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Token $token',
        },
      );

      if (response.statusCode == 200) {
        final myListBooks = json.decode(response.body) as List;
        final myListIds = myListBooks.map((book) => book['id'] as int).toSet();

        final images = books.map((m) => Image.network(m.poster)).toList();
        final keywords = books.map((m) => m.keyword).toList();
        final likes = books.map((m) => myListIds.contains(m.id)).toList();

        state = CarouselState(
          books: books,
          likes: likes,
          keywords: keywords,
          images: images,
        );
      }
    } catch (e) {
      print('Error fetching myList: $e');
    }
  }

  Future<void> toggleLike(int index, int bookId) async {
    const storage = FlutterSecureStorage();
    final token = await storage.read(key: 'auth_token');
    final url = Uri.parse(
        'https://drf-bookchat-test-d3b5e19f0ff5.herokuapp.com/bookchat/book_like/');

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Token $token',
        },
        body: json.encode({'book_id': bookId}),
      );

      print('Response Status: ${response.statusCode}'); // 응답 상태 확인
      print('Response Body: ${response.body}'); // 응답 내용 확인

      if (response.statusCode == 200) {
        final result = json.decode(response.body);
        List<bool> newLikes = [...state.likes];
        newLikes[index] = result['like'];
        state = state.copyWith(likes: newLikes);
      }
    } catch (e) {
      print('Error toggling like: $e');
    }
  }
}

class CarouselImage extends ConsumerStatefulWidget {
  final List<Book> books;
  final VoidCallback onNavigate;

  CarouselImage({
    required this.books, 
    required this.onNavigate,
  });

  @override
  ConsumerState<CarouselImage> createState() => _CarouselImageState();
}

class _CarouselImageState extends ConsumerState<CarouselImage> {
  @override
  void initState() {
    super.initState();
    // 다음 프레임에서 초기화하도록 예약
    Future.microtask(() {
      ref.read(carouselProvider.notifier).initializeState(widget.books);
    });
  }

  @override
  Widget build(BuildContext context) {
    final currentPage = ref.watch(currentPageProvider);
    final carouselState = ref.watch(carouselProvider);

    if (carouselState.books.isEmpty ||
        carouselState.likes.isEmpty ||
        carouselState.keywords.isEmpty ||
        carouselState.images.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    return Container(
        height: MediaQuery.of(context).size.height - 200, // 전체 화면 높이 설정

        child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Container(
                padding: EdgeInsets.all(20),
              ),
              CarouselSlider(
                options: CarouselOptions(
                  height: 200.0,
                  autoPlay: false,
                  enlargeCenterPage: true,
                  onPageChanged: (index, reason) {
                    ref.read(currentPageProvider.notifier).state = index;
                  },
                ),
                items: carouselState.images,
              ),
              Container(
                padding: EdgeInsets.fromLTRB(0, 10, 0, 3),
                child: Text(
                  carouselState.keywords[currentPage],
                  style: TextStyle(fontSize: 11),
                ),
              ),
              Container(
                  child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  Container(
                      child: Column(
                    children: <Widget>[
                      carouselState.likes[currentPage]
                          ? IconButton(
                              icon: Icon(Icons.check),
                              onPressed: () {
                                ref.read(carouselProvider.notifier).toggleLike(
                                  currentPage, 
                                  carouselState.books[currentPage].id
                                );
                              },
                            )
                          : IconButton(
                              icon: Icon(Icons.add),
                              onPressed: () {
                                ref.read(carouselProvider.notifier).toggleLike(
                                  currentPage,
                                  carouselState.books[currentPage].id
                                );
                              },
                            ),
                      Text(
                        'My List',
                        style: TextStyle(fontSize: 11),
                      )
                    ],
                  )),
                  Container(
                      padding: EdgeInsets.only(),
                      child: Column(
                        children: <Widget>[
                          IconButton(
                            icon: Icon(Icons.chat),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => CommentScreen(
                                    bookId: carouselState.books[currentPage].id.toString(),
                                  ),
                                ),
                              );
                              widget.onNavigate(); // 콜백 호출
                             // print("Chat button pressed");
                            },
                          ),
                          Text(
                            'Chat',
                            style: TextStyle(fontSize: 11),
                          )
                        ],
                      )),
                  Container(
                      padding: EdgeInsets.only(),
                      child: Column(
                        children: <Widget>[
                          IconButton(
                            icon: Icon(Icons.edit_note),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => BookMemoScreen(
                                    bookId: carouselState.books[currentPage].id
                                  ),
                                ),
                              );
                              widget.onNavigate(); // 콜백 호출
                            },
                          ),
                          Text(
                            'Notes',
                            style: TextStyle(fontSize: 11),
                          )
                        ],
                      )),
                ],
              )),
              Container(
                  child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: makeIndicator(carouselState.likes, currentPage),
              ))
            ]));
  }
}

List<Widget> makeIndicator(List list, int currentPage) {
  List<Widget> results = [];
  for (var i = 0; i < list.length; i++) {
    results.add(Container(
      width: 8,
      height: 8,
      margin: EdgeInsets.symmetric(vertical: 10.0, horizontal: 2.0),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: currentPage == i
            ? Color.fromRGBO(0, 0, 0, 0.9)
            : Color.fromRGBO(0, 0, 0, 0.4),
      ),
    ));
  }
  return results;
}
