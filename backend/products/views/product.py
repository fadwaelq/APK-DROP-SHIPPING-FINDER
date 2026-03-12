from rest_framework import generics, filters
from django_filters.rest_framework import DjangoFilterBackend
from products.models import Product
from products.serializers import ProductSerializer

class ProductListAPIView(generics.ListAPIView):
    """
    Moteur de recherche intelligent avec filtres avancés (US1).
    """
    queryset = Product.objects.all()
    serializer_class = ProductSerializer
    
    filter_backends = [DjangoFilterBackend, filters.SearchFilter, filters.OrderingFilter]
    
    # FILTRES LATÉRAUX (Catégorie, Niveau de concurrence, Winner)
    filterset_fields = ['category', 'competition_level', 'is_winner']
    
    # RECHERCHE TEXTUELLE
    search_fields = ['title', 'description', 'category', 'ai_analysis_summary']
    
    # SYSTÈME DE TRI (Par défaut : les meilleurs Trend Scores d'abord)
    ordering_fields = ['trend_score', 'potential_profit', 'price', 'created_at']
    ordering = ['-trend_score', '-created_at']

class ProductDetailAPIView(generics.RetrieveAPIView):
    """Pour afficher l'analyse détaillée d'un seul produit"""
    queryset = Product.objects.all()
    serializer_class = ProductSerializer