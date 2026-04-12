from django.db import models
from django.conf import settings

class SubscriptionPlan(models.Model):
    name = models.CharField(max_length=100, verbose_name="Nom du forfait (ex: Pro)")
    description = models.TextField(verbose_name="Description des avantages")
    price = models.DecimalField(max_digits=10, decimal_places=2, verbose_name="Prix (MAD ou EUR)")
    duration_days = models.IntegerField(default=30, verbose_name="Durée en jours")
    is_active = models.BooleanField(default=True, verbose_name="Forfait disponible ?")

    def __str__(self):
        return f"{self.name} - {self.price}"

class UserSubscription(models.Model):
    user = models.OneToOneField(settings.AUTH_USER_MODEL, on_delete=models.CASCADE, related_name='subscription')
    plan = models.ForeignKey(SubscriptionPlan, on_delete=models.SET_NULL, null=True)
    start_date = models.DateTimeField(auto_now_add=True)
    end_date = models.DateTimeField()
    is_active = models.BooleanField(default=False)

    def __str__(self):
        return f"Abonnement de {self.user.email}"
    

class PaymentMethod(models.Model):
    user = models.ForeignKey(settings.AUTH_USER_MODEL, on_delete=models.CASCADE, related_name='payment_methods')
    # On ne stocke que la version masquée (ex: **** **** **** 4242) pour l'affichage
    card_number_masked = models.CharField(max_length=20, verbose_name="Numéro masqué")
    card_brand = models.CharField(max_length=50, blank=True, verbose_name="Marque (Visa, Mastercard...)")
    exp_month = models.IntegerField(verbose_name="Mois d'expiration")
    exp_year = models.IntegerField(verbose_name="Année d'expiration")
    
    # ID fourni par Stripe/CinetPay/etc. pour débiter la carte plus tard
    provider_token = models.CharField(max_length=255, blank=True, verbose_name="Token du prestataire")
    
    is_default = models.BooleanField(default=False, verbose_name="Carte par défaut")
    created_at = models.DateTimeField(auto_now_add=True)

    def __str__(self):
        return f"{self.card_brand} se terminant par {self.card_number_masked[-4:]} ({self.user.username})"