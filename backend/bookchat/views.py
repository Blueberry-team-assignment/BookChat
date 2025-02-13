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
import os
from django.core.files.storage import default_storage
from django.core.files.base import ContentFile

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
def allBooks(request):
    totalBooks = Book.objects.all()
    serializer = BookSerializer(totalBooks, many=True)
    return Response(serializer.data)

@api_view(['POST'])
def upload_image(request):
    try:
        if 'image' not in request.FILES:
            return Response({
                'error': '이미지 파일이 제공되지 않았습니다.'
            }, status=status.HTTP_400_BAD_REQUEST)
        image_file = request.FILES['image']
        file_path = f'bookchat/{image_file.name}'

        path = default_storage.save(file_path, image_file)
        
        # 저장된 파일의 URL 가져오기
        image_url = default_storage.url(path)

        return Response({
            'imageUrl': image_url,
            'message': '이미지가 성공적으로 업로드되었습니다.'
        }, status=status.HTTP_200_OK)

    except Exception as e:
        print(f"Image upload error: {str(e)}")
        return Response({
            'error': f'이미지 업로드 중 오류가 발생했습니다: {str(e)}'
        }, status=status.HTTP_500_INTERNAL_SERVER_ERROR)
    
@api_view(['POST'])
def add_book(request):
    try:
        # 필수 필드 확인
        title = request.data.get('title')
        keyword = request.data.get('keyword')
        description = request.data.get('des')
        image_url = request.data.get('imgurl')
        print("Received image URL:", image_url, flush=True)

        if not title or not keyword:
            return Response({
                'error': '제목과 키워드는 필수 입력 항목입니다.'
            }, status=status.HTTP_400_BAD_REQUEST)

        if not image_url:
            return Response({
                'error': '이미지 URL이 필요합니다.'
            }, status=status.HTTP_400_BAD_REQUEST)

        # file_path = image_url.split('/media/')[-1].split('?')[0] 
        # print("Received file path:", file_path, flush=True)
        # Cloudinary에서 이미 업로드된 이미지 URL을 poster 필드에 저장
        book = Book(
            title=title,
            keyword=keyword,
            description=description,
            poster=image_url 
        )
        
        # Cloudinary URL을 직접 ImageField에 할당
        book.save()

        return Response({
            'message': '책이 성공적으로 추가되었습니다.',
            'id': book.id,
            'title': book.title,
            'poster_url': book.get_poster_url()
        }, status=status.HTTP_201_CREATED)

    except Exception as e:
        print(f"Error adding book: {str(e)}")
        return Response({
            'error': f'책 추가 중 오류가 발생했습니다: {str(e)}'
        }, status=status.HTTP_500_INTERNAL_SERVER_ERROR)
    
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
@permission_classes([IsAuthenticated])
def change_mylist(request):
    try:
        book_id = request.data.get('book_id')
        book = Book.objects.get(id=book_id)
        if request.user in book.liked_by.all():
            book.liked_by.remove(request.user)
            is_liked = False
        else:
            book.liked_by.add(request.user)
            is_liked = True
        return Response({'success': True, 'like': is_liked})
    except Book.DoesNotExist:
        return Response({'success': False, 'error': 'Book not found'}, status=404)

@api_view(['GET'])
def randomBook_myList(request):
    myListBooks = Book.objects.filter(liked_by=request.user)
    sample_size = min(len(myListBooks), 4)
    randomBooks = random.sample(list(myListBooks), sample_size)
    serializer = BookSerializer(randomBooks, many=True)
    return Response(serializer.data)

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

    # 시리얼라이저 에러 처리
    error_messages = {}
    
    # 이메일 필드 에러
    if 'email' in serializer.errors:
        error_messages['email'] = serializer.errors['email'][0]
    
    # 비밀번호 필드 에러
    if 'password' in serializer.errors:
        error_messages['password'] = serializer.errors['password'][0]
        
    # 이름 필드 에러
    if 'name' in serializer.errors:
        error_messages['name'] = serializer.errors['name'][0]
    
    # 에러가 있는 경우
    if error_messages:
        return Response(
            {
                'message': next(iter(error_messages.values())),  # 첫 번째 에러 메시지
                'field_errors': error_messages  # 상세 필드별 에러
            },
            status=status.HTTP_400_BAD_REQUEST
        )
    
    # 기타 에러
    return Response(
        {
            'message': '요청 처리 중 오류가 발생했습니다',
            'field_errors': serializer.errors
        }, 
        status=status.HTTP_400_BAD_REQUEST
    )
    # return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)

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
    comments = Comment.objects.filter(book_id=book_id, parent=None).prefetch_related('replies')
    serializer = CommentSerializer(comments, many=True)
    return Response(serializer.data)

@api_view(['POST'])
@permission_classes([IsAuthenticated])
def create_comment(request, book_id):
    try:
        book = Book.objects.get(id=book_id)
        parent_id = request.data.get('parent_id')
        
        data = request.data.copy()
        if parent_id:
            try:
                parent_comment = Comment.objects.get(id=parent_id)
                data['parent'] = parent_comment.id
            except Comment.DoesNotExist:
                return Response({'error': 'Parent comment not found'}, status=404)


        serializer = CommentSerializer(data=data)
        if serializer.is_valid():
            serializer.save(book=book, user=request.user)
            return Response(serializer.data, status=201)
        return Response(serializer.errors, status=400)
    except Book.DoesNotExist:
        return Response({'error': 'Book not found'}, status=404)
    

@api_view(['POST'])
def signup(request):
    print("Signup request data:", request.data)  # 디버깅용 로그
    
    serializer = UserSerializer(data=request.data)
    if serializer.is_valid():
        try:
            user = serializer.save()  # create 메서드 자동 호출
            token, _ = Token.objects.get_or_create(user=user)
            
            return Response({
                'message': '회원가입이 완료되었습니다.',
                'token': token.key,
                'user': UserSerializer(user).data
            }, status=status.HTTP_201_CREATED)
            
        except Exception as e:
            print("Error during signup:", str(e))  # 에러 로깅
            return Response({
                'error': '회원가입 처리 중 오류가 발생했습니다.'
            }, status=status.HTTP_400_BAD_REQUEST)
    
    print("Validation errors:", serializer.errors)  # 유효성 검사 오류 로깅
    return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)


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

