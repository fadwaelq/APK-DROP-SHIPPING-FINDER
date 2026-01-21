#!/usr/bin/env python
"""
Setup test data for API testing via Swagger
Creates test users, products with scores, and test data for endpoints
"""
import os
import django
from decimal import Decimal

os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'dropshipping_finder.settings')
django.setup()

from django.contrib.auth.models import User
from core.models import UserProfile, Product

def create_test_data():
    """Create comprehensive test data"""
    
    print("🔧 Setting up test data...")
    
    # 1. Create test users
    print("\n✅ Creating test users...")
    test_user, created = User.objects.get_or_create(
        username='testuser',
        defaults={
            'email': 'testuser@test.com',
            'first_name': 'Test',
            'last_name': 'User'
        }
    )
    if created:
        test_user.set_password('testpass123')
        test_user.save()
        print(f"   Created user: {test_user.username}")
    else:
        print(f"   User already exists: {test_user.username}")
    
    # Ensure profile exists
    profile, _ = UserProfile.objects.get_or_create(
        user=test_user,
        defaults={'subscription_plan': 'pro'}
    )
    
    # 2. Create test products with realistic scoring data
    print("\n✅ Creating test products...")
    
    products_data = [
        {
            'name': 'Smart Watch Pro Elite',
            'description': 'Advanced smartwatch with health monitoring and GPS',
            'price': Decimal('29.99'),
            'cost': Decimal('8.50'),
            'profit': Decimal('21.49'),
            'source': 'aliexpress',
            'source_url': 'https://aliexpress.com/product/1',
            'source_id': 'prod_001',
            'category': 'tech',
            'image_url': 'https://via.placeholder.com/300?text=SmartWatch',
            'supplier_name': 'Tech Innovations Ltd',
            'supplier_rating': Decimal('4.8'),
            'supplier_review_count': 1250,
            'score': 85,
            'demand_level': 90,
            'popularity': 88,
            'competition': 75,
            'profitability': 82,
            'trend_percentage': Decimal('15.5'),
            'is_trending': True,
        },
        {
            'name': 'Wireless Earbuds HD',
            'description': 'Premium wireless earbuds with noise cancellation',
            'price': Decimal('18.50'),
            'cost': Decimal('5.00'),
            'profit': Decimal('13.50'),
            'source': 'aliexpress',
            'source_url': 'https://aliexpress.com/product/2',
            'source_id': 'prod_002',
            'category': 'tech',
            'image_url': 'https://via.placeholder.com/300?text=Earbuds',
            'supplier_name': 'Audio Masters',
            'supplier_rating': Decimal('4.6'),
            'supplier_review_count': 890,
            'score': 78,
            'demand_level': 82,
            'popularity': 80,
            'competition': 60,
            'profitability': 73,
            'trend_percentage': Decimal('12.3'),
            'is_trending': True,
        },
        {
            'name': 'Yoga Mat Premium',
            'description': 'Non-slip yoga mat for fitness enthusiasts',
            'price': Decimal('12.99'),
            'cost': Decimal('3.50'),
            'profit': Decimal('9.49'),
            'source': 'aliexpress',
            'source_url': 'https://aliexpress.com/product/3',
            'source_id': 'prod_003',
            'category': 'sport',
            'image_url': 'https://via.placeholder.com/300?text=YogaMat',
            'supplier_name': 'Fitness Gear Co',
            'supplier_rating': Decimal('4.5'),
            'supplier_review_count': 645,
            'score': 72,
            'demand_level': 75,
            'popularity': 70,
            'competition': 55,
            'profitability': 73,
            'trend_percentage': Decimal('8.2'),
            'is_trending': False,
        },
        {
            'name': 'LED Desk Lamp',
            'description': 'Modern LED desk lamp with adjustable brightness',
            'price': Decimal('22.50'),
            'cost': Decimal('6.75'),
            'profit': Decimal('15.75'),
            'source': 'aliexpress',
            'source_url': 'https://aliexpress.com/product/4',
            'source_id': 'prod_004',
            'category': 'home',
            'image_url': 'https://via.placeholder.com/300?text=DeskLamp',
            'supplier_name': 'Home Solutions Inc',
            'supplier_rating': Decimal('4.7'),
            'supplier_review_count': 520,
            'score': 80,
            'demand_level': 85,
            'popularity': 78,
            'competition': 70,
            'profitability': 80,
            'trend_percentage': Decimal('10.1'),
            'is_trending': True,
        },
        {
            'name': 'Makeup Brush Set',
            'description': 'Professional makeup brush set with storage',
            'price': Decimal('14.99'),
            'cost': Decimal('4.20'),
            'profit': Decimal('10.79'),
            'source': 'aliexpress',
            'source_url': 'https://aliexpress.com/product/5',
            'source_id': 'prod_005',
            'category': 'beauty',
            'image_url': 'https://via.placeholder.com/300?text=BrushSet',
            'supplier_name': 'Beauty Essentials',
            'supplier_rating': Decimal('4.4'),
            'supplier_review_count': 1100,
            'score': 76,
            'demand_level': 80,
            'popularity': 75,
            'competition': 65,
            'profitability': 72,
            'trend_percentage': Decimal('9.7'),
            'is_trending': True,
        },
        {
            'name': 'Phone Stand Adjustable',
            'description': 'Universal phone stand for desk and table',
            'price': Decimal('8.99'),
            'cost': Decimal('2.00'),
            'profit': Decimal('6.99'),
            'source': 'aliexpress',
            'source_url': 'https://aliexpress.com/product/6',
            'source_id': 'prod_006',
            'category': 'tech',
            'image_url': 'https://via.placeholder.com/300?text=PhoneStand',
            'supplier_name': 'Tech Accessories Plus',
            'supplier_rating': Decimal('4.3'),
            'supplier_review_count': 750,
            'score': 65,
            'demand_level': 70,
            'popularity': 62,
            'competition': 45,
            'profitability': 65,
            'trend_percentage': Decimal('5.2'),
            'is_trending': False,
        },
    ]
    
    created_count = 0
    for prod_data in products_data:
        product, created = Product.objects.get_or_create(
            source_id=prod_data['source_id'],
            defaults=prod_data
        )
        if created:
            print(f"   ✓ Created: {product.name} (Score: {product.score})")
            created_count += 1
        else:
            print(f"   → Already exists: {product.name}")
    
    print(f"\n📊 Created {created_count} new products")
    
    # 3. Summary
    print("\n" + "="*60)
    print("✅ TEST DATA SETUP COMPLETE")
    print("="*60)
    print(f"\n📝 Test Credentials:")
    print(f"   Username: testuser")
    print(f"   Password: testpass123")
    print(f"   Email: testuser@test.com")
    print(f"\n📦 Total Products: {Product.objects.count()}")
    print(f"   Trending: {Product.objects.filter(is_trending=True).count()}")
    print(f"   Average Score: {sum(p.score for p in Product.objects.all()) / max(1, Product.objects.count()):.1f}")
    print(f"\n🌐 API Endpoints to test:")
    print(f"   POST   /api/auth/login/              (Login)")
    print(f"   POST   /api/auth/register/           (Register)")
    print(f"   GET    /api/products/                (List Products)")
    print(f"   GET    /api/products/<id>/           (Get Product)")
    print(f"   GET    /api/products/<id>/analyze/   (AI Scoring & Analysis)")
    print(f"   GET    /api/products/category_trends/?category=<cat>")
    print(f"   GET    /api/products/trending/       (Trending Products)")
    print(f"   GET    /api/products/top_rated/      (Top Rated Products)")
    print(f"\n🔗 Access Swagger UI at: http://localhost:8000/swagger/")
    print("="*60)

if __name__ == '__main__':
    create_test_data()
