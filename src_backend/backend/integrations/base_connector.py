"""
Base connector class for all integrations
"""
from abc import ABC, abstractmethod
from typing import List, Dict, Any
import logging

logger = logging.getLogger(__name__)


class BaseConnector(ABC):
    """Base class for all external connectors"""
    
    def __init__(self):
        self.session = None
        self.logger = logger
    
    @abstractmethod
    def search_products(self, query: str, **kwargs) -> List[Dict[str, Any]]:
        """Search products by query"""
        pass
    
    @abstractmethod
    def get_product_details(self, product_id: str) -> Dict[str, Any]:
        """Get detailed product information"""
        pass
    
    def normalize_product(self, raw_data: Dict[str, Any]) -> Dict[str, Any]:
        """Normalize product data to standard format"""
        return {
            'title': raw_data.get('title', ''),
            'description': raw_data.get('description', ''),
            'price': self._parse_price(raw_data.get('price', 0)),
            'image_url': raw_data.get('image_url', ''),
            'source_url': raw_data.get('source_url', ''),
            'source_platform': self.get_platform_name(),
            'sales_volume': raw_data.get('sales_volume', 0),
            'rating': raw_data.get('rating', 0.0),
            'reviews_count': raw_data.get('reviews_count', 0),
            'category': raw_data.get('category', ''),
            'supplier_name': raw_data.get('supplier_name', ''),
            'supplier_url': raw_data.get('supplier_url', ''),
            'shipping_cost': raw_data.get('shipping_cost', 0),
            'shipping_time': raw_data.get('shipping_time', ''),
        }
    
    @abstractmethod
    def get_platform_name(self) -> str:
        """Return platform name"""
        pass
    
    def _parse_price(self, price_text) -> float:
        """Parse price from various formats"""
        if isinstance(price_text, (int, float)):
            return float(price_text)
        
        import re
        # Remove currency symbols and extract number
        price_str = str(price_text).replace(',', '').replace('$', '').replace('€', '').strip()
        match = re.search(r'[\d.]+', price_str)
        return float(match.group()) if match else 0.0
    
    def _parse_number(self, text) -> int:
        """Parse number from text (e.g., '1,234 sold' -> 1234)"""
        if isinstance(text, int):
            return text
        
        import re
        text = str(text).replace(',', '').replace('.', '')
        match = re.search(r'\d+', text)
        return int(match.group()) if match else 0
