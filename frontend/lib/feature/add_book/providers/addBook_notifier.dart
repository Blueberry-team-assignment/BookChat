import 'dart:io';

import 'package:book_chat/common/repository/api_repository.dart';
import 'package:book_chat/dto/addbook_dto.dart';
import 'package:cloudinary_public/cloudinary_public.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final addBookProvider = StateNotifierProvider<AddBookNotifier, AddBookState>((ref){
  final apiRepository = ref.read(apiRepositoryProvider);
  return AddBookNotifier(apiRepository);
});

class AddBookNotifier extends StateNotifier<AddBookState>{
  final ApiRepository _apiRepository;
  final cloudinary = CloudinaryPublic('dwt4yri9e', 'bookchat_preset');  // 여기에 생성한 preset 이름 입력

  AddBookNotifier(this._apiRepository)
    : super(AddBookState(
      addBookDto: AddBookDto(
          title: '',
          keyword: '',
          des: '',
          imgpath: null,
          imgurl: null)
  ));

  void updateAddBookDto(AddBookDto dto){
    state = AddBookState(addBookDto: dto);
  }

  Future<void> uploadImageToStorage(String? imagePath)async {
    if (imagePath == null) {
      throw ApiException(message: '선택된 이미지가 없습니다.');
    }

    try {
      print('이미지 업로드 시작: $imagePath'); // 디버깅용 로그
      // Cloudinary에 직접 업로드

      final file = File(imagePath);
      if (!await file.exists()) {
        throw ApiException(message: '파일을 찾을 수 없습니다.');
      }

      final response = await cloudinary.uploadFile(
        CloudinaryFile.fromFile(
          imagePath,
          resourceType: CloudinaryResourceType.Image,
        ),
      );

      print('Cloudinary 응답: ${response.secureUrl}');

      // final response = await _apiRepository.post_multipart(
      //   '/bookchat/upload_image/',
      //   imagePath,
      // );
      //
      // print('서버 응답: $response'); // 디버깅용 로그

      // 응답에서 이미지 URL을 받아와서 상태 업데이트!
      final updatedDto = AddBookDto(
          title: state.addBookDto.title,
          keyword: state.addBookDto.keyword,
          des: state.addBookDto.des,
          imgpath: state.addBookDto.imgpath,
          imgurl: response.secureUrl  // Cloudinary에서 받은 URL 사용
          // imgurl: response['imageUrl'] // API 응답에서 이미지 URL을 가져옴
      );

      updateAddBookDto(updatedDto);
    } catch (e) {
      print('업로드 에러 상세: $e'); // 디버깅용 로그
      throw ApiException(message: '이미지 업로드 중 오류 발생: $e');
    }
  }

  Future<void> addBook({
    required String title,
    required String keyword,
    required String description,
  }) async {
    try {
      final updatedDto = AddBookDto(
        title: title,
        keyword: keyword,
        des: description,
        imgpath: state.addBookDto.imgpath,
        imgurl: state.addBookDto.imgurl,
      );

      await _apiRepository.post(
        '/bookchat/add_book/',
        body: updatedDto.toJson(),
      );
    } catch (e) {
      throw ApiException(message: '책 정보 저장 중 오류 발생: $e');
    }
  }
}

class AddBookState{
  final AddBookDto addBookDto;

  AddBookState({
    required this.addBookDto
  });
}