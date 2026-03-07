"""
Subscription Serializers
"""
from rest_framework import serializers


class SubscriptionTierSerializer(serializers.Serializer):
    """Serializer for subscription tier data"""
    tier_id = serializers.CharField()
    name = serializers.CharField()
    description = serializers.CharField()
    price = serializers.FloatField()
    features = serializers.ListField(child=serializers.CharField())
    limits = serializers.DictField()
    pricing = serializers.DictField()


class SubscriptionFeaturesSerializer(serializers.Serializer):
    """Serializer for subscription features and limits"""
    tier = serializers.CharField()
    features = serializers.ListField(child=serializers.CharField())
    limits = serializers.DictField()


class PaywallSerializer(serializers.Serializer):
    """Serializer for paywall data"""
    show_paywall = serializers.BooleanField()
    current_tier = serializers.CharField(required=False)
    requested_feature = serializers.CharField(required=False)
    required_tier = serializers.CharField(required=False)
    upgrade_options = serializers.ListField(required=False)
    message = serializers.CharField(required=False)


class UpgradePathSerializer(serializers.Serializer):
    """Serializer for upgrade path options"""
    tier_id = serializers.CharField()
    name = serializers.CharField()
    price = serializers.FloatField()
    pricing = serializers.DictField()
    features_added = serializers.ListField()


class SubscriptionComparisonSerializer(serializers.Serializer):
    """Serializer for tier comparison"""
    features = serializers.ListField(child=serializers.CharField())
    tiers = serializers.DictField()


class FeatureAccessCheckSerializer(serializers.Serializer):
    """Serializer for feature access check response"""
    access = serializers.BooleanField()
    tier = serializers.CharField(required=False)
    feature = serializers.CharField(required=False)
    paywall = PaywallSerializer(required=False)
