#!/usr/bin/env python
"""
Test script to validate all product analysis and scoring endpoints
Tests:
1. Product Analysis endpoint (scoring)
2. Category Trends endpoint
3. Trending Products endpoint
4. Top Rated Products endpoint
5. Import Products endpoint
"""

import os
import django
import json
from decimal import Decimal

os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'dropshipping_finder.settings')
django.setup()

from django.contrib.auth.models import User
from core.models import Product, UserProfile
from rest_framework.test import APIClient
from rest_framework_simplejwt.tokens import RefreshToken

# ==================== SETUP ====================
client = APIClient()

# Create test user
test_user, created = User.objects.get_or_create(
    username='testuser',
    defaults={'email': 'test@example.com'}
)
if created:
    test_user.set_password('testpass123')
    test_user.save()
    UserProfile.objects.get_or_create(user=test_user)

# Generate JWT token
refresh = RefreshToken.for_user(test_user)
access_token = str(refresh.access_token)
client.credentials(HTTP_AUTHORIZATION=f'Bearer {access_token}')

# Create test products with scoring data
print("🔧 Creating test products...")
products_data = [
    {
        "name": "Smart Watch Pro X",
        "description": "Advanced fitness tracker with AI health monitoring",
        "source": "aliexpress",
        "source_url": "https://aliexpress.com/item/watch-1",
        "source_id": "12345",
        "category": "tech",
        "price": Decimal("25.99"),
        "cost": Decimal("8.50"),
        "profit": Decimal("17.49"),
        "image_url": "https://example.com/watch.jpg",
        "supplier_name": "TechCorp Ltd",
        "supplier_rating": Decimal("4.8"),
        "supplier_review_count": 1250,
        "score": 85,
        "demand_level": 88,
        "popularity": 82,
        "competition": 70,
        "profitability": 90,
        "trend_percentage": Decimal("25.50"),
        "is_trending": True,
    },
    {
        "name": "Wireless Earbuds Pro",
        "description": "Noise-cancelling Bluetooth earbuds",
        "source": "aliexpress",
        "source_url": "https://aliexpress.com/item/earbuds-1",
        "source_id": "12346",
        "category": "tech",
        "price": Decimal("18.99"),
        "cost": Decimal("6.00"),
        "profit": Decimal("12.99"),
        "image_url": "https://example.com/earbuds.jpg",
        "supplier_name": "AudioPro Inc",
        "supplier_rating": Decimal("4.6"),
        "supplier_review_count": 950,
        "score": 78,
        "demand_level": 80,
        "popularity": 75,
        "competition": 65,
        "profitability": 82,
        "trend_percentage": Decimal("18.30"),
        "is_trending": True,
    },
    {
        "name": "Home Decor LED Strip",
        "description": "RGB LED strip for ambient lighting",
        "source": "aliexpress",
        "source_url": "https://aliexpress.com/item/led-strip-1",
        "source_id": "12347",
        "category": "home",
        "price": Decimal("12.50"),
        "cost": Decimal("3.50"),
        "profit": Decimal("9.00"),
        "image_url": "https://example.com/led.jpg",
        "supplier_name": "LightWorks Ltd",
        "supplier_rating": Decimal("4.5"),
        "supplier_review_count": 750,
        "score": 72,
        "demand_level": 70,
        "popularity": 68,
        "competition": 75,
        "profitability": 85,
        "trend_percentage": Decimal("12.50"),
        "is_trending": False,
    }
]

# Clear existing test products
Product.objects.filter(source_id__in=[p["source_id"] for p in products_data]).delete()

# Create products
test_products = []
for pdata in products_data:
    product = Product.objects.create(**pdata)
    test_products.append(product)
    print(f"✅ Created: {product.name} (Score: {product.score})")

print("\n" + "="*60)
print("🧪 TESTING API ENDPOINTS")
print("="*60)

# ==================== TEST 1: Product Analysis ====================
print("\n📊 TEST 1: Product Analysis Endpoint")
print("-" * 60)
product_id = test_products[0].id
response = client.get(f'/api/products/{product_id}/analyze/')
print(f"Endpoint: GET /api/products/{product_id}/analyze/")
print(f"Status Code: {response.status_code}")

if response.status_code == 200:
    data = response.json()
    print("✅ Response:")
    print(json.dumps(data, indent=2, default=str))
else:
    print(f"❌ Error: {response.content}")

# ==================== TEST 2: Trending Products ====================
print("\n\n🔥 TEST 2: Trending Products Endpoint")
print("-" * 60)
response = client.get('/api/products/trending/')
print(f"Endpoint: GET /api/products/trending/")
print(f"Status Code: {response.status_code}")

if response.status_code == 200:
    data = response.json()
    print(f"✅ Found {len(data)} trending products:")
    for product in data:
        print(f"  - {product['name']} (Score: {product['score']})")
else:
    print(f"❌ Error: {response.content}")

# ==================== TEST 3: Top Rated Products ====================
print("\n\n⭐ TEST 3: Top Rated Products Endpoint")
print("-" * 60)
response = client.get('/api/products/top_rated/')
print(f"Endpoint: GET /api/products/top_rated/")
print(f"Status Code: {response.status_code}")

if response.status_code == 200:
    data = response.json()
    print(f"✅ Found {len(data)} top-rated products:")
    for product in data:
        print(f"  - {product['name']} (Score: {product['score']})")
else:
    print(f"❌ Error: {response.content}")

# ==================== TEST 4: Category Trends ====================
print("\n\n📈 TEST 4: Category Trends Endpoint")
print("-" * 60)
response = client.get('/api/products/category_trends/?category=tech')
print(f"Endpoint: GET /api/products/category_trends/?category=tech")
print(f"Status Code: {response.status_code}")

if response.status_code == 200:
    data = response.json()
    print("✅ Response:")
    print(json.dumps(data, indent=2, default=str))
else:
    print(f"❌ Error: {response.content}")

# ==================== TEST 5: Product Filtering ====================
print("\n\n🔍 TEST 5: Product List with Filters")
print("-" * 60)
response = client.get('/api/products/?category=tech&ordering=-score')
print(f"Endpoint: GET /api/products/?category=tech&ordering=-score")
print(f"Status Code: {response.status_code}")

if response.status_code == 200:
    data = response.json()
    print(f"✅ Found {len(data.get('results', []))} tech products:")
    for product in data.get('results', []):
        print(f"  - {product['name']} (Score: {product['score']})")
else:
    print(f"❌ Error: {response.content}")

# ==================== TEST 6: Import Products ====================
print("\n\n📥 TEST 6: Import Products Endpoint")
print("-" * 60)
import_data = {
    "url": "https://example.aliexpress.com/item/12345"
}
response = client.post('/api/products/import/', import_data, format='json')
print(f"Endpoint: POST /api/products/import/")
print(f"Status Code: {response.status_code}")
print(f"Response: {response.json()}")

# ==================== TEST 7: Product Detail with View Tracking ====================
print("\n\n👁️ TEST 7: Product Detail (with view tracking)")
print("-" * 60)
product_id = test_products[0].id
response = client.get(f'/api/products/{product_id}/')
print(f"Endpoint: GET /api/products/{product_id}/")
print(f"Status Code: {response.status_code}")

if response.status_code == 200:
    data = response.json()
    print(f"✅ Product: {data['name']}")
    print(f"   Score: {data['score']}")
    print(f"   Performance Metrics: {json.dumps(data['performance_metrics'], indent=2)}")
else:
    print(f"❌ Error: {response.content}")

print("\n" + "="*60)
print("✅ ALL TESTS COMPLETED")
print("="*60)
