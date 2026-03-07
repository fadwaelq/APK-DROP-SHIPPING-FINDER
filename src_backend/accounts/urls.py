from django.urls import path
from .views import (
    ForgotPasswordView, 
    RegisterView, 
    UserProfileView, 
    VerifyOTPView, 
    LoginView,
    ResendOTPView,       
    ResetPasswordView    
)

urlpatterns = [
    # Inscription
    path('register/', RegisterView.as_view(), name='register'),
    
    # Vérification du code OTP
    path('verify-otp/', VerifyOTPView.as_view(), name='verify-otp'),

    # Renvoi du code OTP
    path('resend-otp/', ResendOTPView.as_view(), name='resend-otp'), 
    
    # Connexion
    path('login/', LoginView.as_view(), name='login'),

    # Profil utilisateur
    path('profile/', UserProfileView.as_view(), name='user-profile'),

    # Demande de réinitialisation du mot de passe
    path('forgot-password/', ForgotPasswordView.as_view(), name='forgot-password'),

    # Création du nouveau mot de passe
    path('reset-password/', ResetPasswordView.as_view(), name='reset-password'), 
]