from django.db import models
from django.contrib.auth.models import AbstractUser

# Create your models here.
class Book(models.Model):
    title=models.CharField(max_length=255)
    keyword=models.CharField(max_length=255)
    poster= models.ImageField()
    like = models.BooleanField(default=False)
    description = models.TextField(blank=True, null=True)  # 새로운 필드 추가

    def get_poster_url(self):
        if self.poster:
            return self.poster.url  # Cloudinary URL 반환
        return None

class BookMemo(models.Model):
    book = models.ForeignKey(Book, on_delete=models.CASCADE)
    content = models.TextField()
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

class User(AbstractUser):
    name = models.CharField(max_length=100)
    id = models.CharField(unique=True, primary_key=True, max_length=100)
    email = models.EmailField(unique=True)
    password = models.CharField(max_length=100)

    USERNAME_FIELD = 'email'
    REQUIRED_FIELDS = ['name']