from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework.permissions import IsAuthenticated
from rest_framework import status
from django.core.files.storage import FileSystemStorage
from django.conf import settings
import os
from io import BytesIO
from reportlab.lib.pagesizes import letter
from reportlab.pdfgen import canvas
from .models import GeneratedPDF
from .serializers import GeneratedPDFSerializer
from pain.models import PainEntry

class GeneratePDFView(APIView):
    permission_classes = [IsAuthenticated]

    def post(self, request):
        data = request.data
        user = request.user

        name = data.get('name', 'Unknown')
        age = data.get('age', 'N/A')
        gender = data.get('gender', 'N/A')
        weight = data.get('weight', 'N/A')
        phone_number = data.get('phone_number', 'N/A')

        # Create PDF in memory
        buffer = BytesIO()
        pdf = canvas.Canvas(buffer, pagesize=letter)
        pdf.setTitle(f"{name}_Pain_Report")

        # PDF Header
        pdf.setFont("Helvetica-Bold", 16)
        pdf.drawString(200, 750, "Chronic Disease Adherence - Pain Report")

        pdf.setFont("Helvetica", 12)
        pdf.drawString(50, 720, f"Name: {name}")
        pdf.drawString(50, 700, f"Age: {age}")
        pdf.drawString(50, 680, f"Gender: {gender}")
        pdf.drawString(50, 660, f"Weight: {weight} kg")
        pdf.drawString(50, 640, f"Phone Number: {phone_number}")

        # Table Headers
        y_position = 600
        pdf.setFont("Helvetica-Bold", 12)
        pdf.drawString(50, y_position, "Date & Time")
        pdf.drawString(200, y_position, "Pain Area")
        pdf.drawString(350, y_position, "Pain Level")
        pdf.drawString(450, y_position, "Notes")

        pdf.setFont("Helvetica", 10)
        y_position -= 20

        # Fetch Pain Entries
        pain_entries = PainEntry.objects.filter(user=user).order_by("-timestamp")

        for entry in pain_entries:
            pdf.drawString(50, y_position, entry.timestamp.strftime("%Y-%m-%d %H:%M"))
            pdf.drawString(200, y_position, entry.pain_area)
            pdf.drawString(350, y_position, str(entry.pain_level))
            pdf.drawString(450, y_position, entry.pain_notes or "-")
            y_position -= 20

            if y_position < 50:  # Prevent overlapping
                pdf.showPage()
                y_position = 750

        pdf.save()
        buffer.seek(0)

        # Save the PDF to the media directory
        fs = FileSystemStorage(location=os.path.join(settings.MEDIA_ROOT, 'pdfs'))
        pdf_filename = f"{name}_{age}_report.pdf"
        pdf_path = fs.path(pdf_filename)

        with open(pdf_path, "wb") as f:
            f.write(buffer.read())

        buffer.close()

        # Save in the database
        pdf_instance = GeneratedPDF.objects.create(
            user=user, name=name, age=age, gender=gender, weight=weight,
            phone_number=phone_number, file=f"pdfs/{pdf_filename}"
        )

        serializer = GeneratedPDFSerializer(pdf_instance)
        return Response({"message": "PDF generated successfully", "data": serializer.data}, status=status.HTTP_201_CREATED)


class ListPDFView(APIView):
    permission_classes = [IsAuthenticated]

    def get(self, request):
        pdfs = GeneratedPDF.objects.filter(user=request.user)
        serializer = GeneratedPDFSerializer(pdfs, many=True)
        return Response({"pdfs": serializer.data})


class DeletePDFView(APIView):
    permission_classes = [IsAuthenticated]

    def delete(self, request, pdf_id):
        try:
            pdf = GeneratedPDF.objects.get(id=pdf_id, user=request.user)
            pdf.delete()
            return Response({"message": "PDF deleted successfully"}, status=status.HTTP_204_NO_CONTENT)
        except GeneratedPDF.DoesNotExist:
            return Response({"error": "PDF not found"}, status=status.HTTP_404_NOT_FOUND)
