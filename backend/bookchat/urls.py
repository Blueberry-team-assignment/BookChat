from django.urls import path
from .views import helloAPI, randomBook, save_memo, get_memo, allBooks, change_mylist, randomBook_myList, login, get_users, get_user_info

urlpatterns = [
    path("hello/", helloAPI),
    path("<int:id>/", randomBook),
    path("memo/", save_memo),
    path("memo/<int:book_id>/", get_memo),
    path("books/", allBooks),
    path("book_like/", change_mylist),
    path("myList/", randomBook_myList),
    path('login/', login),
    path('users/', get_users),
    path('user/', get_user_info),
]