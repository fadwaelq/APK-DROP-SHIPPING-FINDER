from rest_framework import serializers
from products.models import AdCampaign

class AdCampaignSerializer(serializers.ModelSerializer):
    class Meta:
        model = AdCampaign
        fields = '__all__'