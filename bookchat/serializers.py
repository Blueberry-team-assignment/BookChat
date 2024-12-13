from rest_framework import serializers
from .models import Book

class BookSerializer(serializers.ModelSerializer):
    poster_url = serializers.SerializerMethodField()  
    class Meta:
        model = Book 
        fields = ('title', 'keyword', 'poster', 'like')