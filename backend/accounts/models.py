from django.contrib.auth.models import AbstractUser
from django.db import models
import random

class CustomUser(AbstractUser):
    """Utilisateur personnalisé pour le SaaS Dropshipping"""
    email = models.EmailField(unique=True, verbose_name="Adresse Email")
    is_email_verified = models.BooleanField(default=False, verbose_name="Email vérifié ?")
    otp_code = models.CharField(max_length=6, blank=True, null=True, verbose_name="Code de vérification")

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