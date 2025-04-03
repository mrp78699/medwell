from rest_framework import status
from rest_framework.response import Response
from rest_framework.decorators import api_view
from .models import MedicalPrescription
from .serializers import MedicalPrescriptionSerializer
from rest_framework.views import APIView
from rest_framework.permissions import IsAuthenticated
import os
from django.conf import settings

@api_view(['POST'])
def upload_prescription(request):
    if request.user.is_authenticated:
        user = request.user
        data = request.data.copy()
        data['user'] = user.id
        serializer = MedicalPrescriptionSerializer(data=data)
        if serializer.is_valid():
            serializer.save()
            return Response(serializer.data, status=status.HTTP_201_CREATED)
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)
    return Response({'detail': 'Authentication credentials were not provided.'}, status=status.HTTP_401_UNAUTHORIZED)


class PrescriptionFileListView(APIView):
    permission_classes = [IsAuthenticated]

    def get(self, request):
        prescriptions = MedicalPrescription.objects.filter(user=request.user)
        serializer = MedicalPrescriptionSerializer(prescriptions, many=True)
        return Response(serializer.data, status=status.HTTP_200_OK)


class PrescriptionDeleteView(APIView):
    permission_classes = [IsAuthenticated]

    def delete(self, request, prescription_id):
        try:
            prescription = MedicalPrescription.objects.get(id=prescription_id, user=request.user)
            
            # Delete the associated file from the media folder
            if prescription.prescription_file:
                file_path = os.path.join(settings.MEDIA_ROOT, str(prescription.prescription_file))
                if os.path.exists(file_path):
                    os.remove(file_path)
            
            # Delete the prescription entry from the database
            prescription.delete()
            return Response({"message": "Prescription deleted successfully."}, status=status.HTTP_204_NO_CONTENT)

        except MedicalPrescription.DoesNotExist:
            return Response({"error": "Prescription not found."}, status=status.HTTP_404_NOT_FOUND)
