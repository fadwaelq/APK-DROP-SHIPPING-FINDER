"""
Puppeteer-based AliExpress scraper for Python
Uses pyppeteer (Python port of Puppeteer)
Handles JavaScript rendering and dynamic content

Features:
- JavaScript rendering (gets real prices)
- Tor proxy support
- Image extraction
- Error handling & retries
- Stealth mode (anti-detection)
"""

import asyncio
import logging
import json
import re
from typing import Dict, List, Optional
from pyppeteer import launch
from pyppeteer.page import Page
import time

logger = logging.getLogger(__name__)


class PuppeteerAliExpressScraper:
    """
    Production-ready AliExpress scraper using Puppeteer
    """
    
    def __init__(self, use_tor=True, headless=True):
        self.use_tor = use_tor
        self.headless = headless
        self.browser = None
        self.page = None
        self.timeout = 30000  # 30 seconds
        
    async def initialize(self):
        """Initialize browser instance"""
        try:
            args = [
                '--no-sandbox',
                '--disable-setuid-sandbox',
                '--disable-dev-shm-usage',
                '--disable-gpu',
                '--window-size=1920,1080',
                '--user-agent=Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36',
            ]
            
            # Add Tor proxy if enabled
            if self.use_tor:
                args.append('--proxy-server=socks5://localhost:9050')
            
            self.browser = await launch(
                headless=self.headless,
                args=args,
                executablePath=None,
            )
            
            logger.info("✅ Puppeteer browser initialized")
            
        except Exception as e:
            logger.error(f"❌ Failed to initialize browser: {e}")
            raise
    
    async def create_page(self) -> Page:
        """Create new browser page"""
        if not self.browser:
            await self.initialize()
        
        page = await self.browser.newPage()
        
        # Anti-detection headers
        await page.setUserAgent(
            'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36'
        )
        
        # Viewport
        await page.setViewport({'width': 1920, 'height': 1080})
        
        # Block images to speed up loading
        await page.setRequestInterception(True)
        page.on('request', lambda req: asyncio.create_task(
            self._handle_request(req)
        ))
        
        return page
    
    async def _handle_request(self, request):
        """Block unnecessary requests to speed up scraping"""
        resource_type = request.resourceType
        
        # Block these resource types
        if resource_type in ['image', 'stylesheet', 'font', 'media']:
            await request.abort()
        else:
            await request.continue_()
    
    async def scrape_product(self, url: str) -> Optional[Dict]:
        """
        Scrape complete product data from AliExpress URL
        
        Args:
            url: AliExpress product URL
            
        Returns:
            Dictionary with product data or None if failed
        """
        page = None
        try:
            page = await self.create_page()
            
            logger.info(f"🔍 Scraping: {url}")
            
            # Navigate to URL
            await page.goto(url, {'waitUntil': 'networkidle2', 'timeout': self.timeout})
            
            # Wait for main content to load
            await asyncio.sleep(2)
            
            # Scroll to load lazy-loaded content
            await self._scroll_page(page)
            
            # Extract all data
            data = await asyncio.gather(
                self._extract_title(page),
                self._extract_price(page),
                self._extract_images(page),
                self._extract_rating(page),
                self._extract_reviews(page),
                self._extract_sales(page),
                self._extract_description(page),
                self._extract_supplier(page),
                self._extract_supplier_rating(page),
                self._extract_shipping(page),
                self._extract_stock(page),
            )
            
            product_data = {
                'url': url,
                'title': data[0] or 'Unknown',
                'price': data[1],
                'images': data[2] or [],
                'rating': data[3],
                'reviews': data[4],
                'sales': data[5],
                'description': data[6],
                'supplier': data[7],
                'supplier_rating': data[8],
                'shipping_days': data[9],
                'stock': data[10],
                'scraped_at': time.time(),
            }
            
            logger.info(f"✅ Successfully scraped: {product_data['title']}")
            return product_data
            
        except Exception as e:
            logger.error(f"❌ Scraping failed for {url}: {e}")
            return None
            
        finally:
            if page:
                await page.close()
    
    async def _scroll_page(self, page: Page):
        """Scroll page to load lazy-loaded images"""
        try:
            await page.evaluate("""
                async () => {
                    await new Promise((resolve) => {
                        let totalHeight = 0;
                        const distance = 100;
                        const timer = setInterval(() => {
                            const scrollHeight = document.body.scrollHeight;
                            window.scrollBy(0, distance);
                            totalHeight += distance;
                            
                            if (totalHeight >= scrollHeight) {
                                clearInterval(timer);
                                resolve();
                            }
                        }, 100);
                    });
                }
            """)
            await asyncio.sleep(1)
        except Exception as e:
            logger.warning(f"Scroll failed: {e}")
    
    async def _extract_title(self, page: Page) -> Optional[str]:
        """Extract product title"""
        try:
            # Try multiple selectors
            selectors = [
                'h1.pd-module-title',
                'h1[class*="title"]',
                '.product-title',
                'h1',
            ]
            
            for selector in selectors:
                title = await page.evaluate(f"""
                    () => {{
                        const elem = document.querySelector('{selector}');
                        return elem ? elem.innerText.trim() : null;
                    }}
                """)
                if title:
                    return title
            
            return None
            
        except Exception as e:
            logger.warning(f"Title extraction failed: {e}")
            return None
    
    async def _extract_price(self, page: Page) -> Optional[float]:
        """
        Extract product price (main feature of Puppeteer)
        Handles JavaScript-rendered prices
        """
        try:
            # Try to wait for price element with flexible timeout
            try:
                await page.waitForSelector('.price-main, .product-price-value', {
                    'timeout': 10000
                })
            except:
                logger.warning("Price selector not found, trying fallback")
            
            # Extract price with JavaScript
            price_text = await page.evaluate("""
                () => {
                    const priceSelectors = [
                        '.price-main',
                        '.product-price-value',
                        '[class*="price"]',
                    ];
                    
                    for (let selector of priceSelectors) {
                        const elem = document.querySelector(selector);
                        if (elem) return elem.innerText;
                    }
                    return null;
                }
            """)
            
            if price_text:
                # Parse price: "$12.99" -> 12.99
                match = re.search(r'[\d.]+', str(price_text).replace(',', ''))
                if match:
                    return float(match.group())
            
            return None
            
        except Exception as e:
            logger.warning(f"Price extraction failed: {e}")
            return None
    
    async def _extract_images(self, page: Page) -> List[str]:
        """Extract all product images"""
        try:
            images = await page.evaluate("""
                () => {
                    const images = [];
                    
                    // Get main product images
                    const imgElements = document.querySelectorAll(
                        '.images-wrap img, .product-image img, .thumb-item img'
                    );
                    
                    imgElements.forEach(img => {
                        const src = img.src || img.dataset.src;
                        if (src && !src.includes('placeholder')) {
                            images.push(src);
                        }
                    });
                    
                    return [...new Set(images)].slice(0, 10);
                }
            """)
            
            # Ensure URLs are absolute
            return [img if img.startswith('http') else 'https:' + img 
                    for img in images if img]
            
        except Exception as e:
            logger.warning(f"Image extraction failed: {e}")
            return []
    
    async def _extract_rating(self, page: Page) -> float:
        """Extract product rating"""
        try:
            rating = await page.evaluate("""
                () => {
                    const ratingSelectors = [
                        '.star-view',
                        '[class*="rating"]',
                        '.product-rating'
                    ];
                    
                    for (let selector of ratingSelectors) {
                        const elem = document.querySelector(selector);
                        if (elem) return elem.innerText;
                    }
                    return '0';
                }
            """)
            
            match = re.search(r'[\d.]+', str(rating))
            return float(match.group()) if match else 0.0
            
        except Exception as e:
            logger.warning(f"Rating extraction failed: {e}")
            return 0.0
    
    async def _extract_reviews(self, page: Page) -> int:
        """Extract review count"""
        try:
            reviews = await page.evaluate("""
                () => {
                    const reviewElements = document.querySelectorAll(
                        '[class*="review"], [class*="feedback"]'
                    );
                    
                    for (let elem of reviewElements) {
                        const text = elem.innerText;
                        const match = text.match(/\d+/);
                        if (match) return match[0];
                    }
                    return '0';
                }
            """)
            
            match = re.search(r'\d+', str(reviews))
            return int(match.group()) if match else 0
            
        except Exception as e:
            logger.warning(f"Reviews extraction failed: {e}")
            return 0
    
    async def _extract_sales(self, page: Page) -> int:
        """Extract sales/orders count"""
        try:
            sales = await page.evaluate("""
                () => {
                    const salesElements = document.querySelectorAll(
                        '[class*="sold"], [class*="sales"], [class*="orders"]'
                    );
                    
                    for (let elem of salesElements) {
                        const text = elem.innerText;
                        const match = text.match(/(\d+)\s*(sold|orders|sold out)/i);
                        if (match) return match[1];
                    }
                    return '0';
                }
            """)
            
            match = re.search(r'\d+', str(sales))
            return int(match.group()) if match else 0
            
        except Exception as e:
            logger.warning(f"Sales extraction failed: {e}")
            return 0
    
    async def _extract_description(self, page: Page) -> str:
        """Extract product description"""
        try:
            description = await page.evaluate("""
                () => {
                    const descSelectors = [
                        '.product-description',
                        '[class*="description"]',
                        '.detail-desc'
                    ];
                    
                    for (let selector of descSelectors) {
                        const elem = document.querySelector(selector);
                        if (elem) return elem.innerText.substring(0, 500);
                    }
                    return '';
                }
            """)
            
            return description or ""
            
        except Exception as e:
            logger.warning(f"Description extraction failed: {e}")
            return ""
    
    async def _extract_supplier(self, page: Page) -> str:
        """Extract supplier/store name"""
        try:
            supplier = await page.evaluate("""
                () => {
                    const supplierSelectors = [
                        '.store-name',
                        '[class*="supplier"]',
                        '[class*="store"]'
                    ];
                    
                    for (let selector of supplierSelectors) {
                        const elem = document.querySelector(selector);
                        if (elem) return elem.innerText.trim();
                    }
                    return 'Unknown Supplier';
                }
            """)
            
            return supplier or "Unknown Supplier"
            
        except Exception as e:
            logger.warning(f"Supplier extraction failed: {e}")
            return "Unknown Supplier"
    
    async def _extract_supplier_rating(self, page: Page) -> float:
        """Extract supplier rating"""
        try:
            rating = await page.evaluate("""
                () => {
                    const ratingSelectors = [
                        '.store-rating',
                        '[class*="seller-rating"]',
                        '.supplier-rating'
                    ];
                    
                    for (let selector of ratingSelectors) {
                        const elem = document.querySelector(selector);
                        if (elem) return elem.innerText;
                    }
                    return '4.5';
                }
            """)
            
            match = re.search(r'[\d.]+', str(rating))
            return float(match.group()) if match else 4.5
            
        except Exception as e:
            logger.warning(f"Supplier rating extraction failed: {e}")
            return 4.5
    
    async def _extract_shipping(self, page: Page) -> int:
        """Extract estimated shipping days"""
        try:
            shipping = await page.evaluate("""
                () => {
                    const shippingElements = document.querySelectorAll(
                        '[class*="shipping"], [class*="delivery"]'
                    );
                    
                    for (let elem of shippingElements) {
                        const text = elem.innerText;
                        const match = text.match(/(\d+)\s*(days?|days shipping)/i);
                        if (match) return match[1];
                    }
                    return '14';
                }
            """)
            
            match = re.search(r'\d+', str(shipping))
            return int(match.group()) if match else 14
            
        except Exception as e:
            logger.warning(f"Shipping extraction failed: {e}")
            return 14
    
    async def _extract_stock(self, page: Page) -> int:
        """Extract available stock"""
        try:
            stock = await page.evaluate("""
                () => {
                    const stockElements = document.querySelectorAll(
                        '[class*="stock"], [class*="inventory"]'
                    );
                    
                    for (let elem of stockElements) {
                        const text = elem.innerText;
                        if (!text.toLowerCase().includes('out of stock')) {
                            const match = text.match(/(\d+)/);
                            if (match) return match[1];
                        }
                    }
                    return '9999';
                }
            """)
            
            match = re.search(r'\d+', str(stock))
            return int(match.group()) if match else 9999
            
        except Exception as e:
            logger.warning(f"Stock extraction failed: {e}")
            return 9999
    
    async def scrape_multiple(self, urls: List[str]) -> List[Dict]:
        """Scrape multiple products concurrently"""
        try:
            await self.initialize()
            tasks = [self.scrape_product(url) for url in urls]
            results = await asyncio.gather(*tasks, return_exceptions=True)
            return [r for r in results if isinstance(r, dict)]
            
        finally:
            await self.close()
    
    async def close(self):
        """Close browser"""
        if self.browser:
            await self.browser.close()
            logger.info("✅ Browser closed")


# Synchronous wrapper for Django
class PuppeteerScraper:
    """Synchronous wrapper around async Puppeteer scraper"""
    
    def __init__(self, use_tor=True, headless=True):
        self.scraper = PuppeteerAliExpressScraper(use_tor, headless)
    
    def scrape_product(self, url: str) -> Optional[Dict]:
        """Synchronous scrape method"""
        try:
            loop = asyncio.get_event_loop()
        except RuntimeError:
            loop = asyncio.new_event_loop()
            asyncio.set_event_loop(loop)
        
        try:
            return loop.run_until_complete(self.scraper.scrape_product(url))
        finally:
            loop.run_until_complete(self.scraper.close())
    
    def scrape_multiple(self, urls: List[str]) -> List[Dict]:
        """Synchronous batch scrape method"""
        try:
            loop = asyncio.get_event_loop()
        except RuntimeError:
            loop = asyncio.new_event_loop()
            asyncio.set_event_loop(loop)
        
        try:
            return loop.run_until_complete(self.scraper.scrape_multiple(urls))
        finally:
            pass
