// book_memo_state.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

// 메모 상태를 나타내는 클래스
class MemoState {
  final String content;
  final bool isLoading;
  final bool isEditing;
  final bool isSaving;
  final String? error;

  MemoState({
    required this.content,
    this.isLoading = false,
    this.isEditing = false,
    this.isSaving = false,
    this.error,
  });

  MemoState copyWith({
    String? content,
    bool? isLoading,
    bool? isEditing,
    bool? isSaving,
    String? error,
  }) {
    return MemoState(
      content: content ?? this.content,
      isLoading: isLoading ?? this.isLoading,
      isEditing: isEditing ?? this.isEditing,
      isSaving: isSaving ?? this.isSaving,
      error: error,
    );
  }
}

// StateNotifier 정의
class MemoNotifier extends StateNotifier<MemoState> {
  final int bookId;
  
  MemoNotifier(this.bookId) : super(MemoState(content: ''));

  Future<void> loadMemo() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final response = await http.get(
        Uri.parse('https://drf-bookchat-test-d3b5e19f0ff5.herokuapp.com/bookchat/memo/$bookId/'),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        state = state.copyWith(
          content: data['content'] ?? '',
          isLoading: false,
        );
      } else {
        throw Exception('Failed to load memo');
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to load memo',
      );
    }
  }

  Future<void> saveMemo(String content) async {
    state = state.copyWith(isSaving: true, error: null);

    try {
      final response = await http.post(
        Uri.parse('https://drf-bookchat-test-d3b5e19f0ff5.herokuapp.com/bookchat/memo/'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'book_id': bookId,
          'content': content,
        }),
      );

      if (response.statusCode == 200) {
        state = state.copyWith(
          isSaving: false,
          isEditing: false,
          content: content,
        );
      } else {
        throw Exception('Failed to save memo');
      }
    } catch (e) {
      state = state.copyWith(
        isSaving: false,
        error: 'Failed to save memo',
      );
    }
  }

  void toggleEditing() {
    state = state.copyWith(isEditing: !state.isEditing);
  }
}

// Provider 정의
final memoProvider = StateNotifierProvider.family<MemoNotifier, MemoState, int>(
  (ref, bookId) => MemoNotifier(bookId),
);