from django.db import models
from django.contrib.auth import get_user_model

User = get_user_model()

class UserWallet(models.Model):
    user = models.OneToOneField(User, on_delete=models.CASCADE, related_name='wallet')
    balance = models.PositiveIntegerField(default=0, help_text="Solde actuel en Coins")
    last_update = models.DateTimeField(auto_now=True)

    def __str__(self):
        return f"Wallet de {self.user.username} - {self.balance} Coins"

class CoinTransaction(models.Model):
    TRANSACTION_TYPES = (
        ('EARN', 'Gain'),
        ('SPEND', 'Dépense'),
    )
    user = models.ForeignKey(User, on_delete=models.CASCADE, related_name='coin_transactions')
    transaction_type = models.CharField(max_length=10, choices=TRANSACTION_TYPES)
    amount = models.PositiveIntegerField()
    source = models.CharField(max_length=255, help_text="Ex: 'mission', 'achat_produit', 'referral'")
    description = models.TextField(blank=True, null=True)
    timestamp = models.DateTimeField(auto_now_add=True)

    class Meta:
        ordering = ['-timestamp']

    def __str__(self):
        return f"{self.transaction_type} {self.amount} Coins - {self.user.username}"
    
# POur stocker les produits disponibles à l'achat dans la boutique
class ShopItem(models.Model):
    name = models.CharField(max_length=100)
    description = models.TextField(blank=True)
    price = models.PositiveIntegerField(help_text="Prix en coins")
    image_url = models.URLField(blank=True, help_text="Lien de l'image (ex: icône ou avatar)")
    is_active = models.BooleanField(default=True)
    created_at = models.DateTimeField(auto_now_add=True)

    class Meta:
        ordering = ['price'] # Trie du moins cher au plus cher

    def __str__(self):
        return f"{self.name} - {self.price} Coins"

class UserInventory(models.Model):
    user = models.ForeignKey(User, on_delete=models.CASCADE, related_name='inventory')
    item = models.ForeignKey(ShopItem, on_delete=models.CASCADE)
    purchased_at = models.DateTimeField(auto_now_add=True)

    class Meta:
        # Un utilisateur ne peut acheter un article unique qu'une seule fois
        unique_together = ('user', 'item')

    def __str__(self):
        return f"{self.user.username} possède {self.item.name}"