from django.db import models

# Create your models here.
class Book(models.Model):
    title=models.CharField(max_length=255)
    keyword=models.CharField(max_length=255)
    poster= models.ImageField()
    like = models.BooleanField(default=False)