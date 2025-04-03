from django.contrib import admin
from django.urls import path,include

urlpatterns = [
    path("admin/", admin.site.urls),
    path('api/auth/', include('users.urls')),
    path('api/',include('inhaler.urls')),
    path('api/',include('pain.urls')),
    path('api/',include('prescription.urls')),
    path('api/', include('pdf.urls')),
    path('api/', include('chatbot.urls')),
]
