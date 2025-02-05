import 'package:book_chat/feature/book_search/search_screen.dart';
import 'package:book_chat/common/widget/bottom_bar.dart';
import 'package:book_chat/feature/login/login_screen.dart';
import 'package:book_chat/feature/my_page/my_page_screen.dart';
import 'package:flutter/material.dart';
import 'package:book_chat/feature/book_home/book_talk_screen.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

Future<void> main() async {

  await dotenv.load(fileName: ".env");

  runApp(
    ProviderScope(
      child: MyApp(),
      ),
  );
}

class MyApp extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Book Chat',
      theme: ThemeData(
        brightness: Brightness.light,
        primaryColor: Colors.lime,
        //accentColor: Colors.black
      ),
      // 초기 라우트 설정
      initialRoute: '/login',  // 앱 시작시 로그인 화면으로
      routes: {
        '/login': (context) => LoginScreen(),
        '/home': (context) => DefaultTabController(
          length: 3,
          child: Scaffold(
            body: TabBarView(
              physics: NeverScrollableScrollPhysics(),
              children: [
                BookTalkScreen(),
                SearchScreen(),
                MyPageScreen(),
              ],
            ),
            bottomNavigationBar: Bottom(),
          ),
        ),
      },
    );
  }
}
