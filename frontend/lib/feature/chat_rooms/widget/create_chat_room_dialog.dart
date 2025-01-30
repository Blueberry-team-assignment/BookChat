// lib/feature/chat_rooms/widget/create_chat_room_dialog.dart
import 'dart:convert';
import 'package:book_chat/common/repository/token_repository.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class CreateChatRoomDialog extends StatefulWidget {
  final String bookId;

  CreateChatRoomDialog({required this.bookId});

  @override
  _CreateChatRoomDialogState createState() => _CreateChatRoomDialogState();
}

class _CreateChatRoomDialogState extends State<CreateChatRoomDialog> {
  final _nameController = TextEditingController();
  final _participantController = TextEditingController();
  List<String> participants = [];
  bool _isLoading = false;

  // lib/feature/chat_rooms/widget/create_chat_room_dialog.dart

  Future<void> _createChatRoom() async {
    if (_nameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('채팅방 이름을 입력해주세요')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final tokenRepository = SecureStorageTokenRepository();
      final token = await tokenRepository.getToken();
      if (token == null) {
        throw Exception('Authentication token not found');
      }

      // 요청 데이터 미리 준비
      final requestBody = {
        'title': _nameController.text,
        'chat_type': 'private',
        'users': participants,
      };

      print('토큰: $token');
      print('참여자 목록: $participants');
      print('participants type: ${participants.runtimeType}');  // 타입 출력
      print('요청 데이터: $requestBody');  // 실제 요청할 데이터 출력

      final response = await http.post(
        Uri.parse('https://drf-bookchat-test-d3b5e19f0ff5.herokuapp.com/bookchat/api/v1/chat/rooms/'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Token $token',
        },
        body: jsonEncode(requestBody),
      );

      print('요청 URL: ${response.request?.url}');
      print('요청 헤더: ${response.request?.headers}');
      print('응답 상태: ${response.statusCode}');
      print('응답 본문: ${response.body}');

      if (response.statusCode == 201) {
        if (mounted) {
          Navigator.pop(context, true);
        }
      } else {
        throw Exception('Failed to create chat room: ${response.body}');
      }
    } catch (e) {
      print('Error creating chat room: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('채팅방 생성에 실패했습니다: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.white,
      title: Text('Create new chat room'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _nameController,
            decoration: InputDecoration(labelText: 'Chat room name'),
          ),
          TextField(
            controller: _participantController,
            decoration: InputDecoration(
              labelText: 'Participant ID',
              suffixIcon: IconButton(
                icon: Icon(Icons.add),
                onPressed: () {
                  setState(() {
                    if (_participantController.text.isNotEmpty) {
                      participants.add(_participantController.text);
                      _participantController.clear();
                    }
                  });
                },
              ),
            ),
          ),
          ...participants.map((p) => Chip(
            label: Text(p),
            onDeleted: () {
              setState(() {
                participants.remove(p);
              });
            },
          )).toList(),
        ],
      ),
      actions: [
        TextButton(
          child: Text('Cancel'),
          onPressed: () => Navigator.pop(context),
        ),
        _isLoading
            ? CircularProgressIndicator()
            : TextButton(
                child: Text('Done'),
                onPressed: _createChatRoom,
              ),
      ],
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _participantController.dispose();
    super.dispose();
  }
}