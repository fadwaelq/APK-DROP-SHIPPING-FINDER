from rest_framework import generics, filters
from django_filters.rest_framework import DjangoFilterBackend
from .models import Product
from .serializers import ProductSerializer

class ProductListAPIView(generics.ListAPIView):
    queryset = Product.objects.all()
    serializer_class = ProductSerializer
    
    # On active les 3 moteurs de recherche de DRF
    filter_backends = [DjangoFilterBackend, filters.SearchFilter, filters.OrderingFilter]
    
    # FILTRES EXACTS (Filtrer par ID, si c'est un winner, ou par score exact)
    filterset_fields = ['id', 'is_winner', 'trend_score']
    
    # RECHERCHE TEXTUELLE (La barre de recherche de l'utilisateur)
    search_fields = ['title', 'description', 'ai_analysis_summary']
    
    # SYSTÈME DE TRI (Trier du plus rentable au moins rentable, etc.)
    ordering_fields = ['trend_score', 'potential_profit', 'price', 'created_at']
    ordering = ['-created_at'] # Tri par défaut (les plus récents en premier)