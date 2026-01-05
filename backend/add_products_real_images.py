#!/usr/bin/env python
"""Ajouter des produits avec de vraies images (depuis Unsplash/Picsum)"""

import os
import django
from decimal import Decimal

os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'dropshipping_finder.settings')
django.setup()

from core.models import Product

# Supprimer les produits existants
Product.objects.all().delete()
print("🗑️  Produits existants supprimés\n")

# Créer des produits avec de vraies images
products_data = [
    # TECH (3 produits)
    {
        'name': 'Wireless Bluetooth Earbuds Pro',
        'description': 'Écouteurs sans fil haute qualité avec réduction de bruit active',
        'source': 'aliexpress',
        'source_id': 'tech001',
        'source_url': 'https://www.aliexpress.com/item/tech001.html',
        'category': 'tech',
        'price': Decimal('29.99'),
        'profit': Decimal('15.00'),
        'image_url': 'https://images.unsplash.com/photo-1590658268037-6bf12165a8df?w=400&h=400&fit=crop',
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
        'name': 'LED Strip Lights RGB 5M',
        'description': 'Bande LED RGB avec télécommande et contrôle via app',
        'source': 'aliexpress',
        'source_id': 'tech002',
        'source_url': 'https://www.aliexpress.com/item/tech002.html',
        'category': 'tech',
        'price': Decimal('15.99'),
        'profit': Decimal('8.00'),
        'image_url': 'https://images.unsplash.com/photo-1550985616-10810253b84d?w=400&h=400&fit=crop',
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
        'name': 'Wireless Phone Charger Fast 15W',
        'description': 'Chargeur sans fil rapide compatible tous smartphones',
        'source': 'aliexpress',
        'source_id': 'tech003',
        'source_url': 'https://www.aliexpress.com/item/tech003.html',
        'category': 'tech',
        'price': Decimal('18.99'),
        'profit': Decimal('9.50'),
        'image_url': 'https://images.unsplash.com/photo-1591290619762-d2c9f1b5e0e5?w=400&h=400&fit=crop',
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
    
    # SPORT (2 produits)
    {
        'name': 'Fitness Resistance Bands Set',
        'description': 'Set de 5 bandes de résistance pour musculation',
        'source': 'aliexpress',
        'source_id': 'sport001',
        'source_url': 'https://www.aliexpress.com/item/sport001.html',
        'category': 'sport',
        'price': Decimal('14.99'),
        'profit': Decimal('7.50'),
        'image_url': 'https://images.unsplash.com/photo-1598289431512-b97b0917affc?w=400&h=400&fit=crop',
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
    {
        'name': 'Smart Watch Fitness Tracker',
        'description': 'Montre connectée avec suivi santé et notifications',
        'source': 'aliexpress',
        'source_id': 'sport002',
        'source_url': 'https://www.aliexpress.com/item/sport002.html',
        'category': 'sport',
        'price': Decimal('45.50'),
        'profit': Decimal('22.00'),
        'image_url': 'https://images.unsplash.com/photo-1579586337278-3befd40fd17a?w=400&h=400&fit=crop',
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
    
    # MAISON (2 produits)
    {
        'name': 'Diffuseur Huiles Essentielles',
        'description': 'Diffuseur aromatique avec LED et minuteur',
        'source': 'aliexpress',
        'source_id': 'home001',
        'source_url': 'https://www.aliexpress.com/item/home001.html',
        'category': 'home',
        'price': Decimal('24.99'),
        'profit': Decimal('12.50'),
        'image_url': 'https://images.unsplash.com/photo-1608571423902-eed4a5ad8108?w=400&h=400&fit=crop',
        'supplier_name': 'HomeComfort Store',
        'supplier_rating': Decimal('4.6'),
        'supplier_review_count': 2345,
        'popularity': 75,
        'demand_level': 80,
        'competition': 55,
        'profitability': 68,
        'score': 74,
        'is_trending': False,
    },
    {
        'name': 'Organisateur Cuisine Mural',
        'description': 'Rangement mural multifonction pour cuisine',
        'source': 'aliexpress',
        'source_id': 'home002',
        'source_url': 'https://www.aliexpress.com/item/home002.html',
        'category': 'home',
        'price': Decimal('19.99'),
        'profit': Decimal('10.00'),
        'image_url': 'https://images.unsplash.com/photo-1556911220-bff31c812dba?w=400&h=400&fit=crop',
        'supplier_name': 'KitchenPro Store',
        'supplier_rating': Decimal('4.5'),
        'supplier_review_count': 1987,
        'popularity': 70,
        'demand_level': 75,
        'competition': 60,
        'profitability': 65,
        'score': 70,
        'is_trending': False,
    },
    
    # MODE (2 produits)
    {
        'name': 'Sac à Main Femme Élégant',
        'description': 'Sac à main cuir synthétique haute qualité',
        'source': 'aliexpress',
        'source_id': 'fashion001',
        'source_url': 'https://www.aliexpress.com/item/fashion001.html',
        'category': 'fashion',
        'price': Decimal('34.99'),
        'profit': Decimal('17.50'),
        'image_url': 'https://images.unsplash.com/photo-1548036328-c9fa89d128fa?w=400&h=400&fit=crop',
        'supplier_name': 'FashionStyle Store',
        'supplier_rating': Decimal('4.6'),
        'supplier_review_count': 2876,
        'popularity': 80,
        'demand_level': 83,
        'competition': 72,
        'profitability': 73,
        'score': 76,
        'is_trending': True,
    },
    {
        'name': 'Lunettes de Soleil Polarisées',
        'description': 'Lunettes UV400 protection style aviateur',
        'source': 'aliexpress',
        'source_id': 'fashion002',
        'source_url': 'https://www.aliexpress.com/item/fashion002.html',
        'category': 'fashion',
        'price': Decimal('12.99'),
        'profit': Decimal('6.50'),
        'image_url': 'https://images.unsplash.com/photo-1572635196237-14b3f281503f?w=400&h=400&fit=crop',
        'supplier_name': 'SunStyle Store',
        'supplier_rating': Decimal('4.4'),
        'supplier_review_count': 1654,
        'popularity': 72,
        'demand_level': 76,
        'competition': 65,
        'profitability': 67,
        'score': 71,
        'is_trending': False,
    },
    
    # BEAUTÉ (2 produits)
    {
        'name': 'Set Pinceaux Maquillage Pro',
        'description': '12 pinceaux professionnels avec étui',
        'source': 'aliexpress',
        'source_id': 'beauty001',
        'source_url': 'https://www.aliexpress.com/item/beauty001.html',
        'category': 'beauty',
        'price': Decimal('16.99'),
        'profit': Decimal('8.50'),
        'image_url': 'https://images.unsplash.com/photo-1512496015851-a90fb38ba796?w=400&h=400&fit=crop',
        'supplier_name': 'BeautyPro Store',
        'supplier_rating': Decimal('4.7'),
        'supplier_review_count': 3210,
        'popularity': 84,
        'demand_level': 87,
        'competition': 68,
        'profitability': 70,
        'score': 78,
        'is_trending': True,
    },
    {
        'name': 'Masque Visage LED Thérapie',
        'description': 'Masque LED anti-âge 7 couleurs',
        'source': 'aliexpress',
        'source_id': 'beauty002',
        'source_url': 'https://www.aliexpress.com/item/beauty002.html',
        'category': 'beauty',
        'price': Decimal('89.99'),
        'profit': Decimal('45.00'),
        'image_url': 'https://images.unsplash.com/photo-1596755389378-c31d21fd1273?w=400&h=400&fit=crop',
        'supplier_name': 'SkinCare Pro',
        'supplier_rating': Decimal('4.5'),
        'supplier_review_count': 1432,
        'popularity': 68,
        'demand_level': 72,
        'competition': 75,
        'profitability': 82,
        'score': 73,
        'is_trending': False,
    },
    
    # JOUETS (1 produit)
    {
        'name': 'Drone Caméra HD Débutant',
        'description': 'Mini drone avec caméra HD et contrôle facile',
        'source': 'aliexpress',
        'source_id': 'toys001',
        'source_url': 'https://www.aliexpress.com/item/toys001.html',
        'category': 'toys',
        'price': Decimal('59.99'),
        'profit': Decimal('30.00'),
        'image_url': 'https://images.unsplash.com/photo-1473968512647-3e447244af8f?w=400&h=400&fit=crop',
        'supplier_name': 'ToysTech Store',
        'supplier_rating': Decimal('4.6'),
        'supplier_review_count': 2134,
        'popularity': 76,
        'demand_level': 79,
        'competition': 70,
        'profitability': 78,
        'score': 75,
        'is_trending': True,
    },
    
    # SANTÉ (1 produit)
    {
        'name': 'Thermomètre Infrarouge Sans Contact',
        'description': 'Thermomètre médical précis et rapide',
        'source': 'aliexpress',
        'source_id': 'health001',
        'source_url': 'https://www.aliexpress.com/item/health001.html',
        'category': 'health',
        'price': Decimal('22.99'),
        'profit': Decimal('11.50'),
        'image_url': 'https://images.unsplash.com/photo-1584515933487-779824d29309?w=400&h=400&fit=crop',
        'supplier_name': 'HealthCare Store',
        'supplier_rating': Decimal('4.8'),
        'supplier_review_count': 4567,
        'popularity': 90,
        'demand_level': 93,
        'competition': 62,
        'profitability': 69,
        'score': 81,
        'is_trending': True,
    },
]

print("=" * 60)
print("🚀 Création de produits avec VRAIES IMAGES")
print("=" * 60)
print()

categories_count = {}

for product_data in products_data:
    product = Product.objects.create(**product_data)
    category = product_data['category']
    categories_count[category] = categories_count.get(category, 0) + 1
    print(f"✅ [{category.upper():7}] {product.name} (Score: {product.score})")
    print(f"   📸 Image: {product.image_url[:60]}...")

print()
print("=" * 60)
print("✅ Produits créés avec de vraies images!")
print("=" * 60)
print()
print("📊 Répartition par catégorie:")
for category, count in sorted(categories_count.items()):
    print(f"   {category.capitalize():10} : {count} produits")
print()
print(f"📦 Total: {Product.objects.count()} produits")
print(f"🔥 Tendance: {Product.objects.filter(is_trending=True).count()} produits")
print()
print("=" * 60)
print("🎉 Les images vont maintenant s'afficher!")
print("👉 Rechargez l'application: http://localhost:3000")
print("👉 Source images: Unsplash (haute qualité)")
print("=" * 60)
