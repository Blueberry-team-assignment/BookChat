import 'dart:io';
import 'package:book_chat/feature/add_book/providers/getImage_notifier.dart';
import 'package:book_chat/feature/add_book/providers/addBook_notifier.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AddBookScreen extends ConsumerStatefulWidget {

  const AddBookScreen({super.key});

  @override
  ConsumerState<AddBookScreen> createState() => _AddBookScreenState();
}

class _AddBookScreenState extends ConsumerState<AddBookScreen> {

  final titleController = TextEditingController();
  final keywordController = TextEditingController();
  final descriptionController = TextEditingController();

  @override
  void dispose() {
    titleController.dispose();
    keywordController.dispose();
    descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final imgstate = ref.watch(getImageProvider);
    final imagePath = imgstate.addBookDto.imgpath;

    return Scaffold(
      appBar: AppBar(
        title: const Text("책 등록하기"),
      ),
      body: Form(
        child: Column(
          children: [
            Stack(
              children: [
                // 이미지 선택 영역
                Center(
                  child: Container(
                    width: MediaQuery.of(context).size.width * 0.5,
                    child: Column(
                      children: [
                        GestureDetector(
                          onTap: (){
                            ref.read(getImageProvider.notifier).getImageFromGallery();
                          },
                          child: AspectRatio(
                            aspectRatio: 3/4,
                            child: Container(
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: imagePath != null
                                  ? ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.file(
                                  File(imagePath),
                                  fit: BoxFit.cover,
                                ),
                              )
                                  : Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: const [
                                  Icon(Icons.add_photo_alternate, size: 50),
                                  SizedBox(height: 8),
                                  Text('탭하여 이미지 선택'),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            // 책 정보 입력 섹션
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 제목 입력
                  TextField(
                    controller: titleController,
                    decoration: const InputDecoration(
                      labelText: 'Title',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 15),

                  // 키워드 입력
                  TextField(
                    controller: keywordController,
                    decoration: const InputDecoration(
                      labelText: 'Keywords',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 15),

                  // 설명 입력
                  Container(
                    height: 200,
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: TextField(
                      controller: descriptionController,
                      maxLines: null,
                      decoration: const InputDecoration(
                        labelText: 'Description',
                        border: OutlineInputBorder(),
                        alignLabelWithHint: true,
                      ),
                    ),
                  ),

                  // 저장 버튼
                  ElevatedButton(
                    onPressed: () async{
                      // 유효성 검증을 위해 path를 인자로 받지 않고 uploadImageToStorage() 내부에서 한번 더 확인함
                      ref.read(addBookProvider.notifier).uploadImageToStorage();
                      await ref.read(addBookProvider.notifier).addBook(
                        title: titleController.text,
                        keyword: keywordController.text,
                        description: descriptionController.text,
                      );
                    },
                    child: const Text(
                      'Save Book',
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
