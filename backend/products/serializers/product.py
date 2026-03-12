from rest_framework import serializers
from products.models import Product

class ProductSerializer(serializers.ModelSerializer):
    """
    Sérialiseur pour formater les produits en JSON.
    Adapté au MVP pour le marché marocain (MAD).
    """
    class Meta:
        model = Product
        fields = [
            'id', 
            'title', 
            'description', 
            'category',             # Ajout pour les filtres
            'competition_level',    # Ajout pour les filtres
            'price', 
            'aliexpress_url', 
            'image_url', 
            'video_url',            # Ajout pour l'analyse des pubs
            'suggested_sale_price', 
            'potential_profit', 
            'trend_score', 
            'is_winner', 
            'ai_analysis_summary',
            'created_at'
        ]