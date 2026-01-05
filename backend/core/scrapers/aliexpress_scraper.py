"""
AliExpress product scraper
Uses mock data for demonstration (real scraping requires API key or advanced scraping)
"""
import random
from typing import List, Dict
from .base_scraper import BaseScraper


class AliExpressScraper(BaseScraper):
    """Scraper for AliExpress products"""
    
    def __init__(self):
        super().__init__()
        self.source_name = "aliexpress"
        self.categories = [
            'electronics', 'fashion', 'home', 'beauty', 
            'sports', 'toys', 'jewelry', 'automotive'
        ]
    
    def scrape(self) -> List[Dict]:
        """
        Scrape trending products from AliExpress
        
        NOTE: This is a mock implementation for demonstration.
        Real implementation would use:
        - AliExpress API (requires API key)
        - Selenium for dynamic scraping
        - Proxy rotation for rate limiting
        """
        self.products = self._generate_mock_products()
        self.log_scraping_stats()
        return self.products
    
    def _generate_mock_products(self) -> List[Dict]:
        """Generate mock product data for demonstration"""
        
        mock_products = [
            {
                'name': 'Wireless Earbuds Bluetooth 5.3 TWS',
                'description': 'High quality wireless earbuds with noise cancellation, 30H playtime, IPX7 waterproof',
                'price': 12.99,
                'original_price': 39.99,
                'currency': 'USD',
                'image_url': 'https://via.placeholder.com/400x400?text=Earbuds',
                'product_url': 'https://aliexpress.com/item/123456',
                'category': 'electronics',
                'external_id': 'AE_123456',
                'rating': 4.7,
                'reviews_count': 2543,
                'orders_count': 8234,
                'shipping_cost': 0,
                'shipping_days': 12,
                'stock': 9999,
            },
            {
                'name': 'Smart Watch Fitness Tracker Heart Rate',
                'description': 'Smartwatch with heart rate monitor, sleep tracking, 7 days battery, waterproof',
                'price': 24.99,
                'original_price': 79.99,
                'currency': 'USD',
                'image_url': 'https://via.placeholder.com/400x400?text=Smartwatch',
                'product_url': 'https://aliexpress.com/item/234567',
                'category': 'electronics',
                'external_id': 'AE_234567',
                'rating': 4.5,
                'reviews_count': 1876,
                'orders_count': 6543,
                'shipping_cost': 0,
                'shipping_days': 15,
                'stock': 5432,
            },
            {
                'name': 'LED Strip Lights RGB 10M Smart WiFi',
                'description': 'Smart LED strip lights with app control, music sync, 16 million colors',
                'price': 15.99,
                'original_price': 49.99,
                'currency': 'USD',
                'image_url': 'https://via.placeholder.com/400x400?text=LED+Strip',
                'product_url': 'https://aliexpress.com/item/345678',
                'category': 'home',
                'external_id': 'AE_345678',
                'rating': 4.8,
                'reviews_count': 3421,
                'orders_count': 12456,
                'shipping_cost': 0,
                'shipping_days': 10,
                'stock': 8765,
            },
            {
                'name': 'Phone Holder Car Mount Magnetic 360°',
                'description': 'Universal magnetic car phone holder, 360° rotation, strong magnet, easy installation',
                'price': 5.99,
                'original_price': 19.99,
                'currency': 'USD',
                'image_url': 'https://via.placeholder.com/400x400?text=Phone+Holder',
                'product_url': 'https://aliexpress.com/item/456789',
                'category': 'automotive',
                'external_id': 'AE_456789',
                'rating': 4.6,
                'reviews_count': 987,
                'orders_count': 4321,
                'shipping_cost': 0,
                'shipping_days': 18,
                'stock': 6543,
            },
            {
                'name': 'Resistance Bands Set 11PCS Workout',
                'description': 'Complete resistance bands set for home workout, includes 5 bands, handles, ankle straps',
                'price': 18.99,
                'original_price': 59.99,
                'currency': 'USD',
                'image_url': 'https://via.placeholder.com/400x400?text=Resistance+Bands',
                'product_url': 'https://aliexpress.com/item/567890',
                'category': 'sports',
                'external_id': 'AE_567890',
                'rating': 4.7,
                'reviews_count': 1543,
                'orders_count': 5678,
                'shipping_cost': 0,
                'shipping_days': 14,
                'stock': 4321,
            },
            {
                'name': 'Portable Blender USB Rechargeable',
                'description': 'Mini blender for smoothies, 380ml capacity, USB rechargeable, BPA free',
                'price': 16.99,
                'original_price': 44.99,
                'currency': 'USD',
                'image_url': 'https://via.placeholder.com/400x400?text=Blender',
                'product_url': 'https://aliexpress.com/item/678901',
                'category': 'home',
                'external_id': 'AE_678901',
                'rating': 4.4,
                'reviews_count': 876,
                'orders_count': 3456,
                'shipping_cost': 0,
                'shipping_days': 16,
                'stock': 3210,
            },
            {
                'name': 'Makeup Brush Set 20PCS Professional',
                'description': 'Professional makeup brush set, soft bristles, includes case, perfect for beginners',
                'price': 14.99,
                'original_price': 49.99,
                'currency': 'USD',
                'image_url': 'https://via.placeholder.com/400x400?text=Makeup+Brushes',
                'product_url': 'https://aliexpress.com/item/789012',
                'category': 'beauty',
                'external_id': 'AE_789012',
                'rating': 4.6,
                'reviews_count': 1234,
                'orders_count': 4567,
                'shipping_cost': 0,
                'shipping_days': 13,
                'stock': 5678,
            },
            {
                'name': 'Laptop Stand Adjustable Aluminum',
                'description': 'Ergonomic laptop stand, adjustable height, aluminum alloy, fits 10-17 inch laptops',
                'price': 19.99,
                'original_price': 59.99,
                'currency': 'USD',
                'image_url': 'https://via.placeholder.com/400x400?text=Laptop+Stand',
                'product_url': 'https://aliexpress.com/item/890123',
                'category': 'electronics',
                'external_id': 'AE_890123',
                'rating': 4.8,
                'reviews_count': 2109,
                'orders_count': 7890,
                'shipping_cost': 0,
                'shipping_days': 11,
                'stock': 4567,
            },
            {
                'name': 'Water Bottle 1L Motivational Time Marker',
                'description': 'BPA free water bottle with time markers, leak proof, motivational quotes, 1 liter',
                'price': 9.99,
                'original_price': 29.99,
                'currency': 'USD',
                'image_url': 'https://via.placeholder.com/400x400?text=Water+Bottle',
                'product_url': 'https://aliexpress.com/item/901234',
                'category': 'sports',
                'external_id': 'AE_901234',
                'rating': 4.5,
                'reviews_count': 765,
                'orders_count': 3210,
                'shipping_cost': 0,
                'shipping_days': 17,
                'stock': 6789,
            },
            {
                'name': 'Wireless Charger 15W Fast Charging Pad',
                'description': 'Fast wireless charger, 15W output, compatible with iPhone and Samsung, LED indicator',
                'price': 11.99,
                'original_price': 34.99,
                'currency': 'USD',
                'image_url': 'https://via.placeholder.com/400x400?text=Wireless+Charger',
                'product_url': 'https://aliexpress.com/item/012345',
                'category': 'electronics',
                'external_id': 'AE_012345',
                'rating': 4.7,
                'reviews_count': 1654,
                'orders_count': 5432,
                'shipping_cost': 0,
                'shipping_days': 12,
                'stock': 7654,
            },
        ]
        
        # Normalize and calculate scores
        normalized_products = []
        for product in mock_products:
            normalized = self.normalize_product(product)
            normalized['score'] = self.calculate_score(normalized)
            normalized_products.append(normalized)
        
        return normalized_products
    
    def scrape_category(self, category: str) -> List[Dict]:
        """Scrape products from specific category"""
        all_products = self.scrape()
        return [p for p in all_products if p.get('category') == category]
