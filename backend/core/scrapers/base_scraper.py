"""
Base scraper class for all product scrapers
"""
from abc import ABC, abstractmethod
from typing import List, Dict
import logging

logger = logging.getLogger(__name__)


class BaseScraper(ABC):
    """Base class for all product scrapers"""
    
    def __init__(self):
        self.source_name = "unknown"
        self.products = []
    
    @abstractmethod
    def scrape(self) -> List[Dict]:
        """
        Scrape products from source
        Returns list of product dictionaries
        """
        pass
    
    def normalize_product(self, raw_product: Dict) -> Dict:
        """
        Normalize product data to standard format
        """
        return {
            'name': raw_product.get('name', ''),
            'description': raw_product.get('description', ''),
            'price': float(raw_product.get('price', 0)),
            'original_price': float(raw_product.get('original_price', 0)),
            'currency': raw_product.get('currency', 'USD'),
            'image_url': raw_product.get('image_url', ''),
            'product_url': raw_product.get('product_url', ''),
            'category': raw_product.get('category', 'general'),
            'supplier': self.source_name,
            'external_id': raw_product.get('external_id', ''),
            'rating': float(raw_product.get('rating', 0)),
            'reviews_count': int(raw_product.get('reviews_count', 0)),
            'orders_count': int(raw_product.get('orders_count', 0)),
            'shipping_cost': float(raw_product.get('shipping_cost', 0)),
            'shipping_days': int(raw_product.get('shipping_days', 0)),
            'stock': int(raw_product.get('stock', 0)),
        }
    
    def calculate_score(self, product: Dict) -> int:
        """
        Calculate profitability score (0-100)
        """
        score = 0
        
        # Price and margin (30 points)
        if product['price'] > 0:
            selling_price = product['price'] * 2.5  # 150% markup
            profit_margin = (selling_price - product['price']) / product['price']
            if profit_margin >= 1.5:
                score += 30
            elif profit_margin >= 1.0:
                score += 20
            elif profit_margin >= 0.5:
                score += 10
        
        # Orders/Sales (25 points)
        orders = product.get('orders_count', 0)
        if orders >= 5000:
            score += 25
        elif orders >= 1000:
            score += 20
        elif orders >= 500:
            score += 15
        elif orders >= 100:
            score += 10
        
        # Rating (20 points)
        rating = product.get('rating', 0)
        score += int((rating / 5.0) * 20)
        
        # Reviews (15 points)
        reviews = product.get('reviews_count', 0)
        if reviews >= 1000:
            score += 15
        elif reviews >= 500:
            score += 12
        elif reviews >= 100:
            score += 8
        elif reviews >= 50:
            score += 5
        
        # Shipping (10 points)
        shipping_days = product.get('shipping_days', 30)
        if shipping_days <= 7:
            score += 10
        elif shipping_days <= 14:
            score += 7
        elif shipping_days <= 21:
            score += 4
        
        return min(100, score)
    
    def log_scraping_stats(self):
        """Log scraping statistics"""
        logger.info(f"Scraped {len(self.products)} products from {self.source_name}")
