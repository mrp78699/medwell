from django.urls import path
from .views import GeneratePDFView, ListPDFView, DeletePDFView

urlpatterns = [
    path('generate-pdf/', GeneratePDFView.as_view(), name='generate_pdf'),
    path('list-pdfs/', ListPDFView.as_view(), name='list_pdfs'),
    path('delete-pdf/<int:pdf_id>/', DeletePDFView.as_view(), name='delete_pdf'),
]


from django.conf import settings
from django.conf.urls.static import static

if settings.DEBUG:
    urlpatterns += static(settings.MEDIA_URL, document_root=settings.MEDIA_ROOT)
