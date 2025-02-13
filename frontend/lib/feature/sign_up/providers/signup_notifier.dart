import 'package:book_chat/common/repository/api_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:book_chat/models/signup_model.dart';

// // ApiRepository provider 선언
// final apiRepositoryProvider = Provider<ApiRepository>((ref) {
//   return ApiRepository();
// });

final signUpProvider = StateNotifierProvider<SignUpNotifier, SignUpState>((ref) {
  final apiRepository = ref.read(apiRepositoryProvider);
  return SignUpNotifier(apiRepository);
});

class SignUpNotifier extends StateNotifier<SignUpState> {
  // final IAuthRepository _authInterface;
  final ApiRepository _apiRepository;
  SignUpNotifier(this._apiRepository)
      : super(SignUpState(
      signupDto: SignUpDto(
          email: '',
          password: '',
          name: '')
  ));

  void updateSignUpDto(SignUpDto dto) {
    state = SignUpState(
        signupDto: dto
    );
  }

  Future<void> signUp({
    required String email,
    required String password,
    required String name,
}) async {
    try{
      final signupDto = SignUpDto(
          email: email,
          password: password,
          name: name
      );

      await _apiRepository.post(
        '/bookchat/signup/',
        body: signupDto.toJson(),
      );

      updateSignUpDto(signupDto);

    } on ApiException catch (e) {
      // ApiException의 message와 statusCode를 그대로 전달
      throw ApiException(
        message: e.message,
        statusCode: e.statusCode,
      );
    }
  }
}

class SignUpState{
  final SignUpDto signupDto;

  SignUpState({
    required this.signupDto
  });
}