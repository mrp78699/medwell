from django.urls import path
from chatbot.views import chatbot_api

urlpatterns = [
    path('chat/', chatbot_api, name='chatbot-response'),
]
