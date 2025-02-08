from django.db import models
from django.contrib.auth.models import AbstractUser
from django.conf import settings

class User(AbstractUser):
    name = models.CharField(max_length=100)
    id = models.CharField(unique=True, primary_key=True, max_length=100)
    email = models.EmailField(unique=True)

    USERNAME_FIELD = 'email'
    REQUIRED_FIELDS = ['name', 'username']

class Book(models.Model):
    title = models.CharField(max_length=255)
    keyword = models.CharField(max_length=255)
    # poster = models.ImageField()
    poster = models.URLField(max_length=500)
    liked_by = models.ManyToManyField(User, related_name='liked_books', blank=True)
    description = models.TextField(blank=True, null=True)
    
    def get_poster_url(self):
        if isinstance(self.poster, str):  # 이미 URL 문자열인 경우
            return self.poster
        return self.poster.url if self.poster else None
        # return self.poster.url if self.poster else None

class BookMemo(models.Model):
    book = models.ForeignKey(Book, on_delete=models.CASCADE)
    content = models.TextField()
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

class ChatRoom(models.Model):
    name = models.CharField(max_length=100)
    book = models.ForeignKey('Book', on_delete=models.CASCADE, related_name='chat_rooms')
    created_at = models.DateTimeField(auto_now_add=True)
    participants = models.ManyToManyField('User', related_name='book_chat_rooms')

    class Meta:
        ordering = ['-created_at']

    def __str__(self):
        return f"{self.name} - {self.book.title}"
    
    def to_json(self):
        return {
            'id': self.id,
            'name': self.name,
            'book': self.book.id,
            'created_at': self.created_at.isoformat(),
            'participants': [user.id for user in self.participants.all()]
        }

class Comment(models.Model):
    book = models.ForeignKey(Book, on_delete=models.CASCADE, related_name='comments')
    user = models.ForeignKey(User, on_delete=models.CASCADE)
    content = models.TextField()
    created_at = models.DateTimeField(auto_now_add=True)

    class Meta:
        ordering = ['-created_at']

class ChatMessage(models.Model):
    room = models.ForeignKey(ChatRoom, on_delete=models.CASCADE, related_name='book_messages')
    sender = models.ForeignKey('User', on_delete=models.CASCADE, related_name='book_chat_messages')  # related_name 추가
    content = models.TextField()
    timestamp = models.DateTimeField(auto_now_add=True)
    
    class Meta:
        ordering = ['timestamp']

    def __str__(self):
        return f'{self.sender.name}: {self.content[:50]}'

    def to_json(self):
        return {
            'id': self.id,
            'sender': self.sender.name,
            'sender_id': self.sender.id,
            'content': self.content,
            'timestamp': self.timestamp.isoformat()
        }