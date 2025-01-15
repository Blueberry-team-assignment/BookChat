import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:book_chat/feature/sign_up/signup_dto.dart';

class SignUpNotifier extends StateNotifier<SignUpDto> {
  SignUpNotifier()
      : super(const SignUpDto(email: '', password: '', name: ''));

  void updateEmail(String email) {
    state = state.copyWith(email: email);
  }

  void updatePassword(String password) {
    state = state.copyWith(password: password);
  }

  void updateName(String name) {
    state = state.copyWith(name: name);
  }
}

final signUpProvider = StateNotifierProvider<SignUpNotifier, SignUpDto>((ref) {
  return SignUpNotifier();
});