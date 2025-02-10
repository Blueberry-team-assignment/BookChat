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
        if isinstance(obj.poster, str):  # 이미 URL 문자열인 경우
            return obj.poster
        return obj.get_poster_url()

class UserSerializer(serializers.ModelSerializer):
    class Meta:
        model = User
        fields = ('id', 'email', 'name', 'password')
        extra_kwargs = {
            'password': {'write_only': True},
            'id': {'read_only': True}
        }

    def create(self, validated_data):
        # ID 생성 로직
        import random
        import string
        from datetime import datetime
        
        date_str = datetime.now().strftime('%y%m%d')
        random_str = ''.join(random.choices(string.ascii_uppercase, k=3))
        generated_id = f"{date_str}{random_str}"
        
        user = User.objects.create_user(
            id=generated_id,
            email=validated_data['email'],
            name=validated_data['name'],
            username=validated_data['name'],
            password=validated_data['password']
        )
        return user

    def validate_email(self, value):
        if User.objects.filter(email=value).exists():
            raise serializers.ValidationError("이미 존재하는 이메일입니다.")
        return value

class LoginSerializer(serializers.Serializer):
    email = serializers.EmailField()
    password = serializers.CharField()

class CommentSerializer(serializers.ModelSerializer):
    user_name = serializers.CharField(source='user.name', read_only=True)
    
    class Meta:
        model = Comment
        fields = ['id', 'content', 'user_name', 'created_at']