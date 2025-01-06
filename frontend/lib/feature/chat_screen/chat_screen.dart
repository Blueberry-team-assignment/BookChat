// lib/feature/chat_screen/chat_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:book_chat/common/service/chat_service.dart';
import 'model/chat_message.dart';
import 'package:book_chat/feature/chat_screen/widget/message_bubble.dart';
import 'package:book_chat/feature/my_page/my_page_screen.dart';

final chatServiceProvider = Provider((ref) => ChatService());

class ChatScreen extends ConsumerStatefulWidget {
  final int chatRoomId;
  final String chatRoomName;

  const ChatScreen({
    required this.chatRoomId,
    required this.chatRoomName,
  });

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<ChatMessage> _messages = [];
  bool _isConnecting = true;

  @override
  void initState() {
    super.initState();
    _connectToChat();
  }

  Future<void> _connectToChat() async {
    final chatService = ref.read(chatServiceProvider);
    
    chatService.onMessageReceived = (message) {
      setState(() {
        _messages.add(message);
      });
      _scrollToBottom();
    };

    try {
      await chatService.connectToChat(widget.chatRoomId);
      setState(() {
        _isConnecting = false;
      });
    } catch (e) {
      print('Error connecting to chat: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('채팅 연결에 실패했습니다. 다시 시도해주세요.')),
        );
      }
    }
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  void _sendMessage() async {
    if (_messageController.text.trim().isEmpty) return;

    final chatService = ref.read(chatServiceProvider);
    final userState = ref.read(userInfoProvider);
    
    if (userState.userModel == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('로그인이 필요합니다.')),
      );
      return;
    }

    chatService.sendMessage(
      _messageController.text.trim(),
      userState.userModel!.id,
    );

    _messageController.clear();
  }

  @override
  Widget build(BuildContext context) {
    final userState = ref.watch(userInfoProvider);
    
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.chatRoomName),
      ),
      body: _isConnecting
          ? Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    controller: _scrollController,
                    itemCount: _messages.length,
                    itemBuilder: (context, index) {
                      final message = _messages[index];
                      final isMe = message.senderId == userState.userModel?.id;
                      
                      return MessageBubble(
                        message: message,
                        isMe: isMe,
                      );
                    },
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _messageController,
                          decoration: InputDecoration(
                            hintText: '메시지를 입력하세요',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                          onSubmitted: (_) => _sendMessage(),
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        icon: const Icon(Icons.send),
                        onPressed: _sendMessage,
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  @override
  void dispose() {
    ref.read(chatServiceProvider).dispose();
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }
}