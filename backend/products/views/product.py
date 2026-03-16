from rest_framework import generics, filters, status, permissions
from rest_framework.views import APIView
from rest_framework.response import Response
from django_filters.rest_framework import DjangoFilterBackend
from django.db.models import Count
from django.shortcuts import get_object_or_404

from ..serializers import ProductSerializer, ProductHistorySerializer
from ..models import Product, ProductWatchlist, ProductHistory

# ==========================================
# MOTEUR DE RECHERCHE & LISTE (Ligne 20)
# ==========================================
class ProductListAPIView(generics.ListCreateAPIView):
    """
    GET : Liste avec filtres avancés (Catégorie, Concurrence, Winner).
    POST : Enregistrement de produit par le scraper.
    """
    queryset = Product.objects.all()
    serializer_class = ProductSerializer
    permission_classes = [permissions.IsAuthenticatedOrReadOnly] 
    filter_backends = [DjangoFilterBackend, filters.SearchFilter, filters.OrderingFilter]
    
    filterset_fields = ['category', 'competition_level', 'is_winner']
    search_fields = ['title', 'description', 'category', 'ai_analysis_summary']
    ordering_fields = ['trend_score', 'potential_profit', 'price', 'created_at']
    ordering = ['-trend_score', '-created_at']

# ==========================================
# DÉTAILS & HISTORIQUE (Ligne 21 & 24)
# ==========================================
class ProductDetailAPIView(generics.RetrieveAPIView):
    """ Affiche les détails et enregistre automatiquement dans l'historique """
    queryset = Product.objects.all()
    serializer_class = ProductSerializer

    def get_object(self):
        product = super().get_object()
        user = self.request.user
        if user.is_authenticated:
            # Ligne 24 : Enregistrement auto dans l'historique lors de la vue
            ProductHistory.objects.update_or_create(
                user=user, 
                product=product
            )
        return product

class ProductHistoryAPIView(generics.ListAPIView):
    """ Ligne 24 : Liste des produits consultés par l'utilisateur connecté """
    serializer_class = ProductSerializer
    permission_classes = [permissions.IsAuthenticated]

    def get_queryset(self):
        user = self.request.user
        # On récupère les produits liés à l'historique de l'utilisateur
        return Product.objects.filter(producthistory__user=user).order_by('-producthistory__viewed_at')

# ==========================================
# WATCHLIST / FAVORIS (Ligne 23)
# ==========================================
class ProductWatchlistToggleView(APIView):
    """ Ajoute ou retire un produit des favoris (Toggle) """
    permission_classes = [permissions.IsAuthenticated]

    def post(self, request, pk):
        product = get_object_or_404(Product, pk=pk)
        watchlist_item, created = ProductWatchlist.objects.get_or_create(
            user=request.user, 
            product=product
        )
        
        if not created:
            watchlist_item.delete()
            return Response({"is_saved": False, "message": "Retiré des favoris"}, status=status.HTTP_200_OK)
        
        return Response({"is_saved": True, "message": "Ajouté aux favoris"}, status=status.HTTP_201_CREATED)

# ==========================================
# ANALYSES IA & TENDANCES
# ==========================================
class TrendingProductsAPIView(generics.ListAPIView):
    """ Top 10 produits avec le plus gros Trend Score """
    serializer_class = ProductSerializer
    permission_classes = [] 

    def get_queryset(self):
        return Product.objects.filter(is_winner=True).order_by('-trend_score')[:10]

class TopRatedProductsAPIView(generics.ListAPIView):
    """ Produits les plus rentables (Potential Profit) """
    serializer_class = ProductSerializer
    permission_classes = []

    def get_queryset(self):
        return Product.objects.all().order_by('-potential_profit')[:10]

class CategoryTrendsAPIView(APIView):
    """ Statistiques par catégorie """
    permission_classes = []

    def get(self, request):
        trends = Product.objects.values('category').annotate(total=Count('id')).order_by('-total')
        return Response(trends)

class AnalyzeProductAPIView(APIView):
    """ Analyse IA spécifique d'un produit """
    permission_classes = [permissions.IsAuthenticatedOrReadOnly]

    def get(self, request, pk):
        product = get_object_or_404(Product, pk=pk)
        return Response({
            "id": product.id,
            "title": product.title,
            "trend_score": product.trend_score,
            "potential_profit": product.potential_profit,
            "is_winner": product.is_winner,
            "ai_analysis_summary": product.ai_analysis_summary,
        })