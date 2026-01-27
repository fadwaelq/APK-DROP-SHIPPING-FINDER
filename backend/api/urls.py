from django.urls import path, include
from rest_framework.routers import DefaultRouter
from rest_framework_simplejwt.views import TokenRefreshView

from .views import (
    UserViewSet, 
    UserProfileViewSet, 
    ProductViewSet,
    FavoriteViewSet, 
    TrendAlertViewSet,
    register, 
    login, 
    dashboard_stats,
    import_products,
    verify_email_otp,
    resend_otp_code
)

# ------------------- Router ---------------------
router = DefaultRouter()
router.register(r'users', UserViewSet, basename='user')
router.register(r'profiles', UserProfileViewSet, basename='profile')
router.register(r'products', ProductViewSet, basename='product')
router.register(r'favorites', FavoriteViewSet, basename='favorite')
router.register(r'alerts', TrendAlertViewSet, basename='alert')

# ------------------- URLs -----------------------
urlpatterns = [
    # Auth - Simplified Flow
    path('auth/register/', register, name='register'),  # Step 1: Register + OTP sent
    path('auth/login/', login, name='login'),
    path('auth/token/refresh/', TokenRefreshView.as_view(), name='token_refresh'),
    
    # Email Verification
    path('auth/verify-otp/', verify_email_otp, name='verify_otp'),  # Step 2: Verify OTP + Activate
    path('auth/resend-otp/', resend_otp_code, name='resend_otp'),   # Resend if needed
    
    # Dashboard
    path('dashboard/stats/', dashboard_stats, name='dashboard_stats'),

    # Product Import
    path('products/import/', import_products, name='import_products'),

    # Router (toutes les routes REST par ViewSet)
    path('', include(router.urls)),
]
