// lib/common/service/chat_service.dart
import 'dart:convert';
import 'package:book_chat/common/repository/token_repository.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:book_chat/feature/chat_screen/model/chat_message.dart';

class ChatService {
  WebSocketChannel? _channel;
  Function(ChatMessage)? onMessageReceived;

  // lib/common/service/chat_service.dart
  Future<void> connectToChat(int roomId) async {

    final tokenRepository = SecureStorageTokenRepository();
    final token = await tokenRepository.getToken("auth_token");
    if (token == null) {
      throw Exception('Authentication token not found');
    }

    final wsUrl = Uri.parse(
        'wss://drf-bookchat-test-d3b5e19f0ff5.herokuapp.com/ws/chat/$roomId/?token=$token'
    );
    print('Connecting to WebSocket URL: $wsUrl');

    try {
      _channel = WebSocketChannel.connect(wsUrl);
      print('WebSocket connection established');

      _channel?.stream.listen(
            (message) {
          print('Raw WebSocket message received: $message');
          try {
            final data = jsonDecode(message);
            print('Decoded message: $data');  // 디코딩된 메시지 출력
            if (data['message'] != null) {
              final chatMessage = ChatMessage.fromJson(data);
              onMessageReceived?.call(chatMessage);
            }
          } catch (e) {
            print('Error processing message: $e');
          }
        },
        onError: (error) {
          print('WebSocket error details: ${error.toString()}');  // 상세 에러 출력
          if (!error.toString().contains('Connection closed')) {  // 의도적 종료가 아닌 경우만 재연결
            reconnect(roomId);
          }
        },
        onDone: () {
          print('WebSocket connection closed normally');
          // reconnect(roomId);  // 일단 자동 재연결 비활성화
        },
      );
    } catch (e) {
      print('Error establishing WebSocket connection: ${e.toString()}');
      throw e;
    }
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