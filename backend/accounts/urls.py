from django.urls import path
from rest_framework_simplejwt.views import TokenObtainPairView, TokenRefreshView

# On importe les classes existantes + les nouvelles (Delete, LogoutAll, Sessions)
from accounts.views.auth import (
    RegisterView, 
    VerifyOTPView, 
    ForgotPasswordView, 
    ResetPasswordConfirmView, 
    ChangePasswordView,
    LogoutView          
)
from accounts.views.google import GoogleLoginView
from accounts.views.profile import (
    UpdateUserProfileV2View, 
    UserAvatarView, 
    UserBadgesView, 
    UserProfileView,
    DeleteAccountView,
    LogoutAllDevicesView,
    
)
from accounts.views.google import GoogleLoginView,ActiveSessionsView

urlpatterns = [
    # Workflow d'inscription & Connexion
    path('register/', RegisterView.as_view(), name='register'),
    path('verify-otp/', VerifyOTPView.as_view(), name='verify-otp'),
    path('login/', TokenObtainPairView.as_view(), name='login'),
    path('token/refresh/', TokenRefreshView.as_view(), name='token_refresh'),
    path('logout/', LogoutView.as_view(), name='logout'),
    path('google-login/', GoogleLoginView.as_view(), name='google-login'),

    # --- SÉCURITÉ & RGPD (CRITIQUE POUR GOOGLE/APPLE) ---
    path('delete-account/', DeleteAccountView.as_view(), name='delete-account'),
    path('logout-all/', LogoutAllDevicesView.as_view(), name='logout-all'),
    path('active-sessions/', ActiveSessionsView.as_view(), name='active-sessions'),

    # Workflow de mot de passe
    path('password-reset/', ForgotPasswordView.as_view(), name='password-reset'),
    path('password-reset-confirm/', ResetPasswordConfirmView.as_view(), name='password-reset-confirm'),
    path('change-password/', ChangePasswordView.as_view(), name='change-password'),

    # Endpoints Profil & Gamification
    path('profile/', UserProfileView.as_view(), name='user-profile'),
    path('profile/v2/update/', UpdateUserProfileV2View.as_view(), name='user-profile-v2'), 
    path('profile/v2/avatar/', UserAvatarView.as_view(), name='user-avatar'),
    path('badges/', UserBadgesView.as_view(), name='user-badges'), 
]