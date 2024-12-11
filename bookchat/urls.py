from django.urls import path, include
from .views import helloAPI, randomBook

urlpatterns = [
    path("hello/", helloAPI),
    path("<int:id>/", randomBook)
]