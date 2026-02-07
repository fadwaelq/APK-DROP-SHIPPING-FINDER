# Subscription & Tiers API Documentation

## Overview
Complete subscription management system with 4 tiers: Free, Starter, Pro, and Premium.

---

## Base URL
```
/api/profile/
```

---

## Endpoints

### 1. Get All Subscription Tiers
Retrieve all available subscription tiers with pricing and features.

**Endpoint:**  
`GET /api/profile/subscription_tiers/`

**Authentication:**  
Required (JWT Token)

**Response:**
```json
{
  "tiers": [
    {
      "tier_id": "free",
      "name": "Gratuit",
      "description": "Plan gratuit pour débuter",
      "price": 0,
      "features": [
        "✓ Analyse de 5 produits par jour",
        "✓ Accès aux catégories de base",
        "✓ Score de rentabilité simple",
        "✓ Support communautaire"
      ],
      "limits": {
        "daily_analyses": 5,
        "products_per_month": 150,
        "export_products": false,
        "api_access": false
      },
      "pricing": {
        "monthly": 0,
        "quarterly": 0,
        "annual": 0,
        "billing_cycle": "never"
      }
    },
    {
      "tier_id": "starter",
      "name": "Démarrage",
      "price": 9.99,
      ...
    }
  ],
  "current_tier": "free"
}
```

---

### 2. Get Tier Comparison
Compare features across all tiers in a matrix format.

**Endpoint:**  
`GET /api/profile/subscription_comparison/`

**Authentication:**  
Required

**Response:**
```json
{
  "comparison": {
    "features": [
      "✓ Analyse de 5 produits par jour",
      "✓ API Access",
      "✓ Custom Pricing Rules",
      ...
    ],
    "tiers": {
      "free": {
        "name": "Gratuit",
        "price": 0,
        "has_features": {
          "✓ Analyse de 5 produits par jour": true,
          "✓ API Access": false,
          ...
        }
      },
      "starter": { ... },
      "pro": { ... },
      "premium": { ... }
    }
  },
  "current_tier": "free"
}
```

---

### 3. Get Current Tier Features
Get features and limits for the user's current subscription tier.

**Endpoint:**  
`GET /api/profile/subscription_features/`

**Authentication:**  
Required

**Response:**
```json
{
  "tier": "free",
  "features": [
    "✓ Analyse de 5 produits par jour",
    "✓ Accès aux catégories de base",
    "✓ Score de rentabilité simple",
    "✓ Support communautaire"
  ],
  "limits": {
    "daily_analyses": 5,
    "products_per_month": 150,
    "categories": 3,
    "api_calls_per_month": 5000,
    "export_products": false,
    "trend_alerts": 3,
    "custom_pricing_rules": false,
    "api_access": false,
    "priority_support": false
  }
}
```

---

### 4. Check Feature Access
Check if the user has access to a specific feature.

**Endpoint:**  
`POST /api/profile/check_feature_access/`

**Authentication:**  
Required

**Request Body:**
```json
{
  "feature": "export_products"
}
```

**Response - Access Granted (200):**
```json
{
  "access": true,
  "tier": "starter",
  "feature": "export_products"
}
```

**Response - Access Denied (403):**
```json
{
  "access": false,
  "paywall": {
    "show_paywall": true,
    "current_tier": "free",
    "requested_feature": "export_products",
    "required_tier": "starter",
    "upgrade_options": [
      {
        "tier_id": "starter",
        "name": "Démarrage",
        "price": 9.99,
        "pricing": { ... },
        "features_added": [ ... ]
      },
      {
        "tier_id": "pro",
        "name": "Professionnel",
        "price": 29.99,
        ...
      }
    ],
    "message": "Upgrade to Starter to access export_products"
  }
}
```

---

### 5. Get Upgrade Path
Get available upgrade options from current tier.

**Endpoint:**  
`GET /api/profile/upgrade_path/`

**Authentication:**  
Required

**Response:**
```json
{
  "current_tier": "free",
  "available_upgrades": [
    {
      "tier_id": "starter",
      "name": "Démarrage",
      "price": 9.99,
      "pricing": {
        "monthly": 9.99,
        "quarterly": 26.97,
        "annual": 99.90,
        "billing_cycle": "monthly"
      },
      "features_added": [
        "✓ Analyse de 50 produits par jour",
        "✓ Toutes les catégories",
        ...
      ]
    },
    {
      "tier_id": "pro",
      "name": "Professionnel",
      "price": 29.99,
      ...
    },
    {
      "tier_id": "premium",
      "name": "Premium",
      "price": 99.99,
      ...
    }
  ]
}
```

---

### 6. Get Paywall Data
Get paywall data for a specific feature (for modal display).

**Endpoint:**  
`GET /api/profile/paywall_data/?feature=FEATURE_NAME`

**Authentication:**  
Required

**Query Parameters:**
- `feature` (required): Feature name to check access for

**Example:**
```
GET /api/profile/paywall_data/?feature=custom_pricing
```

**Response:**
```json
{
  "show_paywall": true,
  "current_tier": "starter",
  "requested_feature": "custom_pricing",
  "required_tier": "pro",
  "upgrade_options": [
    {
      "tier_id": "pro",
      "name": "Professionnel",
      "price": 29.99,
      "pricing": {
        "monthly": 29.99,
        "quarterly": 80.97,
        "annual": 299.90
      },
      "features_added": [ ... ]
    },
    {
      "tier_id": "premium",
      "name": "Premium",
      "price": 99.99,
      ...
    }
  ],
  "message": "Upgrade to Pro to access custom_pricing"
}
```

---

## Feature Requirements by Tier

| Feature | Free | Starter | Pro | Premium |
|---------|------|---------|-----|---------|
| Unlimited Analyses | ❌ | ❌ | ✅ | ✅ |
| Export Products | ❌ | ✅ | ✅ | ✅ |
| Custom Pricing | ❌ | ❌ | ✅ | ✅ |
| API Access | ❌ | ❌ | ✅ | ✅ |
| Priority Support | ❌ | ❌ | ✅ | ✅ |
| Team Features | ❌ | ❌ | ❌ | ✅ |
| Webhooks | ❌ | ❌ | ❌ | ✅ |
| Automations | ❌ | ❌ | ❌ | ✅ |
| Shopify Integration | ❌ | ❌ | ❌ | ✅ |
| WooCommerce Integration | ❌ | ❌ | ❌ | ✅ |

---

## Features List

### Tier Features

#### Free (Gratuit)
- ✓ Analyse de 5 produits par jour
- ✓ Accès aux catégories de base
- ✓ Score de rentabilité simple
- ✓ Support communautaire

#### Starter (Démarrage) - $9.99/month
- ✓ Analyse de 50 produits par jour
- ✓ Toutes les catégories
- ✓ Score de rentabilité avancé
- ✓ Trends et alertes illimitées
- ✓ Historique sur 3 mois
- ✓ Support par email
- ✓ Export CSV basique

#### Pro (Professionnel) - $29.99/month
- ✓ Analyses illimitées
- ✓ Toutes les catégories
- ✓ Score IA avancé + prédictions
- ✓ Analyse de concurrence détaillée
- ✓ Alerts de trends personnalisés
- ✓ Historique complet (illimité)
- ✓ Export avancé (tous formats)
- ✓ Intégration API
- ✓ Support prioritaire
- ✓ Règles de prix personnalisées

#### Premium - $99.99/month
- ✓ Tout du plan Pro
- ✓ Analyses illimitées en temps réel
- ✓ IA prédictive avancée
- ✓ Dashboard d'équipe (5 utilisateurs)
- ✓ Webhooks et automations
- ✓ Intégration Shopify/WooCommerce
- ✓ Support 24/7 dédié
- ✓ Rapports mensuels détaillés
- ✓ Accès anticipé aux nouvelles features
- ✓ SLA garanti 99.9%

---

## Pricing Options

All paid tiers offer three billing cycles:

| Tier | Monthly | Quarterly | Annual | Savings |
|------|---------|-----------|--------|---------|
| Free | $0 | $0 | $0 | - |
| Starter | $9.99 | $26.97 | $99.90 | 17% |
| Pro | $29.99 | $80.97 | $299.90 | 17% |
| Premium | $99.99 | $269.97 | $999.90 | 17% |

---

## Error Responses

### 400 Bad Request
Missing required parameters:
```json
{
  "error": "Feature name required"
}
```

### 403 Forbidden
Feature access denied (with paywall data):
```json
{
  "access": false,
  "paywall": { ... }
}
```

### 404 Not Found
Feature not found in requirements:
```json
{
  "error": "Feature parameter required"
}
```

---

## Integration Examples

### Check if user can export products
```bash
curl -X POST http://localhost:8000/api/profile/check_feature_access/ \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"feature": "export_products"}'
```

### Show paywall when accessing pro feature
```bash
curl -X GET "http://localhost:8000/api/profile/paywall_data/?feature=api_access" \
  -H "Authorization: Bearer YOUR_TOKEN"
```

### Get subscription tiers for selection screen
```bash
curl -X GET http://localhost:8000/api/profile/subscription_tiers/ \
  -H "Authorization: Bearer YOUR_TOKEN"
```

### Display tier comparison on pricing page
```bash
curl -X GET http://localhost:8000/api/profile/subscription_comparison/ \
  -H "Authorization: Bearer YOUR_TOKEN"
```

---

## Status Codes

| Code | Meaning |
|------|---------|
| 200 | Success |
| 400 | Bad Request / Missing Parameters |
| 401 | Unauthorized (No Authentication) |
| 403 | Forbidden (No Access to Feature) |
| 404 | Not Found |
| 500 | Server Error |

---

## Rate Limits

- **Free Tier**: 5,000 API calls/month
- **Starter Tier**: 50,000 API calls/month  
- **Pro Tier**: 500,000 API calls/month
- **Premium Tier**: 2,000,000 API calls/month

---

## Implementation Notes

1. **Feature Access Check** - Call before showing pro features
2. **Paywall Display** - Use 403 response with paywall data to trigger upgrade modal
3. **Tier Comparison** - Use `/subscription_comparison/` for pricing page
4. **Upgrade Path** - Show only available upgrades from current tier
5. **Caching** - Tier data can be safely cached (static configuration)

---

## Testing

Run the comprehensive test suite:
```bash
python test_subscription_system.py
```

This will test:
- All tier retrieval
- Feature access matrix
- Paywall logic
- Upgrade paths
- Pricing options
- Real-world scenarios
