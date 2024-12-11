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
    serializer = QuizSerializer(randomBooks, many=True)
    return Response(serializer.data)