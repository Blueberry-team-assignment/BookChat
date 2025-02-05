import 'package:book_chat/common/repository/api_repository.dart';
import 'package:book_chat/dto/addbook_dto.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final addBookProvider = StateNotifierProvider<AddBookNotifier, AddBookState>((ref){
  final apiRepository = ref.read(apiRepositoryProvider);
  return AddBookNotifier(apiRepository);
});

class AddBookNotifier extends StateNotifier<AddBookState>{
  final ApiRepository _apiRepository;

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

  Future<void> uploadImageToStorage()async {
    if (state.addBookDto.imgpath == null) {
      throw ApiException(message: '선택된 이미지가 없습니다.');
    }

    try {
      final response = await _apiRepository.post(
        '/bookchat/upload-image/',
        body: {
          'image': state.addBookDto.imgpath,
        },
      );

      // 응답에서 이미지 URL을 받아와서 상태 업데이트
      final updatedDto = AddBookDto(
          title: state.addBookDto.title,
          keyword: state.addBookDto.keyword,
          des: state.addBookDto.des,
          imgpath: state.addBookDto.imgpath,
          imgurl: response['imageUrl'] // API 응답에서 이미지 URL을 가져옴
      );

      updateAddBookDto(updatedDto);
      return response;
    } catch (e) {
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
        '/bookchat/addbook/',
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