# bookchat/consumers.py
import json
from channels.generic.websocket import AsyncWebsocketConsumer
from channels.db import database_sync_to_async
from .models import ChatRoom, ChatMessage, User

class ChatConsumer(AsyncWebsocketConsumer):
    async def connect(self):
        self.room_id = self.scope['url_route']['kwargs']['room_id']
        self.room_group_name = f'chat_{self.room_id}'

        # 채팅방 그룹에 참여
        await self.channel_layer.group_add(
            self.room_group_name,
            self.channel_name
        )

        await self.accept()

    async def disconnect(self, close_code):
        # 채팅방 그룹에서 나가기
        await self.channel_layer.group_discard(
            self.room_group_name,
            self.channel_name
        )

    async def receive(self, text_data):
        text_data_json = json.loads(text_data)
        message = text_data_json['message']
        sender_id = text_data_json['sender_id']

        # 메시지 저장
        chat_message = await self.save_message(sender_id, message)
        
        # 그룹으로 메시지 전송
        await self.channel_layer.group_send(
            self.room_group_name,
            {
                'type': 'chat_message',
                'message': chat_message.to_json()
            }
        )

    async def chat_message(self, event):
        message = event['message']

        # WebSocket으로 메시지 전송
        await self.send(text_data=json.dumps({
            'message': message
        }))

    @database_sync_to_async
    def save_message(self, sender_id, message_content):
        user = User.objects.get(id=sender_id)
        chat_room = ChatRoom.objects.get(id=self.room_id)
        message = ChatMessage.objects.create(
            room=chat_room,
            sender=user,
            content=message_content
        )
        return message