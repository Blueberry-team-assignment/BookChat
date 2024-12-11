from django.db import models
from django.conf import settings

# Create your models here.
class Book(models.Model):
    title=models.CharField(max_length=255)
    keyword=models.CharField(max_length=255)
    poster= models.ImageField()
    like = models.BooleanField(default=False)

    def get_poster_url(self):
        if self.poster:
            return f"{settings.MEDIA_URL}{self.poster}"
        return None