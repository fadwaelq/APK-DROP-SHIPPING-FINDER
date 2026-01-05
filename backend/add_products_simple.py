#!/usr/bin/env python
"""Simple script to add test products"""

import os
import django
from decimal import Decimal

os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'dropshipping_finder.settings')
django.setup()

from core.models import Product

# Delete existing products
Product.objects.all().delete()
print("🗑️  Cleared existing products")

# Create 10 test products
products_data = [
    {
        'name': 'Wireless Bluetooth Earbuds Pro',
        'description': 'High-quality wireless earbuds with noise cancellation',
        'source': 'aliexpress',
        'source_id': 'prod001',
        'source_url': 'https://www.aliexpress.com/item/1.html',
        'category': 'tech',
        'price': Decimal('29.99'),
        'profit': Decimal('15.00'),
        'image_url': 'https://via.placeholder.com/300x300.png?text=Earbuds',
        'supplier_name': 'TechGear Store',
        'supplier_rating': Decimal('4.7'),
        'supplier_review_count': 3421,
        'popularity': 85,
        'demand_level': 90,
        'competition': 65,
        'profitability': 80,
        'score': 85,
        'is_trending': True,
    },
    {
        'name': 'Smart Watch Fitness Tracker',
        'description': 'Waterproof smartwatch with heart rate monitor',
        'source': 'aliexpress',
        'source_id': 'prod002',
        'source_url': 'https://www.aliexpress.com/item/2.html',
        'category': 'sport',
        'price': Decimal('45.50'),
        'profit': Decimal('22.00'),
        'image_url': 'https://via.placeholder.com/300x300.png?text=SmartWatch',
        'supplier_name': 'WatchPro Official',
        'supplier_rating': Decimal('4.5'),
        'supplier_review_count': 1876,
        'popularity': 78,
        'demand_level': 85,
        'competition': 70,
        'profitability': 75,
        'score': 77,
        'is_trending': True,
    },
    {
        'name': 'LED Strip Lights RGB 5M',
        'description': 'Color changing LED lights with remote control',
        'source': 'aliexpress',
        'source_id': 'prod003',
        'source_url': 'https://www.aliexpress.com/item/3.html',
        'category': 'home',
        'price': Decimal('15.99'),
        'profit': Decimal('8.00'),
        'image_url': 'https://via.placeholder.com/300x300.png?text=LED+Lights',
        'supplier_name': 'LightMaster Store',
        'supplier_rating': Decimal('4.8'),
        'supplier_review_count': 5432,
        'popularity': 92,
        'demand_level': 95,
        'competition': 60,
        'profitability': 70,
        'score': 88,
        'is_trending': True,
    },
    {
        'name': 'Phone Camera Lens Kit 3-in-1',
        'description': 'Professional phone camera lenses set',
        'source': 'aliexpress',
        'source_id': 'prod004',
        'source_url': 'https://www.aliexpress.com/item/4.html',
        'category': 'tech',
        'price': Decimal('12.99'),
        'profit': Decimal('6.50'),
        'image_url': 'https://via.placeholder.com/300x300.png?text=Camera+Lens',
        'supplier_name': 'PhotoPro Shop',
        'supplier_rating': Decimal('4.6'),
        'supplier_review_count': 2987,
        'popularity': 72,
        'demand_level': 75,
        'competition': 55,
        'profitability': 68,
        'score': 70,
        'is_trending': False,
    },
    {
        'name': 'Portable Mini Projector HD',
        'description': 'Compact HD projector for home cinema',
        'source': 'aliexpress',
        'source_id': 'prod005',
        'source_url': 'https://www.aliexpress.com/item/5.html',
        'category': 'tech',
        'price': Decimal('89.99'),
        'profit': Decimal('45.00'),
        'image_url': 'https://via.placeholder.com/300x300.png?text=Projector',
        'supplier_name': 'CinemaHome Store',
        'supplier_rating': Decimal('4.4'),
        'supplier_review_count': 1234,
        'popularity': 65,
        'demand_level': 70,
        'competition': 75,
        'profitability': 85,
        'score': 73,
        'is_trending': False,
    },
    {
        'name': 'Wireless Phone Charger Fast',
        'description': '15W fast wireless charger Qi compatible',
        'source': 'aliexpress',
        'source_id': 'prod006',
        'source_url': 'https://www.aliexpress.com/item/6.html',
        'category': 'tech',
        'price': Decimal('18.99'),
        'profit': Decimal('9.50'),
        'image_url': 'https://via.placeholder.com/300x300.png?text=Wireless+Charger',
        'supplier_name': 'ChargeTech Official',
        'supplier_rating': Decimal('4.7'),
        'supplier_review_count': 4321,
        'popularity': 88,
        'demand_level': 92,
        'competition': 68,
        'profitability': 72,
        'score': 82,
        'is_trending': True,
    },
    {
        'name': 'Bluetooth Speaker Waterproof',
        'description': 'Portable waterproof speaker 12h battery',
        'source': 'aliexpress',
        'source_id': 'prod007',
        'source_url': 'https://www.aliexpress.com/item/7.html',
        'category': 'tech',
        'price': Decimal('25.99'),
        'profit': Decimal('13.00'),
        'image_url': 'https://via.placeholder.com/300x300.png?text=Speaker',
        'supplier_name': 'SoundWave Store',
        'supplier_rating': Decimal('4.6'),
        'supplier_review_count': 2345,
        'popularity': 80,
        'demand_level': 83,
        'competition': 62,
        'profitability': 76,
        'score': 78,
        'is_trending': True,
    },
    {
        'name': 'Gaming Mouse RGB Wireless',
        'description': 'Professional gaming mouse 7 buttons',
        'source': 'aliexpress',
        'source_id': 'prod008',
        'source_url': 'https://www.aliexpress.com/item/8.html',
        'category': 'tech',
        'price': Decimal('32.50'),
        'profit': Decimal('16.00'),
        'image_url': 'https://via.placeholder.com/300x300.png?text=Gaming+Mouse',
        'supplier_name': 'GamePro Official',
        'supplier_rating': Decimal('4.8'),
        'supplier_review_count': 1987,
        'popularity': 75,
        'demand_level': 78,
        'competition': 72,
        'profitability': 74,
        'score': 75,
        'is_trending': False,
    },
    {
        'name': 'Car Phone Holder Magnetic',
        'description': 'Strong magnetic car mount dashboard',
        'source': 'aliexpress',
        'source_id': 'prod009',
        'source_url': 'https://www.aliexpress.com/item/9.html',
        'category': 'tech',
        'price': Decimal('8.99'),
        'profit': Decimal('4.50'),
        'image_url': 'https://via.placeholder.com/300x300.png?text=Car+Holder',
        'supplier_name': 'AutoTech Store',
        'supplier_rating': Decimal('4.5'),
        'supplier_review_count': 5678,
        'popularity': 90,
        'demand_level': 88,
        'competition': 58,
        'profitability': 65,
        'score': 80,
        'is_trending': True,
    },
    {
        'name': 'Fitness Resistance Bands Set',
        'description': '5-piece resistance band set for workout',
        'source': 'aliexpress',
        'source_id': 'prod010',
        'source_url': 'https://www.aliexpress.com/item/10.html',
        'category': 'sport',
        'price': Decimal('14.99'),
        'profit': Decimal('7.50'),
        'image_url': 'https://via.placeholder.com/300x300.png?text=Resistance+Bands',
        'supplier_name': 'FitLife Official',
        'supplier_rating': Decimal('4.7'),
        'supplier_review_count': 3456,
        'popularity': 82,
        'demand_level': 86,
        'competition': 64,
        'profitability': 71,
        'score': 79,
        'is_trending': True,
    },
]

print("\n" + "=" * 60)
print("🚀 Creating test products...")
print("=" * 60 + "\n")

for product_data in products_data:
    product = Product.objects.create(**product_data)
    print(f"✅ Created: {product.name} (Score: {product.score})")

print("\n" + "=" * 60)
print("✅ Successfully created 10 test products!")
print("=" * 60)
print(f"📊 Total products in database: {Product.objects.count()}")
print(f"🔥 Trending products: {Product.objects.filter(is_trending=True).count()}")
print("=" * 60)
print("\n🎉 You can now see products in the app!")
print("👉 Refresh the app: http://localhost:3000")
print("👉 Admin panel: http://localhost:8000/admin/core/product/")
print("=" * 60 + "\n")
