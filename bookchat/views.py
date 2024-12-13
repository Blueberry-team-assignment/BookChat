from rest_framework.response import Response
from rest_framework.decorators import api_view
from .models import Book, BookMemo
from .serializers import BookSerializer
import random 

@api_view(['GET'])
def helloAPI(request):
    return Response("hello world!")

@api_view(['GET'])
def randomBook(request, id):
    totalBooks = Book.objects.all()
    randomBooks = random.sample(list(totalBooks), id)
    serializer = BookSerializer(randomBooks, many=True)
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