
from django.contrib import admin
from django.urls import include, path
from drf_spectacular.views import SpectacularAPIView, SpectacularSwaggerView, SpectacularRedocView

urlpatterns = [
    path('admin/', admin.site.urls),

    # --- DOCUMENTATION API (SWAGGER) ---
    # Téléchargement du schéma au format YAML/JSON
    path('api/schema/', SpectacularAPIView.as_view(), name='schema'),
    
    # L'interface Swagger UI
    path('api/docs/', SpectacularSwaggerView.as_view(url_name='schema'), name='swagger-ui'),

    # L'interface alternative Redoc (optionnel)
    path('api/redoc/', SpectacularRedocView.as_view(url_name='schema'), name='redoc'),

    # Analyse de la couverture de la documentation (optionnel)
    path('api/analytics/', include('analytics.urls')),

    # Api accounts
    path('api/accounts/', include('accounts.urls')), 

    # Inclure les URLs de l'application scraper
    path('api/scraper/', include('scraper.urls')),

    # Inclure les URLs de l'application products
    path('api/products/', include('products.urls')),
]
