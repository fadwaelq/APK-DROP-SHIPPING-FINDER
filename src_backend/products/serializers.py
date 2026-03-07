
from rest_framework import serializers
from .models import Product

class ProductSerializer(serializers.ModelSerializer):
    class Meta:
        model = Product
        # Remplace 'name' par 'title' et ajoute les nouveaux champs IA
        fields = [
            'id', 
            'title',             # <-- Corrigé (au lieu de 'name')
            'description', 
            'price', 
            'aliexpress_url', 
            'image_url', 
            'suggested_sale_price', 
            'potential_profit', 
            'trend_score', 
            'is_winner', 
            'ai_analysis_summary',
            'created_at'
        ]