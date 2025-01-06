"""
ASGI config for myapi project.

It exposes the ASGI callable as a module-level variable named ``application``.

For more information on this file, see
https://docs.djangoproject.com/en/4.2/howto/deployment/asgi/
"""

import os
import django
from django.core.asgi import get_asgi_application
from channels.routing import ProtocolTypeRouter, URLRouter
from channels.auth import AuthMiddlewareStack

os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'myapi.settings')
django.setup()  # 추가: Django 앱 레지스트리를 명시적으로 초기화

from df_chat.asgi.routing import websocket_urlpatterns as df_chat_routing
from bookchat.routing import websocket_urlpatterns as bookchat_routing

# Combine the websocket_urlpatterns from both apps
combined_patterns = df_chat_routing + bookchat_routing

application = ProtocolTypeRouter({
    "http": get_asgi_application(),
    "websocket": AuthMiddlewareStack(
        URLRouter(combined_patterns)
    ),
})