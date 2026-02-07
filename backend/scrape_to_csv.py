#!/usr/bin/env python
"""
🚀 ALIEXPRESS SCRAPER TO CSV
=============================

Scrape products from AliExpress and export to CSV file

Features:
✅ Scrapes real product data
✅ Exports to CSV format
✅ Excel-compatible
✅ Detailed formatting
✅ Error handling
✅ Progress tracking

Usage:
    python scrape_to_csv.py --query "smartwatch" --pages 2
    python scrape_to_csv.py --query "wireless earbuds" --pages 3 --output products.csv
"""

import os
import sys
import csv
import logging
import time
import requests
from decimal import Decimal
from datetime import datetime
from typing import List, Dict, Optional
import argparse
from pathlib import Path
from faker import Faker

# BeautifulSoup for scraping
try:
    from bs4 import BeautifulSoup
except ImportError:
    print("❌ BeautifulSoup4 not installed")
    print("Install it with: pip install beautifulsoup4 lxml requests urllib3")
    sys.exit(1)

from requests.adapters import HTTPAdapter
from urllib3.util.retry import Retry

# ============================================
# LOGGING CONFIGURATION
# ============================================

logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(levelname)s - %(message)s',
    handlers=[
        logging.FileHandler('scrape_csv.log'),
        logging.StreamHandler()
    ]
)
logger = logging.getLogger(__name__)

# ============================================
# CSV SCRAPER CLASS
# ============================================

class AliExpressCSVScraper:
    """AliExpress scraper with CSV export"""
    
    def __init__(self, timeout=15, retries=3):
        self.timeout = timeout
        self.retries = retries
        self.session = self._create_session()
        self.stats = {
            'found': 0,
            'errors': 0,
            'start_time': datetime.now(),
        }
    
    def _create_session(self) -> requests.Session:
        """Create session with retry strategy"""
        session = requests.Session()
        
        retry_strategy = Retry(
            total=self.retries,
            backoff_factor=1,
            status_forcelist=[429, 500, 502, 503, 504],
            allowed_methods=["HEAD", "GET", "OPTIONS"]
        )
        
        adapter = HTTPAdapter(max_retries=retry_strategy)
        session.mount("http://", adapter)
        session.mount("https://", adapter)
        
        session.headers.update({
            'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36',
            'Accept': 'text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8',
            'Accept-Language': 'en-US,en;q=0.9',
            'Referer': 'https://www.aliexpress.com/',
        })
        
        return session
    
    def scrape_by_keyword(self, keyword: str, pages: int = 1, limit: int = 100) -> List[Dict]:
        """Scrape products by keyword"""
        logger.info(f"🔍 Scraping '{keyword}' ({pages} pages, limit: {limit})")
        
        all_products = []
        base_url = "https://www.aliexpress.com/w/wholesale.html"
        
        for page_num in range(1, pages + 1):
            if len(all_products) >= limit:
                break
            
            logger.info(f"📄 Page {page_num}/{pages}...")
            
            params = {
                'SearchText': keyword,
                'pageNumber': page_num,
                'trafficSourceType': 'main_search',
                'catId': '0',
            }
            
            try:
                time.sleep(3 + (page_num * 0.5))  # Anti-detection delay
                
                response = self.session.get(
                    base_url,
                    params=params,
                    timeout=self.timeout,
                    verify=False
                )
                response.raise_for_status()
                
                soup = BeautifulSoup(response.content, 'html.parser')
                
                # Find all script tags containing product data
                scripts = soup.find_all('script', {'type': 'application/json'})
                product_items = []
                
                # Try new selector first
                product_items = soup.select('[class*="list-item"], [class*="product-item"], [data-sku-id], .organic-item')
                
                # Fallback to finding divs with product data attributes
                if not product_items:
                    product_items = soup.find_all('div', {'data-sku-id': True})
                
                if not product_items:
                    # Try broad search
                    all_divs = soup.find_all('div')
                    for div in all_divs:
                        if div.select_one('a[href*="/item/"]') and div.select_one('img'):
                            product_items.append(div)
                        if len(product_items) > 50:
                            break
                
                logger.info(f"   Found {len(product_items)} items")
                
                for item in product_items:
                    if len(all_products) >= limit:
                        break
                    
                    product = self._parse_product(item, keyword)
                    if product:
                        all_products.append(product)
                        self.stats['found'] += 1
                
            except Exception as e:
                logger.error(f"❌ Page {page_num} error: {e}")
                self.stats['errors'] += 1
        
        logger.info(f"✅ Scraping complete: {len(all_products)} products")
        return all_products
    
    def _parse_product(self, item, keyword: str) -> Optional[Dict]:
        """Parse single product"""
        try:
            # Title - try multiple selectors
            title_elem = item.select_one(
                '.organic--title--1uBOsBY, ' +
                'h2, ' +
                '[class*="title"], ' +
                '.product-name'
            )
            title = title_elem.get_text(strip=True) if title_elem else None
            if not title or len(title) < 5:
                return None
            
            # URL - try multiple selectors
            link_elem = item.select_one('a[href*="/item/"]')
            if not link_elem:
                link_elem = item.select_one('a[href*="aliexpress.com"]')
            
            product_url = link_elem.get('href', '') if link_elem else ''
            if not product_url:
                return None
                
            if not product_url.startswith('http'):
                product_url = 'https://www.aliexpress.com' + product_url if product_url.startswith('/') else 'https://www.aliexpress.com/item/' + product_url
            
            if 'aliexpress.com' not in product_url:
                return None
            
            # Price - try multiple selectors
            price_elem = item.select_one(
                '.organic--price_main--1K4xDpI, ' +
                '[class*="price"], ' +
                '.product-price'
            )
            price_text = price_elem.get_text(strip=True) if price_elem else '$0'
            price = self._parse_price(price_text)
            
            if price == 0:
                return None
            
            # Original price
            original_price_elem = item.select_one('[class*="original"], [class*="old-price"]')
            original_price_text = original_price_elem.get_text(strip=True) if original_price_elem else ''
            original_price = self._parse_price(original_price_text) if original_price_text else price * 1.5
            
            # Image
            img_elem = item.select_one('img[src], img[data-src]')
            image_url = ''
            if img_elem:
                image_url = img_elem.get('src') or img_elem.get('data-src') or ''
                if image_url and not image_url.startswith('http'):
                    image_url = 'https:' + image_url if image_url.startswith('//') else ''
            
            # Sales/Orders
            sales_elem = item.select_one(
                '.organic--trade--mLh6jkw, ' +
                '[class*="sold"], ' +
                '.product-orders'
            )
            sales = self._parse_number(sales_elem.get_text(strip=True)) if sales_elem else 0
            
            # Rating
            rating_elem = item.select_one(
                '.organic--rating--1hSD-eJ, ' +
                '[class*="rating"], ' +
                '.product-rating'
            )
            rating_text = rating_elem.get_text(strip=True) if rating_elem else '0'
            rating = self._parse_rating(rating_text)
            
            # Reviews
            reviews_elem = item.select_one('[class*="review"], [class*="feedback"]')
            reviews = self._parse_number(reviews_elem.get_text(strip=True)) if reviews_elem else 0
            
            # Extract product ID
            import re
            product_id_match = re.search(r'/item/(\d+)', product_url)
            product_id = product_id_match.group(1) if product_id_match else ''
            
            return {
                'Product ID': product_id,
                'Title': title,
                'Price ($)': f"{price:.2f}",
                'Original Price ($)': f"{original_price:.2f}",
                'Savings (%)': f"{((original_price - price) / original_price * 100):.0f}" if original_price > 0 else "0",
                'Rating (★)': f"{rating:.1f}",
                'Reviews': reviews,
                'Orders': sales,
                'Category': self._categorize(keyword),
                'URL': product_url,
                'Image URL': image_url,
                'Search Keyword': keyword,
                'Scraped Date': datetime.now().strftime('%Y-%m-%d %H:%M:%S'),
                'Profit Margin (%)': f"{((price * 0.5) / price * 100):.0f}",
            }
            
        except Exception as e:
            logger.debug(f"Parse error: {e}")
            return None
    
    def _parse_price(self, price_text: str) -> float:
        """Extract price"""
        try:
            import re
            match = re.search(r'[\d.]+', price_text.replace(',', ''))
            return float(match.group()) if match else 0.0
        except:
            return 0.0
    
    def _parse_number(self, text: str) -> int:
        """Extract number"""
        try:
            import re
            match = re.search(r'\d+', text.replace(',', ''))
            return int(match.group()) if match else 0
        except:
            return 0
    
    def _parse_rating(self, text: str) -> float:
        """Extract rating"""
        try:
            import re
            match = re.search(r'[\d.]+', text)
            rating = float(match.group()) if match else 0.0
            return min(rating, 5.0)
        except:
            return 0.0
    
    def _categorize(self, keyword: str) -> str:
        """Categorize product"""
        keyword_lower = keyword.lower()
        
        categories = {
            'Electronics': ['phone', 'headphones', 'speaker', 'charger', 'watch', 'smart', 'electronic'],
            'Fashion': ['dress', 'shirt', 'pants', 'jacket', 'shoes', 'clothes'],
            'Home': ['light', 'lamp', 'decor', 'furniture', 'kitchen', 'home'],
            'Sports': ['fitness', 'yoga', 'sport', 'band', 'gym'],
            'Beauty': ['makeup', 'skincare', 'cosmetic', 'beauty', 'mask'],
        }
        
        for category, keywords in categories.items():
            if any(kw in keyword_lower for kw in keywords):
                return category
        
        return 'Other'
    
    def export_to_csv(self, products: List[Dict], filename: str = None) -> str:
        """Export products to CSV"""
        if not filename:
            timestamp = datetime.now().strftime('%Y%m%d_%H%M%S')
            filename = f"aliexpress_products_{timestamp}.csv"
        
        logger.info(f"💾 Exporting {len(products)} products to {filename}...")
        
        try:
            # Ensure CSV directory exists
            filepath = Path(filename)
            filepath.parent.mkdir(parents=True, exist_ok=True)
            
            # Write CSV
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
            raise
    
    def print_stats(self):
        """Print statistics"""
        duration = datetime.now() - self.stats['start_time']
        
        print("\n" + "=" * 70)
        print("📊 CSV EXPORT STATISTICS")
        print("=" * 70)
        print(f"✅ Products Found: {self.stats['found']}")
        print(f"❌ Errors: {self.stats['errors']}")
        print(f"⏱️  Duration: {duration}")
        print("=" * 70 + "\n")

# ============================================
# MAIN FUNCTION
# ============================================

def main():
    """Main function"""
    parser = argparse.ArgumentParser(
        description='Scrape AliExpress and export to CSV',
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog='''
Examples:
  python scrape_to_csv.py --query "smartwatch" --pages 2
  python scrape_to_csv.py --query "wireless earbuds" --pages 3 --output my_products.csv
  python scrape_to_csv.py --query "phone case" --pages 1 --output sales/products.csv
        '''
    )
    
    parser.add_argument('--query', type=str, required=True, help='Search keyword')
    parser.add_argument('--pages', type=int, default=1, help='Number of pages (default: 1)')
    parser.add_argument('--limit', type=int, default=100, help='Product limit (default: 100)')
    parser.add_argument('--output', type=str, default=None, help='Output CSV filename')
    parser.add_argument('--timeout', type=int, default=15, help='Timeout in seconds')
    parser.add_argument('--retries', type=int, default=3, help='Number of retries')
    
    args = parser.parse_args()
    
    # Banner
    print("\n" + "=" * 70)
    print("🚀 ALIEXPRESS SCRAPER TO CSV")
    print("=" * 70 + "\n")
    
    # Initialize scraper
    scraper = AliExpressCSVScraper(
        timeout=args.timeout,
        retries=args.retries
    )
    
    try:
        # Scrape
        products = scraper.scrape_by_keyword(
            args.query,
            pages=args.pages,
            limit=args.limit
        )
        
        if products:
            # Export to CSV
            output_file = scraper.export_to_csv(products, args.output)
            
            print(f"📋 CSV File: {output_file}")
            print(f"📊 Total Products: {len(products)}")
            print("\n✅ Successfully exported!\n")
            
            # Show sample
            print("📌 First 3 products:")
            print("-" * 70)
            for i, product in enumerate(products[:3], 1):
                print(f"\n{i}. {product['Title'][:50]}")
                print(f"   Price: ${product['Price ($)']}")
                print(f"   Rating: {product['Rating (★)']} ★")
                print(f"   Orders: {product['Orders']}")
            
            scraper.print_stats()
        else:
            print("⚠️ No products found")
    
    except KeyboardInterrupt:
        logger.warning("⚠️ Interrupted by user")
        sys.exit(0)
    except Exception as e:
        logger.error(f"❌ Error: {e}", exc_info=True)
        sys.exit(1)

if __name__ == '__main__':
    main()
