import os
import sys
import django

# Setup Django
os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'backend.settings')
django.setup()

from api.models import Product

def check_trending():
    """Check trending products"""
    
    total = Product.objects.count()
    trending = Product.objects.filter(is_trending=True).count()
    
    print(f"📊 Total products: {total}")
    print(f"🔥 Trending products: {trending}")
    
    if trending == 0:
        print("\n⚠️  No products marked as trending!")
        print("   Setting top 10 products as trending...")
        
        top_products = Product.objects.order_by('-score')[:10]
        for product in top_products:
            product.is_trending = True
            product.save()
            print(f"   ✅ {product.name} - Score: {product.score}")
        
        print(f"\n✅ Marked {top_products.count()} products as trending")
    else:
        print("\n🔥 Trending products:")
        for product in Product.objects.filter(is_trending=True):
            print(f"   - {product.name} (Score: {product.score})")

if __name__ == '__main__':
    check_trending()
