"""
Production-ready AliExpress scraper using Playwright (async).
Implements stealth techniques, anti-detection, and human-like behavior.
Compatible with Django/Celery for background task processing.
"""

import asyncio
import json
import logging
from datetime import datetime, timezone
from typing import Optional, List, Dict, Any
from dataclasses import dataclass, asdict
import random
import re

from playwright.async_api import async_playwright, Browser, Page, BrowserContext

# Configure logging
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s'
)
logger = logging.getLogger(__name__)

# Import playwright-stealth for enhanced anti-detection
try:
    from playwright_stealth import Stealth
    STEALTH_AVAILABLE = True
except ImportError:
    STEALTH_AVAILABLE = False
    Stealth = None
    logger.warning("playwright-stealth not installed. Run: pip install playwright-stealth")


# ============================================================================
# Constants and Configuration
# ============================================================================

# NOTE: AliExpress has aggressive anti-bot measures.
# For production use, you MUST use:
#   1. Residential rotating proxies (BrightData, Oxylabs, SmartProxy)
#   2. Proxy rotation per request
#   3. Rate limiting (max 1 request per 5-10 seconds)
#   4. Session/cookie management
#
# Without proxies, the scraper will likely be blocked after 1-3 requests.

USER_AGENTS = [
    "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36",
    "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36",
    "Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36",
    "Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:121.0) Gecko/20100101 Firefox/121.0",
    "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15",
]

# Default headers for natural-looking requests
DEFAULT_HEADERS = {
    "Accept": "text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8",
    "Accept-Encoding": "gzip, deflate",
    "Accept-Language": "en-US,en;q=0.9",
    "DNT": "1",
    "Connection": "keep-alive",
    "Upgrade-Insecure-Requests": "1",
}

# Delay ranges (in seconds) for human-like behavior
DELAY_BETWEEN_REQUESTS = (2, 5)
DELAY_BEFORE_SCROLL = (1, 3)
DELAY_AFTER_SCROLL = (1, 2)
DELAY_BETWEEN_PAGES = (3, 8)

# Default category mapping for product detection
CATEGORY_KEYWORDS = {
    "Electronics": ["phone", "cable", "charger", "headphone", "earphone", "bluetooth", "usb", "adapter", "speaker", "camera", "watch", "smart"],
    "Fashion": ["dress", "shirt", "pants", "shoes", "bag", "wallet", "jewelry", "necklace", "ring", "bracelet", "clothing", "fashion"],
    "Home & Garden": ["home", "kitchen", "garden", "furniture", "lamp", "light", "decor", "bed", "pillow", "curtain"],
    "Sports": ["sport", "fitness", "gym", "yoga", "bicycle", "running", "outdoor", "camping"],
    "Beauty": ["makeup", "beauty", "skincare", "cosmetic", "hair", "nail", "perfume"],
    "Toys": ["toy", "game", "puzzle", "doll", "kid", "baby", "children"],
    "Automotive": ["car", "auto", "vehicle", "motor", "bike", "motorcycle"],
}


def detect_category(title: str) -> str:
    """Detect product category from title using keywords."""
    title_lower = title.lower()
    for category, keywords in CATEGORY_KEYWORDS.items():
        if any(kw in title_lower for kw in keywords):
            return category
    return "General"


# ============================================================================
# Data Models
# ============================================================================

@dataclass
class Product:
    """
    Product data model for structured output.
    Matches Django model structure for easy integration.
    """
    # Core fields from scraping
    name: str
    price: float
    source_url: str
    image_url: Optional[str] = None
    supplier_rating: Optional[float] = None
    supplier_review_count: Optional[int] = None
    
    # Computed/derived fields
    description: Optional[str] = None
    cost: Optional[float] = None
    profit: Optional[float] = None
    category: str = "General"
    source: str = "aliexpress"
    source_id: Optional[str] = None
    supplier_name: str = "AliExpress Seller"
    trend_percentage: float = 22.5
    is_active: bool = True
    is_trending: bool = False
    score: int = 0
    scraped_at: str = None
    
    def __post_init__(self):
        # Set scraped timestamp
        if self.scraped_at is None:
            self.scraped_at = datetime.now(timezone.utc).isoformat()
        
        # Auto-generate description if not set
        if self.description is None:
            self.description = f"Product from AliExpress - {self.name[:100]}"
        
        # Calculate cost and profit (60/40 split)
        if self.price and self.price > 0:
            if self.cost is None:
                self.cost = round(self.price * 0.6, 2)
            if self.profit is None:
                self.profit = round(self.price * 0.4, 2)
        
        # Auto-detect category from name
        if self.category == "General":
            self.category = detect_category(self.name)
        
        # Calculate trending status
        if self.supplier_review_count and self.supplier_review_count > 500:
            self.is_trending = True
        
        # Calculate score (0-100)
        if self.supplier_rating and self.supplier_rating > 0:
            self.score = int(self.supplier_rating * 20)
    
    def to_dict(self) -> Dict[str, Any]:
        """Convert to dictionary for JSON serialization."""
        return {
            "name": self.name,
            "description": self.description,
            "price": self.price,
            "cost": self.cost,
            "profit": self.profit,
            "category": self.category,
            "source": self.source,
            "source_url": self.source_url,
            "source_id": self.source_id,
            "image_url": self.image_url or "",
            "supplier_name": self.supplier_name,
            "supplier_rating": self.supplier_rating,
            "supplier_review_count": self.supplier_review_count,
            "trend_percentage": self.trend_percentage,
            "is_active": self.is_active,
            "is_trending": self.is_trending,
            "score": self.score,
            "scraped_at": self.scraped_at,
        }


@dataclass
class ScrapingResult:
    """Container for scraping results."""
    success: bool
    products: List[Product]
    total_products: int
    pages_scraped: int
    errors: List[str]
    started_at: str
    completed_at: str
    duration_seconds: float
    
    def to_dict(self) -> Dict[str, Any]:
        """Convert to dictionary for JSON serialization."""
        return {
            "success": self.success,
            "products": [p.to_dict() for p in self.products],
            "total_products": self.total_products,
            "pages_scraped": self.pages_scraped,
            "errors": self.errors,
            "started_at": self.started_at,
            "completed_at": self.completed_at,
            "duration_seconds": self.duration_seconds,
        }


# ============================================================================
# Utility Functions
# ============================================================================

def get_random_user_agent() -> str:
    """Get a random user agent from the pool."""
    return random.choice(USER_AGENTS)


async def random_delay(min_delay: float = DELAY_BETWEEN_REQUESTS[0],
                       max_delay: float = DELAY_BETWEEN_REQUESTS[1]) -> None:
    """
    Introduce random delay to mimic human behavior.
    
    Args:
        min_delay: Minimum delay in seconds
        max_delay: Maximum delay in seconds
    """
    delay = random.uniform(min_delay, max_delay)
    logger.info(f"Waiting {delay:.2f} seconds...")
    await asyncio.sleep(delay)


async def human_like_scroll(page: Page, max_scrolls: int = 5) -> None:
    """
    Perform human-like scrolling with random pauses.
    Helps trigger lazy-loaded content loading.
    
    Args:
        page: Playwright page object
        max_scrolls: Maximum number of scroll operations
    """
    logger.info(f"Starting human-like scroll with {max_scrolls} iterations...")
    
    for i in range(max_scrolls):
        # Scroll down a random amount
        scroll_amount = random.randint(300, 800)
        await page.evaluate(f"window.scrollBy(0, {scroll_amount})")
        
        # Random pause between scrolls
        await asyncio.sleep(random.uniform(1, 2.5))
        logger.debug(f"Scroll iteration {i+1}/{max_scrolls} completed")


async def check_if_blocked(page: Page) -> bool:
    """
    Check if the page is showing a CAPTCHA or block page.
    
    Args:
        page: Playwright page object
        
    Returns:
        True if blocked, False otherwise
    """
    # Get page content
    try:
        content = await page.content()
        
        # Check for blocking indicators
        blocking_indicators = [
            'punish-component',
            'captcha',
            'awsc.js',
            'sufei-punish',
            'slider-btn',
            'nc-container',
            'baxia-dialog',
            'security check',
            'please verify',
        ]
        
        content_lower = content.lower()
        for indicator in blocking_indicators:
            if indicator.lower() in content_lower:
                logger.warning(f"Bot detection triggered - found: {indicator}")
                return True
        
        # Check for very short page (likely error)
        if len(content) < 5000:
            logger.warning("Page content too short - likely blocked")
            return True
            
    except Exception as e:
        logger.error(f"Error checking block status: {e}")
    
    return False


async def handle_popups_and_consent(page: Page) -> None:
    """
    Handle cookie consent, region selection, and other popups.
    
    Args:
        page: Playwright page object
    """
    popup_selectors = [
        # Cookie consent buttons
        'button[data-role="close-btn"]',
        'button[class*="close"]',
        'button[class*="accept"]',
        'button[class*="agree"]',
        '[class*="gdpr"] button',
        '[class*="cookie"] button',
        # Region/currency selection close
        '[class*="ship-to"] [class*="close"]',
        '[class*="modal"] [class*="close"]',
        '[class*="popup"] [class*="close"]',
        # "Got it" or "OK" buttons
        'button:has-text("OK")',
        'button:has-text("Got it")',
        'button:has-text("Accept")',
    ]
    
    for selector in popup_selectors:
        try:
            elem = await page.query_selector(selector)
            if elem and await elem.is_visible():
                await elem.click()
                logger.info(f"Closed popup using: {selector}")
                await asyncio.sleep(0.5)
        except Exception:
            continue


async def setup_stealth_page(context: BrowserContext, url: str = None) -> Page:
    """
    Create a page with stealth techniques applied.
    Reduces detection by mimicking real browser behavior.
    
    Args:
        context: Browser context
        url: Optional URL to navigate to immediately
        
    Returns:
        Configured Playwright page
    """
    page = await context.new_page()
    
    # Apply playwright-stealth if available
    if STEALTH_AVAILABLE and Stealth:
        stealth = Stealth()
        await stealth.apply_stealth_async(page)
        logger.info("Applied playwright-stealth patches")
    
    # Set realistic viewport
    await page.set_viewport_size({"width": 1920, "height": 1080})
    
    # Add stealth scripts to prevent detection
    await page.add_init_script("""
        // Hide webdriver
        Object.defineProperty(navigator, 'webdriver', {
            get: () => undefined,
        });
        
        // Mock plugins
        Object.defineProperty(navigator, 'plugins', {
            get: () => {
                const plugins = [
                    { name: 'Chrome PDF Plugin', filename: 'internal-pdf-viewer' },
                    { name: 'Chrome PDF Viewer', filename: 'mhjfbmdgcfjbbpaeojofohoefgiehjai' },
                    { name: 'Native Client', filename: 'internal-nacl-plugin' }
                ];
                plugins.length = 3;
                return plugins;
            },
        });
        
        // Mock languages
        Object.defineProperty(navigator, 'languages', {
            get: () => ['en-US', 'en'],
        });
        
        // Mock permissions
        const originalQuery = window.navigator.permissions.query;
        window.navigator.permissions.query = (parameters) => (
            parameters.name === 'notifications' ?
                Promise.resolve({ state: Notification.permission }) :
                originalQuery(parameters)
        );
        
        // Mock chrome runtime
        window.chrome = {
            runtime: {},
            loadTimes: function() {},
            csi: function() {},
            app: {}
        };
        
        // Fix iframe contentWindow
        Object.defineProperty(HTMLIFrameElement.prototype, 'contentWindow', {
            get: function() {
                return window;
            }
        });
        
        // Mock WebGL vendor/renderer
        const getParameter = WebGLRenderingContext.prototype.getParameter;
        WebGLRenderingContext.prototype.getParameter = function(parameter) {
            if (parameter === 37445) return 'Intel Inc.';
            if (parameter === 37446) return 'Intel Iris OpenGL Engine';
            return getParameter.call(this, parameter);
        };
    """)
    
    # Optional: Add geolocation
    await context.grant_permissions(['geolocation'])
    await context.set_geolocation({"latitude": 40.7128, "longitude": -74.0060})
    
    if url:
        logger.info(f"Navigating to {url}")
        await page.goto(url, wait_until="networkidle")
    
    return page


def extract_price(price_text: str) -> str:
    """
    Extract and clean price from text.
    
    Args:
        price_text: Raw price text from page
        
    Returns:
        Cleaned price string
    """
    if not price_text:
        return None
    
    # Remove common currency symbols and clean whitespace
    cleaned = re.sub(r'\s+', ' ', price_text.strip())
    return cleaned


def parse_price_to_float(price_text: str) -> float:
    """
    Parse price string to float value.
    
    Args:
        price_text: Price string (e.g., "$12.99", "US $24.50", "€15,99")
        
    Returns:
        Price as float or 0.0 if parsing fails
    """
    if not price_text:
        return 0.0
    
    try:
        # Remove currency symbols and text
        cleaned = re.sub(r'[^\d.,]', '', price_text)
        
        # Handle European format (comma as decimal)
        if ',' in cleaned and '.' in cleaned:
            # Both present: assume comma is thousands separator
            cleaned = cleaned.replace(',', '')
        elif ',' in cleaned:
            # Only comma: could be decimal or thousands
            # If after comma there are exactly 2 digits at end, it's decimal
            if re.search(r',\d{2}$', cleaned):
                cleaned = cleaned.replace(',', '.')
            else:
                cleaned = cleaned.replace(',', '')
        
        return float(cleaned)
    except (ValueError, AttributeError):
        return 0.0


def extract_item_id(url: str) -> Optional[str]:
    """
    Extract item ID from AliExpress URL.
    
    Args:
        url: AliExpress product URL
        
    Returns:
        Item ID string or None
    """
    if not url:
        return None
    
    # Match patterns like /item/1234567890.html
    match = re.search(r'/item/(\d+)\.html', url)
    if match:
        return match.group(1)
    
    # Match patterns like /item/1234567890
    match = re.search(r'/item/(\d+)', url)
    if match:
        return match.group(1)
    
    return None


def extract_rating(rating_text: str) -> Optional[float]:
    """
    Extract rating as float from text.
    
    Args:
        rating_text: Raw rating text from page
        
    Returns:
        Rating as float or None
    """
    if not rating_text:
        return None
    
    try:
        # Extract numeric part
        match = re.search(r'(\d+\.?\d*)', rating_text)
        if match:
            return float(match.group(1))
    except (ValueError, AttributeError):
        pass
    
    return None


# ============================================================================
# Core Scraping Functions
# ============================================================================

async def scrape_product_list_page(page: Page) -> List[Product]:
    """
    Extract product information from a single page.
    Updated selectors for AliExpress 2026 structure.
    
    Args:
        page: Playwright page object
        
    Returns:
        List of Product objects
    """
    products = []
    
    # Multiple selector strategies for resilience
    PRODUCT_CARD_SELECTORS = [
        'div[class*="search-item-card"]',
        'div[class*="product-card"]',
        'a[class*="search--itemCard"]',
        'div[class*="list--gallery"] > a',
        '.search-card-item',
        '[data-widget-cid*="item"]',
    ]
    
    try:
        # Wait for page to be ready
        await page.wait_for_load_state('networkidle', timeout=20000)
        await asyncio.sleep(3)  # Extra wait for JS rendering
        
        # Additional wait for dynamic content
        try:
            await page.wait_for_selector('a[href*="/item/"]', timeout=10000)
        except Exception:
            logger.info("No product links found after initial wait, continuing...")
        
        # Try multiple selectors to find product cards
        product_elements = []
        for selector in PRODUCT_CARD_SELECTORS:
            try:
                product_elements = await page.query_selector_all(selector)
                if len(product_elements) > 0:
                    logger.info(f"Found {len(product_elements)} products using selector: {selector}")
                    break
            except Exception:
                continue
        
        # Fallback: try to find all product links
        if len(product_elements) == 0:
            logger.info("Using fallback link-based extraction")
            product_elements = await page.query_selector_all('a[href*="/item/"]')
            logger.info(f"Found {len(product_elements)} product links")
        
        for idx, element in enumerate(product_elements):
            try:
                # Extract title - try multiple selectors
                title = None
                for title_sel in ['h1', 'h2', 'h3', '[class*="title"]', '[class*="Title"]', 'img[alt]']:
                    title_elem = await element.query_selector(title_sel)
                    if title_elem:
                        if title_sel == 'img[alt]':
                            title = await title_elem.get_attribute('alt')
                        else:
                            title = await title_elem.inner_text()
                        if title and len(title.strip()) > 5:
                            break
                
                # Extract price - try multiple selectors (AliExpress specific)
                price = None
                price_selectors = [
                    '[class*="multi--price"]',
                    '[class*="price-sale"]',
                    '[class*="price--current"]',
                    '[class*="Price"]',
                    '[class*="price"]',
                    'span[class*="price"]',
                ]
                for price_sel in price_selectors:
                    try:
                        price_elem = await element.query_selector(price_sel)
                        if price_elem:
                            price = await price_elem.inner_text()
                            if price and any(c.isdigit() for c in price):
                                price = extract_price(price)
                                if price:
                                    break
                    except Exception:
                        continue
                
                # Extract link
                link = None
                tag_name = await element.evaluate('el => el.tagName.toLowerCase()')
                if tag_name == 'a':
                    link = await element.get_attribute('href')
                else:
                    link_elem = await element.query_selector('a[href*="/item/"], a[href*="aliexpress"]')
                    if link_elem:
                        link = await link_elem.get_attribute('href')
                
                # Normalize link
                if link:
                    # Handle protocol-relative URLs (//www.aliexpress.com...)
                    if link.startswith('//'):
                        link = f"https:{link}"
                    # Handle absolute paths (/item/...)
                    elif link.startswith('/') and not link.startswith('//'):
                        link = f"https://www.aliexpress.com{link}"
                    # Handle relative URLs without leading slash
                    elif not link.startswith('http'):
                        link = f"https://{link}"
                
                # Extract rating
                rating = None
                for rating_sel in ['[class*="star"]', '[class*="rating"]', '[class*="Rating"]']:
                    rating_elem = await element.query_selector(rating_sel)
                    if rating_elem:
                        rating_text = await rating_elem.inner_text()
                        rating = extract_rating(rating_text)
                        if rating:
                            break
                
                # Extract review count
                review_count = None
                for review_sel in ['[class*="sold"]', '[class*="review"]', '[class*="orders"]']:
                    review_elem = await element.query_selector(review_sel)
                    if review_elem:
                        review_text = await review_elem.inner_text()
                        try:
                            match = re.search(r'([\d,\.]+)', review_text.replace(',', ''))
                            if match:
                                review_count = int(float(match.group(1)))
                                break
                        except (ValueError, AttributeError):
                            pass
                
                # Extract image URL
                image_url = None
                for img_sel in ['img[src*="alicdn"]', 'img[data-src*="alicdn"]', 'img']:
                    img_elem = await element.query_selector(img_sel)
                    if img_elem:
                        # Try data-src first (lazy loading)
                        image_url = await img_elem.get_attribute('data-src')
                        if not image_url:
                            image_url = await img_elem.get_attribute('src')
                        if image_url and ('alicdn' in image_url or 'ae01.alicdn' in image_url):
                            # Normalize image URL
                            if image_url.startswith('//'):
                                image_url = f"https:{image_url}"
                            break
                
                # Validate required fields and create Product
                if title and len(title.strip()) > 5 and link and '/item/' in link:
                    # Parse price to float
                    price_value = parse_price_to_float(price) if price else 0.0
                    
                    # Extract item ID for source_id
                    item_id = extract_item_id(link)
                    source_id = f"aliexpress_{item_id}" if item_id else f"aliexpress_{idx}"
                    
                    product = Product(
                        name=title.strip()[:200],  # Limit title length
                        price=price_value,
                        source_url=link,
                        image_url=image_url,
                        supplier_rating=rating,
                        supplier_review_count=review_count,
                        source_id=source_id,
                    )
                    products.append(product)
                    logger.debug(f"Scraped product: {title[:50]}...")
                
            except Exception as e:
                logger.warning(f"Error scraping product {idx}: {str(e)}")
                continue
        
    except Exception as e:
        logger.error(f"Error scraping product list: {str(e)}")
    
    return products


async def navigate_and_scrape_page(context: BrowserContext, 
                                   url: str,
                                   debug_screenshots: bool = False) -> tuple[List[Product], bool]:
    """
    Navigate to a page, wait for content, scroll, and scrape.
    
    Args:
        context: Browser context
        url: URL to scrape
        debug_screenshots: If True, save screenshots for debugging
        
    Returns:
        Tuple of (List of products, is_blocked flag)
    """
    page = await setup_stealth_page(context, url)
    products = []
    is_blocked = False
    
    try:
        # Handle any popups (cookies, region, etc.)
        await handle_popups_and_consent(page)
        
        # Check if we're blocked
        is_blocked = await check_if_blocked(page)
        if is_blocked:
            logger.error("BOT DETECTION: AliExpress has blocked this request. Use residential proxies.")
            return products, is_blocked
        
        # Add random delay to appear human-like
        await random_delay()
        
        # Scroll to trigger lazy-loading
        await human_like_scroll(page, max_scrolls=5)
        
        # Handle popups again after scrolling
        await handle_popups_and_consent(page)
        
        # Wait for content to stabilize
        await page.wait_for_timeout(2000)
        
        # Check again after scrolling
        is_blocked = await check_if_blocked(page)
        if is_blocked:
            logger.error("BOT DETECTION: Blocked after scrolling. Use residential proxies.")
        
        # Debug: save screenshot
        if debug_screenshots:
            screenshot_path = f"debug_page_{datetime.now(timezone.utc).strftime('%H%M%S')}.png"
            await page.screenshot(path=screenshot_path, full_page=True)
            logger.info(f"Debug screenshot saved: {screenshot_path}")
            
            # Also dump page HTML for debugging
            html_content = await page.content()
            html_path = f"debug_page_{datetime.now(timezone.utc).strftime('%H%M%S')}.html"
            with open(html_path, 'w', encoding='utf-8') as f:
                f.write(html_content)
            logger.info(f"Debug HTML saved: {html_path}")
        
        # Scrape products if not blocked
        if not is_blocked:
            products = await scrape_product_list_page(page)
        
    except Exception as e:
        logger.error(f"Error navigating and scraping {url}: {str(e)}")
    
    finally:
        await page.close()
    
    return products, is_blocked


def generate_demo_results(search_query: str, num_pages: int, 
                         start_time: datetime) -> ScrapingResult:
    """
    Generate demo/sample results for development and testing.
    Use ALIEXPRESS_DEMO_MODE=true environment variable to enable.
    
    Args:
        search_query: The search query
        num_pages: Number of pages requested
        start_time: When scraping started
        
    Returns:
        ScrapingResult with sample products
    """
    sample_products = [
        Product(
            name=f"Premium {search_query.title()} - High Quality - Fast Shipping",
            price=12.99,
            source_url=f"https://www.aliexpress.com/item/1234567890.html",
            image_url="https://ae01.alicdn.com/kf/sample1.jpg",
            supplier_rating=4.8,
            supplier_review_count=1250,
            source_id="aliexpress_1234567890"
        ),
        Product(
            name=f"Professional {search_query.title()} - 2026 Latest Model",
            price=24.50,
            source_url=f"https://www.aliexpress.com/item/1234567891.html",
            image_url="https://ae01.alicdn.com/kf/sample2.jpg",
            supplier_rating=4.6,
            supplier_review_count=856,
            source_id="aliexpress_1234567891"
        ),
        Product(
            name=f"Budget {search_query.title()} - Great Value - Free Shipping",
            price=8.99,
            source_url=f"https://www.aliexpress.com/item/1234567892.html",
            image_url="https://ae01.alicdn.com/kf/sample3.jpg",
            supplier_rating=4.3,
            supplier_review_count=2340,
            source_id="aliexpress_1234567892"
        ),
        Product(
            name=f"Luxury {search_query.title()} - Premium Edition",
            price=45.00,
            source_url=f"https://www.aliexpress.com/item/1234567893.html",
            image_url="https://ae01.alicdn.com/kf/sample4.jpg",
            supplier_rating=4.9,
            supplier_review_count=567,
            source_id="aliexpress_1234567893"
        ),
        Product(
            name=f"Portable {search_query.title()} - Compact Design",
            price=15.75,
            source_url=f"https://www.aliexpress.com/item/1234567894.html",
            image_url="https://ae01.alicdn.com/kf/sample5.jpg",
            supplier_rating=4.5,
            supplier_review_count=1890,
            source_id="aliexpress_1234567894"
        ),
    ]
    
    # Duplicate for multiple pages
    all_products = sample_products * num_pages
    
    end_time = datetime.now(timezone.utc)
    
    return ScrapingResult(
        success=True,
        products=all_products,
        total_products=len(all_products),
        pages_scraped=num_pages,
        errors=["DEMO_MODE: Using sample data. Set ALIEXPRESS_DEMO_MODE=false for production."],
        started_at=start_time.isoformat(),
        completed_at=end_time.isoformat(),
        duration_seconds=(end_time - start_time).total_seconds()
    )


async def scrape_aliexpress(search_query: str, 
                           num_pages: int = 1,
                           proxy: Optional[str] = None,
                           headless: bool = True,
                           debug_screenshots: bool = False,
                           use_firefox: bool = False) -> ScrapingResult:
    """
    Main scraping function for AliExpress.
    Implements multi-page scraping with stealth techniques.
    
    Args:
        search_query: Product search query (e.g., "wireless headphones")
        num_pages: Number of pages to scrape (default: 1)
        proxy: Optional proxy URL (format: "http://ip:port" or "socks5://ip:port")
        headless: Run browser in headless mode (default: True)
        debug_screenshots: Save debug screenshots (default: False)
        use_firefox: Use Firefox instead of Chromium (sometimes better for anti-detection)
        
    Returns:
        ScrapingResult containing all scraped products and metadata
    """
    start_time = datetime.now(timezone.utc)
    logger.info(f"Starting AliExpress scrape for query: '{search_query}', pages: {num_pages}")
    
    # Check for demo mode
    import os
    if os.environ.get("ALIEXPRESS_DEMO_MODE", "").lower() == "true":
        logger.info("DEMO MODE: Returning sample data without making requests")
        return generate_demo_results(search_query, num_pages, start_time)
    
    all_products = []
    errors = []
    pages_scraped = 0
    
    # URL encode the search query
    from urllib.parse import quote_plus
    encoded_query = quote_plus(search_query)
    base_url = f"https://www.aliexpress.com/w/wholesale-{encoded_query}.html?page="
    
    browser: Browser = None
    context: BrowserContext = None
    
    try:
        async with async_playwright() as p:
            # Launch browser with stealth options
            launch_args = {
                "headless": headless,
                "args": [
                    "--disable-blink-features=AutomationControlled",
                    "--disable-dev-shm-usage",
                    "--no-first-run",
                    "--no-default-browser-check",
                    "--disable-infobars",
                    "--window-size=1920,1080",
                    "--start-maximized",
                ]
            }
            
            if proxy:
                launch_args["proxy"] = {"server": proxy}
                logger.info(f"Using proxy: {proxy}")
            
            # Choose browser type
            if use_firefox:
                logger.info("Using Firefox browser")
                browser = await p.firefox.launch(**launch_args)
            else:
                logger.info("Using Chromium browser")
                browser = await p.chromium.launch(**launch_args)
            
            # Create context with specific configuration
            context_args = {
                "user_agent": get_random_user_agent(),
                "extra_http_headers": DEFAULT_HEADERS,
            }
            
            context = await browser.new_context(**context_args)
            
            # Scrape each page
            for page_num in range(1, num_pages + 1):
                try:
                    page_url = f"{base_url}{page_num}"
                    logger.info(f"Scraping page {page_num}/{num_pages}: {page_url}")
                    
                    # Scrape the page
                    page_products, is_blocked = await navigate_and_scrape_page(
                        context, page_url, debug_screenshots=debug_screenshots
                    )
                    
                    if is_blocked:
                        error_msg = "BOT_BLOCKED: AliExpress detected automation. Use residential proxies."
                        errors.append(error_msg)
                        logger.error(error_msg)
                        break  # Stop scraping if blocked
                    
                    all_products.extend(page_products)
                    pages_scraped += 1
                    
                    logger.info(f"Page {page_num}: Found {len(page_products)} products")
                    
                    # Delay between pages
                    if page_num < num_pages:
                        await random_delay(*DELAY_BETWEEN_PAGES)
                
                except Exception as e:
                    error_msg = f"Error scraping page {page_num}: {str(e)}"
                    logger.error(error_msg)
                    errors.append(error_msg)
        
    except Exception as e:
        error_msg = f"Fatal error during scraping: {str(e)}"
        logger.error(error_msg)
        errors.append(error_msg)
    
    finally:
        try:
            if context:
                await context.close()
        except Exception:
            pass
        try:
            if browser:
                await browser.close()
        except Exception:
            pass
    
    # Compile results
    end_time = datetime.now(timezone.utc)
    duration = (end_time - start_time).total_seconds()
    
    result = ScrapingResult(
        success=len(errors) == 0 or len(all_products) > 0,
        products=all_products,
        total_products=len(all_products),
        pages_scraped=pages_scraped,
        errors=errors,
        started_at=start_time.isoformat(),
        completed_at=end_time.isoformat(),
        duration_seconds=duration
    )
    
    logger.info(f"Scraping completed. Found {len(all_products)} products in {duration:.2f} seconds")
    
    return result


# ============================================================================
# Export Functions for Django/Celery Integration
# ============================================================================

def scrape_aliexpress_sync(search_query: str, 
                          num_pages: int = 1,
                          proxy: Optional[str] = None) -> Dict[str, Any]:
    """
    Synchronous wrapper for async scraping function.
    Use this for Django/Celery task integration.
    
    Args:
        search_query: Product search query
        num_pages: Number of pages to scrape
        proxy: Optional proxy URL
        
    Returns:
        Dictionary with scraping results (JSON-serializable)
    """
    logger.info(f"Starting sync wrapper for query: '{search_query}'")
    
    try:
        # Run async function in event loop
        result = asyncio.run(
            scrape_aliexpress(
                search_query=search_query,
                num_pages=num_pages,
                proxy=proxy
            )
        )
        return result.to_dict()
    
    except Exception as e:
        logger.error(f"Error in sync wrapper: {str(e)}")
        return {
            "success": False,
            "products": [],
            "total_products": 0,
            "pages_scraped": 0,
            "errors": [str(e)],
            "started_at": datetime.now(timezone.utc).isoformat(),
            "completed_at": datetime.now(timezone.utc).isoformat(),
            "duration_seconds": 0,
        }


def save_results_to_json(result: ScrapingResult, 
                        filepath: str) -> None:
    """
    Save scraping results to JSON file.
    
    Args:
        result: ScrapingResult object
        filepath: Path to save JSON file
    """
    try:
        with open(filepath, 'w', encoding='utf-8') as f:
            json.dump(result.to_dict(), f, indent=2, ensure_ascii=False)
        logger.info(f"Results saved to {filepath}")
    except Exception as e:
        logger.error(f"Error saving results: {str(e)}")


# ============================================================================
# Celery Task Example (Uncomment if using Celery)
# ============================================================================

# from celery import shared_task
#
# @shared_task
# def celery_scrape_aliexpress(search_query: str, num_pages: int = 1, 
#                              proxy: str = None) -> Dict[str, Any]:
#     """
#     Celery task for background scraping.
#     Use in Django settings: CELERY_BROKER_URL, CELERY_RESULT_BACKEND
#     
#     Usage:
#         from .scrapers.aliexpress_scraper import celery_scrape_aliexpress
#         result = celery_scrape_aliexpress.delay('wireless headphones', num_pages=2)
#         result.get()  # Retrieve result when ready
#     """
#     logger.info(f"Celery task started for: {search_query}")
#     return scrape_aliexpress_sync(search_query, num_pages, proxy)


# ============================================================================
# CLI Example (for testing)
# ============================================================================

if __name__ == "__main__":
    import sys
    
    # Default parameters
    query = "wireless headphones"
    pages = 1
    headless = True
    debug = False
    
    # Override with command line arguments
    if len(sys.argv) > 1:
        query = sys.argv[1]
    if len(sys.argv) > 2:
        pages = int(sys.argv[2])
    if "--debug" in sys.argv:
        debug = True
        headless = False
        logger.info("Debug mode enabled - running with visible browser")
    if "--headed" in sys.argv:
        headless = False
    
    # Check for firefox flag
    use_firefox = "--firefox" in sys.argv
    if use_firefox:
        logger.info("Using Firefox browser (better anti-detection)")
    
    logger.info(f"Running scraper with query='{query}', pages={pages}")
    
    # Run scraper
    result = asyncio.run(scrape_aliexpress(
        query, pages, headless=headless, debug_screenshots=debug, use_firefox=use_firefox
    ))
    
    # Display results
    print(f"\n{'='*60}")
    print(f"Scraping Results for: {query}")
    print(f"{'='*60}")
    print(f"Success: {result.success}")
    print(f"Total Products: {result.total_products}")
    print(f"Pages Scraped: {result.pages_scraped}")
    print(f"Duration: {result.duration_seconds:.2f} seconds")
    
    if result.errors:
        print(f"\nErrors ({len(result.errors)}):")
        for error in result.errors:
            print(f"  - {error}")
    
    print(f"\nProducts ({len(result.products)}):")
    print("-" * 60)
    
    for idx, product in enumerate(result.products[:5], 1):  # Show first 5
        print(f"\n{idx}. {product.name}")
        print(f"   Price: ${product.price:.2f} (Cost: ${product.cost:.2f}, Profit: ${product.profit:.2f})")
        print(f"   Category: {product.category}")
        print(f"   Rating: {product.supplier_rating or 'N/A'} | Reviews: {product.supplier_review_count or 0}")
        print(f"   Score: {product.score} | Trending: {'Yes' if product.is_trending else 'No'}")
        print(f"   Image: {product.image_url[:50]}..." if product.image_url else "   Image: N/A")
        print(f"   Link: {product.source_url[:80]}...")
    
    if len(result.products) > 5:
        print(f"\n... and {len(result.products) - 5} more products")
    
    # Save results
    output_file = f"aliexpress_results_{datetime.now(timezone.utc).strftime('%Y%m%d_%H%M%S')}.json"
    save_results_to_json(result, output_file)
    print(f"\n✓ Results saved to: {output_file}")
