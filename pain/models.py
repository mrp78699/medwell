from django.db import models
from django.contrib.auth.models import User

class PainEntry(models.Model):
    PAIN_AREAS = [
        ('Head', 'Head'),
        ('Leg', 'Leg'),
        ('Hand', 'Hand'),
    ]

    user = models.ForeignKey(User, on_delete=models.CASCADE)
    pain_area = models.CharField(max_length=10, choices=PAIN_AREAS)
    pain_level = models.IntegerField()
    pain_notes = models.TextField(blank=True, null=True)
    timestamp = models.DateTimeField(auto_now_add=True)

    def __str__(self):
        return f"{self.user.username} - {self.pain_area} - {self.pain_level}"
