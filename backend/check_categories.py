#!/usr/bin/env python
"""Vérifier les catégories des produits"""

import os
import django

os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'dropshipping_finder.settings')
django.setup()

from core.models import Product

print("=" * 60)
print("📊 Catégories des Produits en Base de Données")
print("=" * 60)
print()

products = Product.objects.all().order_by('category', 'name')

current_category = None
for product in products:
    if product.category != current_category:
        current_category = product.category
        print(f"\n🏷️  Catégorie: {product.category}")
        print("-" * 60)
    
    print(f"   ✅ {product.name}")

print()
print("=" * 60)
print("📈 Résumé par Catégorie")
print("=" * 60)

from django.db.models import Count
categories = Product.objects.values('category').annotate(count=Count('id')).order_by('category')

for cat in categories:
    print(f"   {cat['category']:10} : {cat['count']} produits")

print()
print(f"📦 Total: {Product.objects.count()} produits")
print("=" * 60)
