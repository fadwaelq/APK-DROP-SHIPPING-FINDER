#!/usr/bin/env python
"""
🚀 ALIEXPRESS SCRAPER TO CSV - MOCK DATA VERSION
==================================================

Generates realistic mock AliExpress products and exports to CSV file
Perfect for testing, development, and demonstration purposes.

Features:
✅ Generates realistic mock products
✅ Exports to CSV format
✅ Excel-compatible
✅ No network requests needed
✅ Fast processing
✅ Customizable quantity

Usage:
    python scrape_to_csv_mock.py --query "smartwatch" --count 50
    python scrape_to_csv_mock.py --query "wireless earbuds" --count 100 --output products.csv
"""

import csv
import logging
import time
import random
from datetime import datetime
from typing import List, Dict
import argparse
from pathlib import Path

# ============================================
# LOGGING CONFIGURATION
# ============================================

logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(levelname)s - %(message)s',
    handlers=[
        logging.FileHandler('scrape_csv_mock.log'),
        logging.StreamHandler()
    ]
)
logger = logging.getLogger(__name__)

# ============================================
# MOCK DATA GENERATOR
# ============================================

class AliExpressCSVMockGenerator:
    """Generate realistic mock AliExpress data"""
    
    def __init__(self):
        self.product_templates = {
            'smartwatch': {
                'variants': [
                    'Smart Watch {brand} Fitness Tracker Blood Pressure',
                    '{brand} Smartwatch Sport Band Heart Rate Monitor',
                    'Waterproof {brand} Smart Watch Fitness',
                    '{brand} Digital Watch Android iOS Compatible',
                    'Bluetooth {brand} Smart Watch Pedometer',
                ],
                'brands': ['AMOLED', 'OLED', 'GPS', 'Ultra', 'Pro', 'Max', 'Elite'],
                'price_range': (15, 80),
            },
            'wireless earbuds': {
                'variants': [
                    '{brand} Wireless Earbuds Bluetooth 5.3 Headphones',
                    '{brand} TWS Earphones Noise Canceling Waterproof',
                    'Wireless {brand} Sport Earbuds With Charging Case',
                    '{brand} Bluetooth Earbuds Stereo Sound',
                    'Premium {brand} Earphones Wireless Charging',
                ],
                'brands': ['Pro', 'Max', 'Elite', 'Ultra', 'X', 'Air', 'Wave'],
                'price_range': (10, 60),
            },
            'phone case': {
                'variants': [
                    '{brand} Protective Phone Case {phone} Model',
                    'Transparent {brand} Phone Cover Anti-Shock',
                    '{brand} Leather Flip Case for {phone}',
                    'Silicone {brand} Phone Case Drop Protection',
                    '{brand} Premium Phone Case {phone}',
                ],
                'brands': ['Premium', 'Rugged', 'Luxury', 'Ultra-Thin', 'Armor'],
                'price_range': (3, 25),
            },
            'LED light': {
                'variants': [
                    '{brand} RGB LED Light Strip WiFi Smart',
                    'LED {brand} Lamp Dimmable Smart Home Control',
                    '{brand} LED String Lights Waterproof Outdoor',
                    'Smart {brand} LED Bulb Color Changing',
                    '{brand} LED Light Panel Gaming Setup',
                ],
                'brands': ['Smart', 'RGB', 'WiFi', 'Color', 'Pro'],
                'price_range': (5, 50),
            },
            'camera': {
                'variants': [
                    '{brand} Digital Camera {type} Video Recording',
                    'Compact {brand} Camera Portable {mp}MP Sensor',
                    '{brand} {type} Camera Professional Video',
                    '4K {brand} Action Camera Waterproof',
                    '{brand} Instant Camera Photo Printer',
                ],
                'brands': ['Digital', 'Pro', '4K', 'HD', 'UHD'],
                'price_range': (25, 200),
            },
        }
        
        self.category_map = {
            'smartwatch': 'Electronics',
            'wireless earbuds': 'Electronics',
            'phone case': 'Accessories',
            'LED light': 'Home & Garden',
            'camera': 'Electronics',
        }
    
    def generate_products(self, keyword: str, count: int = 50) -> List[Dict]:
        """Generate mock products"""
        logger.info(f"🔍 Generating {count} mock products for '{keyword}'...")
        
        products = []
        
        # Find matching template
        template = None
        for key, tmpl in self.product_templates.items():
            if key.lower() in keyword.lower() or keyword.lower() in key.lower():
                template = tmpl
                break
        
        if not template:
            # Use generic template
            template = {
                'variants': [f"{{brand}} {keyword} Product {{model}}"],
                'brands': ['Pro', 'Max', 'Elite', 'Ultra', 'X'],
                'price_range': (10, 100),
            }
        
        for i in range(count):
            variant = random.choice(template['variants'])
            brand = random.choice(template['brands'])
            
            # Generate product details
            title = variant.replace('{brand}', brand)
            title = title.replace('{phone}', random.choice(['iPhone 15', 'Samsung S24', 'Xiaomi 14']))
            title = title.replace('{model}', f"Model {random.choice(['A', 'B', 'C', 'D'])}{random.randint(1, 9)}00")
            title = title.replace('{type}', random.choice(['Digital', 'Professional', 'Compact', 'HD']))
            title = title.replace('{mp}', str(random.choice([12, 16, 20, 24, 48])))
            
            # Generate price
            price = round(random.uniform(template['price_range'][0], template['price_range'][1]), 2)
            original_price = round(price * random.uniform(1.2, 2.5), 2)
            savings = round(((original_price - price) / original_price * 100), 0)
            
            # Generate stats
            rating = round(random.uniform(3.5, 5.0), 1)
            reviews = random.randint(10, 5000)
            orders = random.randint(50, 50000)
            
            # Generate IDs and URLs
            product_id = f"100500{i:05d}"
            product_url = f"https://www.aliexpress.com/item/{product_id}.html"
            
            # Generate image URL (realistic AliExpress image CDN)
            image_id = f"g0-{random.randint(100000, 999999)}-L"
            image_url = f"https://ae01.alicdn.com/kf/{image_id}.jpg"
            
            # Calculate profit
            cost = price * 0.4  # Assume 40% cost of selling price
            profit_margin = round(((price - cost) / price * 100), 0)
            
            product = {
                'Product ID': product_id,
                'Title': title[:100],  # Limit title length
                'Price ($)': f"{price:.2f}",
                'Original Price ($)': f"{original_price:.2f}",
                'Savings (%)': int(savings),
                'Rating (★)': f"{rating:.1f}",
                'Reviews': reviews,
                'Orders': orders,
                'Category': self.category_map.get(keyword.lower(), 'Other'),
                'URL': product_url,
                'Image URL': image_url,
                'Search Keyword': keyword,
                'Scraped Date': datetime.now().strftime('%Y-%m-%d %H:%M:%S'),
                'Profit Margin (%)': int(profit_margin),
            }
            
            products.append(product)
            
            # Progress
            if (i + 1) % 10 == 0:
                logger.info(f"   Generated {i + 1}/{count}...")
        
        logger.info(f"✅ Generated {len(products)} products")
        return products
    
    def export_to_csv(self, products: List[Dict], filename: str = None) -> str:
        """Export products to CSV"""
        if not filename:
            timestamp = datetime.now().strftime('%Y%m%d_%H%M%S')
            filename = f"aliexpress_mock_{timestamp}.csv"
        
        logger.info(f"💾 Exporting {len(products)} products to {filename}...")
        
        try:
            filepath = Path(filename)
            filepath.parent.mkdir(parents=True, exist_ok=True)
            
            with open(filepath, 'w', newline='', encoding='utf-8-sig') as csvfile:
                if products:
                    fieldnames = products[0].keys()
                    writer = csv.DictWriter(csvfile, fieldnames=fieldnames)
                    
                    writer.writeheader()
                    writer.writerows(products)
                    
                    logger.info(f"✅ Successfully exported to {filepath}")
                    return str(filepath)
            
        except Exception as e:
            logger.error(f"❌ Export error: {e}")
            return None
    
    def print_stats(self, products: List[Dict]):
        """Print product statistics"""
        if not products:
            logger.warning("⚠️ No products to display stats")
            return
        
        logger.info("=" * 60)
        logger.info(f"📊 PRODUCTS SUMMARY (Total: {len(products)})")
        logger.info("=" * 60)
        
        # Price stats
        prices = [float(p['Price ($)']) for p in products]
        logger.info(f"💰 Price Range: ${min(prices):.2f} - ${max(prices):.2f}")
        logger.info(f"   Average: ${sum(prices) / len(prices):.2f}")
        
        # Rating stats
        ratings = [float(p['Rating (★)']) for p in products]
        logger.info(f"⭐ Rating Average: {sum(ratings) / len(ratings):.1f}/5.0")
        
        # Orders stats
        orders = [int(p['Orders']) for p in products]
        logger.info(f"📦 Orders Range: {min(orders):,} - {max(orders):,}")
        
        # Category distribution
        categories = {}
        for p in products:
            cat = p['Category']
            categories[cat] = categories.get(cat, 0) + 1
        
        logger.info(f"🏷️  Categories: {', '.join(f'{k}({v})' for k, v in categories.items())}")
        logger.info("=" * 60)


# ============================================
# MAIN EXECUTION
# ============================================

def main():
    parser = argparse.ArgumentParser(
        description='🚀 AliExpress CSV Scraper - Mock Data Version',
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog='''
Examples:
  python scrape_to_csv_mock.py --query "smartwatch" --count 50
  python scrape_to_csv_mock.py --query "wireless earbuds" --count 100 --output earbuds.csv
        '''
    )
    
    parser.add_argument('--query', '-q', default='smartwatch',
                        help='Product to search for (default: smartwatch)')
    parser.add_argument('--count', '-c', type=int, default=50,
                        help='Number of products to generate (default: 50)')
    parser.add_argument('--output', '-o', default=None,
                        help='Output CSV filename (auto-generated if not specified)')
    
    args = parser.parse_args()
    
    logger.info("=" * 60)
    logger.info("🚀 ALIEXPRESS CSV MOCK SCRAPER")
    logger.info("=" * 60)
    
    try:
        generator = AliExpressCSVMockGenerator()
        
        # Generate products
        products = generator.generate_products(args.query, args.count)
        
        if not products:
            logger.error("❌ Failed to generate products")
            return
        
        # Export to CSV
        output_file = generator.export_to_csv(products, args.output)
        
        if output_file:
            # Print stats
            generator.print_stats(products)
            logger.info(f"✅ CSV file ready: {output_file}")
            print(f"\n✅ SUCCESS! Products exported to: {output_file}\n")
        else:
            logger.error("❌ Failed to export CSV")
    
    except KeyboardInterrupt:
        logger.warning("\n⚠️ Interrupted by user")
    except Exception as e:
        logger.error(f"❌ Error: {e}")
        import traceback
        traceback.print_exc()


if __name__ == '__main__':
    main()
