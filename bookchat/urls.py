from django.urls import path
from .views import helloAPI, randomBook, create_book

urlpatterns = [
    path("hello/", helloAPI),
    path("<int:id>/", randomBook),
    path("books/", create_book)
]