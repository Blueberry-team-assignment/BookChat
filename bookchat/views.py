from rest_framework.response import Response
from rest_framework.decorators import api_view
from .models import Book
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
    print("Received request.data:", request.data, flush=True) 
    book_id = request.data.get('book_id')
    content = request.data.get('content')
    print("book id: ", book_id, "content: ", content, flush=True)
    try:
        book = Book.objects.get(id=book_id)
        memo, created = BookMemo.objects.update_or_create(
            book=book,
            defaults={'content': content}
        )
        return Response({'message': 'Memo saved successfully'})
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