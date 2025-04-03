from django.urls import path, include
from rest_framework.routers import DefaultRouter
from .views import InhalerReminderViewSet

router = DefaultRouter()
router.register(r'inhaler-reminders', InhalerReminderViewSet, basename='inhaler-reminders')


urlpatterns = [
    path('', include(router.urls)),
]
