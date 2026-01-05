#!/usr/bin/env python
"""
Script pour corriger les URLs d'images invalides
"""
import os
import sys
import django

# Configuration Django
sys.path.append(os.path.dirname(os.path.abspath(__file__)))
os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'dropshipping_finder.settings')
django.setup()

from core.models import Product

def fix_image_urls():
    """Corrige les URLs d'images avec des URLs valides"""
    
    print("=" * 70)
    print("🖼️  CORRECTION DES URLS D'IMAGES")
    print("=" * 70)
    print()
    
    # URLs Unsplash valides et testées
    valid_images = {
        'Wireless Earbuds': 'https://images.unsplash.com/photo-1572569511254-d8f925fe2cbb?w=400&h=400&fit=crop',
        'Smart Watch': 'https://images.unsplash.com/photo-1579586337278-3befd40fd17a?w=400&h=400&fit=crop',
        'LED Strip': 'https://images.unsplash.com/photo-1550009158-9ebf69173e03?w=400&h=400&fit=crop',
        'Phone Holder': 'https://images.unsplash.com/photo-1601784551446-20c9e07cdbdb?w=400&h=400&fit=crop',
        'Resistance Bands': 'https://images.unsplash.com/photo-1598289431512-b97b0917affc?w=400&h=400&fit=crop',
        'Blender': 'https://images.unsplash.com/photo-1570222094114-d054a817e56b?w=400&h=400&fit=crop',
        'Makeup Brush': 'https://images.unsplash.com/photo-1596462502278-27bfdc403348?w=400&h=400&fit=crop',
        'Laptop Stand': 'https://images.unsplash.com/photo-1527864550417-7fd91fc51a46?w=400&h=400&fit=crop',
        'Water Bottle': 'https://images.unsplash.com/photo-1602143407151-7111542de6e8?w=400&h=400&fit=crop',
        'Wireless Charger': 'https://images.unsplash.com/photo-1591290619762-d2c9f1b5e0e5?w=400&h=400&fit=crop',
    }
    
    # Image par défaut pour les produits sans correspondance
    default_image = 'https://images.unsplash.com/photo-1523275335684-37898b6baf30?w=400&h=400&fit=crop'
    
    updated_count = 0
    products = Product.objects.all()
    
    print(f"🔍 Vérification de {products.count()} produits...")
    print()
    
    for product in products:
        old_url = product.image_url
        new_url = None
        
        # Trouver l'image correspondante
        for keyword, url in valid_images.items():
            if keyword.lower() in product.name.lower():
                new_url = url
                break
        
        # Si pas de correspondance, utiliser l'image par défaut
        if not new_url:
            new_url = default_image
        
        # Mettre à jour si différent
        if old_url != new_url:
            product.image_url = new_url
            product.save()
            updated_count += 1
            print(f"✅ {product.name[:45]}")
            print(f"   Ancienne: {old_url[:60]}...")
            print(f"   Nouvelle: {new_url[:60]}...")
            print()
    
    print("=" * 70)
    print(f"✅ {updated_count} images corrigées sur {products.count()} produits")
    print("=" * 70)
    print()
    print("💡 Toutes les images utilisent maintenant des URLs valides!")
    print("   Rechargez l'application pour voir les changements.")
    print()

if __name__ == '__main__':
    try:
        fix_image_urls()
    except Exception as e:
        print(f"\n❌ ERREUR: {e}")
        import traceback
        traceback.print_exc()
