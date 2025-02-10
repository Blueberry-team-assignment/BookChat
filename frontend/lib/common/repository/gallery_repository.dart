import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

abstract class GalleryRepository{
  Future<dynamic> pickImage();
 }

final GalleryRepositoryProvider = Provider<GalleryRepository>((ref) {
  return GalleryRepoImpl();
});

class GalleryRepoImpl implements GalleryRepository {

  @override
  Future<dynamic> pickImage() async {
    // pickImage()에서 이미지만 선택하고 getImagePath()에서 선택한 이미지 경로를 반환하는 경우.
    // pickImage()와 getImagePath()가 서로 다른 인스턴스에서 호출될 수 있기 때문에 selectedImage 상태가 공유되지 않을 수 있어서 합침
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      return image.path;
    }
    return null;
  }
}