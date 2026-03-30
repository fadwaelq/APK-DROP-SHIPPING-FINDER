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

from django.db.models import Q
from rest_framework.pagination import PageNumberPagination

class ProductPagination(PageNumberPagination):
    page_size = 10
    page_size_query_param = 'page_size'
    max_page_size = 50

class ProductListAPIView(generics.ListCreateAPIView):
    """
    GET: Liste des produits avec filtres + search optimisé
    POST: Création produit (scraper)
    """

    serializer_class = ProductSerializer
    permission_classes = [permissions.IsAuthenticatedOrReadOnly]

    filter_backends = [DjangoFilterBackend, filters.OrderingFilter]

    filterset_fields = ['category', 'competition_level', 'is_winner']
    ordering_fields = ['trend_score', 'potential_profit', 'price', 'created_at']
    ordering = ['-trend_score', '-created_at']

    def get_queryset(self):
        queryset = Product.objects.all().order_by('-created_at')
        user = self.request.user

    # 🔒 PAYWALL
        if not user.is_authenticated:
            queryset = queryset.filter(is_winner=False)

    # 🔍 SEARCH (قوي + صحيح)
        search = self.request.query_params.get('search', '').strip()

        if search:
            print("🔥 SEARCH:", search)

            queryset = queryset.filter(
            Q(title__iregex=rf'\b{search}\b')
    )

        return queryset
    pagination_class = ProductPagination
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
from ..permissions import IsProUser
from rest_framework import permissions

class TrendingProductsAPIView(generics.ListAPIView):
    serializer_class = ProductSerializer
    permission_classes = [permissions.IsAuthenticated, IsProUser]

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
    
# ==========================================
# ANALYSE PRODUIT AVANCÉE
# ==========================================

class ProductSuppliersAPIView(APIView):
    """ GET /api/products/{productId}/suppliers : Liste des fournisseurs trouvés """
    permission_classes = [permissions.IsAuthenticated]

    def get(self, request, pk):
        product = get_object_or_404(Product, pk=pk)
        suppliers = [
            {"id": 1, "name": "AliExpress Supplier A", "price": float(product.price) * 0.4 if product.price else 4.50, "shipping_time": "10-15 jours", "rating": 4.8, "link": "https://aliexpress.com/item/......"},
            {"id": 2, "name": "CJ Dropshipping", "price": float(product.price) * 0.45 if product.price else 5.20, "shipping_time": "7-12 jours", "rating": 4.5, "link": "https://cjdropshipping.com/product/..."}
        ]
        return Response({"product_id": pk, "suppliers": suppliers}, status=status.HTTP_200_OK)

class ContactSupplierAPIView(APIView):
    """ POST /api/products/{productId}/contact-supplier : Proxy de mise en relation """
    permission_classes = [permissions.IsAuthenticated]

    def post(self, request, pk):
        product = get_object_or_404(Product, pk=pk)
        message = request.data.get('message', '')
        supplier_id = request.data.get('supplier_id')
        
        if not message or not supplier_id:
            return Response({"error": "Le message et le supplier_id sont requis."}, status=status.HTTP_400_BAD_REQUEST)
            
        return Response({
            "success": True, 
            "message": "Message envoyé au fournisseur.",
            "details": {"product_id": pk, "supplier_id": supplier_id}
        }, status=status.HTTP_200_OK)

class ProductPerformanceAPIView(APIView):
    """ GET /api/products/{productId}/performance : Scores (0-100) """
    permission_classes = [permissions.IsAuthenticated]

    def get(self, request, pk):
        product = get_object_or_404(Product, pk=pk)
        base_score = product.trend_score if product.trend_score else 50
        
        performance = {
            "demand_score": min(100, int(base_score * 1.2)),
            "profit_score": min(100, int(base_score * 1.1)),
            "competition_score": max(0, 100 - int(base_score)),
            "overall_score": int(base_score)
        }
        return Response({"product_id": pk, "performance": performance}, status=status.HTTP_200_OK)

class ProductReviewsAPIView(APIView):
    """ GET /api/products/{productId}/reviews : Récupération des avis clients """
    permission_classes = [permissions.IsAuthenticated]

    def get(self, request, pk):
        product = get_object_or_404(Product, pk=pk)
        reviews = [
            {"rating": 5, "comment": "Excellent produit !", "source": "AliExpress", "date": "2023-10-25"},
            {"rating": 4, "comment": "Bonne qualité.", "source": "AliExpress", "date": "2023-10-20"},
        ]
        
        return Response({
            "product_id": pk, 
            "average_rating": 4.5,
            "total_reviews": len(reviews), 
            "reviews": reviews
        }, status=status.HTTP_200_OK)
    
# ==========================================
# MODULE BENCHMARK (NOUVEAU)
# ==========================================

class BenchmarkSummaryAPIView(APIView):
    """ GET /api/benchmark/summary/ : Stats globales pour comparaison """
    permission_classes = [permissions.IsAuthenticated]

    def get(self, request):
        user = request.user
        # On calcule des stats réelles basées sur tes modèles
        total_scraped = Product.objects.count()
        user_history_count = ProductHistory.objects.filter(user=user).count()
        
        # Simulation de marge moyenne basée sur tes produits Winner
        avg_profit = Product.objects.filter(is_winner=True).values_list('potential_profit', flat=True)
        margin_mean = sum(avg_profit) / len(avg_profit) if avg_profit else 0

        return Response({
            "total_products_market": total_scraped,
            "user_analyzed_count": user_history_count,
            "average_market_margin": round(margin_mean, 2),
            "monthly_performance_index": 78.5 # Index de tendance globale
        }, status=status.HTTP_200_OK)

class BenchmarkProductsAPIView(generics.ListAPIView):
    """ GET /api/benchmark/products/ : Liste comparative des Top Potentiels """
    serializer_class = ProductSerializer
    permission_classes = [permissions.IsAuthenticated]

    def get_queryset(self):
        # On filtre les produits qui ont le meilleur score de tendance 
        # pour l'écran "Meilleur Potentiel"
        return Product.objects.filter(trend_score__gt=75).order_by('-trend_score')[:20]