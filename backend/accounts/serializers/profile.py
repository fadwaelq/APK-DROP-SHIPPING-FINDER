from rest_framework import serializers
from django.contrib.auth import get_user_model
from accounts.models import Badge

User = get_user_model()

class UserProfileSerializer(serializers.ModelSerializer):
    class Meta:
        model = User
        # Les champs que le frontend de Fadwa pourra lire et modifier
        fields = ['id', 'email', 'avatar_url', 'username', 'first_name', 'last_name', 'is_email_verified']
        # L'utilisateur ne peut pas modifier son email ou son statut de vérification lui-même
        read_only_fields = ['id', 'email', 'is_email_verified']


# Serializer pour les badges, si on veut les afficher dans le profil utilisateur
class BadgeSerializer(serializers.ModelSerializer):
    class Meta:
        model = Badge
        fields = ['id', 'name', 'description', 'icon_url']