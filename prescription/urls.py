from django.urls import path, include
from django.conf import settings
from django.conf.urls.static import static
from . import views
from .views import PrescriptionDeleteView, PrescriptionFileListView

urlpatterns = [
    path('upload_prescription/', views.upload_prescription, name='upload_prescription'),
    path('prescriptions/', PrescriptionFileListView.as_view(), name='prescription-list'),
    path('prescriptions/<int:prescription_id>/', PrescriptionDeleteView.as_view(), name='delete_prescription'),
]


if settings.DEBUG:
    urlpatterns += static(settings.MEDIA_URL, document_root=settings.MEDIA_ROOT)
