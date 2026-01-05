#!/usr/bin/env python
"""Ajouter des produits dans différentes catégories pour tester les filtres"""

import os
import django
from decimal import Decimal

os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'dropshipping_finder.settings')
django.setup()

from core.models import Product

# Supprimer les produits existants
Product.objects.all().delete()
print("🗑️  Produits existants supprimés\n")

# Créer des produits dans TOUTES les catégories
products_data = [
    # TECH (3 produits)
    {
        'name': 'Wireless Bluetooth Earbuds Pro',
        'description': 'Écouteurs sans fil haute qualité',
        'source': 'aliexpress',
        'source_id': 'tech001',
        'source_url': 'https://www.aliexpress.com/item/tech001.html',
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
        'name': 'LED Strip Lights RGB 5M',
        'description': 'Bande LED RGB avec télécommande',
        'source': 'aliexpress',
        'source_id': 'tech002',
        'source_url': 'https://www.aliexpress.com/item/tech002.html',
        'category': 'tech',
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
        'name': 'Wireless Phone Charger Fast',
        'description': 'Chargeur sans fil rapide 15W',
        'source': 'aliexpress',
        'source_id': 'tech003',
        'source_url': 'https://www.aliexpress.com/item/tech003.html',
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
    
    # SPORT (2 produits)
    {
        'name': 'Fitness Resistance Bands Set',
        'description': 'Set de 5 bandes de résistance',
        'source': 'aliexpress',
        'source_id': 'sport001',
        'source_url': 'https://www.aliexpress.com/item/sport001.html',
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
    {
        'name': 'Smart Watch Fitness Tracker',
        'description': 'Montre connectée fitness',
        'source': 'aliexpress',
        'source_id': 'sport002',
        'source_url': 'https://www.aliexpress.com/item/sport002.html',
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
    
    # MAISON (2 produits)
    {
        'name': 'Diffuseur Huiles Essentielles',
        'description': 'Diffuseur aromatique LED',
        'source': 'aliexpress',
        'source_id': 'home001',
        'source_url': 'https://www.aliexpress.com/item/home001.html',
        'category': 'home',
        'price': Decimal('24.99'),
        'profit': Decimal('12.50'),
        'image_url': 'https://via.placeholder.com/300x300.png?text=Diffuseur',
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
        'description': 'Rangement mural multifonction',
        'source': 'aliexpress',
        'source_id': 'home002',
        'source_url': 'https://www.aliexpress.com/item/home002.html',
        'category': 'home',
        'price': Decimal('19.99'),
        'profit': Decimal('10.00'),
        'image_url': 'https://via.placeholder.com/300x300.png?text=Organisateur',
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
        'description': 'Sac à main cuir synthétique',
        'source': 'aliexpress',
        'source_id': 'fashion001',
        'source_url': 'https://www.aliexpress.com/item/fashion001.html',
        'category': 'fashion',
        'price': Decimal('34.99'),
        'profit': Decimal('17.50'),
        'image_url': 'https://via.placeholder.com/300x300.png?text=Sac+Main',
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
        'description': 'Lunettes UV400 protection',
        'source': 'aliexpress',
        'source_id': 'fashion002',
        'source_url': 'https://www.aliexpress.com/item/fashion002.html',
        'category': 'fashion',
        'price': Decimal('12.99'),
        'profit': Decimal('6.50'),
        'image_url': 'https://via.placeholder.com/300x300.png?text=Lunettes',
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
        'description': '12 pinceaux professionnels',
        'source': 'aliexpress',
        'source_id': 'beauty001',
        'source_url': 'https://www.aliexpress.com/item/beauty001.html',
        'category': 'beauty',
        'price': Decimal('16.99'),
        'profit': Decimal('8.50'),
        'image_url': 'https://via.placeholder.com/300x300.png?text=Pinceaux',
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
        'description': 'Masque LED anti-âge',
        'source': 'aliexpress',
        'source_id': 'beauty002',
        'source_url': 'https://www.aliexpress.com/item/beauty002.html',
        'category': 'beauty',
        'price': Decimal('89.99'),
        'profit': Decimal('45.00'),
        'image_url': 'https://via.placeholder.com/300x300.png?text=Masque+LED',
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
        'description': 'Mini drone avec caméra',
        'source': 'aliexpress',
        'source_id': 'toys001',
        'source_url': 'https://www.aliexpress.com/item/toys001.html',
        'category': 'toys',
        'price': Decimal('59.99'),
        'profit': Decimal('30.00'),
        'image_url': 'https://via.placeholder.com/300x300.png?text=Drone',
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
        'description': 'Thermomètre médical précis',
        'source': 'aliexpress',
        'source_id': 'health001',
        'source_url': 'https://www.aliexpress.com/item/health001.html',
        'category': 'health',
        'price': Decimal('22.99'),
        'profit': Decimal('11.50'),
        'image_url': 'https://via.placeholder.com/300x300.png?text=Thermometre',
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
print("🚀 Création de produits dans TOUTES les catégories")
print("=" * 60)
print()

categories_count = {}

for product_data in products_data:
    product = Product.objects.create(**product_data)
    category = product_data['category']
    categories_count[category] = categories_count.get(category, 0) + 1
    print(f"✅ [{category.upper():7}] {product.name} (Score: {product.score})")

print()
print("=" * 60)
print("✅ Produits créés avec succès!")
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
print("🎉 Les filtres de catégories vont maintenant fonctionner!")
print("👉 Rechargez l'application: http://localhost:3000")
print("👉 Testez les filtres: Tech, Sport, Maison, Mode, Beauté, Jouets, Santé")
print("=" * 60)
