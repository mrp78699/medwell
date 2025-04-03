from django.db import models
from django.contrib.auth.models import User

class GeneratedPDF(models.Model):
    user = models.ForeignKey(User, on_delete=models.CASCADE, null=True, blank=True)  # Allow null values
    name = models.CharField(max_length=100)
    age = models.IntegerField()
    gender = models.CharField(max_length=10)
    weight = models.FloatField()
    phone_number = models.CharField(max_length=15)
    created_at = models.DateTimeField(auto_now_add=True)
    file = models.FileField(upload_to='generated_pdfs/')

    def __str__(self):
        return f"{self.user.username} - {self.file.name}"
