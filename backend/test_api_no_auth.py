#!/usr/bin/env python
"""Test API without authentication"""

import requests

BASE_URL = 'http://localhost:8000/api'

print("=" * 60)
print("🧪 Testing API WITHOUT Authentication")
print("=" * 60)

# Test trending products without auth
print("\n📊 Testing /api/products/trending/ (NO AUTH)")
try:
    response = requests.get(f'{BASE_URL}/products/trending/')
    print(f"Status: {response.status_code}")
    
    if response.status_code == 200:
        data = response.json()
        print(f"✅ SUCCESS! Found {len(data)} trending products")
        print("\nProducts:")
        for i, product in enumerate(data[:5], 1):
            print(f"  {i}. {product.get('name', 'N/A')[:50]} - Score: {product.get('score', 0)}")
    else:
        print(f"❌ Error {response.status_code}")
        print(f"Response: {response.text[:200]}")
except Exception as e:
    print(f"❌ Error: {e}")

print("\n" + "=" * 60)
print("✅ Test Complete")
print("=" * 60)
