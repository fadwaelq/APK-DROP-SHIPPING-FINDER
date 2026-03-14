# subscriptions/serializers.py
from rest_framework import serializers
from .models import SubscriptionPlan

class SubscriptionPlanSerializer(serializers.ModelSerializer):
    class Meta:
        model = SubscriptionPlan
        fields = ['id', 'name', 'description', 'price', 'duration_days']

# AJOUTE CECI : C'est ce qui va débloquer Swagger
class PaymentInputSerializer(serializers.Serializer):
    plan_id = serializers.IntegerField(help_text="ID du forfait (ex: 1)")
    transaction_id = serializers.CharField(required=False, allow_blank=True, help_text="ID de transaction fourni par la banque")