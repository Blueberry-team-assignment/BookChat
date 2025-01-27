import 'dart:convert';
import 'package:book_chat/common/repository/token_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:book_chat/feature/login/login_screen.dart';
import 'package:http/http.dart' as http;

// 사용자 모델
class UserModel {
  final String email;
  final String name;
  final String id;

  UserModel({
    required this.email,
    required this.name,
    required this.id,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      email: json['email'] as String,
      name: json['name'] as String,
      id: json['id'] as String,
    );
  }
}

// 상태 클래스
class UserInfoState {
  final UserModel? userModel;
  final bool isLoading;
  final String? error;

  UserInfoState({
    this.userModel,
    this.isLoading = false,
    this.error,
  });

  UserInfoState copyWith({
    UserModel? userModel,
    bool? isLoading,
    String? error,
  }) {
    return UserInfoState(
      userModel: userModel ?? this.userModel,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

class UserInfoNotifier extends StateNotifier<UserInfoState> {
  final TextEditingController _emailController;
  final TextEditingController _passwordController;

  UserInfoNotifier(this._emailController, this._passwordController)
      : super(UserInfoState());

  Future<void> loadUserInfo() async {
    state = state.copyWith(isLoading: true);

    try {

      final token = await UserSecureStorage.getToken();
      if (token == null) {
        state = state.copyWith(
          error: '로그인이 필요합니다',
          isLoading: false,
        );
        return;
      }

      // 토큰을 사용하여 사용자 정보 요청
    final userResponse = await http.get(
      Uri.parse('https://drf-bookchat-test-d3b5e19f0ff5.herokuapp.com/bookchat/user/'),
      headers: {
        'Authorization': 'Token $token',
        'Content-Type': 'application/json',
      },
    );

    if (userResponse.statusCode == 200) {
      final userData = jsonDecode(userResponse.body);
      final user = UserModel.fromJson(userData);
      state = state.copyWith(
        userModel: user,
        isLoading: false,
      );
    } else {
      state = state.copyWith(
        error: '사용자 정보를 불러오는데 실패했습니다',
        isLoading: false,
      );
    }
  } catch (e) {
    state = state.copyWith(
      error: '오류가 발생했습니다: $e',
      isLoading: false,
    );
  }
  }
  void updateUserInfo(UserModel user) {
    state = state.copyWith(userModel: user);
  }

  void logout() async{
    await UserSecureStorage.deleteToken();
    state = UserInfoState();
  }
}

final userInfoProvider = StateNotifierProvider<UserInfoNotifier, UserInfoState>((ref) {
  final _emailController = ref.watch(emailControllerProvider);
  final _passwordController = ref.watch(passwordControllerProvider);
  return UserInfoNotifier(_emailController, _passwordController);
});

final emailControllerProvider = Provider((ref) => TextEditingController());
final passwordControllerProvider = Provider((ref) => TextEditingController());



class MyPageScreen extends ConsumerStatefulWidget {
  const MyPageScreen({super.key});

  @override
  _MyPageScreenState createState() => _MyPageScreenState();
}

class _MyPageScreenState extends ConsumerState<MyPageScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() async {
      final token = await UserSecureStorage.getToken();
      if (token != null) {
        ref.read(userInfoProvider.notifier).loadUserInfo();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final userState = ref.watch(userInfoProvider);

    if (userState.isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (userState.error != null) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(userState.error!),
              ElevatedButton(
                onPressed: () => ref.read(userInfoProvider.notifier).loadUserInfo(),
                child: Text('다시 시도'),
              ),
            ],
          ),
        ),
      );
    }

    final userInfo = userState.userModel;
    print(userInfo);
    return Scaffold(
      body: userInfo == null
          ? const Center(child: Text('로그인이 필요합니다'))
          : Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'My Page',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 30),
            Text(
              'ID: ${userInfo.id}',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 10),
            Text(
              '이름: ${userInfo.name}',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 10),
            Text(
              '이메일: ${userInfo.email}',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                ref.read(userInfoProvider.notifier).logout();
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (_) => LoginScreen()),
                );
              },
              child: Text('로그아웃'),
            ),
          ],
        ),
      ),
    );
  }
}