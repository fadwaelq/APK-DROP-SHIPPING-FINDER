from rest_framework import serializers
from .models import RewardProfile

class RewardProfileSerializer(serializers.ModelSerializer):
    class Meta:
        model = RewardProfile
        fields = ['referral_code', 'points']

#  Serializer pour appliquer un code de parrainage
class ApplyCodeSerializer(serializers.Serializer):
    code = serializers.CharField(
        max_length=20, 
        help_text="Le code de parrainage de votre ami (ex: USE-7EA71)"
    )