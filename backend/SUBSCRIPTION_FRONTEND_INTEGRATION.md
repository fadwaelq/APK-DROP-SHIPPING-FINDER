# Subscription System - Frontend Integration Guide

## Quick Start

This guide explains how to integrate the subscription/tiers system into your React Native app.

---

## 1. API Client Setup

### Create `services/subscriptionService.ts`

```typescript
import axios from 'axios';
import AsyncStorage from '@react-native-async-storage/async-storage';

const API_BASE_URL = 'https://api.dropshippingfinder.com';

const subscriptionAPI = axios.create({
  baseURL: `${API_BASE_URL}/api/profile`,
});

// Add auth token to requests
subscriptionAPI.interceptors.request.use(async (config) => {
  const token = await AsyncStorage.getItem('authToken');
  if (token) {
    config.headers.Authorization = `Bearer ${token}`;
  }
  return config;
});

export const subscriptionService = {
  // Get all subscription tiers
  getTiers: () => subscriptionAPI.get('/subscription_tiers/'),
  
  // Get tier comparison
  getComparison: () => subscriptionAPI.get('/subscription_comparison/'),
  
  // Get user's current features
  getFeatures: () => subscriptionAPI.get('/subscription_features/'),
  
  // Check if user can access a feature
  checkFeatureAccess: (feature: string) =>
    subscriptionAPI.post('/check_feature_access/', { feature }),
  
  // Get upgrade options
  getUpgradePath: () => subscriptionAPI.get('/upgrade_path/'),
  
  // Get paywall data for a feature
  getPaywallData: (feature: string) =>
    subscriptionAPI.get(`/paywall_data/?feature=${feature}`),
  
  // Update subscription (admin only)
  updateSubscription: (plan: string) =>
    subscriptionAPI.post('/update_subscription/', { plan }),
};
```

---

## 2. Feature Gate Component

### Create `components/FeatureGate.tsx`

```typescript
import React, { useState, useEffect } from 'react';
import { View, ActivityIndicator } from 'react-native';
import { subscriptionService } from '../services/subscriptionService';
import PaywallModal from './PaywallModal';

interface FeatureGateProps {
  feature: string;
  children: React.ReactNode;
  fallback?: React.ReactNode;
}

export const FeatureGate: React.FC<FeatureGateProps> = ({
  feature,
  children,
  fallback,
}) => {
  const [hasAccess, setHasAccess] = useState<boolean | null>(null);
  const [paywallData, setPaywallData] = useState(null);
  const [showPaywall, setShowPaywall] = useState(false);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    checkAccess();
  }, [feature]);

  const checkAccess = async () => {
    try {
      const response = await subscriptionService.checkFeatureAccess(feature);
      setHasAccess(true);
    } catch (error: any) {
      if (error.response?.status === 403) {
        setHasAccess(false);
        setPaywallData(error.response?.data?.paywall);
      }
    } finally {
      setLoading(false);
    }
  };

  if (loading) {
    return <ActivityIndicator size="large" color="#FF6B00" />;
  }

  if (!hasAccess) {
    return (
      <>
        {fallback || (
          <View style={styles.lockedContent}>
            {/* Show lock icon or upgrade button */}
            <TouchableOpacity
              onPress={() => setShowPaywall(true)}
              style={styles.upgradeButton}
            >
              <Text style={styles.upgradeText}>Upgrade to Access</Text>
            </TouchableOpacity>
          </View>
        )}
        <PaywallModal
          visible={showPaywall}
          onClose={() => setShowPaywall(false)}
          data={paywallData}
        />
      </>
    );
  }

  return <>{children}</>;
};
```

---

## 3. Subscription Badge Component

### Create `components/SubscriptionBadge.tsx`

```typescript
import React, { useState, useEffect } from 'react';
import { View, Text, TouchableOpacity } from 'react-native';
import { subscriptionService } from '../services/subscriptionService';

interface SubscriptionBadgeProps {
  onUpgradePress?: () => void;
}

export const SubscriptionBadge: React.FC<SubscriptionBadgeProps> = ({
  onUpgradePress,
}) => {
  const [currentTier, setCurrentTier] = useState<string>('free');

  useEffect(() => {
    loadUserTier();
  }, []);

  const loadUserTier = async () => {
    try {
      const response = await subscriptionService.getFeatures();
      setCurrentTier(response.data.tier);
    } catch (error) {
      console.error('Failed to load tier:', error);
    }
  };

  const tierColors: Record<string, string> = {
    free: '#CCCCCC',
    starter: '#FFB300',
    pro: '#FF6B00',
    premium: '#9B59B6',
  };

  const tierLabels: Record<string, string> = {
    free: 'Gratuit',
    starter: 'Démarrage',
    pro: 'Pro',
    premium: 'Premium',
  };

  return (
    <View style={[styles.badge, { backgroundColor: tierColors[currentTier] }]}>
      <Text style={styles.badgeText}>{tierLabels[currentTier]}</Text>
      {currentTier === 'free' && (
        <TouchableOpacity onPress={onUpgradePress}>
          <Text style={styles.upgradeLink}>Upgrade</Text>
        </TouchableOpacity>
      )}
    </View>
  );
};
```

---

## 4. Paywall Modal Component

### Create `components/PaywallModal.tsx`

```typescript
import React from 'react';
import {
  Modal,
  View,
  Text,
  TouchableOpacity,
  ScrollView,
  StyleSheet,
} from 'react-native';
import { MaterialCommunityIcons } from '@expo/vector-icons';

interface PaywallModalProps {
  visible: boolean;
  onClose: () => void;
  data: any;
}

export const PaywallModal: React.FC<PaywallModalProps> = ({
  visible,
  onClose,
  data,
}) => {
  if (!data) return null;

  return (
    <Modal
      visible={visible}
      transparent={true}
      animationType="slide"
      onRequestClose={onClose}
    >
      <View style={styles.container}>
        <View style={styles.header}>
          <TouchableOpacity onPress={onClose}>
            <MaterialCommunityIcons name="close" size={24} color="black" />
          </TouchableOpacity>
          <Text style={styles.title}>Upgrade Required</Text>
          <View style={{ width: 24 }} />
        </View>

        <ScrollView style={styles.content}>
          <View style={styles.messageBox}>
            <MaterialCommunityIcons
              name="lock-outline"
              size={48}
              color="#FF6B00"
            />
            <Text style={styles.message}>{data.message}</Text>
          </View>

          <Text style={styles.sectionTitle}>Choose Your Plan</Text>

          {data.upgrade_options?.map((option: any, index: number) => (
            <View key={index} style={styles.tierCard}>
              <View style={styles.tierHeader}>
                <Text style={styles.tierName}>{option.name}</Text>
                <Text style={styles.tierPrice}>${option.price}/mo</Text>
              </View>

              <View style={styles.featuresList}>
                {option.features_added?.slice(0, 4).map(
                  (feature: string, idx: number) => (
                    <View key={idx} style={styles.featureItem}>
                      <MaterialCommunityIcons
                        name="check"
                        size={16}
                        color="#4CAF50"
                      />
                      <Text style={styles.featureText}>{feature}</Text>
                    </View>
                  )
                )}
              </View>

              <TouchableOpacity style={styles.selectButton}>
                <Text style={styles.selectButtonText}>
                  Continue to Payment
                </Text>
              </TouchableOpacity>
            </View>
          ))}
        </ScrollView>
      </View>
    </Modal>
  );
};

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: '#fff',
    paddingTop: 50,
  },
  header: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    paddingHorizontal: 16,
    paddingBottom: 16,
    borderBottomWidth: 1,
    borderBottomColor: '#f0f0f0',
  },
  title: {
    fontSize: 18,
    fontWeight: '600',
  },
  content: {
    flex: 1,
    padding: 16,
  },
  messageBox: {
    alignItems: 'center',
    marginVertical: 24,
  },
  message: {
    fontSize: 16,
    textAlign: 'center',
    marginTop: 12,
    color: '#333',
  },
  sectionTitle: {
    fontSize: 16,
    fontWeight: '600',
    marginVertical: 16,
  },
  tierCard: {
    borderWidth: 1,
    borderColor: '#f0f0f0',
    borderRadius: 12,
    padding: 16,
    marginBottom: 12,
  },
  tierHeader: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    marginBottom: 12,
  },
  tierName: {
    fontSize: 16,
    fontWeight: '600',
  },
  tierPrice: {
    fontSize: 16,
    fontWeight: '700',
    color: '#FF6B00',
  },
  featuresList: {
    marginVertical: 12,
  },
  featureItem: {
    flexDirection: 'row',
    alignItems: 'flex-start',
    marginVertical: 6,
  },
  featureText: {
    marginLeft: 8,
    fontSize: 14,
    color: '#555',
  },
  selectButton: {
    backgroundColor: '#FF6B00',
    paddingVertical: 12,
    borderRadius: 8,
    alignItems: 'center',
    marginTop: 12,
  },
  selectButtonText: {
    color: 'white',
    fontSize: 16,
    fontWeight: '600',
  },
});
```

---

## 5. Pricing/Subscription Screen

### Create `screens/SubscriptionScreen.tsx`

```typescript
import React, { useState, useEffect } from 'react';
import {
  View,
  Text,
  ScrollView,
  TouchableOpacity,
  StyleSheet,
  ActivityIndicator,
} from 'react-native';
import { subscriptionService } from '../services/subscriptionService';

export const SubscriptionScreen: React.FC = () => {
  const [tiers, setTiers] = useState([]);
  const [currentTier, setCurrentTier] = useState('free');
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    loadSubscriptions();
  }, []);

  const loadSubscriptions = async () => {
    try {
      const response = await subscriptionService.getTiers();
      setTiers(response.data.tiers);
      setCurrentTier(response.data.current_tier);
    } catch (error) {
      console.error('Failed to load tiers:', error);
    } finally {
      setLoading(false);
    }
  };

  if (loading) {
    return <ActivityIndicator size="large" color="#FF6B00" />;
  }

  return (
    <ScrollView style={styles.container}>
      <Text style={styles.title}>Choose Your Plan</Text>

      {tiers.map((tier: any) => (
        <View
          key={tier.tier_id}
          style={[
            styles.tierCard,
            currentTier === tier.tier_id && styles.activeTierCard,
          ]}
        >
          <View style={styles.tierCardHeader}>
            <Text style={styles.tierName}>{tier.name}</Text>
            {currentTier === tier.tier_id && (
              <Text style={styles.currentBadge}>Current Plan</Text>
            )}
          </View>

          <Text style={styles.price}>
            ${tier.price}
            <Text style={styles.priceUnit}>/month</Text>
          </Text>

          <Text style={styles.description}>{tier.description}</Text>

          <View style={styles.features}>
            {tier.features.slice(0, 5).map((feature: string, idx: number) => (
              <Text key={idx} style={styles.feature}>
                {feature}
              </Text>
            ))}
            {tier.features.length > 5 && (
              <Text style={styles.moreFeatures}>
                +{tier.features.length - 5} more features
              </Text>
            )}
          </View>

          <TouchableOpacity
            style={[
              styles.button,
              currentTier === tier.tier_id && styles.buttonDisabled,
            ]}
            disabled={currentTier === tier.tier_id}
          >
            <Text style={styles.buttonText}>
              {currentTier === tier.tier_id ? 'Current Plan' : 'Upgrade'}
            </Text>
          </TouchableOpacity>
        </View>
      ))}
    </ScrollView>
  );
};

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: '#f5f5f5',
    padding: 16,
  },
  title: {
    fontSize: 24,
    fontWeight: 'bold',
    marginBottom: 24,
  },
  tierCard: {
    backgroundColor: 'white',
    borderRadius: 12,
    padding: 16,
    marginBottom: 16,
    borderWidth: 2,
    borderColor: 'transparent',
  },
  activeTierCard: {
    borderColor: '#FF6B00',
  },
  tierCardHeader: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    marginBottom: 8,
  },
  tierName: {
    fontSize: 18,
    fontWeight: '600',
  },
  currentBadge: {
    backgroundColor: '#FF6B00',
    color: 'white',
    paddingHorizontal: 8,
    paddingVertical: 4,
    borderRadius: 4,
    fontSize: 12,
    fontWeight: '600',
  },
  price: {
    fontSize: 28,
    fontWeight: 'bold',
    color: '#FF6B00',
    marginBottom: 4,
  },
  priceUnit: {
    fontSize: 14,
    fontWeight: 'normal',
  },
  description: {
    fontSize: 12,
    color: '#666',
    marginBottom: 12,
  },
  features: {
    marginVertical: 12,
  },
  feature: {
    fontSize: 13,
    color: '#333',
    marginVertical: 4,
  },
  moreFeatures: {
    fontSize: 12,
    color: '#FF6B00',
    fontWeight: '500',
    marginTop: 4,
  },
  button: {
    backgroundColor: '#FF6B00',
    paddingVertical: 12,
    borderRadius: 8,
    alignItems: 'center',
    marginTop: 12,
  },
  buttonDisabled: {
    opacity: 0.5,
  },
  buttonText: {
    color: 'white',
    fontSize: 16,
    fontWeight: '600',
  },
});
```

---

## 6. Context/Hook for Subscription State

### Create `hooks/useSubscription.ts`

```typescript
import { useState, useEffect } from 'react';
import { subscriptionService } from '../services/subscriptionService';

export const useSubscription = () => {
  const [tier, setTier] = useState<string>('free');
  const [features, setFeatures] = useState<string[]>([]);
  const [limits, setLimits] = useState<Record<string, any>>({});
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    loadSubscription();
  }, []);

  const loadSubscription = async () => {
    try {
      const response = await subscriptionService.getFeatures();
      setTier(response.data.tier);
      setFeatures(response.data.features);
      setLimits(response.data.limits);
    } catch (err: any) {
      setError(err.message);
    } finally {
      setLoading(false);
    }
  };

  const checkAccess = async (feature: string) => {
    try {
      await subscriptionService.checkFeatureAccess(feature);
      return true;
    } catch (error: any) {
      if (error.response?.status === 403) {
        return false;
      }
      throw error;
    }
  };

  const canUse = (feature: string): boolean => {
    const featureMap: Record<string, string> = {
      export: 'export_products',
      api: 'api_access',
      premium: 'priority_support',
    };
    return limits[featureMap[feature]] === true ||
      (featureMap[feature] && limits[featureMap[feature]]);
  };

  return {
    tier,
    features,
    limits,
    loading,
    error,
    checkAccess,
    canUse,
    refresh: loadSubscription,
  };
};
```

---

## 7. Usage Examples

### Example 1: Protect a Feature
```typescript
<FeatureGate feature="export_products">
  <ExportButton />
</FeatureGate>
```

### Example 2: Check Access in Logic
```typescript
const { checkAccess } = useSubscription();

const handleExport = async () => {
  const hasAccess = await checkAccess('export_products');
  if (hasAccess) {
    // Export data
  } else {
    // Show paywall
  }
};
```

### Example 3: Show Current Subscription
```typescript
const { tier } = useSubscription();

return (
  <View>
    <SubscriptionBadge />
    <Text>Your current plan: {tier}</Text>
  </View>
);
```

---

## 8. Real-World Integration

### In Your Main App Navigation
```typescript
// screens/MainNavigator.tsx
import { SubscriptionScreen } from './screens/SubscriptionScreen';
import { ProfileScreen } from './screens/ProfileScreen';

export const MainNavigator = () => {
  return (
    <Stack.Navigator>
      <Stack.Screen name="Profile" component={ProfileScreen} />
      <Stack.Screen name="Subscription" component={SubscriptionScreen} />
    </Stack.Navigator>
  );
};
```

### On First App Load
```typescript
// App.tsx
useEffect(() => {
  const checkSubscription = async () => {
    const { tier } = useSubscription();
    if (tier === 'free') {
      // Show onboarding/upgrade prompt
    }
  };
  
  checkSubscription();
}, []);
```

---

## 9. Testing the Integration

```bash
# Run the backend test suite
python test_subscription_system.py

# Check API endpoints
curl -X GET http://localhost:8000/api/profile/subscription_tiers/ \
  -H "Authorization: Bearer YOUR_TOKEN"
```

---

## Summary

The subscription system provides:
- ✅ 4 tiers (Free, Starter, Pro, Premium)
- ✅ Feature-based access control
- ✅ Dynamic paywall display
- ✅ Upgrade path suggestions
- ✅ Price comparison
- ✅ Real-time subscription validation

Integrate using the components and hooks provided above!
