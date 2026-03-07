from django.contrib import admin
from django.urls import path, include 
from django.http import JsonResponse
from drf_spectacular.views import SpectacularAPIView, SpectacularRedocView, SpectacularSwaggerView

# Fonction rapide pour l'accueil
def home(request):
    return JsonResponse({
        "message": "Bienvenue sur l'API APK-DROPSHIPPING-FINDER-V2",
        "statut": "En ligne",
        "documentation": "/api/docs/"
    })

urlpatterns = [
    # Administration Django
    path('admin/', admin.site.urls),

    # Accueil
    path('', home, name='home'),

    # Routes de l'application products
    path('api/', include('products.urls')),
    
    # Tes routes d'authentification personnalisées (register, login, verify-otp, forgot-password, etc.)
    path('api/auth/', include('accounts.urls')),

    # Vues d'authentification internes de DRF (renommées en 'api-auth/')
    path('api-auth/', include('rest_framework.urls')), 

    # Routes pour Swagger
    path('api/schema/', SpectacularAPIView.as_view(), name='schema'),
    path('api/docs/', SpectacularSwaggerView.as_view(url_name='schema'), name='swagger-ui'),

    # Route pour Redoc
    path('api/schema/redoc/', SpectacularRedocView.as_view(url_name='schema'), name='redoc'),

    # Routes de l'application scraper
    path('api/scraper/', include('scraper.urls')),
]