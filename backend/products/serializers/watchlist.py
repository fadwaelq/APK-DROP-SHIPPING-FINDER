from rest_framework import serializers
from products.models import ProductWatchlist
from .product import ProductSerializer

class ProductWatchlistSerializer(serializers.ModelSerializer):
    # On inclut les détails du produit pour l'affichage dans le dashboard
    product_details = ProductSerializer(source='product', read_only=True)

    class Meta:
        model = ProductWatchlist
        fields = ['id', 'user', 'product', 'product_details', 'added_at']
        read_only_fields = ['user', 'added_at']