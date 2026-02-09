#!/usr/bin/env python
"""
🚀 QUICK START SCRAPER
Simple version for immediate use
"""

import os
import sys
import django
from decimal import Decimal
from datetime import datetime

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'dropshipping_finder.settings')
django.setup()

from core.models import Product
from core.scrapers.aliexpress_scraper import AliExpressScraper

def quick_import():
    """Quick import of mock products"""
    
    print("\n" + "=" * 70)
    print("🚀 QUICK PRODUCT IMPORT")
    print("=" * 70 + "\n")
    
    print("📡 Initializing scraper...")
    scraper = AliExpressScraper()
    
    print("🔍 Scraping 10 mock products...")
    products = scraper.scrape()
    print(f"✅ Found {len(products)} products\n")
    
    created = 0
    updated = 0
    
    print("💾 Saving to database...")
    for product_data in products:
        try:
            existing = Product.objects.filter(
                source_url=product_data.get('product_url', '')
            ).first()
            
            product_dict = {
                'name': product_data['name'],
                'description': product_data.get('description', ''),
                'price': Decimal(str(product_data['price'])),
                'image_url': product_data.get('image_url', ''),
                'category': product_data.get('category', 'general'),
                'source': 'aliexpress',
                'source_id': product_data.get('external_id', ''),
                'supplier_rating': Decimal(str(product_data.get('rating', 0))),
                'supplier_review_count': product_data.get('reviews_count', 0),
                'cost': Decimal(str(product_data['price'])) * Decimal('0.3'),
                'profit': Decimal(str(product_data['price'])) * Decimal('0.7'),
                'last_scraped_at': datetime.now(),
            }
            
            if existing:
                for key, value in product_dict.items():
                    setattr(existing, key, value)
                existing.save()
                updated += 1
                print(f"  🔄 Updated: {product_data['name'][:45]}")
            else:
                Product.objects.create(
                    source_url=product_data.get('product_url', ''),
                    **product_dict
                )
                created += 1
                print(f"  ✅ Created: {product_data['name'][:45]}")
                
        except Exception as e:
            print(f"  ❌ Error: {str(e)[:50]}")
    
    print("\n" + "=" * 70)
    print("📊 IMPORT SUMMARY")
    print("=" * 70)
    print(f"✅ Created:  {created} products")
    print(f"🔄 Updated:  {updated} products")
    print(f"📦 Total:    {Product.objects.count()} products in database")
    print("=" * 70 + "\n")
    
    print("✨ Next steps:")
    print("   1. View in admin: http://localhost:8000/admin")
    print("   2. View frontend: http://localhost:3000")
    print("   3. For real scraping: python scrape_aliexpress_pro.py --query 'smartwatch'\n")

if __name__ == '__main__':
    try:
        quick_import()
    except Exception as e:
        print(f"\n❌ Error: {e}\n")
        import traceback
        traceback.print_exc()
        sys.exit(1)
