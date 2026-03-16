from rest_framework import serializers
from products.models import Product, ProductWatchlist, ProductHistory

class ProductSerializer(serializers.ModelSerializer):
    is_saved = serializers.SerializerMethodField()

    class Meta:
        model = Product
        fields = [
            'id', 'title', 'description', 'category', 'competition_level', 
            'price', 'aliexpress_url', 'image_url', 'video_url', 
            'suggested_sale_price', 'potential_profit', 'trend_score', 
            'is_winner', 'ai_analysis_summary', 'created_at', 'is_saved'
        ]

    def get_is_saved(self, obj):
        user = self.context.get('request').user
        if user and user.is_authenticated:
            return ProductWatchlist.objects.filter(user=user, product=obj).exists()
        return False

class ProductHistorySerializer(serializers.ModelSerializer):
    # On récupère les détails du produit à l'intérieur de l'historique
    product = ProductSerializer(read_only=True)
    
    class Meta:
        model = ProductHistory
        fields = ['id', 'product', 'viewed_at']