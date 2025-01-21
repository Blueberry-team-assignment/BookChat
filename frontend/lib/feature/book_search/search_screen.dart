import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:book_chat/model/book_model.dart';
import 'package:book_chat/feature/book_info/book_info_screen.dart';

class SearchScreen extends StatefulWidget {
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _filter = TextEditingController();
  FocusNode focusNode = FocusNode();
  String _searchText = "";

  _SearchScreenState() {
    _filter.addListener(() {
      setState(() {
        _searchText = _filter.text;
      });
    });
  }

  Widget _buildBody(BuildContext context) {
    return FutureBuilder<List<Book>>(
        future: fetchBooks(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No books found'));
          }

          return _buildList(context, snapshot.data!);
        }
    );
  }

  Future<List<Book>> fetchBooks() async {
    final response = await http.get(
        Uri.parse('https://drf-bookchat-test-d3b5e19f0ff5.herokuapp.com/bookchat/books/'),
        headers: {
          'Content-Type': 'application/json',
        }
    );

    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      return data.map((json) => Book.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load books: ${response.statusCode}');
    }
  }

  Widget _buildList(BuildContext context, List<Book> books) {
    List<Book> searchResults = [];

    // 검색어로 책 필터링
    for (Book book in books) {
      if (book.title.toLowerCase().contains(_searchText.toLowerCase()) ||
          book.keyword.toLowerCase().contains(_searchText.toLowerCase())) {
        searchResults.add(book);
      }
    }

    return Expanded(
      child: GridView.count(
        crossAxisCount: 3,  // 한 줄에 3개의 아이템
        childAspectRatio: 1 / 1.5,  // 아이템의 가로:세로 비율
        padding: EdgeInsets.all(3),
        children: searchResults.map((book) => _buildListItem(context, book)).toList(),
      ),
    );
  }

  Widget _buildListItem(BuildContext context, Book book) {
    return InkWell(
      child: Image.network(
        book.poster,
        errorBuilder: (context, error, stackTrace) {
          return const Icon(Icons.book);
        },
      ),
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute<void>(
            fullscreenDialog: true,
            builder: (BuildContext context) {
              return DetailScreen(book: book);  // 상세 화면으로 이동
            },
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        child: Column(
      children: <Widget>[
        Padding(
          padding: EdgeInsets.all(30),
        ),
        Container(
          color: Colors.blueGrey,
          padding: EdgeInsets.fromLTRB(5, 10, 5, 10),
          child: Row(
            children: <Widget>[
              Expanded(
                flex: 5,
                child: TextField(
                  focusNode: focusNode,
                  style: TextStyle(
                    fontSize: 15,
                  ),
                  autofocus: true,
                  controller: _filter,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white24,
                    prefixIcon: Icon(
                      Icons.search,
                      color: Colors.white,
                      size: 20,
                    ),
                    suffixIcon: focusNode.hasFocus
                        ? IconButton(
                            icon: Icon(
                              Icons.cancel,
                              color: Colors.white,
                              size: 20,
                            ),
                            onPressed: () {
                              setState(() {
                                _filter.clear();
                                _searchText = "";
                              });
                            },
                          )
                        : Container(),
                    hintText: 'Search',
                    labelStyle: TextStyle(color: Colors.white),
                    focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.transparent),
                        borderRadius: BorderRadius.all(Radius.circular(10))),
                    enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.transparent),
                        borderRadius: BorderRadius.all(Radius.circular(10))),
                    border: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.transparent),
                        borderRadius: BorderRadius.all(Radius.circular(10))),
                  ),
                ),
              ),
              focusNode.hasFocus
                  ? Expanded(
                      child: TextButton(
                        child: Text('Cancel',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.white,
                            )),
                        onPressed: (){
                          setState(() {
                            _filter.clear();
                            _searchText = "";
                            focusNode.unfocus();
                          });
                        },
                      ),
                    )
                  : Expanded(
                      flex: 0,
                      child: Container(),
                    )
            ],
          ),
        ),
        _buildBody(context),
      ],
    ));
  }
}
