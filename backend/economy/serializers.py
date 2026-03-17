from rest_framework import serializers
from .models import UserWallet, CoinTransaction,ShopItem

class UserWalletSerializer(serializers.ModelSerializer):
    currency = serializers.SerializerMethodField()

    class Meta:
        model = UserWallet
        fields = ['balance', 'currency', 'last_update']

    def get_currency(self, obj):
        return 'MAD' # Pour Maroc, on peut aussi envisager de rendre cela dynamique en fonction de la localisation de l'utilisateur ou d'une configuration globale

class CoinTransactionSerializer(serializers.ModelSerializer):
    class Meta:
        model = CoinTransaction
        fields = ['id', 'timestamp', 'transaction_type', 'amount', 'source', 'description']

from rest_framework import serializers
from .models import UserWallet, CoinTransaction

class UserWalletSerializer(serializers.ModelSerializer):
    currency = serializers.SerializerMethodField()

    class Meta:
        model = UserWallet
        fields = ['balance', 'currency', 'last_update']

    def get_currency(self, obj):
        return 'MAD' 

class CoinTransactionSerializer(serializers.ModelSerializer):
    class Meta:
        model = CoinTransaction
        fields = ['id', 'timestamp', 'transaction_type', 'amount', 'source', 'description']

# ==========================================
# SERIALIZER POUR LE PAIEMENT
# ==========================================
class PaymentCheckoutSerializer(serializers.Serializer):
    PAYMENT_METHODS = (
        ('CARD', 'Carte Bancaire (Stripe)'),
        ('PAYPAL', 'PayPal'),
        ('GOOGLE_PLAY', 'Google Play In-App'),
    )
    
    payment_method = serializers.ChoiceField(choices=PAYMENT_METHODS)
    amount = serializers.DecimalField(max_digits=10, decimal_places=2, required=True)
    
    # Le token de paiement envoyé par le front (Stripe Token, PayPal Order ID, Google Purchase Token)
    payment_token = serializers.CharField(required=True, help_text="Token/ID de la transaction fourni par le front")
    
    # Optionnel: Ce que l'utilisateur achète (ex: id d'un pack de coins)
    item_id = serializers.CharField(required=False, allow_blank=True)


# Serializer pour les items de la boutique
class ShopItemSerializer(serializers.ModelSerializer):
    class Meta:
        model = ShopItem
        fields = ['id', 'name', 'description', 'price', 'image_url', 'is_active']
# Serializer pour les détails d'un item de la boutique
class ShopItemDetailSerializer(serializers.ModelSerializer):
    class Meta:
        model = ShopItem
        fields = ['id', 'name', 'description', 'price', 'image_url', 'is_active']

class BuyItemSerializer(serializers.Serializer):
    item_id = serializers.IntegerField(required=True, help_text="ID de l'article à acheter")
    # Optionnel: Quantité à acheter (si on veut gérer les achats en quantité)
    quantity = serializers.IntegerField(required=False, default=1, min_value=1, help_text="Quantité à acheter (par défaut 1)")