// lib/screen/chat_rooms_screen.dart
import 'dart:convert';

import 'package:book_chat/common/repository/token_repository.dart';
import 'package:flutter/material.dart';
import 'package:book_chat/feature/chat_rooms/widget/create_chat_room_dialog.dart';
import 'package:book_chat/feature/chat_screen/chat_screen.dart';
import 'package:book_chat/model/chat_room_model.dart';
import 'package:http/http.dart' as http;

// lib/screen/chat_rooms_screen.dart
class ChatRoomsScreen extends StatefulWidget {
  final int bookId;
  final String bookTitle;

  ChatRoomsScreen({required this.bookId, required this.bookTitle});

  @override
  _ChatRoomsScreenState createState() => _ChatRoomsScreenState();
}

class _ChatRoomsScreenState extends State<ChatRoomsScreen> {
  List<ChatRoom> chatRooms = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadChatRooms();
  }

  // lib/feature/chat_rooms/chat_rooms_screen.dart

  Future<void> _loadChatRooms() async {
    try {

      final token = await UserSecureStorage.getToken();
      if (token == null) {
        throw Exception('Authentication token not found');
      }

      final response = await http.get(
        Uri.parse('https://drf-bookchat-test-d3b5e19f0ff5.herokuapp.com/bookchat/api/v1/chat/rooms/'),
        headers: {
          'Authorization': 'Token $token',
        },
      );

      print('응답 상태: ${response.statusCode}');
      print('응답 본문: ${response.body}');

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(utf8.decode(response.bodyBytes));
        setState(() {
          // df-chat의 응답 구조에 맞게 변환
          chatRooms = data.map((json) => ChatRoom(
            id: json['id'],
            name: json['title'],
            bookId: widget.bookId,
            participants: json['users']?.cast<String>() ?? [],  // null 체크 추가
            createdAt: DateTime.parse(json['created']),
    )).toList();
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load chat rooms');
      }
    } catch (e) {
      print('Error loading chat rooms: $e');
      setState(() {
        isLoading = false;
      });
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('Discussion rooms'),
        backgroundColor: Colors.blueGrey,
        foregroundColor: Colors.white,
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : chatRooms.isEmpty
              ? Center(
                  child: Text(
                      '${widget.bookTitle}\nChat room does not exist.\nPlease add a chat room!'))
              : ListView.builder(
                  itemCount: chatRooms.length,
                  itemBuilder: (context, index) {
                    final room = chatRooms[index];
                    return ListTile(
                      title: Text(room.name),
                      subtitle: Text('참여자: ${room.participants.length}명'),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ChatScreen(
                              chatRoomId: room.id,
                              chatRoomName: room.name,
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        backgroundColor: Colors.blueGrey,
        foregroundColor: Colors.white,
        onPressed: () async {
          final created = await showDialog(
            context: context,
            builder: (context) =>
                CreateChatRoomDialog(bookId: widget.bookId.toString()),
          );

          if (created == true) {
            _loadChatRooms(); // 새 채팅방 생성 후 목록 새로고침
          }
        },
      ),
    );
  }
}
