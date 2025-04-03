from rest_framework import serializers, viewsets
from rest_framework.permissions import IsAuthenticated
from .models import InhalerReminder

class InhalerReminderSerializer(serializers.ModelSerializer):
    class Meta:
        model = InhalerReminder
        fields = ['id', 'reminder_time', 'is_active']  # Exclude 'user'

class InhalerReminderViewSet(viewsets.ModelViewSet):
    serializer_class = InhalerReminderSerializer
    permission_classes = [IsAuthenticated]

    def get_queryset(self):
        """ Ensure users can only see their own reminders. """
        return InhalerReminder.objects.filter(user=self.request.user)

    def perform_create(self, serializer):
        """ Save reminder with the logged-in user. """
        serializer.save(user=self.request.user)  # Assign user automatically
