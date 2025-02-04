import 'package:freezed_annotation/freezed_annotation.dart';
part 'addbook_dto.freezed.dart';
part 'addbook_dto.g.dart';

@freezed
class AddBookDto with _$AddBookDto {
  const factory AddBookDto({
    required String title,
    required String keyword,
    required String des,
    String? imgpath,  // 로컬 이미지 경로
    String? imgurl,   // 클라우드 저장소 URL
  }) = _AddBookDto;

  factory AddBookDto.fromJson(Map<String, dynamic> json) =>
      _$AddBookDtoFromJson(json);
}