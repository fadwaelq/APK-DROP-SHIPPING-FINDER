import os
import sys
import django

# Setup Django
os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'backend.settings')
django.setup()

from api.models import Product

def fix_broken_image():
    """Fix the specific broken image URL"""
    
    broken_url = "https://images.unsplash.com/photo-1591290619762-d2c9f1b5e0e5"
    
    # Find products with this broken URL
    products = Product.objects.filter(image_url__contains="1591290619762-d2c9f1b5e0e5")
    
    print(f"🔍 Found {products.count()} products with broken image")
    
    # Valid replacement URL
    new_url = "https://images.unsplash.com/photo-1505740420928-5e560c06d30e?w=400&h=400&fit=crop"
    
    for product in products:
        print(f"\n📦 Product: {product.name}")
        print(f"   Old URL: {product.image_url}")
        product.image_url = new_url
        product.save()
        print(f"   ✅ New URL: {product.image_url}")
    
    print(f"\n✅ Fixed {products.count()} products")

if __name__ == '__main__':
    fix_broken_image()
