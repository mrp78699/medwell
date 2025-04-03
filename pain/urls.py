from django.urls import path, include
from rest_framework.routers import DefaultRouter
from .views import PainEntryViewSet

router = DefaultRouter()
router.register(r'pain-tracker', PainEntryViewSet, basename='pain-tracker')

urlpatterns = [
    path('', include(router.urls)),
]

