import 'package:flutter/material.dart';
import 'package:book_chat/model/model_book.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:book_chat/feature/book_info/provider/book_provider.dart';

class DetailScreen extends ConsumerWidget {
  final Book book;

  const DetailScreen({
    super.key,
    required this.book,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bookState = ref.watch(bookDetailProvider(book));

    return Scaffold(
      body: SafeArea(
        child: ListView(
          children: [
            Stack(
              children: [
                // 뒤로가기 버튼
                Positioned(
                  top: 10,
                  left: 10,
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.black),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                ),
                // 이미지를 감싸는 컨테이너
                Center( // 가로 중앙 정렬
                  child: Container(
                    width: MediaQuery.of(context).size.width * 0.75, // 화면 너비의 3/4
                    padding: const EdgeInsets.only(top: 20), // 상단 여백 추가
                    child: AspectRatio(
                      aspectRatio: 3/4, // 이미지 비율 유지
                      child: Image.network(
                        bookState.poster,
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) {
                          return const Icon(Icons.book);
                        },
                      ),
                    ),
                  ),
                ),
              ],
            ),
            // 책 정보 섹션
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 제목
                  Text(
                    bookState.title,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 15),

                  // 키워드
                  Row(
                    children: [
                      const Text(
                        'Keywords: ',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Expanded(
                        child: Text(
                          bookState.keyword,
                          style: const TextStyle(fontSize: 16),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 10),

                  // 좋아요 상태
                  Row(
                    children: [
                      const Text(
                        'Favorite: ',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      InkWell(  // 클릭 가능하도록 InkWell로 감싸기
                        onTap: (){
                          ref.read(bookDetailProvider(book).notifier).toggleLike();
                        },  // 클릭시 toggleLike 호출
                        child: Icon(
                          bookState.like ? Icons.check : Icons.add,
                          color: bookState.like ? Colors.red : Colors.grey,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 15),

                  // 설명
                  const Text(
                    'Description:',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    height: 200,  // 최대 높이 설정
                    decoration: BoxDecoration(
                      color: Colors.grey[100],  // 배경색 추가
                      borderRadius: BorderRadius.circular(8),  // 모서리 둥글게
                    ),
                    child: SingleChildScrollView(  // 스크롤 가능하게 만듦
                      padding: const EdgeInsets.all(10),
                      child: Text(
                        bookState.description,
                        style: const TextStyle(
                          fontSize: 16,
                          height: 1.5,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
