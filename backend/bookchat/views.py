from rest_framework.response import Response
from rest_framework.decorators import api_view, permission_classes
from .models import Book, BookMemo, Comment
from .serializers import BookSerializer, UserSerializer, LoginSerializer, CommentSerializer
import random 
from django.contrib.auth import authenticate
from rest_framework import status
from rest_framework.authtoken.models import Token
from rest_framework.permissions import IsAuthenticated
from bookchat.models import User  #
from df_chat.drf.viewsets import RoomViewSet
from rest_framework.authentication import TokenAuthentication

class CustomRoomViewSet(RoomViewSet):
    authentication_classes = [TokenAuthentication]

    def create(self, request, *args, **kwargs):
        print("Received data:", request.data)  # 요청 데이터 출력
        try:
            return super().create(request, *args, **kwargs)
        except Exception as e:
            print("Error:", str(e))  # 에러 출력
            raise

@api_view(['GET'])
def helloAPI(request):
    return Response("hello world!")

@api_view(['GET'])
def randomBook(request, id):
    totalBooks = Book.objects.all()
    randomBooks = random.sample(list(totalBooks), id)
    serializer = BookSerializer(randomBooks, many=True)
    return Response(serializer.data)

@api_view(['GET'])
def randomBook_myList(request):
    myListBooks = Book.objects.filter(like=True)
    sample_size = min(len(myListBooks), 4)
    randomBooks = random.sample(list(myListBooks), sample_size)
    serializer = BookSerializer(randomBooks, many=True)
    return Response(serializer.data)

@api_view(['GET'])
def allBooks(request):
    totalBooks = Book.objects.all()
    serializer = BookSerializer(totalBooks, many=True)
    return Response(serializer.data)

@api_view(['POST'])
def save_memo(request):
    try:
        print("Received request.data:", request.data, flush=True)
        book_id = request.data.get('book_id')
        content = request.data.get('content')
        print("book id: ", book_id, "content: ", content, flush=True)

        # Book 객체 가져오기 시도
        try:
            book = Book.objects.get(id=book_id)
        except Book.DoesNotExist:
            print(f"Book with id {book_id} not found", flush=True)
            return Response({'error': 'Book not found'}, status=404)

        # BookMemo 생성 시도
        try:
            memo, created = BookMemo.objects.get_or_create(
            book=book,  # 이 조건으로 찾고
            defaults={'content': content}  # 없으면 생성, 있으면 업데이트
            )
            print(f"Successfully created memo: {memo.id}", flush=True)

            if not created:  # 이미 존재하는 메모라면 내용 업데이트
                memo.content = content
                memo.save()

        except Exception as e:
            print(f"Error creating memo: {str(e)}", flush=True)
            return Response({'error': str(e)}, status=500)

        return Response({
            'message': 'Memo saved successfully',
            'created': created  # 새로 생성됐는지 여부
        })

    except Exception as e:
        print(f"Unexpected error: {str(e)}")
        return Response({'error': str(e)}, status=500)

@api_view(['GET'])
def get_memo(request, book_id):
    try:
        memo = BookMemo.objects.filter(book_id=book_id).first()
        if memo:
            return Response({
                'content': memo.content,
                'updated_at': memo.updated_at
            })
        print("get memo: ", memo, flush=True)
        return Response({'content': ''})  # 메모가 없는 경우 빈 내용 반환
    except Exception as e:
        return Response({'error': str(e)}, status=500)


@api_view(['POST'])
def change_mylist(request):
    try:
        book_id = request.data.get('book_id')
        book = Book.objects.get(id=book_id)
        book.like = not book.like
        book.save()
        return Response({'success': True, 'like': book.like})
    except Book.DoesNotExist:
        return Response({'success': False, 'error': 'Book not found'}, status=404)

@api_view(['POST'])
def login(request):
    print("Login request data:", request.data)  # 요청 데이터 로깅
    serializer = LoginSerializer(data=request.data)
    if serializer.is_valid():
        print("Serializer valid:", serializer.validated_data)  # 유효성 검사 통과 데이터
        user = authenticate(
            email=serializer.validated_data['email'],
            password=serializer.validated_data['password']
        )
        print("Authenticated user:", user)  
        
        if user:
            token, _ = Token.objects.get_or_create(user=user)
            return Response({
                'token': token.key,
                'user': UserSerializer(user).data
            })
        
        return Response(
            {'error': '잘못된 이메일이나 비밀번호입니다.'},
            status=status.HTTP_401_UNAUTHORIZED
        )
    
    print("Serializer errors:", serializer.errors)  # 유효성 검사 오류
    return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)

@api_view(['GET'])
@permission_classes([IsAuthenticated])
def get_users(request):
    users = User.objects.all()
    serializer = UserSerializer(users, many=True)
    return Response(serializer.data)

@api_view(['GET'])
@permission_classes([IsAuthenticated])
def get_user_info(request):
    serializer = UserSerializer(request.user)
    return Response(serializer.data)

@api_view(['GET'])
@permission_classes([IsAuthenticated])
def get_comments(request, book_id):
    comments = Comment.objects.filter(book_id=book_id)
    serializer = CommentSerializer(comments, many=True)
    return Response(serializer.data)

@api_view(['POST'])
@permission_classes([IsAuthenticated])
def create_comment(request, book_id):
    try:
        book = Book.objects.get(id=book_id)
        serializer = CommentSerializer(data=request.data)
        if serializer.is_valid():
            serializer.save(book=book, user=request.user)
            return Response(serializer.data, status=201)
        return Response(serializer.errors, status=400)
    except Book.DoesNotExist:
        return Response({'error': 'Book not found'}, status=404)
    
####################################
@api_view(['POST'])
def create_book(request):
    print("Received request to create a book.")  # 이 줄이 로그에 기록됩니다.
    serializer = BookSerializer(data=request.data)
    if serializer.is_valid():
        serializer.save()
        print(f"Book created: {serializer.data}")  # 이 줄도 로그에 기록됩니다.
        return Response(serializer.data, status=201)
    print(f"Book creation failed: {serializer.errors}")  # 이 줄도 로그에 기록됩니다.
    return Response(serializer.errors, status=400)

