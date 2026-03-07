from rest_framework import serializers
from django.contrib.auth import get_user_model
import random

# --- NOUVEAUX IMPORTS POUR L'EMAIL ---
from django.core.mail import send_mail
from django.conf import settings

User = get_user_model()

# Traducteur pour l'inscription
class RegisterSerializer(serializers.ModelSerializer):
    password = serializers.CharField(write_only=True)

    class Meta:
        model = User
        fields = ('full_name', 'email', 'password')

    def create(self, validated_data):
        user = User.objects.create_user(
            email=validated_data['email'],
            full_name=validated_data['full_name'],
            password=validated_data['password']
        )
        user.otp_code = str(random.randint(100000, 999999))
        user.save()
        
        # --- ENVOI DU VRAI EMAIL ---
        try:
            send_mail(
                subject="Bienvenue ! Ton code de vérification",
                message=f"Bonjour {user.full_name},\n\nVoici ton code OTP pour valider ton compte : {user.otp_code}\n\nÀ très vite sur l'application !",
                from_email=settings.EMAIL_HOST_USER,
                recipient_list=[user.email],
                fail_silently=False,
            )
            print(f"Vrai email envoyé avec succès à {user.email}")
        except Exception as e:
            print(f"Erreur lors de l'envoi de l'email : {e}")
        # ---------------------------

        return user

# Traducteur pour vérifier l'OTP
class VerifyOTPSerializer(serializers.Serializer):
    email = serializers.EmailField()
    otp_code = serializers.CharField(max_length=6)

# Traducteur pour la connexion
class LoginSerializer(serializers.Serializer):
    email = serializers.EmailField()
    password = serializers.CharField(write_only=True)

# Traducteur pour la demande de mot de passe oublié
class ForgotPasswordSerializer(serializers.Serializer):
    email = serializers.EmailField()

# Traducteur pour le renvoi du code OTP
class ResendOTPSerializer(serializers.Serializer):
    email = serializers.EmailField()

# Traducteur pour la création du nouveau mot de passe
class ResetPasswordSerializer(serializers.Serializer):
    email = serializers.EmailField()
    otp_code = serializers.CharField(max_length=6)
    new_password = serializers.CharField(write_only=True, min_length=8)