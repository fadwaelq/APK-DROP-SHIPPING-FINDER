from django.urls import path
from . import views

urlpatterns = [
    #  MOTEUR DE RECHERCHE & CATALOGUE (US1) 
    # GET /api/products/ -> Liste avec filtres et recherche
    path('', views.ProductListAPIView.as_view(), name='product-list'),
    
    # GET /api/products/1/ -> Détails complets d'un produit spécifique
    path('<int:pk>/', views.ProductDetailAPIView.as_view(), name='product-detail'),

    #  PORTFOLIO & FAVORIS (Workflow 2) ---
    # GET /api/products/watchlist/ -> Liste les favoris de l'utilisateur
    # POST /api/products/watchlist/ -> Ajoute un produit aux favoris
    path('watchlist/', views.WatchlistAPIView.as_view(), name='watchlist-list-create'),
    
    # DELETE /api/products/watchlist/1/ -> Retire un favori précis
    path('watchlist/<int:pk>/', views.WatchlistDetailAPIView.as_view(), name='watchlist-delete'),
]