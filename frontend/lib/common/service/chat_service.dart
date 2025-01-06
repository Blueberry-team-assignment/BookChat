// lib/common/service/chat_service.dart
import 'dart:convert';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:book_chat/feature/chat_screen/model/chat_message.dart';

class ChatService {
  WebSocketChannel? _channel;
  Function(ChatMessage)? onMessageReceived;

  Future<void> connectToChat(int roomId) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    
    if (token == null) {
      throw Exception('Authentication token not found');
    }

    final wsUrl = Uri.parse(
      'wss://drf-bookchat-test-d3b5e19f0ff5.herokuapp.com/ws/chat/$roomId/?token=$token'
    );
    _channel = WebSocketChannel.connect(wsUrl);

    _channel?.stream.listen(
      (message) {
        final data = jsonDecode(message);
        if (data['message'] != null) {
          final chatMessage = ChatMessage.fromJson(data);
          onMessageReceived?.call(chatMessage);
        }
      },
      onError: (error) {
        print('WebSocket error: $error');
        reconnect(roomId);
      },
      onDone: () {
        print('WebSocket connection closed');
        reconnect(roomId);
      },
    );
  }

  void sendMessage(String content, String senderId) {
    if (_channel == null) {
      print('WebSocket is not connected');
      return;
    }

    final message = {
      'message': content,
      'created_by': senderId,
    };

    _channel?.sink.add(jsonEncode(message));
  }
  
  Future<void> reconnect(int roomId) async {
    await Future.delayed(const Duration(seconds: 5));
    try {
      await connectToChat(roomId);
    } catch (e) {
      print('Reconnection failed: $e');
    }
  }

  void dispose() {
    _channel?.sink.close();
    _channel = null;
  }
}