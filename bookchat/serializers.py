# bookchat/serializers.py
from rest_framework import serializers
from .models import Book, User

class BookSerializer(serializers.ModelSerializer):
    poster_url = serializers.SerializerMethodField()
    
    class Meta:
        model = Book 
        fields = ('id', 'title', 'keyword', 'poster_url', 'like', 'description')
        
    def get_poster_url(self, obj):
        return obj.get_poster_url()

class UserSerializer(serializers.ModelSerializer):
    class Meta:
        model = User
        fields = ('id', 'email', 'name', 'password', 'username')
        extra_kwargs = {
            'password': {'write_only': True},
            'username': {'required': False}  # username은 선택적으로
        }
    
    def create(self, validated_data):
        user = User.objects.create_user(
            email=validated_data['email'],
            id=validated_data['id'],
            name=validated_data['name'],
            password=validated_data['password']
        )
        return user

    def to_representation(self, instance):
        # df_chat이 기대하는 형식으로 변환
        ret = super().to_representation(instance)
        ret['username'] = instance.email  # username 필드가 필요한 경우 email을 사용
        return ret

class LoginSerializer(serializers.Serializer):
    email = serializers.EmailField()
    password = serializers.CharField()

# df_chat을 위한 간단한 User Serializer
class ChatUserSerializer(serializers.ModelSerializer):
    class Meta:
        model = User
        fields = ('id', 'email', 'name', 'username')