from rest_framework import serializers
from .models import GeneratedPDF

class GeneratedPDFSerializer(serializers.ModelSerializer):
    generated_at = serializers.DateTimeField(source='created_at', format='%Y-%m-%d %H:%M:%S')
    
    class Meta:
        model = GeneratedPDF
        fields = '__all__'  # Include all fields
