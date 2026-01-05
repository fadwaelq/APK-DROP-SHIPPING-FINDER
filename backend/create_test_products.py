#!/usr/bin/env python
"""Script to create test products for the Dropshipping Finder app"""

import os
import django
import random
from decimal import Decimal

# Setup Django
os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'dropshipping_finder.settings')
django.setup()

from core.models import Product

def create_test_products():
    """Create test products with realistic data"""
    
    test_products = [
        {
            'name': 'Wireless Bluetooth Earbuds Pro',
            'description': 'High-quality wireless earbuds with noise cancellation and 24h battery life',
            'price': Decimal('29.99'),
            'profit': Decimal('15.00'),
            'image_url': 'https://via.placeholder.com/300x300.png?text=Earbuds',
            'source_url': 'https://www.aliexpress.com/item/example1.html',
            'source': 'aliexpress',
            'source_id': 'example1',
            'category': 'tech',
            'supplier_name': 'TechGear Store',
            'supplier_rating': Decimal('4.7'),
            'supplier_review_count': 3421,
            'popularity': 85,
            'demand_level': 90,
            'competition': 65,
            'profitability': 80,
            'is_trending': True,
        },
        {
            'title': 'Smart Watch Fitness Tracker',
            'description': 'Waterproof smartwatch with heart rate monitor and GPS tracking',
            'price': Decimal('45.50'),
            'image_url': 'https://via.placeholder.com/300x300.png?text=SmartWatch',
            'source_url': 'https://www.aliexpress.com/item/example2.html',
            'source_platform': 'aliexpress',
            'category': 'Wearables',
            'sales_volume': 8932,
            'rating': Decimal('4.5'),
            'reviews_count': 1876,
            'supplier_name': 'WatchPro Official',
        },
        {
            'title': 'LED Strip Lights RGB 5M',
            'description': 'Color changing LED lights with remote control and music sync',
            'price': Decimal('15.99'),
            'image_url': 'https://via.placeholder.com/300x300.png?text=LED+Lights',
            'source_url': 'https://www.aliexpress.com/item/example3.html',
            'source_platform': 'aliexpress',
            'category': 'Home & Garden',
            'sales_volume': 25678,
            'rating': Decimal('4.8'),
            'reviews_count': 5432,
            'supplier_name': 'LightMaster Store',
        },
        {
            'title': 'Phone Camera Lens Kit 3-in-1',
            'description': 'Professional phone camera lenses: wide angle, macro, and fisheye',
            'price': Decimal('12.99'),
            'image_url': 'https://via.placeholder.com/300x300.png?text=Camera+Lens',
            'source_url': 'https://www.aliexpress.com/item/example4.html',
            'source_platform': 'aliexpress',
            'category': 'Phone Accessories',
            'sales_volume': 12456,
            'rating': Decimal('4.6'),
            'reviews_count': 2987,
            'supplier_name': 'PhotoPro Shop',
        },
        {
            'title': 'Portable Mini Projector HD',
            'description': 'Compact HD projector for home cinema, supports 1080p',
            'price': Decimal('89.99'),
            'image_url': 'https://via.placeholder.com/300x300.png?text=Projector',
            'source_url': 'https://www.aliexpress.com/item/example5.html',
            'source_platform': 'aliexpress',
            'category': 'Electronics',
            'sales_volume': 5678,
            'rating': Decimal('4.4'),
            'reviews_count': 1234,
            'supplier_name': 'CinemaHome Store',
        },
        {
            'title': 'Wireless Phone Charger Fast Charging',
            'description': '15W fast wireless charger compatible with all Qi devices',
            'price': Decimal('18.99'),
            'image_url': 'https://via.placeholder.com/300x300.png?text=Wireless+Charger',
            'source_url': 'https://www.aliexpress.com/item/example6.html',
            'source_platform': 'aliexpress',
            'category': 'Phone Accessories',
            'sales_volume': 18765,
            'rating': Decimal('4.7'),
            'reviews_count': 4321,
            'supplier_name': 'ChargeTech Official',
        },
        {
            'title': 'Bluetooth Speaker Waterproof',
            'description': 'Portable waterproof speaker with 12h battery and bass boost',
            'price': Decimal('25.99'),
            'image_url': 'https://via.placeholder.com/300x300.png?text=Speaker',
            'source_url': 'https://www.aliexpress.com/item/example7.html',
            'source_platform': 'aliexpress',
            'category': 'Audio',
            'sales_volume': 9876,
            'rating': Decimal('4.6'),
            'reviews_count': 2345,
            'supplier_name': 'SoundWave Store',
        },
        {
            'title': 'Gaming Mouse RGB Wireless',
            'description': 'Professional gaming mouse with 7 programmable buttons and RGB lighting',
            'price': Decimal('32.50'),
            'image_url': 'https://via.placeholder.com/300x300.png?text=Gaming+Mouse',
            'source_url': 'https://www.aliexpress.com/item/example8.html',
            'source_platform': 'aliexpress',
            'category': 'Gaming',
            'sales_volume': 7654,
            'rating': Decimal('4.8'),
            'reviews_count': 1987,
            'supplier_name': 'GamePro Official',
        },
        {
            'title': 'Car Phone Holder Magnetic',
            'description': 'Strong magnetic car mount for dashboard or windshield',
            'price': Decimal('8.99'),
            'image_url': 'https://via.placeholder.com/300x300.png?text=Car+Holder',
            'source_url': 'https://www.aliexpress.com/item/example9.html',
            'source_platform': 'aliexpress',
            'category': 'Car Accessories',
            'sales_volume': 23456,
            'rating': Decimal('4.5'),
            'reviews_count': 5678,
            'supplier_name': 'AutoTech Store',
        },
        {
            'title': 'Fitness Resistance Bands Set',
            'description': '5-piece resistance band set for home workout and yoga',
            'price': Decimal('14.99'),
            'image_url': 'https://via.placeholder.com/300x300.png?text=Resistance+Bands',
            'source_url': 'https://www.aliexpress.com/item/example10.html',
            'source_platform': 'aliexpress',
            'category': 'Sports & Fitness',
            'sales_volume': 11234,
            'rating': Decimal('4.7'),
            'reviews_count': 3456,
            'supplier_name': 'FitLife Official',
        },
    ]
    
    print("=" * 60)
    print("🚀 Creating test products...")
    print("=" * 60)
    
    created_count = 0
    updated_count = 0
    
    for product_data in test_products:
        product, created = Product.objects.update_or_create(
            source_url=product_data['source_url'],
            defaults=product_data
        )
        
        if created:
            created_count += 1
            print(f"✅ Created: {product.title}")
        else:
            updated_count += 1
            print(f"🔄 Updated: {product.title}")
        
        # Calculate AI score
        product.calculate_ai_score()
        product.save()
    
    print("\n" + "=" * 60)
    print("✅ Test products created successfully!")
    print("=" * 60)
    print(f"✅ Products created: {created_count}")
    print(f"🔄 Products updated: {updated_count}")
    print(f"📊 Total products: {Product.objects.count()}")
    print("=" * 60)
    print("\n🎉 You can now see products in the app!")
    print("👉 Refresh the app: http://localhost:3000")
    print("👉 Admin panel: http://localhost:8000/admin/core/product/")
    print("=" * 60)

if __name__ == '__main__':
    create_test_products()
