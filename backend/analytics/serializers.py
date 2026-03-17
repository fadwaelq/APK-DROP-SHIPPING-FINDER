from rest_framework import serializers
from .models import UserActivity 

class ROICalculatorSerializer(serializers.Serializer):
    selling_price = serializers.FloatField(help_text="Prix de vente final au Maroc (MAD)")
    product_cost = serializers.FloatField(help_text="Coût d'achat (MAD)")
    ads_cost_per_order = serializers.FloatField(help_text="CPA estimé (MAD)")
    shipping_cost = serializers.FloatField(default=35.0, help_text="Frais de livraison AMANA/Colis (MAD)")
    confirmation_rate = serializers.FloatField(default=0.8, help_text="Taux de confirmation (ex: 0.8 pour 80%)")
    delivery_rate = serializers.FloatField(default=0.7, help_text="Taux de livraison réelle (ex: 0.7 pour 70%)")

# --- LE NOUVEAU SERIALIZER POUR LE TABLEAU DE BORD ---
class UserActivitySerializer(serializers.ModelSerializer):
    # Formatage de la date pour que ce soit joli sur le frontend
    created_at_formatted = serializers.SerializerMethodField()

    class Meta:
        model = UserActivity
        fields = ['id', 'action', 'details', 'created_at', 'created_at_formatted']

    def get_created_at_formatted(self, obj):
        # Renvoie la date sous format "14/03/2026 14:30"
        return obj.created_at.strftime("%d/%m/%Y %H:%M")