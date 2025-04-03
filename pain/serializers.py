from rest_framework import serializers
from .models import PainEntry

class PainEntrySerializer(serializers.ModelSerializer):
    class Meta:
        model = PainEntry
        fields = ['id', 'pain_area', 'pain_level', 'pain_notes', 'timestamp']
