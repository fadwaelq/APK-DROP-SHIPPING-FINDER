"""
Discovery Scraper for AliExpress - Working Version
Uses direct product link extraction from search results
"""

import logging
import requests
import re
import json
from typing import Dict, List, Optional, Set
import time
from urllib.parse import quote, urljoin
from bs4 import BeautifulSoup

logger = logging.getLogger(__name__)


class TorDiscoveryScraper:
    """
    Discovery scraper for AliExpress
    Extracts product links from search results
    """
    
    TRENDING_KEYWORDS = [
        'smartwatch', 'wireless earbuds', 'power bank', 'usb hub',
        'phone stand', 'led light', 'bluetooth speaker',
        'yoga mat', 'resistance band', 'storage box',
        'sunglasses', 'watch', 'wallet', 'phone case',
        'mini projector', 'drone', 'action camera',
    ]
    
    def __init__(self, use_tor=False, timeout=15):
        """Initialize scraper"""
        self.use_tor = use_tor
        self.timeout = timeout
        self.product_urls: Set[str] = set()
        self.session = self._setup_session()
        
    def _setup_session(self) -> requests.Session:
        """Setup requests session"""
        session = requests.Session()
        
        session.headers.update({
            'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36',
            'Accept': 'text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8',
            'Accept-Language': 'en-US,en;q=0.5',
            'Referer': 'https://www.aliexpress.com/',
        })
        
        if self.use_tor:
            try:
                proxies = {
                    'http': 'socks5://localhost:9050',
                    'https': 'socks5://localhost:9050'
                }
                session.proxies.update(proxies)
                logger.info("✅ Tor proxy enabled")
            except Exception as e:
                logger.warning(f"⚠️ Tor setup failed: {e}")
        
        return session
    
    def discover_by_keyword(self, keyword: str, pages: int = 1) -> List[str]:
        """Discover products by keyword"""
        product_urls = []
        
        for page in range(1, pages + 1):
            try:
                logger.info(f"🔍 Searching: {keyword} (page {page})")
                
                # Search URL
                search_url = f"https://www.aliexpress.com/wholesale?SearchText={quote(keyword)}"
                
                response = self.session.get(
                    search_url,
                    timeout=self.timeout,
                    verify=False,
                    allow_redirects=True
                )
                
                if response.status_code != 200:
                    logger.warning(f"⚠️ Status {response.status_code}")
                    continue
                
                # Parse with BeautifulSoup
                soup = BeautifulSoup(response.text, 'lxml')
                
                # Try multiple selectors for product links
                selectors = [
                    'a[href*="/item/"][href*=".html"]',
                    'a[class*="item"]',
                ]
                
                found_urls = []
                
                for selector in selectors:
                    links = soup.select(selector)
                    for link in links:
                        href = link.get('href', '')
                        
                        # Check if it's a valid product URL
                        if '/item/' in href and '.html' in href:
                            # Clean URL
                            if href.startswith('http'):
                                full_url = href
                            else:
                                full_url = urljoin('https://www.aliexpress.com', href)
                            
                            # Remove fragment and extra params
                            full_url = full_url.split('#')[0]
                            
                            if full_url not in found_urls:
                                found_urls.append(full_url)
                    
                    if found_urls:
                        break
                
                product_urls.extend(found_urls)
                logger.info(f"✅ Found {len(found_urls)} products for '{keyword}'")
                
                if not found_urls:
                    # Try alternative: extract from JSON data in page
                    try:
                        # Look for itemId in various JSON formats
                        json_pattern = r'"itemId":\s*"?(\d+)"?'
                        json_matches = re.findall(json_pattern, response.text)
                        
                        if json_matches:
                            for item_id in json_matches[:20]:
                                url = f"https://www.aliexpress.com/item/{item_id}.html"
                                if url not in product_urls:
                                    product_urls.append(url)
                            logger.info(f"✅ Found {len(json_matches)} products via JSON")
                    except:
                        pass
                
                time.sleep(2)
                
            except Exception as e:
                logger.error(f"❌ Error: {e}")
                continue
        
        return list(set(product_urls))
    
    def discover_trending(self, pages: int = 1) -> List[str]:
        """Discover trending products"""
        product_urls = []
        
        try:
            logger.info(f"📈 Fetching trending products")
            
            # Try multiple trending endpoints
            trending_urls = [
                "https://www.aliexpress.com/",  # Home page has trending
                "https://www.aliexpress.com/wholesale?SearchText=&SortType=default",
            ]
            
            for trend_url in trending_urls:
                try:
                    response = self.session.get(
                        trend_url,
                        timeout=self.timeout,
                        verify=False,
                        allow_redirects=True
                    )
                    
                    if response.status_code != 200:
                        continue
                    
                    soup = BeautifulSoup(response.text, 'lxml')
                    
                    # Extract product links
                    links = soup.select('a[href*="/item/"][href*=".html"]')
                    
                    for link in links:
                        href = link.get('href', '')
                        if '/item/' in href and '.html' in href:
                            if href.startswith('http'):
                                full_url = href
                            else:
                                full_url = urljoin('https://www.aliexpress.com', href)
                            
                            full_url = full_url.split('#')[0]
                            product_urls.append(full_url)
                    
                    if product_urls:
                        logger.info(f"✅ Found {len(product_urls)} trending products")
                        break
                
                except Exception as e:
                    logger.warning(f"⚠️ {trend_url}: {e}")
                    continue
            
            time.sleep(2)
            
        except Exception as e:
            logger.error(f"❌ Trending error: {e}")
        
        return list(set(product_urls))
    
    def discover_all(self, 
                    keywords: Optional[List[str]] = None,
                    pages: int = 1) -> List[str]:
        """Discover products from all sources"""
        all_urls = set()
        
        keywords = keywords or self.TRENDING_KEYWORDS[:5]
        
        logger.info(f"🔍 Discovering by {len(keywords)} keywords...")
        for keyword in keywords:
            try:
                urls = self.discover_by_keyword(keyword, pages=pages)
                all_urls.update(urls)
                logger.info(f"   ✅ {keyword}: {len(urls)} products")
            except Exception as e:
                logger.error(f"   ❌ {keyword}: {e}")
        
        logger.info("📈 Discovering trending products...")
        try:
            urls = self.discover_trending(pages=pages)
            all_urls.update(urls)
            logger.info(f"   ✅ Trending: {len(urls)} products")
        except Exception as e:
            logger.error(f"   ❌ Trending: {e}")
        
        logger.info(f"🎯 Total unique products: {len(all_urls)}")
        
        return list(all_urls)
    
    def close(self):
        """Close session"""
        if self.session:
            self.session.close()


def discover_products_sync(keywords: Optional[List[str]] = None, 
                          pages: int = 1,
                          use_tor: bool = False) -> Dict:
    """Synchronous wrapper for discovery"""
    try:
        scraper = TorDiscoveryScraper(use_tor=use_tor, timeout=15)
        discovered_urls = scraper.discover_all(keywords, pages)
        scraper.close()
        
        return {
            'status': 'success',
            'discovered_count': len(discovered_urls),
            'urls': discovered_urls,
            'error': None
        }
    
    except Exception as e:
        logger.error(f"Discovery failed: {e}")
        return {
            'status': 'error',
            'discovered_count': 0,
            'urls': [],
            'error': str(e)
        }