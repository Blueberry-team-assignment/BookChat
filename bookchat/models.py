from django.db import models
from django.conf import settings

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