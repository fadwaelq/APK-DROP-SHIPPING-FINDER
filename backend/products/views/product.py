from rest_framework import generics, filters
from rest_framework.permissions import IsAuthenticatedOrReadOnly
from django_filters.rest_framework import DjangoFilterBackend
from products.models import Product
from products.serializers import ProductSerializer 
from rest_framework.views import APIView
from rest_framework.response import Response
from django.db.models import Count

# CHANGEMENT : ListAPIView devient ListCreateAPIView
class ProductListAPIView(generics.ListCreateAPIView):
    """
    GET : Moteur de recherche intelligent avec filtres avancés (US1).
    POST : Enregistrer un produit depuis le scraper vers la base de données (Validation Frontend).
    """
    queryset = Product.objects.all()
    serializer_class = ProductSerializer
    
    # AJOUT : Seuls les utilisateurs connectés peuvent sauvegarder, mais tout le monde peut chercher
    permission_classes = [IsAuthenticatedOrReadOnly] 
    
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


class TrendingProductsAPIView(generics.ListAPIView):
    """ GET /api/products/trending/ - Les 10 produits avec le plus gros Trend Score """
    serializer_class = ProductSerializer
    permission_classes = [] # Public

    def get_queryset(self):
        return Product.objects.filter(is_winner=True).order_by('-trend_score')[:10]

class TopRatedProductsAPIView(generics.ListAPIView):
    """ GET /api/products/top_rated/ - Les produits les plus rentables (Potential Profit) """
    serializer_class = ProductSerializer
    permission_classes = []

    def get_queryset(self):
        return Product.objects.all().order_by('-potential_profit')[:10]

class CategoryTrendsAPIView(APIView):
    """ GET /api/products/category_trends/ - Statistiques par catégorie """
    permission_classes = []

    def get(self, request):
        # On regroupe les produits par catégorie et on les compte
        trends = Product.objects.values('category').annotate(total=Count('id')).order_by('-total')
        return Response(trends)

class AnalyzeProductAPIView(APIView):
    """ GET /api/products/analyze/{id}/ - Renvoie uniquement l'analyse IA d'un produit """
    permission_classes = [IsAuthenticatedOrReadOnly]

    def get(self, request, pk):
        try:
            product = Product.objects.get(pk=pk)
            # On ne renvoie que les données pertinentes pour l'IA
            data = {
                "id": product.id,
                "title": product.title,
                "trend_score": product.trend_score,
                "potential_profit": product.potential_profit,
                "is_winner": product.is_winner,
                "ai_analysis_summary": product.ai_analysis_summary,
            }
            return Response(data)
        except Product.DoesNotExist:
            return Response({"error": "Produit introuvable"}, status=404)