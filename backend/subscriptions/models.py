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