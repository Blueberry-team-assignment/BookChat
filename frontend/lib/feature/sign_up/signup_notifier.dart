import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:book_chat/feature/sign_up/signup_dto.dart';
import 'package:book_chat/feature/sign_up/signup_repository.dart';
import 'dart:math';

class SignUpState{
  final SignUpDto signupDto;

  SignUpState({
    required this.signupDto
  });
}
class SignUpNotifier extends StateNotifier<SignUpState> {
  final IAuthRepository _authInterface;
  SignUpNotifier(this._authInterface)
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

      final signUpResult = await _authInterface.signUp(
        signupDto: signupDto
      );

      updateSignUpDto(signupDto);

    } catch (e) {
      print(e);
    }
  }
}
final signUpProvider = StateNotifierProvider<SignUpNotifier, SignUpState>((ref) {
  final IAuthRepository = ref.read(authRepositoryProvider);
  return SignUpNotifier(IAuthRepository);
});

