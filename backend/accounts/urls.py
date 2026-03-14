from django.urls import path
from rest_framework_simplejwt.views import TokenObtainPairView, TokenRefreshView

# On importe bien les CLASSES (avec des Majuscules) et non plus les minuscules
from accounts.views.auth import (
    RegisterView, 
    VerifyOTPView, 
    ForgotPasswordView, 
    ResetPasswordConfirmView, 
    ChangePasswordView,
    LogoutView          
)
from accounts.views.google import GoogleLoginView
from accounts.views.profile import UserBadgesView, UserProfileView

urlpatterns = [
    # Workflow d'inscription
    path('register/', RegisterView.as_view(), name='register'),
    path('verify-otp/', VerifyOTPView.as_view(), name='verify-otp'),
    
    # Workflow de connexion standard
    path('login/', TokenObtainPairView.as_view(), name='login'),
    path('token/refresh/', TokenRefreshView.as_view(), name='token_refresh'),
    path('logout/', LogoutView.as_view(), name='logout'), # <-- Modifié ici avec .as_view()

    # Workflow de récupération et modification de mot de passe
    path('password-reset/', ForgotPasswordView.as_view(), name='password-reset'),
    path('password-reset-confirm/', ResetPasswordConfirmView.as_view(), name='password-reset-confirm'),
    path('change-password/', ChangePasswordView.as_view(), name='change-password'), # <-- Modifié ici avec .as_view()

    # Endpoint pour le profil utilisateur
    path('profile/', UserProfileView.as_view(), name='user-profile'),
    path('badges/', UserBadgesView.as_view(), name='user-badges'), # <-- NOUVELLE ROUTE

    # La route pour l'authentification Google
    path('google-login/', GoogleLoginView.as_view(), name='google-login'),
]