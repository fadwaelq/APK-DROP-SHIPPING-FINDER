from django.urls import path

from .views import product as views
from .views import watchlist as watchlist_views
urlpatterns = [
    #  MOTEUR DE RECHERCHE & CATALOGUE (US1) 
    # GET /api/products/ -> Liste avec filtres et recherche
    path('', views.ProductListAPIView.as_view(), name='product-list'),
    
    # GET /api/products/1/ -> Détails complets d'un produit spécifique
    path('<int:pk>/', views.ProductDetailAPIView.as_view(), name='product-detail'),

    #  PORTFOLIO & FAVORIS (Workflow 2) ---
    # GET /api/products/watchlist/ -> Liste les favoris de l'utilisateur
    # POST /api/products/watchlist/ -> Ajoute un produit aux favoris
    path('favorites/', watchlist_views.WatchlistAPIView.as_view(), name='watchlist-list-create'),
    
    # DELETE /api/products/watchlist/1/ -> Retire un favori précis
    path('watchlist/<int:pk>/', watchlist_views.WatchlistDetailAPIView.as_view(), name='watchlist-delete'),

    # HISTORIQUE DE CONSULTATION (Workflow 2) ---
    # GET /api/products/history/ -> Liste les produits récemment consultés par l'utilisateur
    path('history/', views.ProductHistoryAPIView.as_view(), name='product-history'),

    # ==========================================
    #  ANALYSE PRODUIT AVANCÉE
    # ==========================================
    # GET /api/products/{productId}/suppliers
    path('<int:pk>/suppliers/', views.ProductSuppliersAPIView.as_view(), name='product-suppliers'),
    
    # POST /api/products/{productId}/contact-supplier
    path('<int:pk>/contact-supplier/', views.ContactSupplierAPIView.as_view(), name='product-contact-supplier'),
    
    # GET /api/products/{productId}/performance
    path('<int:pk>/performance/', views.ProductPerformanceAPIView.as_view(), name='product-performance'),
    
    # GET /api/products/{productId}/reviews
    path('<int:pk>/reviews/', views.ProductReviewsAPIView.as_view(), name='product-reviews'),
]