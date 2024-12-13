from django.urls import path
from .views import helloAPI, randomBook, save_memo, get_memo, create_book

urlpatterns = [
    path("hello/", helloAPI),
    path("<int:id>/", randomBook),
    path("memo/", save_memo),
    path("memo/<int:book_id>/", get_memo),
    path("books/", create_book)
]