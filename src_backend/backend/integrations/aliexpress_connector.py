"""
AliExpress connector for product data collection
Uses web scraping with BeautifulSoup
"""
import requests
from bs4 import BeautifulSoup
from typing import List, Dict, Any
import time
import random
from .base_connector import BaseConnector


class AliExpressConnector(BaseConnector):
    """Connector for AliExpress product data"""
    
    BASE_URL = 'https://www.aliexpress.com'
    SEARCH_URL = 'https://www.aliexpress.com/wholesale'
    
    def __init__(self, use_tor=False):
        super().__init__()
        self.use_tor = use_tor
        self.session = requests.Session()
        
        # Set headers to mimic browser
        self.session.headers.update({
            'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36',
            'Accept': 'text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8',
            'Accept-Language': 'en-US,en;q=0.5',
            'Accept-Encoding': 'gzip, deflate, br',
            'Connection': 'keep-alive',
            'Upgrade-Insecure-Requests': '1',
        })
        
        # Configure Tor proxy if needed
        if use_tor:
            self.session.proxies = {
                'http': 'socks5h://localhost:9050',
                'https': 'socks5h://localhost:9050'
            }
    
    def get_platform_name(self) -> str:
        return 'aliexpress'
    
    def search_products(self, query: str, page: int = 1, max_results: int = 40) -> List[Dict[str, Any]]:
        """
        Search products on AliExpress
        
        Args:
            query: Search query
            page: Page number
            max_results: Maximum number of results to return
            
        Returns:
            List of product dictionaries
        """
        self.logger.info(f"Searching AliExpress for: {query} (page {page})")
        
        params = {
            'SearchText': query,
            'page': page,
            'SortType': 'total_tranpro_desc',  # Sort by orders
        }
        
        try:
            # Add random delay to avoid rate limiting
            time.sleep(random.uniform(1, 3))
            
            response = self.session.get(self.SEARCH_URL, params=params, timeout=30)
            response.raise_for_status()
            
            soup = BeautifulSoup(response.content, 'html.parser')
            products = []
            
            # Find product items (structure may vary)
            product_items = soup.select('.list--gallery--C2f2tvm .list--item--c7CjlNa')
            
            if not product_items:
                # Try alternative selectors
                product_items = soup.select('.product-item')
            
            self.logger.info(f"Found {len(product_items)} products")
            
            for item in product_items[:max_results]:
                try:
                    product = self._parse_product_item(item)
                    if product:
                        products.append(product)
                except Exception as e:
                    self.logger.error(f"Error parsing product item: {e}")
                    continue
            
            return products
            
        except Exception as e:
            self.logger.error(f"Error searching AliExpress: {e}")
            return []
    
    def _parse_product_item(self, item) -> Dict[str, Any]:
        """Parse a single product item from search results"""
        try:
            # Extract title
            title_elem = item.select_one('.multi--titleText--nXeOvyr')
            if not title_elem:
                title_elem = item.select_one('.product-title')
            title = title_elem.text.strip() if title_elem else ''
            
            # Extract price
            price_elem = item.select_one('.multi--price-sale--U-S0jtj')
            if not price_elem:
                price_elem = item.select_one('.product-price')
            price = self._parse_price(price_elem.text if price_elem else '0')
            
            # Extract image
            img_elem = item.select_one('img')
            image_url = img_elem.get('src', '') if img_elem else ''
            if image_url and not image_url.startswith('http'):
                image_url = 'https:' + image_url
            
            # Extract URL
            link_elem = item.select_one('a')
            product_url = link_elem.get('href', '') if link_elem else ''
            if product_url and not product_url.startswith('http'):
                product_url = self.BASE_URL + product_url
            
            # Extract orders/sales
            orders_elem = item.select_one('.multi--trade--Ktbl2jB')
            if not orders_elem:
                orders_elem = item.select_one('.product-orders')
            sales_volume = self._parse_number(orders_elem.text if orders_elem else '0')
            
            # Extract rating
            rating_elem = item.select_one('.multi--starRating--rBNUhxB')
            if not rating_elem:
                rating_elem = item.select_one('.product-rating')
            rating = float(rating_elem.text.strip()) if rating_elem else 0.0
            
            return {
                'title': title,
                'price': price,
                'image_url': image_url,
                'source_url': product_url,
                'sales_volume': sales_volume,
                'rating': rating,
                'source_platform': 'aliexpress',
            }
            
        except Exception as e:
            self.logger.error(f"Error parsing product item: {e}")
            return None
    
    def get_product_details(self, product_url: str) -> Dict[str, Any]:
        """
        Get detailed product information
        
        Args:
            product_url: Product page URL
            
        Returns:
            Detailed product dictionary
        """
        self.logger.info(f"Fetching product details: {product_url}")
        
        try:
            # Add random delay
            time.sleep(random.uniform(2, 4))
            
            response = self.session.get(product_url, timeout=30)
            response.raise_for_status()
            
            soup = BeautifulSoup(response.content, 'html.parser')
            
            # Extract detailed information
            details = {
                'title': self._extract_title(soup),
                'description': self._extract_description(soup),
                'price': self._extract_price(soup),
                'images': self._extract_images(soup),
                'sales_volume': self._extract_sales(soup),
                'rating': self._extract_rating(soup),
                'reviews_count': self._extract_reviews_count(soup),
                'shipping_info': self._extract_shipping(soup),
                'supplier': self._extract_supplier(soup),
                'source_url': product_url,
                'source_platform': 'aliexpress',
            }
            
            return details
            
        except Exception as e:
            self.logger.error(f"Error fetching product details: {e}")
            return {}
    
    def _extract_title(self, soup) -> str:
        """Extract product title"""
        title_elem = soup.select_one('.product-title-text')
        if not title_elem:
            title_elem = soup.select_one('h1')
        return title_elem.text.strip() if title_elem else ''
    
    def _extract_description(self, soup) -> str:
        """Extract product description"""
        desc_elem = soup.select_one('.product-description')
        if not desc_elem:
            desc_elem = soup.select_one('.description')
        return desc_elem.text.strip() if desc_elem else ''
    
    def _extract_price(self, soup) -> float:
        """Extract product price"""
        price_elem = soup.select_one('.product-price-value')
        if not price_elem:
            price_elem = soup.select_one('.price')
        return self._parse_price(price_elem.text if price_elem else '0')
    
    def _extract_images(self, soup) -> List[str]:
        """Extract product images"""
        images = []
        img_elems = soup.select('.images-view-item img')
        for img in img_elems:
            src = img.get('src', '')
            if src and not src.startswith('http'):
                src = 'https:' + src
            if src:
                images.append(src)
        return images
    
    def _extract_sales(self, soup) -> int:
        """Extract sales volume"""
        sales_elem = soup.select_one('.product-reviewer-sold')
        return self._parse_number(sales_elem.text if sales_elem else '0')
    
    def _extract_rating(self, soup) -> float:
        """Extract product rating"""
        rating_elem = soup.select_one('.overview-rating-average')
        if rating_elem:
            try:
                return float(rating_elem.text.strip())
            except:
                pass
        return 0.0
    
    def _extract_reviews_count(self, soup) -> int:
        """Extract number of reviews"""
        reviews_elem = soup.select_one('.product-reviewer-reviews')
        return self._parse_number(reviews_elem.text if reviews_elem else '0')
    
    def _extract_shipping(self, soup) -> str:
        """Extract shipping information"""
        shipping_elem = soup.select_one('.product-shipping')
        return shipping_elem.text.strip() if shipping_elem else ''
    
    def _extract_supplier(self, soup) -> Dict[str, str]:
        """Extract supplier information"""
        supplier_elem = soup.select_one('.shop-name')
        if supplier_elem:
            return {
                'name': supplier_elem.text.strip(),
                'url': supplier_elem.select_one('a').get('href', '') if supplier_elem.select_one('a') else ''
            }
        return {'name': '', 'url': ''}
