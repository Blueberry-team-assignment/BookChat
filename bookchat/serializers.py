from rest_framework import serializers
from .models import Book

class BookSerializer(serializers.ModelSerializer):
    poster_url = serializers.SerializerMethodField()
    
    class Meta:
        model = Book 
        fields = ('id', 'title', 'keyword', 'poster_url', 'like', 'description')  # id 필드 추가
        
    def get_poster_url(self, obj):
        return obj.get_poster_url()