import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SignUpScreen extends ConsumerStatefulWidget{
  static final emailRegex = RegExp(r'^[a-zA-Z0-9.]+@[a-zA-Z0-9]+\.[a-zA-Z]+');
  static final passwordRegex = RegExp(r'^(?=.*[A-Za-z])(?=.*\d)(?=.*[@$!%*#?&])[A-Za-z\d@$!%*#?&]{8,}$');
  static final nameRegex = RegExp(r'^[a-zA-Z][a-zA-Z0-9]*$');

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  SignUpScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends ConsumerState<SignUpScreen>{
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    widget.emailController.dispose();
    widget.passwordController.dispose();
    widget.nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("회원가입"),
      ),
    body: Form(
    key: _formKey,
    child: Column(
        children: [
          TextFormField(
            controller: widget.emailController,
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
            controller: widget.passwordController,
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
            controller: widget.nameController,
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
            onPressed: (){
              if (_formKey.currentState!.validate()) {
                // 유효성 검사 통과시 처리할 로직
                print('폼 검증 성공');
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