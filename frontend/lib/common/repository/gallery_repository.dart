import 'dart:convert';
import 'dart:io';
import 'package:book_chat/dto/addbook_dto.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

abstract class GalleryRepository{
  Future<void> pickImage();
  Future<String?> getImagePath();
  // Future<dynamic> uploadBookImg(); -> 서버와 의존성을 가지므로 notifier에서 api 리포지토리 호출
  // Future<dynamic> addBookTextInfo({required AddBookDto addbookDto}); -> 갤러리 리포지토리에 있을 게 아님. 외부 의존성도 없음
}

final GalleryRepositoryProvider = Provider<GalleryRepository>((ref) {
  return GalleryRepoImpl();
});

class GalleryRepoImpl implements GalleryRepository{
  File? selectedImage;

  @override
  Future<void> pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    selectedImage = File(image!.path);
  }

  @override
  Future<String?> getImagePath() async{
    if (selectedImage != null) {
      return selectedImage!.path;
    }
    return null;
  }

  // api리포지토리와 의존성을 가지므로 notifier로 이동
  // @override
  // Future<dynamic> uploadBookImg() async {
  //   if (selectedImage == null) {
  //     throw ApiException(message: '선택된 이미지가 없습니다.');
  //   }
  //
  //   try {
  //     final response = await post(
  //       '/bookchat/upload-image/',
  //       body: {
  //         'image': selectedImage,
  //       },
  //     );
  //     return response;
  //   } catch (e) {
  //     throw ApiException(message: '이미지 업로드 중 오류 발생: $e');
  //   }
  // }

  // 갤러리 데이터 사용 X
  // @override
  // Future<dynamic> addBookTextInfo({
  //   required AddBookDto addbookDto
  // }) async {
  //   try {
  //     final response = await post(
  //       '/bookchat/addbook/',
  //       body: addbookDto.toJson(),
  //     );
  //     return response;
  //   } catch (e) {
  //     throw BookException(message: '책 정보 등록 중 오류 발생: $e');
  //   }
  // }

  // 백엔드 로직으로 이동
  // @override
  // dynamic _handleResponse(dynamic response) {
  //   if (response.statusCode == 201 || response.statusCode == 200) {
  //     if (response.body.isNotEmpty) {
  //       return jsonDecode(response.body);
  //     }
  //     return null;
  //   }
  //
  //   final errorData = jsonDecode(response.body);
  //
  //   // 책 관련 특수 에러 처리
  //   if (errorData['title'] != null) {
  //     throw BookException(
  //       message: errorData['title'][0],
  //       statusCode: response.statusCode,
  //     );
  //   }
  //
  //   if (errorData['keyword'] != null) {
  //     throw BookException(
  //       message: errorData['keyword'][0],
  //       statusCode: response.statusCode,
  //     );
  //   }
  //
  //   if (errorData['image'] != null) {
  //     throw BookException(
  //       message: errorData['image'][0],
  //       statusCode: response.statusCode,
  //     );
  //   }
  //
  //   // 기본 에러 메시지
  //   throw BookException(
  //     message: errorData['message'] ?? '요청 처리 중 오류가 발생했습니다',
  //     statusCode: response.statusCode,
  //   );
  // }
}
// 서버 요청에 대한 에러 처리는 api 리포지토리에서 함.
// class BookException extends ApiException {
//   BookException({
//     required String message,
//     int? statusCode,
//   }) : super(message: message, statusCode: statusCode);
// }