"""
Test Suite for Subscription & Tiers System
"""
import os
import django

os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'dropshipping_finder.settings')
django.setup()

from core.subscription_service import (
    SubscriptionService,
    FeatureRestrictions,
    PaywallManager,
    SUBSCRIPTION_TIERS,
    SUBSCRIPTION_PRICING,
)


def print_section(title):
    """Print a formatted section title"""
    print(f"\n{'='*70}")
    print(f"  {title}")
    print(f"{'='*70}\n")


def test_get_all_tiers():
    """Test getting all subscription tiers"""
    print_section("TEST 1: Get All Subscription Tiers")
    
    tiers = SubscriptionService.get_available_tiers()
    
    for tier in tiers:
        print(f"\n📦 {tier['name'].upper()} TIER")
        print(f"   ID: {tier['tier_id']}")
        print(f"   Price: ${tier['price']}/month")
        print(f"   Description: {tier['description']}")
        print(f"   Features:")
        for feature in tier['features'][:3]:  # Show first 3 features
            print(f"      {feature}")
        print(f"      ... and {len(tier['features']) - 3} more features")
        print(f"   Pricing Options: {tier['pricing']}")


def test_tier_features():
    """Test getting features for each tier"""
    print_section("TEST 2: Get Features by Tier")
    
    tiers = ['free', 'starter', 'pro', 'premium']
    
    for tier_id in tiers:
        features = SubscriptionService.get_tier_features(tier_id)
        limits = SubscriptionService.get_tier_limits(tier_id)
        
        print(f"\n✨ {tier_id.upper()} TIER")
        print(f"   Total Features: {len(features)}")
        print(f"   Daily Analyses Limit: {limits.get('daily_analyses', 'N/A')}")
        print(f"   Export Products: {limits.get('export_products', False)}")
        print(f"   API Access: {limits.get('api_access', False)}")
        print(f"   Priority Support: {limits.get('priority_support', False)}")


def test_feature_access():
    """Test feature access control"""
    print_section("TEST 3: Feature Access Control")
    
    features_to_test = [
        'export_products',
        'api_access',
        'custom_pricing',
        'webhooks',
    ]
    
    tiers = ['free', 'starter', 'pro', 'premium']
    
    print("Feature Access Matrix:\n")
    print(f"{'Feature':<20} | {'Free':<8} | {'Starter':<8} | {'Pro':<8} | {'Premium':<8}")
    print("-" * 70)
    
    for feature in features_to_test:
        access_status = []
        for tier in tiers:
            has_access = FeatureRestrictions.check_access(tier, feature)
            access_status.append("✓" if has_access else "✗")
        
        status_str = " | ".join(f"{s:<8}" for s in access_status)
        print(f"{feature:<20} | {status_str}")


def test_paywall_logic():
    """Test paywall display logic"""
    print_section("TEST 4: Paywall Logic")
    
    # Free user trying to access pro feature
    print("\n🚫 FREE USER trying to access: custom_pricing")
    paywall = PaywallManager.get_paywall_data('free', 'custom_pricing')
    print(f"   Show Paywall: {paywall['show_paywall']}")
    print(f"   Current Tier: {paywall.get('current_tier', 'N/A')}")
    print(f"   Required Tier: {paywall.get('required_tier', 'N/A')}")
    print(f"   Message: {paywall.get('message', 'N/A')}")
    print(f"   Upgrade Options: {len(paywall.get('upgrade_options', []))} available")
    
    # Pro user trying to access pro feature
    print("\n✅ PRO USER trying to access: custom_pricing")
    paywall = PaywallManager.get_paywall_data('pro', 'custom_pricing')
    print(f"   Show Paywall: {paywall['show_paywall']}")
    
    # Premium user trying to access premium feature
    print("\n✅ PREMIUM USER trying to access: webhooks")
    paywall = PaywallManager.get_paywall_data('premium', 'webhooks')
    print(f"   Show Paywall: {paywall['show_paywall']}")


def test_upgrade_paths():
    """Test upgrade path suggestions"""
    print_section("TEST 5: Upgrade Path Suggestions")
    
    tiers = ['free', 'starter', 'pro']
    
    for tier in tiers:
        upgrades = SubscriptionService.upgrade_path(tier)
        print(f"\n🔄 {tier.upper()} User Upgrade Options:")
        
        for upgrade in upgrades:
            print(f"\n   → Upgrade to {upgrade['name'].upper()}")
            print(f"     Price: ${upgrade['price']}/month")
            print(f"     New Features Available: {len(upgrade['features_added'])} features")


def test_tier_comparison():
    """Test tier comparison"""
    print_section("TEST 6: Tier Comparison")
    
    comparison = SubscriptionService.compare_tiers()
    
    print(f"\nTotal Unique Features: {len(comparison['features'])}\n")
    
    print("Tier Summary:")
    for tier_id, tier_data in comparison['tiers'].items():
        total_features = sum(1 for has_feature in tier_data['has_features'].values() if has_feature)
        print(f"  {tier_id.upper():<10} - {tier_data['name']:<20} (${tier_data['price']:<6}) - {total_features} features")


def test_pricing_options():
    """Test pricing options for tiers"""
    print_section("TEST 7: Pricing Options (Monthly, Quarterly, Annual)")
    
    print("\nPrice Comparison:\n")
    print(f"{'Tier':<15} | {'Monthly':<12} | {'Quarterly':<12} | {'Annual':<12} | {'Annual Savings'}")
    print("-" * 80)
    
    for tier_id, pricing in SUBSCRIPTION_PRICING.items():
        monthly = pricing['monthly']
        quarterly = pricing['quarterly']
        annual = pricing['annual']
        
        if annual > 0:
            monthly_total = monthly * 12
            savings = monthly_total - annual
            savings_pct = (savings / monthly_total * 100) if monthly_total > 0 else 0
            savings_str = f"-${savings:.2f} ({savings_pct:.0f}%)"
        else:
            savings_str = "Free"
        
        print(f"{tier_id.upper():<15} | ${monthly:<11.2f} | ${quarterly:<11.2f} | ${annual:<11.2f} | {savings_str}")


def test_inaccessible_features():
    """Test getting inaccessible features per tier"""
    print_section("TEST 8: Inaccessible Features per Tier")
    
    tiers = ['free', 'starter', 'pro']
    
    for tier_id in tiers:
        inaccessible = FeatureRestrictions.get_inaccessible_features(tier_id)
        print(f"\n🔒 {tier_id.upper()} User - Locked Features ({len(inaccessible)}):")
        
        for item in inaccessible[:5]:  # Show first 5
            print(f"   • {item['feature']} (requires {item['required_tier'].upper()})")
        
        if len(inaccessible) > 5:
            print(f"   ... and {len(inaccessible) - 5} more locked features")


def test_real_world_scenarios():
    """Test real-world usage scenarios"""
    print_section("TEST 9: Real-World Scenarios")
    
    # Scenario 1: New free user wants to export data
    print("\n📊 SCENARIO 1: Free User Wants to Export Products")
    has_access = FeatureRestrictions.check_access('free', 'export_products')
    print(f"   Access: {'✅ Yes' if has_access else '❌ No'}")
    if not has_access:
        paywall = PaywallManager.get_paywall_data('free', 'export_products')
        required = paywall['required_tier']
        print(f"   Action: Show paywall - Upgrade needed to {required.upper()}")
    
    # Scenario 2: Starter user wants API access
    print("\n🔌 SCENARIO 2: Starter User Wants API Access")
    has_access = FeatureRestrictions.check_access('starter', 'api_access')
    print(f"   Access: {'✅ Yes' if has_access else '❌ No'}")
    if not has_access:
        paywall = PaywallManager.get_paywall_data('starter', 'api_access')
        required = paywall['required_tier']
        upgrades = paywall['upgrade_options']
        print(f"   Action: Show paywall - Upgrade to {required.upper()}")
        print(f"   Available upgrades: {[u['name'] for u in upgrades]}")
    
    # Scenario 3: Pro user wants team features
    print("\n👥 SCENARIO 3: Pro User Wants Team Features")
    has_access = FeatureRestrictions.check_access('pro', 'team_features')
    print(f"   Access: {'✅ Yes' if has_access else '❌ No'}")
    if not has_access:
        paywall = PaywallManager.get_paywall_data('pro', 'team_features')
        required = paywall['required_tier']
        print(f"   Action: Show paywall - Upgrade to {required.upper()}")


def run_all_tests():
    """Run all tests"""
    print("\n")
    print("╔════════════════════════════════════════════════════════════════════╗")
    print("║          SUBSCRIPTION & TIERS SYSTEM - COMPREHENSIVE TEST         ║")
    print("║                   Dropshipping Finder Backend                     ║")
    print("╚════════════════════════════════════════════════════════════════════╝")
    
    test_get_all_tiers()
    test_tier_features()
    test_feature_access()
    test_paywall_logic()
    test_upgrade_paths()
    test_tier_comparison()
    test_pricing_options()
    test_inaccessible_features()
    test_real_world_scenarios()
    
    # Print summary statistics
    print_section("SUMMARY STATISTICS")
    
    all_tiers = SubscriptionService.get_all_tiers()
    total_features = len(FeatureRestrictions.FEATURE_REQUIREMENTS)
    
    print(f"\n📈 Subscription System Overview:")
    print(f"   Total Tiers: {len(all_tiers)}")
    print(f"   Total Features: {total_features}")
    print(f"   Feature Requirements Defined: {len(FeatureRestrictions.FEATURE_REQUIREMENTS)}")
    print(f"\n💳 Tier Details:")
    
    for tier_id, tier in all_tiers.items():
        limits = tier.limits
        daily_limit = limits.get('daily_analyses', 0)
        print(f"   {tier.name:<15} - ${tier.price:<7.2f}/mo | {daily_limit:>6} analyses/day | {len(tier.features)} features")
    
    print(f"\n✅ All tests completed successfully!\n")


if __name__ == '__main__':
    run_all_tests()
