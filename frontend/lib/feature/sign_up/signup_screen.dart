import 'package:book_chat/feature/sign_up/signup_dto.dart';
import 'package:book_chat/feature/sign_up/signup_notifier.dart';
import 'package:book_chat/feature/sign_up/signup_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';


class SignUpScreen extends ConsumerStatefulWidget{
  static final emailRegex = RegExp(r'^[a-zA-Z0-9.]+@[a-zA-Z0-9]+\.[a-zA-Z]+');
  static final passwordRegex = RegExp(r'^(?=.*[A-Za-z])(?=.*\d)(?=.*[@$!%*#?&])[A-Za-z\d@$!%*#?&]{8,}$');
  static final nameRegex = RegExp(r'^[a-zA-Z][a-zA-Z0-9]*$');

  const SignUpScreen({super.key});

  @override
  ConsumerState<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends ConsumerState<SignUpScreen>{
  Future<void> _handleSignUp(SignUpDto signUpDto) async {
    try {
      await ref.read(authRepositoryProvider).signUp(signUpDto);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('회원가입이 완료되었습니다'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      }
    } on AuthException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.message),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    // SignUpDto 상태 읽기
    final signUpState = ref.watch(signUpProvider);
    final notifier = ref.read(signUpProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text("회원가입"),
      ),
    body: Form(
    key: _formKey,
    child: Column(
        children: [
          TextFormField(
            initialValue: signUpState.email,
            onChanged: (value) => notifier.updateEmail(value),
            decoration: InputDecoration(
              labelText: '이메일',
              hintText: 'example@email.com',
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return '이메일을 입력해주세요';
              }
              if (!SignUpScreen.emailRegex.hasMatch(value)) {
                return '올바른 이메일 형식이 아닙니다';
              }
              return null;
            },
          ),
          TextFormField(
            initialValue: signUpState.password,
            onChanged: (value) => notifier.updatePassword(value),
            decoration: InputDecoration(
              labelText: '비밀번호',
              hintText: '8자 이상, 특수문자 포함',
            ),
            obscureText: true, // 가려져서 보임
            validator: (value) {
              if (value == null || value.isEmpty) {
                return '비밀번호를 입력해주세요';
              }
              if (!SignUpScreen.passwordRegex.hasMatch(value)) {
                return '비밀번호는 8자 이상, 영문, 숫자, 특수문자를 포함해야 합니다';
              }
              return null;
            },
          ),
          TextFormField(
            initialValue: signUpState.name,
            onChanged: (value) => notifier.updateName(value),
            decoration: const InputDecoration(
              labelText: '이름',
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return '이름을 입력해주세요';
              }
              if (!SignUpScreen.nameRegex.hasMatch(value)) {
                return '이름은 첫 글자로 숫자를 사용할 수 없습니다';
              }
              return null;
            },
          ),

          ElevatedButton(
            onPressed: () async {
              if (_formKey.currentState!.validate()) {
                final signUpState = ref.read(signUpProvider);
                _handleSignUp(signUpState);
              }
            },
            child: const Text('가입하기'),
          ),
        ],
      ),
    )
    );
  }
}