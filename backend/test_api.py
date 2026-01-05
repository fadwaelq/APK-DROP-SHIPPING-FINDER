#!/usr/bin/env python
"""Test API endpoints"""

import requests
import json

BASE_URL = 'http://localhost:8000/api'

print("=" * 60)
print("🧪 Testing API Endpoints")
print("=" * 60)

# Test 1: Products list
print("\n1️⃣ Testing /api/products/")
try:
    response = requests.get(f'{BASE_URL}/products/')
    print(f"Status: {response.status_code}")
    if response.status_code == 200:
        data = response.json()
        print(f"✅ Success! Found {len(data)} products")
        if data:
            print(f"First product: {data[0].get('name', 'N/A')}")
    elif response.status_code == 401:
        print("⚠️  Authentication required (expected)")
    else:
        print(f"❌ Error: {response.text[:200]}")
except Exception as e:
    print(f"❌ Error: {e}")

# Test 2: Trending products
print("\n2️⃣ Testing /api/products/trending/")
try:
    response = requests.get(f'{BASE_URL}/products/trending/')
    print(f"Status: {response.status_code}")
    if response.status_code == 200:
        data = response.json()
        print(f"✅ Success! Found {len(data)} trending products")
        for i, product in enumerate(data[:3], 1):
            print(f"  {i}. {product.get('name', 'N/A')} (Score: {product.get('score', 0)})")
    elif response.status_code == 401:
        print("⚠️  Authentication required")
    else:
        print(f"❌ Error: {response.text[:200]}")
except Exception as e:
    print(f"❌ Error: {e}")

# Test 3: Login
print("\n3️⃣ Testing /api/auth/login/")
try:
    response = requests.post(
        f'{BASE_URL}/auth/login/',
        json={'username': 'test@test.com', 'password': 'test123456'}
    )
    print(f"Status: {response.status_code}")
    if response.status_code == 200:
        data = response.json()
        token = data.get('token', '')
        print(f"✅ Login successful!")
        print(f"Token: {token[:50]}...")
        
        # Test 4: Trending with auth
        print("\n4️⃣ Testing /api/products/trending/ with auth")
        response = requests.get(
            f'{BASE_URL}/products/trending/',
            headers={'Authorization': f'Bearer {token}'}
        )
        print(f"Status: {response.status_code}")
        if response.status_code == 200:
            data = response.json()
            print(f"✅ Success! Found {len(data)} trending products")
            for i, product in enumerate(data[:5], 1):
                print(f"  {i}. {product.get('name', 'N/A')[:40]} - Score: {product.get('score', 0)}")
        else:
            print(f"❌ Error: {response.text[:200]}")
    else:
        print(f"❌ Login failed: {response.text[:200]}")
except Exception as e:
    print(f"❌ Error: {e}")

print("\n" + "=" * 60)
print("✅ API Test Complete")
print("=" * 60)
