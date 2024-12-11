from rest_framework import serializers
from .models import Book

class BookSerializer(serializers.ModelSerializer):
    poster_url = serializers.SerializerMethodField()  
    class Meta:
        model = Book 
        fields = ('title', 'keyword', 'poster_url', 'like')
    
    def get_poster_url(self, obj):
        if obj.poster:
            request = self.context.get('request')
            if request:
                return request.build_absolute_uri(obj.poster.url)
            return obj.poster.url
        return None