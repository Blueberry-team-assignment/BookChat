import 'package:book_chat/common/repository/gallery_repository.dart';
import 'package:book_chat/models/addbook_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
}

class AddBookState{
  final AddBookDto addBookDto;

  AddBookState({
    required this.addBookDto
  });

}