from rest_framework import serializers
from django.contrib.auth import get_user_model

User = get_user_model()

class RegisterSerializer(serializers.ModelSerializer):
    class Meta:
        model = User
        fields = ['email', 'username', 'password']
        # On s'assure que le mot de passe est masqué et jamais renvoyé
        extra_kwargs = {'password': {'write_only': True}}

    def create(self, validated_data):
        # Utilisation de create_user pour hacher le mot de passe de façon sécurisée
        user = User.objects.create_user(**validated_data)
        return user

# Serializer pour la vérification du code OTP lors de l'inscription ou de la réinitialisation du mot de passe
class VerifyOTPSerializer(serializers.Serializer):
    email = serializers.EmailField()
    otp_code = serializers.CharField(max_length=6)

# Serializer pour la connexion avec Google (Frontend Flutter)
class ChangePasswordSerializer(serializers.Serializer):
    old_password = serializers.CharField(required=True)
    new_password = serializers.CharField(required=True)

class ForgotPasswordSerializer(serializers.Serializer):
    email = serializers.EmailField(required=True)

# Serializer pour la confirmation de la réinitialisation du mot de passe avec OTP
class ResetPasswordConfirmSerializer(serializers.Serializer):
    email = serializers.EmailField(required=True)
    otp_code = serializers.CharField(max_length=6, required=True)
    new_password = serializers.CharField(required=True, write_only=True)
    
# Serializer pour la déconnexion (Logout) qui nécessite le Refresh Token pour invalider la session
class LogoutSerializer(serializers.Serializer):
    refresh = serializers.CharField(required=True, help_text="Le Refresh Token de l'utilisateur")