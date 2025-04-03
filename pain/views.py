from rest_framework import viewsets, permissions
from rest_framework.response import Response
from .models import PainEntry
from .serializers import PainEntrySerializer
from rest_framework import generics

class PainEntryViewSet(viewsets.ModelViewSet):
    serializer_class = PainEntrySerializer
    permission_classes = [permissions.IsAuthenticated]

    def get_queryset(self):
        return PainEntry.objects.filter(user=self.request.user).order_by('-timestamp')

    def perform_create(self, serializer):
        serializer.save(user=self.request.user)
