// lib/feature/chat_rooms/widget/create_chat_room_dialog.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

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
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      
      if (token == null) {
        throw Exception('Authentication token not found');
      }

      print('Token: $token'); // 토큰 확인용 로그
      print('Creating chat room with participants: $participants'); // 참여자 확인용 로그

      final response = await http.post(
        Uri.parse('https://drf-bookchat-test-d3b5e19f0ff5.herokuapp.com/api/v1/chat/rooms/'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Token $token',
        },
        body: jsonEncode({
          'title': _nameController.text,
          'type': 'private',  // 'private' 또는 'group'
          'users': participants,  // 참여자 ID 리스트
        }),
      );

      print('Request URL: ${response.request?.url}'); // URL 확인
      print('Request headers: ${response.request?.headers}'); // 헤더 확인
      print('Request body: ${response.request}'); // 요청 본문 확인
      print('Response status: ${response.statusCode}'); // 응답 상태 코드 확인
      print('Response body: ${response.body}'); // 응답 내용 확인

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