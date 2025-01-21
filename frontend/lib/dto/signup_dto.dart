import 'package:freezed_annotation/freezed_annotation.dart';

part 'signup_dto.freezed.dart';
part 'signup_dto.g.dart';

@freezed
class SignUpDto with _$SignUpDto {
  const factory SignUpDto({
    required String email,
    required String password,
    required String name,
  }) = _SignUpDto;

  factory SignUpDto.fromJson(Map<String, dynamic> json) =>
      _$SignUpDtoFromJson(json);
}

