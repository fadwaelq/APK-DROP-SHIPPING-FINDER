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
    SearchHistory, TrendAlert, ScrapingJob, EmailOTP
)
from .serializers import (
    UserSerializer, UserProfileSerializer, ProductSerializer,
    ProductListSerializer, FavoriteSerializer, ProductViewSerializer,
    SearchHistorySerializer, TrendAlertSerializer, RegisterSerializer,
    PasswordChangeSerializer, ProductAnalysisSerializer, EmailOTPSerializer,
    OTPVerificationSerializer, OTPResendSerializer, RegisterWithOTPSerializer,
    GoogleAuthSerializer, GoogleLoginSerializer
)
# Email OTP service
from core.email_service import (
    create_otp_for_email, verify_otp, resend_otp
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

        try:
            # Gère les prix invalides avec fallback
            try:
                price = float(data.get("price", 0))
                if price == 0:
                    price = None
            except (ValueError, TypeError):
                price = None
            
            # Si le prix n'a pas pu être récupéré, utilise une estimation par défaut
            if price is None or price == 0:
                # Estimation par catégorie (valeurs par défaut pour MVP)
                category_defaults = {
                    "tech": 25.0,
                    "electronics": 30.0,
                    "clothing": 15.0,
                    "home": 20.0,
                    "beauty": 12.0,
                }
                price = category_defaults.get(data.get("category", "tech").lower(), 20.0)
                price_source = "estimated"
            else:
                price_source = "scraped"
            
            # Calcule le profit (prix de vente - coût)
            cost = float(data.get("cost", price * 0.3)) if price > 0 else 0
            profit = price - cost

            product = Product.objects.create(
                name=data["title"],
                description=data.get("description", "Imported from AliExpress"),
                price=price,
                cost=cost,
                profit=profit,
                source="aliexpress",
                source_url=url,
                source_id=data.get("source_id", url.split('/')[-1]),
                category=data.get("category", "tech"),
                image_url=data.get("image", data.get("images", [])[0] if data.get("images") else ""),
                images=data.get("images", []),
                supplier_name=data.get("supplier", "Unknown"),
                supplier_rating=float(data.get("rating", 0)),
                supplier_review_count=int(data.get("review_count", 0)),
                trend_percentage=float(data.get("trend_percentage", 0)),
                score=0,
            )

            response_data = ProductSerializer(product).data
            if price_source == "estimated":
                response_data["warning"] = f"Price was estimated (${price:.2f}) as it couldn't be scraped. Please verify on AliExpress."
            
            return Response(response_data, status=201)
        except Exception as e:
            return Response({"error": str(e)}, status=400)



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
    """Register new user - OTP automatically sent to email"""
    serializer = RegisterSerializer(data=request.data)
    if serializer.is_valid():
        # Create user but inactive until email verification
        user = serializer.save()
        user.is_active = False  # Inactive until verified
        user.save()
        
        # Create OTP and send to email
        email = user.email
        otp = create_otp_for_email(email, user=user)
        
        # Get fullname from first_name and last_name
        fullname = f"{user.first_name} {user.last_name}".strip()
        
        return Response({
            'message': 'Registration successful! OTP sent to your email. Please verify your account.',
            'user': {
                'id': user.id,
                'email': user.email,
                'fullname': fullname,
            },
            'email': email,
            'otp_expires_in': '10 minutes',
            'next_step': 'Verify your email with the OTP code sent to your email address'
        }, status=status.HTTP_201_CREATED)
    
    return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)


@api_view(['POST'])
@permission_classes([AllowAny])
def login(request):
    """Login user with email and password"""
    email = request.data.get('email')
    password = request.data.get('password')
    
    if not email or not password:
        return Response(
            {'error': 'Email and password are required'},
            status=status.HTTP_400_BAD_REQUEST
        )
    
    # Authenticate with email
    try:
        user_obj = User.objects.get(email=email)
        user = authenticate(username=user_obj.username, password=password)
    except User.DoesNotExist:
        user = None
    
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
        {'error': 'Invalid email or password'},
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
    """Import product from AliExpress URL"""
    
    url = request.data.get('url')
    
    if not url:
        return Response(
            {'error': 'url is required'},
            status=status.HTTP_400_BAD_REQUEST
        )
    
    try:
        # Scrape les données AliExpress
        data = import_product_from_aliexpress(url)
        
        if not data:
            return Response(
                {'error': 'Scraping failed or structure changed'}, 
                status=400
            )
        
        # Gère les prix invalides avec fallback
        try:
            price = float(data.get("price", 0))
            if price == 0:
                price = None
        except (ValueError, TypeError):
            price = None
        
        # Si le prix n'a pas pu être récupéré, utilise une estimation par défaut
        if price is None or price == 0:
            # Estimation par catégorie (valeurs par défaut pour MVP)
            category_defaults = {
                "tech": 25.0,
                "electronics": 30.0,
                "clothing": 15.0,
                "home": 20.0,
                "beauty": 12.0,
            }
            price = category_defaults.get(data.get("category", "tech").lower(), 20.0)
            price_source = "estimated"
        else:
            price_source = "scraped"
        
        # Calcule le profit (prix de vente - coût)
        cost = float(data.get("cost", price * 0.3)) if price > 0 else 0
        profit = price - cost
        
        # Crée le produit en base de données
        product = Product.objects.create(
            name=data["title"],
            description=data.get("description", "Imported from AliExpress"),
            price=price,
            cost=cost,
            profit=profit,
            source="aliexpress",
            source_url=url,
            source_id=data.get("source_id", url.split('/')[-1]),
            category=data.get("category", "tech"),
            image_url=data.get("image", data.get("images", [])[0] if data.get("images") else ""),
            images=data.get("images", []),
            supplier_name=data.get("supplier", "Unknown"),
            supplier_rating=float(data.get("rating", 0)),
            supplier_review_count=int(data.get("review_count", 0)),
            trend_percentage=float(data.get("trend_percentage", 0)),
            score=0,
        )
        
        response_data = ProductSerializer(product).data
        if price_source == "estimated":
            response_data["warning"] = f"Price was estimated (${price:.2f}) as it couldn't be scraped. Please verify on AliExpress."
        
        return Response(response_data, status=status.HTTP_201_CREATED)
        
    except Exception as e:
        return Response({'error': str(e)}, status=400)



# ========== EMAIL OTP VERIFICATION ENDPOINTS ==========

@api_view(['POST'])
@permission_classes([AllowAny])
def verify_email_otp(request):
    """Verify OTP code and activate account"""
    serializer = OTPVerificationSerializer(data=request.data)
    if serializer.is_valid():
        email = serializer.validated_data['email']
        otp_code = serializer.validated_data['otp_code']
        
        result = verify_otp(email, otp_code)
        
        if result['success']:
            try:
                # Get user and activate account
                user = User.objects.get(email=email)
                user.is_active = True
                user.save()
                
                # Create user profile
                UserProfile.objects.get_or_create(user=user)
                
                # Generate JWT tokens
                refresh = RefreshToken.for_user(user)
                
                return Response({
                    'message': 'Email verified successfully! Your account is now active.',
                    'email': email,
                    'verified': True,
                    'user': UserSerializer(user).data,
                    'token': str(refresh.access_token),
                    'refresh': str(refresh),
                }, status=status.HTTP_200_OK)
            except User.DoesNotExist:
                return Response(
                    {'error': 'User not found'},
                    status=status.HTTP_404_NOT_FOUND
                )
        else:
            return Response(
                {'error': result['error']},
                status=status.HTTP_400_BAD_REQUEST
            )
    
    return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)


@api_view(['POST'])
@permission_classes([AllowAny])
def resend_otp_code(request):
    """Resend OTP code to email"""
    serializer = OTPResendSerializer(data=request.data)
    if serializer.is_valid():
        email = serializer.validated_data['email']
        
        result = resend_otp(email)
        
        if result['success']:
            return Response({
                'message': result['message'],
                'email': email,
                'expires_in': '10 minutes'
            }, status=status.HTTP_200_OK)
        else:
            return Response(
                {'error': result['error']},
                status=status.HTTP_400_BAD_REQUEST
            )
    
    return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)


# ========== GOOGLE OAUTH ENDPOINTS ==========

@api_view(['POST'])
@permission_classes([AllowAny])
def google_auth(request):
    """
    Google OAuth authentication endpoint
    Verifies Google token and creates/returns user with JWT tokens
    """
    serializer = GoogleAuthSerializer(data=request.data)
    if not serializer.is_valid():
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)
    
    try:
        access_token = serializer.validated_data['access_token']
        
        # Verify token with Google using access token info endpoint
        import requests as req
        response = req.get(
            'https://www.googleapis.com/oauth2/v2/userinfo',
            headers={'Authorization': f'Bearer {access_token}'},
            timeout=5
        )
        
        if response.status_code != 200:
            return Response(
                {'error': 'Invalid Google token'},
                status=status.HTTP_401_UNAUTHORIZED
            )
        
        user_data = response.json()
        email = user_data.get('email')
        name = user_data.get('name', '')
        picture = user_data.get('picture', '')
        
        if not email:
            return Response(
                {'error': 'Email not provided by Google'},
                status=status.HTTP_400_BAD_REQUEST
            )
        
        # Get or create user
        user, created = User.objects.get_or_create(
            email=email,
            defaults={
                'username': email.split('@')[0],
                'is_active': True,
            }
        )
        
        # Update user info from Google
        if created or not user.first_name:
            name_parts = name.strip().split(' ', 1)
            user.first_name = name_parts[0]
            user.last_name = name_parts[1] if len(name_parts) > 1 else ''
            user.save()
        
        # Create/get user profile
        profile, _ = UserProfile.objects.get_or_create(user=user)
        
        # Generate JWT tokens
        refresh = RefreshToken.for_user(user)
        
        return Response({
            'message': 'Google authentication successful!',
            'user': UserSerializer(user).data,
            'profile': UserProfileSerializer(profile).data,
            'token': str(refresh.access_token),
            'refresh': str(refresh),
        }, status=status.HTTP_200_OK)
        
    except Exception as e:
        return Response(
            {'error': f'Authentication failed: {str(e)}'},
            status=status.HTTP_401_UNAUTHORIZED
        )


@api_view(['POST'])
@permission_classes([AllowAny])
def google_login(request):
    """
    Google ID token verification endpoint
    Use this if you have id_token from Google Sign-In
    """
    id_token_str = request.data.get('id_token')
    
    if not id_token_str:
        return Response(
            {'error': 'id_token is required'},
            status=status.HTTP_400_BAD_REQUEST
        )
    
    try:
        from google.oauth2 import id_token
        from google.auth.transport import requests as google_requests
        import os
        
        client_id = os.getenv('GOOGLE_CLIENT_ID')
        if not client_id:
            return Response(
                {'error': 'Google Client ID not configured'},
                status=status.HTTP_500_INTERNAL_SERVER_ERROR
            )
        
        # Verify ID token with Google
        idinfo = id_token.verify_oauth2_token(
            id_token_str,
            google_requests.Request(),
            client_id
        )
        
        # Extract user info
        email = idinfo.get('email')
        name = idinfo.get('name', '')
        picture = idinfo.get('picture', '')
        
        if not email:
            return Response(
                {'error': 'Email not provided in token'},
                status=status.HTTP_400_BAD_REQUEST
            )
        
        # Get or create user
        user, created = User.objects.get_or_create(
            email=email,
            defaults={
                'username': email.split('@')[0],
                'is_active': True,
            }
        )
        
        # Update user name if not set
        if created or not user.first_name:
            name_parts = name.strip().split(' ', 1)
            user.first_name = name_parts[0]
            user.last_name = name_parts[1] if len(name_parts) > 1 else ''
            user.save()
        
        # Create/get user profile
        profile, _ = UserProfile.objects.get_or_create(user=user)
        
        # Generate JWT tokens
        refresh = RefreshToken.for_user(user)
        
        return Response({
            'message': 'Google login successful!',
            'user': UserSerializer(user).data,
            'profile': UserProfileSerializer(profile).data,
            'token': str(refresh.access_token),
            'refresh': str(refresh),
        }, status=status.HTTP_200_OK)
        
    except ValueError as e:
        return Response(
            {'error': 'Invalid ID token'},
            status=status.HTTP_401_UNAUTHORIZED
        )
    except Exception as e:
        return Response(
            {'error': f'Login failed: {str(e)}'},
            status=status.HTTP_401_UNAUTHORIZED
        )



