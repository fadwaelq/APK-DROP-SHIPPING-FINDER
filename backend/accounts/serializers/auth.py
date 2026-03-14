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

class VerifyOTPSerializer(serializers.Serializer):
    email = serializers.EmailField()
    otp_code = serializers.CharField(max_length=6)

from rest_framework import serializers

class ChangePasswordSerializer(serializers.Serializer):
    old_password = serializers.CharField(required=True)
    new_password = serializers.CharField(required=True)