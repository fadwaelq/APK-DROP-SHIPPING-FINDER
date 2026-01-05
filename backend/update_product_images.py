#!/usr/bin/env python
"""
Script pour mettre à jour les images des produits avec de vraies URLs
"""
import os
import sys
import django

# Configuration Django
sys.path.append(os.path.dirname(os.path.abspath(__file__)))
os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'dropshipping_finder.settings')
django.setup()

from core.models import Product

def update_product_images():
    """Met à jour les URLs des images des produits"""
    
    print("=" * 70)
    print("🖼️  MISE À JOUR DES IMAGES DES PRODUITS")
    print("=" * 70)
    print()
    
    # Mapping des produits avec de vraies images Unsplash
    image_mapping = {
        'Wireless Earbuds': 'https://images.unsplash.com/photo-1590658268037-6bf12165a8df?w=400&h=400&fit=crop',
        'Smart Watch': 'https://images.unsplash.com/photo-1523275335684-37898b6baf30?w=400&h=400&fit=crop',
        'LED Strip': 'https://images.unsplash.com/photo-1558618666-fcd25c85cd64?w=400&h=400&fit=crop',
        'Phone Holder': 'https://images.unsplash.com/photo-1519558260268-cde7e03a0152?w=400&h=400&fit=crop',
        'Resistance Bands': 'https://images.unsplash.com/photo-1598289431512-b97b0917affc?w=400&h=400&fit=crop',
        'Blender': 'https://images.unsplash.com/photo-1585515320310-259814833e62?w=400&h=400&fit=crop',
        'Makeup Brush': 'https://images.unsplash.com/photo-1512496015851-a90fb38ba796?w=400&h=400&fit=crop',
        'Laptop Stand': 'https://images.unsplash.com/photo-1527864550417-7fd91fc51a46?w=400&h=400&fit=crop',
        'Water Bottle': 'https://images.unsplash.com/photo-1602143407151-7111542de6e8?w=400&h=400&fit=crop',
        'Wireless Charger': 'https://images.unsplash.com/photo-1591290619762-c588f0e8e61a?w=400&h=400&fit=crop',
    }
    
    updated_count = 0
    
    products = Product.objects.all()
    
    for product in products:
        # Trouver l'image correspondante
        image_url = None
        for keyword, url in image_mapping.items():
            if keyword.lower() in product.name.lower():
                image_url = url
                break
        
        if image_url:
            product.image_url = image_url
            product.save()
            updated_count += 1
            print(f"✅ {product.name[:50]}")
            print(f"   Image: {image_url}")
        else:
            print(f"⚠️  {product.name[:50]} - Pas d'image trouvée")
    
    print()
    print("=" * 70)
    print(f"✅ {updated_count} images mises à jour sur {products.count()} produits")
    print("=" * 70)
    print()
    print("💡 Les produits ont maintenant de vraies images!")
    print("   Rechargez l'application pour voir les changements.")
    print()

if __name__ == '__main__':
    try:
        update_product_images()
    except Exception as e:
        print(f"\n❌ ERREUR: {e}")
        import traceback
        traceback.print_exc()
