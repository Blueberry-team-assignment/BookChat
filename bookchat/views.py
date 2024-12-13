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
    book = Book.objects.get(id=id)
    serializer = BookSerializer(book)
    return Response(serializer.data)

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