from django.contrib.auth.models import AbstractUser
from django.db import models
import random

class Badge(models.Model):
    """Modèle pour les badges utilisateurs (ex: Débutant, Top Vendeur, etc.)"""
    name = models.CharField(max_length=50, unique=True, verbose_name="Nom du badge")
    description = models.TextField(blank=True, verbose_name="Description")
    # On utilise un URLField pour l'icône
    icon_url = models.URLField(blank=True, null=True, verbose_name="URL de l'icône")

    def __str__(self):
        return self.name

class CustomUser(AbstractUser):
    # On remplace le champ email pour le rendre unique et obligatoire
    email = models.EmailField(unique=True, verbose_name="Adresse Email")
    is_email_verified = models.BooleanField(default=False, verbose_name="Email vérifié ?")
    otp_code = models.CharField(max_length=6, blank=True, null=True, verbose_name="Code de vérification")

    # Relation ManyToMany pour les badges, un utilisateur peut en avoir plusieurs et un badge peut être attribué à plusieurs utilisateurs
    badges = models.ManyToManyField(Badge, blank=True, related_name="users", verbose_name="Badges de l'utilisateur")

    # avatar_url pour stocker l'URL de l'image de profil de l'utilisateur
    avatar_url = models.URLField(max_length=500, blank=True, null=True, verbose_name="URL Avatar 3D")
    
    # On force la connexion avec l'email au lieu du nom d'utilisateur
    USERNAME_FIELD = 'email'
    REQUIRED_FIELDS = ['username']

    def generate_otp(self):
        """Génère un code à 6 chiffres pour la vérification"""
        self.otp_code = str(random.randint(100000, 999999))
        self.save()
        return self.otp_code

    def __str__(self):
        return self.email