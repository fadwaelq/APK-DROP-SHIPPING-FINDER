from django.urls import include, path
from rest_framework_simplejwt.views import TokenObtainPairView, TokenRefreshView
from accounts.views.auth import RegisterView, VerifyOTPView
from accounts.views.google import GoogleLoginView
from accounts.views.profile import UserProfileView

urlpatterns = [
    # Workflow d'inscription
    path('register/', RegisterView.as_view(), name='register'),
    path('verify-otp/', VerifyOTPView.as_view(), name='verify-otp'),
    
    # Workflow de connexion standard (Connexion JWT fournie par Django)
    path('login/', TokenObtainPairView.as_view(), name='login'),
    path('token/refresh/', TokenRefreshView.as_view(), name='token_refresh'),

    # Endpoint pour le profil utilisateur (Récupération et mise à jour)
    path('profile/', UserProfileView.as_view(), name='user-profile'),

    # La route pour Fadwa et son google_auth_service.dart
    path('google-login/', GoogleLoginView.as_view(), name='google-login'),
]