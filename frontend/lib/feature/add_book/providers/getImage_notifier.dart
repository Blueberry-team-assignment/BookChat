import 'dart:io';

import 'package:book_chat/common/repository/gallery_repository.dart';
import 'package:book_chat/models/addbook_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image/image.dart' as img;

final getImageProvider = StateNotifierProvider<GetImageNotifier, AddBookState>((ref){
  final galleryRepository = ref.read(GalleryRepositoryProvider);
  return GetImageNotifier(galleryRepository);
});

class GetImageNotifier extends StateNotifier<AddBookState>{
  final GalleryRepository _galleryRepository;

  GetImageNotifier(this._galleryRepository)
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

  Future<void> getImageFromGallery()async {
    final imagePath = await _galleryRepository.pickImage();
    if (imagePath != null) {
      final updatedDto = AddBookDto(
          title: state.addBookDto.title,
          keyword: state.addBookDto.keyword,
          des: state.addBookDto.des,
          imgpath: imagePath,
          imgurl: state.addBookDto.imgurl
      );

      updateAddBookDto(updatedDto);
    }
  }

  /* 이미지 압축 메서드 */
  Future<File> _compressImage(File imageFile) async {
    final bytes = await imageFile.readAsBytes();
    img.Image image = img.decodeImage(bytes)!;

    // 이미지 크기를 조정 (예: 너비를 1024로 설정)
    img.Image resizedImage = img.copyResize(image, width: 800, height: 1200);

    // 압축된 이미지 파일 생성 (JPEG 품질을 85로 설정)
    final compressedBytes = img.encodeJpg(resizedImage, quality: 85);
    final compressedImageFile = File('${imageFile.path}_compressed.jpg')
      ..writeAsBytesSync(compressedBytes);

    return compressedImageFile;
  }
}

class AddBookState{
  final AddBookDto addBookDto;

  AddBookState({
    required this.addBookDto
  });

}