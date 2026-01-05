from rest_framework import viewsets, status, filters
from rest_framework.decorators import action, api_view, permission_classes
from rest_framework.response import Response
from rest_framework.permissions import IsAuthenticated, AllowAny
from rest_framework_simplejwt.tokens import RefreshToken
from django.contrib.auth.models import User
from django.contrib.auth import authenticate
from django.db.models import Q, Count
from django_filters.rest_framework import DjangoFilterBackend
from core.scrapers.aliexpress_import import import_product_from_aliexpress


from core.models import (
    UserProfile, Product, Favorite, ProductView,
    SearchHistory, TrendAlert, ScrapingJob
)
from .serializers import (
    UserSerializer, UserProfileSerializer, ProductSerializer,
    ProductListSerializer, FavoriteSerializer, ProductViewSerializer,
    SearchHistorySerializer, TrendAlertSerializer, RegisterSerializer,
    PasswordChangeSerializer, ProductAnalysisSerializer
)
# Temporarily commented out for initial setup
from ai_engine.scoring import ProductScorer, TrendAnalyzer


class UserViewSet(viewsets.ModelViewSet):
    queryset = User.objects.all()
    serializer_class = UserSerializer
    permission_classes = [IsAuthenticated]
    
    @action(detail=False, methods=['get', 'patch', 'put'])
    def me(self, request):
        """Get or update current user profile"""
        if request.method == 'GET':
            serializer = self.get_serializer(request.user)
            return Response(serializer.data)
        else:
            # PATCH or PUT - update profile
            serializer = self.get_serializer(request.user, data=request.data, partial=True)
            if serializer.is_valid():
                serializer.save()
                return Response(serializer.data)
            return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)
    
    @action(detail=False, methods=['put'])
    def update_profile(self, request):
        """Update user profile"""
        user = request.user
        serializer = self.get_serializer(user, data=request.data, partial=True)
        if serializer.is_valid():
            serializer.save()
            return Response(serializer.data)
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)
    
    @action(detail=False, methods=['post'])
    def change_password(self, request):
        """Change user password"""
        serializer = PasswordChangeSerializer(data=request.data)
        if serializer.is_valid():
            user = request.user
            if not user.check_password(serializer.validated_data['old_password']):
                return Response(
                    {'error': 'Invalid old password'},
                    status=status.HTTP_400_BAD_REQUEST
                )
            
            user.set_password(serializer.validated_data['new_password'])
            user.save()
            return Response({'message': 'Password updated successfully'})
        
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)


class UserProfileViewSet(viewsets.ModelViewSet):
    queryset = UserProfile.objects.all()
    serializer_class = UserProfileSerializer
    permission_classes = [IsAuthenticated]
    
    def get_queryset(self):
        return UserProfile.objects.filter(user=self.request.user)
    
    @action(detail=False, methods=['get'])
    def my_profile(self, request):
        """Get current user's profile"""
        profile, created = UserProfile.objects.get_or_create(user=request.user)
        serializer = self.get_serializer(profile)
        return Response(serializer.data)
    
    @action(detail=False, methods=['post'])
    def update_subscription(self, request):
        """Update subscription plan"""
        profile, created = UserProfile.objects.get_or_create(user=request.user)
        plan = request.data.get('plan')
        
        if plan not in dict(UserProfile.SUBSCRIPTION_CHOICES):
            return Response(
                {'error': 'Invalid subscription plan'},
                status=status.HTTP_400_BAD_REQUEST
            )
        
        profile.subscription_plan = plan
        profile.save()
        
        serializer = self.get_serializer(profile)
        return Response(serializer.data)
    
    @action(detail=False, methods=['post'])
    def toggle_notifications(self, request):
        """Toggle notifications on/off"""
        profile, created = UserProfile.objects.get_or_create(user=request.user)
        profile.notifications_enabled = request.data.get('enabled', True)
        profile.save()
        
        return Response({'notifications_enabled': profile.notifications_enabled})


class ProductViewSet(viewsets.ModelViewSet):
    queryset = Product.objects.filter(is_active=True)
    permission_classes = [IsAuthenticated]
    filter_backends = [DjangoFilterBackend, filters.SearchFilter, filters.OrderingFilter]
    filterset_fields = ['category', 'source', 'is_trending']
    search_fields = ['name', 'description']
    ordering_fields = ['score', 'price', 'profit', 'created_at']
    ordering = ['-score']
    
    def get_serializer_class(self):
        if self.action == 'list':
            return ProductListSerializer
        return ProductSerializer
    
    def list(self, request, *args, **kwargs):
        """List products with search history tracking"""
        response = super().list(request, *args, **kwargs)
        
        # Track search if query exists
        query = request.query_params.get('search', '')
        if query:
            SearchHistory.objects.create(
                user=request.user,
                query=query,
                filters=dict(request.query_params),
                results_count=response.data.get('count', 0)
            )
        
        return response
    
    def retrieve(self, request, *args, **kwargs):
        """Retrieve product and track view"""
        response = super().retrieve(request, *args, **kwargs)
        
        # Track product view
        product = self.get_object()
        ProductView.objects.create(user=request.user, product=product)
        
        return response
    
    @action(detail=False, methods=['get'], permission_classes=[AllowAny])
    def trending(self, request):
        """Get trending products"""
        products = self.queryset.filter(is_trending=True)[:20]
        serializer = ProductListSerializer(products, many=True, context={'request': request})
        return Response(serializer.data)
    
    @action(detail=False, methods=['get'], permission_classes=[AllowAny])
    def top_rated(self, request):
        """Get top rated products"""
        products = self.queryset.order_by('-score')[:20]
        serializer = ProductListSerializer(products, many=True, context={'request': request})
        return Response(serializer.data)
    
    
    @action(detail=True, methods=['get'])
    def analyze(self, request, pk=None):
        """Get AI analysis for a product"""
        product = self.get_object()

        scorer = ProductScorer()

        product_data = {
            "price": float(product.price),
            "cost": float(product.cost) if product.cost else 0,
            "trend_percentage": float(product.trend_percentage),
            "review_count": product.supplier_review_count,
            "rating": float(product.supplier_rating),
            # valeurs simulées (MVP)
            "sales_count": 500,
            "views_count": 2000,
            "search_volume": 3000,
            "competitor_count": 20,
            "market_saturation": 40,
            "social_shares": 150,
            "growth_rate": product.trend_percentage,
        }

        analysis = scorer.analyze_product_potential(product_data)
        return Response(analysis)
    
    
    
    
    @action(detail=False, methods=['get'])
    def category_trends(self, request):
        """Get trend analysis for categories"""
        category = request.query_params.get('category')
        
        if not category:
            return Response(
                {'error': 'Category parameter required'},
                status=status.HTTP_400_BAD_REQUEST
            )
        
        products = self.queryset.filter(category=category)
        product_data = [
            {
                'score': p.score,
                'trend_percentage': float(p.trend_percentage),
                'name': p.name,
                'id': p.id,
            }
            for p in products
        ]
        
        analyzer = TrendAnalyzer()
        trends = analyzer.analyze_category_trends(category, product_data)
        return Response(trends)

         # 🚀 NEW ENDPOINT: Import real product from AliExpress using URL
    @action(detail=False, methods=['post'], url_path="import")
    def import_from_url(self, request):
        """Import real product data from AliExpress using URL"""

        url = request.data.get("url")
        if not url:
            return Response({"error": "URL is required"}, status=status.HTTP_400_BAD_REQUEST)

        data = import_product_from_aliexpress(url)
        if not data:
            return Response({"error": "Scraping failed or structure changed"}, status=400)

        product = Product.objects.create(
            name=data["title"],
            price=data.get("price", 0),
            description=data.get("description", "Imported from AliExpress"),
            source="AliExpress",
            source_url=data["url"],
            image_urls=data.get("images", []),  # doit exister dans modèle Product
            score=0,
        )

        return Response(ProductSerializer(product).data, status=201)



class FavoriteViewSet(viewsets.ModelViewSet):
    serializer_class = FavoriteSerializer
    permission_classes = [IsAuthenticated]
    
    def get_queryset(self):
        return Favorite.objects.filter(user=self.request.user)
    
    @action(detail=False, methods=['post'])
    def toggle(self, request):
        """Toggle favorite status for a product"""
        product_id = request.data.get('product_id')
        
        if not product_id:
            return Response(
                {'error': 'product_id required'},
                status=status.HTTP_400_BAD_REQUEST
            )
        
        try:
            product = Product.objects.get(id=product_id)
        except Product.DoesNotExist:
            return Response(
                {'error': 'Product not found'},
                status=status.HTTP_404_NOT_FOUND
            )
        
        favorite, created = Favorite.objects.get_or_create(
            user=request.user,
            product=product
        )
        
        if not created:
            favorite.delete()
            return Response({'status': 'removed', 'is_favorite': False})
        
        return Response({'status': 'added', 'is_favorite': True})


class TrendAlertViewSet(viewsets.ModelViewSet):
    serializer_class = TrendAlertSerializer
    permission_classes = [IsAuthenticated]
    
    def get_queryset(self):
        return TrendAlert.objects.filter(user=self.request.user)
    
    @action(detail=False, methods=['get'])
    def unread(self, request):
        """Get unread alerts"""
        alerts = self.get_queryset().filter(is_read=False)
        serializer = self.get_serializer(alerts, many=True)
        return Response(serializer.data)
    
    @action(detail=True, methods=['post'])
    def mark_read(self, request, pk=None):
        """Mark alert as read"""
        alert = self.get_object()
        alert.is_read = True
        alert.save()
        return Response({'status': 'marked_read'})


@api_view(['POST'])
@permission_classes([AllowAny])
def register(request):
    """Register new user"""
    serializer = RegisterSerializer(data=request.data)
    if serializer.is_valid():
        user = serializer.save()
        
        # Generate tokens
        refresh = RefreshToken.for_user(user)
        
        return Response({
            'user': UserSerializer(user).data,
            'token': str(refresh.access_token),
            'refresh': str(refresh),
        }, status=status.HTTP_201_CREATED)
    
    return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)


@api_view(['POST'])
@permission_classes([AllowAny])
def login(request):
    """Login user"""
    username = request.data.get('username') or request.data.get('email')
    password = request.data.get('password')
    
    if not username or not password:
        return Response(
            {'error': 'Username/email and password required'},
            status=status.HTTP_400_BAD_REQUEST
        )
    
    # Try to authenticate with username or email
    user = authenticate(username=username, password=password)
    
    if not user:
        # Try with email
        try:
            user_obj = User.objects.get(email=username)
            user = authenticate(username=user_obj.username, password=password)
        except User.DoesNotExist:
            pass
    
    if user:
        refresh = RefreshToken.for_user(user)
        
        # Get or create profile
        profile, created = UserProfile.objects.get_or_create(user=user)
        
        return Response({
            'user': UserSerializer(user).data,
            'profile': UserProfileSerializer(profile).data,
            'token': str(refresh.access_token),
            'refresh': str(refresh),
        })
    
    return Response(
        {'error': 'Invalid credentials'},
        status=status.HTTP_401_UNAUTHORIZED
    )


@api_view(['GET'])
@permission_classes([IsAuthenticated])
def dashboard_stats(request):
    """Get dashboard statistics"""
    user = request.user
    
    favorites_count = Favorite.objects.filter(user=user).count()
    views_count = ProductView.objects.filter(user=user).count()
    
    # Get user's profitability score
    profile, created = UserProfile.objects.get_or_create(user=user)
    
    # Get trending products count
    trending_count = Product.objects.filter(is_trending=True).count()
    
    # Recent favorites
    recent_favorites = Favorite.objects.filter(user=user).select_related('product')[:5]
    
    return Response({
        'favorites_count': favorites_count,
        'views_count': views_count,
        'profitability_score': profile.profitability_score,
        'trending_count': trending_count,
        'subscription_plan': profile.subscription_plan,
        'recent_favorites': FavoriteSerializer(recent_favorites, many=True).data,
    })
@api_view(['POST'])
@permission_classes([IsAuthenticated])
def import_products(request):
    """Import products from external sources temporarily using dummy data"""
    
    sample_products = [
        {
            "name": "Smart Watch Pro",
            "price": 15.99,
            "source": "AliExpress",
            "image_url": "https://example.com/watch.jpg",
            "category": "electronics"
        },
        {
            "name": "Wireless Earbuds",
            "price": 9.50,
            "source": "AliExpress",
            "image_url": "https://example.com/earbuds.jpg",
            "category": "audio"
        }
    ]

    created_count = 0

    for p in sample_products:
        Product.objects.create(
            name=p["name"],
            price=p["price"],
            image_url=p["image_url"],
            category=p["category"],
            source=p["source"],
            score=0  # sera calculé plus tard
        )
        created_count += 1

    return Response({"message": "Products imported", "imported": created_count})

