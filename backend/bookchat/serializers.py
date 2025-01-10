from rest_framework import serializers
from .models import Book, User, Comment
    
class BookSerializer(serializers.ModelSerializer):
    like = serializers.SerializerMethodField()
    poster_url = serializers.SerializerMethodField()
    
    class Meta:
        model = Book
        fields = ('id', 'title', 'keyword', 'poster_url', 'like', 'description')
        
    def get_like(self, obj):
        request = self.context.get('request')
        if request and request.user.is_authenticated:
            return request.user in obj.liked_by.all()
        return False
    def get_poster_url(self, obj):
        return obj.get_poster_url()
    
class UserSerializer(serializers.ModelSerializer):
    class Meta:
        model = User
        fields = ('id', 'email', 'name', 'password')
        extra_kwargs = {'password': {'write_only': True}}
    
    def create(self, validated_data):
        user = User.objects.create_user(
            email=validated_data['email'],
            id=validated_data['id'],
            name=validated_data['name'],
            password=validated_data['password']
        )
        return user

class LoginSerializer(serializers.Serializer):
    email = serializers.EmailField()
    password = serializers.CharField()

class CommentSerializer(serializers.ModelSerializer):
    user_name = serializers.CharField(source='user.name', read_only=True)
    
    class Meta:
        model = Comment
        fields = ['id', 'content', 'user_name', 'created_at']