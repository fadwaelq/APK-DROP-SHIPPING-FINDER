from rest_framework import serializers
from django.contrib.auth import get_user_model

User = get_user_model()

class UserProfileSerializer(serializers.ModelSerializer):
    class Meta:
        model = User
        # Les champs que le frontend de Fadwa pourra lire et modifier
        fields = ['id', 'email', 'username', 'first_name', 'last_name', 'is_email_verified']
        # L'utilisateur ne peut pas modifier son email ou son statut de vérification lui-même
        read_only_fields = ['id', 'email', 'is_email_verified']