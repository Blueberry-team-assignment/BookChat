from django.urls import path, include
from .views import (
    helloAPI,
    randomBook,
    save_memo,
    get_memo,
    allBooks,
    change_mylist,
    randomBook_myList,
    login,
    get_users,
    get_user_info,
    get_comments,
    create_comment,
    signup,
    upload_image,
    add_book
)
from . import views
from rest_framework.routers import DefaultRouter  # 이 줄 추가

router = DefaultRouter()
router.register(r'rooms', views.CustomRoomViewSet, basename='chat_room')

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
    path('api/v1/chat/', include(router.urls)),
    path('books/<int:book_id>/comments/', get_comments),
    path('books/<int:book_id>/comments/create/', create_comment),
    path('signup/', signup),
    path('upload_image/', upload_image),
    path('add_book/', add_book)
]