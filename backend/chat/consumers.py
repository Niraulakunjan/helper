import json
from channels.generic.websocket import AsyncWebsocketConsumer
from channels.db import database_sync_to_async
from django.contrib.auth import get_user_model
from .models import Message

User = get_user_model()

# In-memory presence store: { user_id: set(channel_names) }
online_users: dict[int, set] = {}

class ChatConsumer(AsyncWebsocketConsumer):
    async def connect(self):
        user_id   = int(self.scope['url_route']['kwargs']['user_id'])
        helper_id = int(self.scope['url_route']['kwargs']['helper_id'])
        self.user_id   = user_id
        self.helper_id = helper_id

        # Sorted so both sides share the same room name
        ids = sorted([user_id, helper_id])
        self.room_name    = f"chat_{ids[0]}_{ids[1]}"
        self.presence_group = f"presence_{user_id}"   # personal group for status broadcasts

        await self.channel_layer.group_add(self.room_name, self.channel_name)
        await self.accept()

        # Mark this user online
        online_users.setdefault(user_id, set()).add(self.channel_name)

        # Broadcast to the chat room that this user is online
        await self.channel_layer.group_send(self.room_name, {
            'type': 'presence_update',
            'user_id': user_id,
            'status': 'online',
        })

    async def disconnect(self, close_code):
        await self.channel_layer.group_discard(self.room_name, self.channel_name)

        # Remove channel from presence
        if self.user_id in online_users:
            online_users[self.user_id].discard(self.channel_name)
            if not online_users[self.user_id]:
                del online_users[self.user_id]

        # Broadcast offline
        await self.channel_layer.group_send(self.room_name, {
            'type': 'presence_update',
            'user_id': self.user_id,
            'status': 'offline',
        })

    async def receive(self, text_data):
        data = json.loads(text_data)
        msg_type = data.get('type', 'message')

        if msg_type == 'message':
            message    = data['message']
            sender_id  = data['sender_id']
            receiver_id = data['receiver_id']
            saved = await self.save_message(sender_id, receiver_id, message)
            await self.channel_layer.group_send(self.room_name, {
                'type': 'chat_message',
                'message': message,
                'sender_id': sender_id,
                'timestamp': str(saved.timestamp),
            })

        elif msg_type == 'typing':
            await self.channel_layer.group_send(self.room_name, {
                'type': 'typing_event',
                'sender_id': data['sender_id'],
                'is_typing': True,
            })

        elif msg_type == 'stop_typing':
            await self.channel_layer.group_send(self.room_name, {
                'type': 'typing_event',
                'sender_id': data['sender_id'],
                'is_typing': False,
            })

        elif msg_type == 'check_presence':
            # Client asks if the other user is online
            other_id = data['other_id']
            is_online = other_id in online_users and len(online_users[other_id]) > 0
            await self.send(text_data=json.dumps({
                'type': 'presence_update',
                'user_id': other_id,
                'status': 'online' if is_online else 'offline',
            }))

    # --- Group message handlers ---

    async def chat_message(self, event):
        await self.send(text_data=json.dumps({
            'type': 'message',
            'message': event['message'],
            'sender_id': event['sender_id'],
            'timestamp': event['timestamp'],
        }))

    async def typing_event(self, event):
        await self.send(text_data=json.dumps({
            'type': 'typing',
            'sender_id': event['sender_id'],
            'is_typing': event['is_typing'],
        }))

    async def presence_update(self, event):
        await self.send(text_data=json.dumps({
            'type': 'presence',
            'user_id': event['user_id'],
            'status': event['status'],
        }))

    @database_sync_to_async
    def save_message(self, sender_id, receiver_id, content):
        sender   = User.objects.get(id=sender_id)
        receiver = User.objects.get(id=receiver_id)
        return Message.objects.create(sender=sender, receiver=receiver, content=content)
