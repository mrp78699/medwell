# serializers.py
from rest_framework import serializers
from .models import MedicalPrescription

class MedicalPrescriptionSerializer(serializers.ModelSerializer):
    class Meta:
        model = MedicalPrescription
        fields = ['id', 'user', 'prescription_file', 'uploaded_at']