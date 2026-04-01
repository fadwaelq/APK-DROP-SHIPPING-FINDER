from django.urls import path
from .views import product as views
from .views import watchlist as watchlist_views

urlpatterns = [
    # --- MOTEUR DE RECHERCHE & CATALOGUE ---
    path('', views.ProductListAPIView.as_view(), name='product-list'),
    path('<int:pk>/', views.ProductDetailAPIView.as_view(), name='product-detail'),

    # --- BENCHMARK & COMPARATIVES (LES MANQUANTS) ---
    # GET /api/products/benchmark/summary/
    path('benchmark/summary/', views.BenchmarkSummaryAPIView.as_view(), name='benchmark-summary'),
    # GET /api/products/benchmark/products/
    path('benchmark/products/', views.BenchmarkProductsAPIView.as_view(), name='benchmark-products'),

    # --- FAVORIS (WATCHLIST) ---
    path('watchlist/', watchlist_views.WatchlistAPIView.as_view(), name='watchlist-list-create'),
    path('watchlist/<int:pk>/', watchlist_views.WatchlistDetailAPIView.as_view(), name='watchlist-delete'),

    # --- HISTORIQUE & TENDANCES ---
    path('history/', views.ProductHistoryAPIView.as_view(), name='product-history'),
    path('trending/', views.TrendingProductsAPIView.as_view(), name='product-trending'),
    path('category-trends/', views.CategoryTrendsAPIView.as_view(), name='category-trends'),

    # --- ANALYSE PRODUIT AVANCÉE ---
    path('<int:pk>/suppliers/', views.ProductSuppliersAPIView.as_view(), name='product-suppliers'),
    path('<int:pk>/contact-supplier/', views.ContactSupplierAPIView.as_view(), name='product-contact-supplier'),
    path('<int:pk>/performance/', views.ProductPerformanceAPIView.as_view(), name='product-performance'),
    path('<int:pk>/reviews/', views.ProductReviewsAPIView.as_view(), name='product-reviews'),
]