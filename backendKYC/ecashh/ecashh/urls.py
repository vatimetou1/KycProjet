from django.contrib import admin
from django.urls import path, include
from django.conf.urls.static import static
from ecashh import settings

urlpatterns = [
    path('admin/', admin.site.urls),  # URL pour l'interface d'administration de Django
    path('appecash/', include('appecash.urls'))  # Inclure les URL définies dans votre application 'api'
] + static(settings.MEDIA_URL, document_root=settings.MEDIA_ROOT)
