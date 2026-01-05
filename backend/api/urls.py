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
    import_products       # ← IMPORTANT : ajouté ici
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
    # Auth
    path('auth/register/', register, name='register'),
    path('auth/login/', login, name='login'),
    path('auth/token/refresh/', TokenRefreshView.as_view(), name='token_refresh'),
    
    # Dashboard
    path('dashboard/stats/', dashboard_stats, name='dashboard_stats'),

    # 🔥 Nouvelle fonctionnalité (Ta tâche)
    path('products/import/', import_products, name='import_products'),

    # Router (toutes les routes REST par ViewSet)
    path('', include(router.urls)),
]
