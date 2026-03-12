from django.urls import path
from .views.jobs import LiveSearchAPIView, BulkLiveSearchAPIView

urlpatterns = [
    # POST /api/scraper/search/ -> Cherche un produit sans le sauvegarder
    path('search/', LiveSearchAPIView.as_view(), name='live-search'),
    
    # POST /api/scraper/bulk-search/ -> Cherche plusieurs produits
    path('bulk-search/', BulkLiveSearchAPIView.as_view(), name='bulk-live-search'),
]