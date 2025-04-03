from django.db import models
from django.contrib.auth.models import User

def prescription_upload_path(instance, filename):
    # Define how the file path should be structured
    return f'prescriptions/{instance.id}/{filename}'

class MedicalPrescription(models.Model):
    user = models.ForeignKey(User, on_delete=models.CASCADE)
    prescription_file = models.FileField(upload_to=prescription_upload_path, null=False, default=None)  # Corrected default value
    uploaded_at = models.DateTimeField(auto_now_add=True)

    def __str__(self):
        return f"{self.user.username} - {self.prescription_file.name}"
