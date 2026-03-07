"""
Subscription & Tiers Management Service
Handles all subscription-related logic, features, and pricing
"""

from typing import Dict, List, Optional
from datetime import datetime, timedelta
from django.utils import timezone


# ============================================================================
# SUBSCRIPTION TIER DEFINITIONS
# ============================================================================

class SubscriptionTier:
    """Base class for subscription tiers"""
    
    def __init__(self, tier_id: str, name: str, description: str, price: float, 
                 features: List[str], limits: Dict[str, int]):
        self.tier_id = tier_id
        self.name = name
        self.description = description
        self.price = price
        self.features = features
        self.limits = limits
    
    def to_dict(self):
        return {
            'tier_id': self.tier_id,
            'name': self.name,
            'description': self.description,
            'price': self.price,
            'features': self.features,
            'limits': self.limits,
        }


# Subscription Tiers Configuration
SUBSCRIPTION_TIERS = {
    'free': SubscriptionTier(
        tier_id='free',
        name='Gratuit',
        description='Plan gratuit pour débuter',
        price=0,
        features=[
            '✓ Analyse de 5 produits par jour',
            '✓ Accès aux catégories de base',
            '✓ Score de rentabilité simple',
            '✓ Support communautaire',
        ],
        limits={
            'daily_analyses': 5,
            'products_per_month': 150,
            'categories': 3,
            'api_calls_per_month': 5000,
            'export_products': False,
            'trend_alerts': 3,
            'custom_pricing_rules': False,
            'api_access': False,
            'priority_support': False,
        }
    ),
    'starter': SubscriptionTier(
        tier_id='starter',
        name='Démarrage',
        description='Pour les petits entrepreneurs',
        price=9.99,
        features=[
            '✓ Analyse de 50 produits par jour',
            '✓ Toutes les catégories',
            '✓ Score de rentabilité avancé',
            '✓ Trends et alertes illimitées',
            '✓ Historique sur 3 mois',
            '✓ Support par email',
            '✓ Export CSV basique',
        ],
        limits={
            'daily_analyses': 50,
            'products_per_month': 1500,
            'categories': 99,
            'api_calls_per_month': 50000,
            'export_products': True,
            'trend_alerts': 99,
            'custom_pricing_rules': False,
            'api_access': False,
            'priority_support': False,
            'history_days': 90,
        }
    ),
    'pro': SubscriptionTier(
        tier_id='pro',
        name='Professionnel',
        description='Pour les dropshippeurs actifs',
        price=29.99,
        features=[
            '✓ Analyses illimitées',
            '✓ Toutes les catégories',
            '✓ Score IA avancé + prédictions',
            '✓ Analyse de concurrence détaillée',
            '✓ Alerts de trends personnalisés',
            '✓ Historique complet (illimité)',
            '✓ Export avancé (tous formats)',
            '✓ Intégration API',
            '✓ Support prioritaire',
            '✓ Règles de prix personnalisées',
        ],
        limits={
            'daily_analyses': 999999,
            'products_per_month': 999999,
            'categories': 99,
            'api_calls_per_month': 500000,
            'export_products': True,
            'trend_alerts': 999,
            'custom_pricing_rules': True,
            'api_access': True,
            'priority_support': True,
            'history_days': 36500,
        }
    ),
    'premium': SubscriptionTier(
        tier_id='premium',
        name='Premium',
        description='Pour les agences et équipes',
        price=99.99,
        features=[
            '✓ Tout du plan Pro',
            '✓ Analyses illimitées en temps réel',
            '✓ IA prédictive avancée',
            '✓ Dashboard d\'équipe (5 utilisateurs)',
            '✓ Webhooks et automations',
            '✓ Intégration Shopify/WooCommerce',
            '✓ Support 24/7 dédié',
            '✓ Rapports mensuels détaillés',
            '✓ Accès anticipé aux nouvelles features',
            '✓ SLA garanti 99.9%',
        ],
        limits={
            'daily_analyses': 999999,
            'products_per_month': 999999,
            'categories': 99,
            'api_calls_per_month': 2000000,
            'export_products': True,
            'trend_alerts': 9999,
            'custom_pricing_rules': True,
            'api_access': True,
            'priority_support': True,
            'history_days': 36500,
            'team_members': 5,
            'webhooks': True,
            'automations': True,
            'shopify_integration': True,
            'woocommerce_integration': True,
            'dedicated_support': True,
            'custom_reports': True,
            'early_access': True,
            'sla_guarantee': 0.999,
        }
    ),
}


# ============================================================================
# SUBSCRIPTION PRICING & BILLING
# ============================================================================

SUBSCRIPTION_PRICING = {
    'free': {
        'monthly': 0,
        'quarterly': 0,
        'annual': 0,
        'billing_cycle': 'never',
    },
    'starter': {
        'monthly': 9.99,
        'quarterly': 26.97,
        'annual': 99.90,
        'billing_cycle': 'monthly',
    },
    'pro': {
        'monthly': 29.99,
        'quarterly': 80.97,
        'annual': 299.90,
        'billing_cycle': 'monthly',
    },
    'premium': {
        'monthly': 99.99,
        'quarterly': 269.97,
        'annual': 999.90,
        'billing_cycle': 'monthly',
    },
}


# ============================================================================
# SUBSCRIPTION SERVICE
# ============================================================================

class SubscriptionService:
    """Main subscription management service"""
    
    @staticmethod
    def get_tier(tier_id: str) -> Optional[SubscriptionTier]:
        """Get subscription tier by ID"""
        return SUBSCRIPTION_TIERS.get(tier_id)
    
    @staticmethod
    def get_all_tiers() -> Dict[str, SubscriptionTier]:
        """Get all subscription tiers"""
        return SUBSCRIPTION_TIERS
    
    @staticmethod
    def get_available_tiers() -> List[Dict]:
        """Get all available tiers as dictionaries for API response"""
        return [
            {
                **tier.to_dict(),
                'pricing': SUBSCRIPTION_PRICING.get(tier_id, {})
            }
            for tier_id, tier in SUBSCRIPTION_TIERS.items()
        ]
    
    @staticmethod
    def compare_tiers() -> Dict:
        """Get tier comparison for display"""
        all_features = set()
        
        for tier in SUBSCRIPTION_TIERS.values():
            all_features.update(tier.features)
        
        comparison = {
            'features': sorted(list(all_features)),
            'tiers': {}
        }
        
        for tier_id, tier in SUBSCRIPTION_TIERS.items():
            comparison['tiers'][tier_id] = {
                'name': tier.name,
                'price': tier.price,
                'has_features': {
                    feature: feature in tier.features 
                    for feature in all_features
                }
            }
        
        return comparison
    
    @staticmethod
    def get_tier_features(tier_id: str) -> List[str]:
        """Get features for a specific tier"""
        tier = SUBSCRIPTION_TIERS.get(tier_id)
        return tier.features if tier else []
    
    @staticmethod
    def get_tier_limits(tier_id: str) -> Dict[str, int]:
        """Get limits for a specific tier"""
        tier = SUBSCRIPTION_TIERS.get(tier_id)
        return tier.limits if tier else {}
    
    @staticmethod
    def has_feature(tier_id: str, feature: str) -> bool:
        """Check if tier has a specific feature"""
        tier = SUBSCRIPTION_TIERS.get(tier_id)
        if not tier:
            return False
        return any(feature in f for f in tier.features)
    
    @staticmethod
    def can_use_feature(tier_id: str, feature_name: str) -> bool:
        """Check if tier can use a specific feature"""
        limits = SubscriptionService.get_tier_limits(tier_id)
        
        feature_map = {
            'analyses': 'daily_analyses',
            'export': 'export_products',
            'api': 'api_access',
            'custom_pricing': 'custom_pricing_rules',
            'alerts': 'trend_alerts',
            'priority_support': 'priority_support',
            'team': 'team_members',
            'webhooks': 'webhooks',
            'automations': 'automations',
        }
        
        limit_key = feature_map.get(feature_name)
        if not limit_key:
            return True
        
        limit = limits.get(limit_key)
        return limit not in [0, False]
    
    @staticmethod
    def get_subscription_validity_period(plan: str, months: int = 1) -> Dict:
        """Calculate subscription validity period"""
        now = timezone.now()
        days = {
            'monthly': 30,
            'quarterly': 90,
            'annual': 365,
        }
        
        if months == 1:
            valid_days = days.get('monthly', 30)
        elif months == 3:
            valid_days = days.get('quarterly', 90)
        elif months == 12:
            valid_days = days.get('annual', 365)
        else:
            valid_days = days.get('monthly', 30)
        
        expiry = now + timedelta(days=valid_days)
        
        return {
            'started_at': now,
            'expires_at': expiry,
            'days': valid_days,
        }
    
    @staticmethod
    def upgrade_path(current_tier: str) -> List[Dict]:
        """Get possible upgrade paths from current tier"""
        tier_hierarchy = ['free', 'starter', 'pro', 'premium']
        
        if current_tier not in tier_hierarchy:
            return []
        
        current_index = tier_hierarchy.index(current_tier)
        available_upgrades = []
        
        for i in range(current_index + 1, len(tier_hierarchy)):
            tier_id = tier_hierarchy[i]
            tier = SUBSCRIPTION_TIERS[tier_id]
            pricing = SUBSCRIPTION_PRICING[tier_id]
            
            available_upgrades.append({
                'tier_id': tier_id,
                'name': tier.name,
                'price': tier.price,
                'pricing': pricing,
                'features_added': tier.features,
            })
        
        return available_upgrades


# ============================================================================
# FEATURE RESTRICTIONS BY TIER
# ============================================================================

class FeatureRestrictions:
    """Manage feature access based on subscription tier"""
    
    FEATURE_REQUIREMENTS = {
        'unlimited_analyses': 'pro',
        'export_products': 'starter',
        'custom_pricing': 'pro',
        'api_access': 'pro',
        'priority_support': 'pro',
        'team_features': 'premium',
        'webhooks': 'premium',
        'automations': 'premium',
        'shopify_integration': 'premium',
        'woocommerce_integration': 'premium',
        'advanced_reports': 'pro',
        'trend_predictions': 'pro',
        'competitor_analysis': 'pro',
        'bulk_operations': 'pro',
        'custom_alerts': 'pro',
    }
    
    @staticmethod
    def check_access(tier_id: str, feature: str) -> bool:
        """Check if tier has access to feature"""
        required_tier = FeatureRestrictions.FEATURE_REQUIREMENTS.get(feature)
        
        if not required_tier:
            return True
        
        tier_hierarchy = ['free', 'starter', 'pro', 'premium']
        
        if tier_id not in tier_hierarchy or required_tier not in tier_hierarchy:
            return False
        
        return tier_hierarchy.index(tier_id) >= tier_hierarchy.index(required_tier)
    
    @staticmethod
    def get_required_tier(feature: str) -> Optional[str]:
        """Get minimum tier required for a feature"""
        return FeatureRestrictions.FEATURE_REQUIREMENTS.get(feature)
    
    @staticmethod
    def get_inaccessible_features(tier_id: str) -> List[str]:
        """Get list of features not available in tier"""
        inaccessible = []
        
        for feature, required_tier in FeatureRestrictions.FEATURE_REQUIREMENTS.items():
            if not FeatureRestrictions.check_access(tier_id, feature):
                inaccessible.append({
                    'feature': feature,
                    'required_tier': required_tier,
                })
        
        return inaccessible


# ============================================================================
# PAYWALL & UPGRADE MANAGEMENT
# ============================================================================

class PaywallManager:
    """Manages paywall display and upgrade prompts"""
    
    @staticmethod
    def get_paywall_data(user_tier: str, requested_feature: str) -> Dict:
        """Get paywall data for a feature"""
        required_tier = FeatureRestrictions.get_required_tier(requested_feature)
        
        if not required_tier:
            return {'show_paywall': False}
        
        tier_hierarchy = ['free', 'starter', 'pro', 'premium']
        user_index = tier_hierarchy.index(user_tier) if user_tier in tier_hierarchy else 0
        
        if user_index >= tier_hierarchy.index(required_tier):
            return {'show_paywall': False}
        
        upgrades = SubscriptionService.upgrade_path(user_tier)
        
        return {
            'show_paywall': True,
            'current_tier': user_tier,
            'requested_feature': requested_feature,
            'required_tier': required_tier,
            'upgrade_options': upgrades,
            'message': f"Upgrade to {required_tier.capitalize()} to access {requested_feature}",
        }
    
    @staticmethod
    def get_tier_comparison_for_upgrade(current_tier: str) -> Dict:
        """Get detailed comparison for upgrade decision"""
        comparison = SubscriptionService.compare_tiers()
        upgrades = SubscriptionService.upgrade_path(current_tier)
        
        return {
            'current_tier': current_tier,
            'all_tiers': comparison,
            'available_upgrades': upgrades,
        }
