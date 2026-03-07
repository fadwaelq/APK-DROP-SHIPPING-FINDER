"""
eBay Product Scraper using Playwright (async).
Implements stealth techniques and human-like behavior.
Compatible with Django/Celery for background task processing.
"""

import asyncio
import json
import logging
from datetime import datetime, timezone
from typing import Optional, List, Dict, Any
from dataclasses import dataclass
import random
import re
import argparse
import os

from playwright.async_api import async_playwright, Page

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

USER_AGENTS = [
    "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/122.0.0.0 Safari/537.36",
    "Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:123.0) Gecko/20100101 Firefox/123.0",
    "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/122.0.0.0 Safari/537.36",
    "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/121.0.0.0 Safari/537.36 Edg/121.0.0.0",
]

DEFAULT_HEADERS = {
    "Accept": "text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8",
    "Accept-Encoding": "gzip, deflate, br",
    "Accept-Language": "en-US,en;q=0.9",
    "Cache-Control": "no-cache",
    "DNT": "1",
    "Connection": "keep-alive",
    "Upgrade-Insecure-Requests": "1",
}

# Delay ranges for human-like behavior
DELAY_BETWEEN_REQUESTS = (2, 4)
DELAY_BEFORE_SCROLL = (0.5, 1.5)
DELAY_AFTER_SCROLL = (0.5, 1)
DELAY_BETWEEN_PAGES = (2, 5)

# Category detection
CATEGORY_KEYWORDS = {
    "Electronics": ["phone", "cable", "charger", "headphone", "earphone", "bluetooth", "usb", "adapter", "speaker", "camera", "watch", "smart", "laptop", "tablet", "iphone", "samsung", "android"],
    "Fashion": ["dress", "shirt", "pants", "shoes", "bag", "wallet", "jewelry", "necklace", "ring", "bracelet", "clothing", "fashion", "sneakers", "boots", "jacket"],
    "Home & Garden": ["home", "kitchen", "garden", "furniture", "lamp", "light", "decor", "bed", "pillow", "curtain", "coffee", "blender", "vacuum"],
    "Sports": ["sport", "fitness", "gym", "yoga", "bicycle", "running", "outdoor", "camping", "golf", "tennis", "basketball"],
    "Beauty": ["makeup", "beauty", "skincare", "cosmetic", "hair", "nail", "perfume", "shampoo", "lotion"],
    "Toys": ["toy", "game", "puzzle", "doll", "kid", "baby", "children", "lego", "nerf", "action figure"],
    "Automotive": ["car", "auto", "vehicle", "motor", "bike", "motorcycle", "dash cam"],
    "Collectibles": ["collectible", "vintage", "antique", "rare", "coin", "stamp", "card", "memorabilia"],
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
    source: str = "ebay"
    source_id: Optional[str] = None
    supplier_name: str = "eBay Seller"
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
            self.description = f"Product from eBay - {self.name[:100]}"
        
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
# Scraping Functions
# ============================================================================

async def setup_stealth_page(context, page: Page) -> Page:
    """Apply stealth patches to avoid detection."""
    if STEALTH_AVAILABLE and Stealth:
        stealth = Stealth()
        await stealth.apply_stealth_async(page)
        logger.info("Stealth patches applied")
    else:
        # Manual stealth if library not available
        await page.add_init_script("""
            // Override webdriver check
            Object.defineProperty(navigator, 'webdriver', { get: () => undefined });
            
            // Override plugins
            Object.defineProperty(navigator, 'plugins', {
                get: () => [1, 2, 3, 4, 5]
            });
            
            // Override languages
            Object.defineProperty(navigator, 'languages', {
                get: () => ['en-US', 'en']
            });
        """)
    return page


async def human_like_scroll(page: Page):
    """Perform human-like scrolling behavior."""
    await asyncio.sleep(random.uniform(*DELAY_BEFORE_SCROLL))
    
    # Scroll in increments
    scroll_height = await page.evaluate("document.body.scrollHeight")
    current_position = 0
    
    while current_position < scroll_height * 0.8:
        scroll_amount = random.randint(200, 500)
        current_position += scroll_amount
        await page.evaluate(f"window.scrollTo(0, {current_position})")
        await asyncio.sleep(random.uniform(0.1, 0.3))
    
    await asyncio.sleep(random.uniform(*DELAY_AFTER_SCROLL))


def parse_price(price_text: str) -> Optional[float]:
    """Parse price from eBay price string."""
    if not price_text:
        return None
    
    # Remove currency symbols and clean
    clean = re.sub(r'[^\d.,]', '', price_text)
    
    # Handle different formats
    if ',' in clean and '.' in clean:
        if clean.index(',') < clean.index('.'):
            clean = clean.replace(',', '')  # 1,234.56 format
        else:
            clean = clean.replace('.', '').replace(',', '.')  # 1.234,56 format
    elif ',' in clean:
        parts = clean.split(',')
        if len(parts[-1]) == 2:
            clean = clean.replace(',', '.')  # Decimal separator
        else:
            clean = clean.replace(',', '')  # Thousand separator
    
    try:
        return round(float(clean), 2)
    except ValueError:
        return None


def parse_seller_rating(rating_text: str) -> Optional[float]:
    """Parse seller rating percentage to 0-5 scale."""
    if not rating_text:
        return None
    
    # eBay uses percentage (e.g., "99.5% positive")
    match = re.search(r'([\d.]+)\s*%', rating_text)
    if match:
        try:
            percentage = float(match.group(1))
            # Convert percentage to 0-5 scale
            return round(percentage / 20, 1)  # 100% = 5.0
        except ValueError:
            return None
    return None


def parse_sold_count(sold_text: str) -> Optional[int]:
    """Parse sold count from eBay (e.g., '1.2k sold', '500+ sold')."""
    if not sold_text:
        return None
    
    sold_text = sold_text.lower()
    
    # Handle 'k' suffix (thousands)
    if 'k' in sold_text:
        match = re.search(r'([\d.]+)\s*k', sold_text)
        if match:
            return int(float(match.group(1)) * 1000)
    
    # Handle '+' suffix
    clean = re.sub(r'[^\d]', '', sold_text)
    if clean:
        try:
            return int(clean)
        except ValueError:
            return None
    return None


def extract_item_id(url: str) -> Optional[str]:
    """Extract eBay item ID from product URL."""
    patterns = [
        r'/itm/(\d+)',
        r'item=(\d+)',
        r'/(\d{12})',  # eBay IDs are typically 12 digits
    ]
    for pattern in patterns:
        match = re.search(pattern, url)
        if match:
            return match.group(1)
    return None


async def check_if_blocked(page: Page) -> tuple[bool, str]:
    """Check if eBay has blocked the request."""
    content = await page.content()
    
    # More specific blocking indicators to avoid false positives
    blocked_indicators = [
        ("please verify you are a human", "CAPTCHA required"),
        ("verify you're not a robot", "Robot check detected"),
        ("access to this page has been denied", "Access blocked"),
        ("security measure", "Security measure triggered"),
        ("unusual traffic from your computer", "Unusual traffic detected"),
        ("complete the captcha", "CAPTCHA required"),
    ]
    
    content_lower = content.lower()
    for indicator, message in blocked_indicators:
        if indicator in content_lower:
            return True, message
    
    # Check if page has no results container at all (might be blocked)
    has_results = await page.query_selector(".srp-results, .s-item, #srp-river-results")
    if not has_results:
        # Check if it's a valid empty search vs blocked
        empty_search = await page.query_selector(".srp-save-null-search")
        if not empty_search and len(content) < 10000:
            return True, "Page appears to be blocked (no results container)"
    
    return False, ""


async def scrape_ebay(
    query: str,
    max_pages: int = 1,
    headless: bool = True,
    proxy: Optional[str] = None,
    demo_mode: bool = False,
) -> ScrapingResult:
    """
    Scrape eBay search results.
    
    Args:
        query: Search query
        max_pages: Maximum pages to scrape (default 1)
        headless: Run browser in headless mode
        proxy: Optional proxy URL (format: http://user:pass@host:port)
        demo_mode: Return demo data instead of real scraping
    
    Returns:
        ScrapingResult with products and metadata
    """
    started_at = datetime.now(timezone.utc)
    products: List[Product] = []
    errors: List[str] = []
    pages_scraped = 0
    
    # Demo mode for development/testing
    if demo_mode:
        logger.info("Running in DEMO mode - returning sample data")
        return generate_demo_results(query, max_pages)
    
    logger.info(f"Starting eBay scrape: query='{query}', pages={max_pages}")
    
    async with async_playwright() as p:
        # Browser launch options
        launch_options = {
            "headless": headless,
        }
        
        if proxy:
            launch_options["proxy"] = {"server": proxy}
            logger.info(f"Using proxy: {proxy.split('@')[-1] if '@' in proxy else proxy}")
        
        # Use Firefox for better stealth
        browser = await p.firefox.launch(**launch_options)
        
        context = await browser.new_context(
            user_agent=random.choice(USER_AGENTS),
            viewport={"width": 1920, "height": 1080},
            extra_http_headers=DEFAULT_HEADERS,
            locale="en-US",
            timezone_id="America/New_York",
        )
        
        page = await context.new_page()
        await setup_stealth_page(context, page)
        
        try:
            for page_num in range(1, max_pages + 1):
                # Build search URL
                search_url = f"https://www.ebay.com/sch/i.html?_nkw={query.replace(' ', '+')}&_sacat=0"
                if page_num > 1:
                    # eBay uses _pgn for page number
                    search_url += f"&_pgn={page_num}"
                
                logger.info(f"Scraping page {page_num}: {search_url}")
                
                # Navigate with retry
                for attempt in range(3):
                    try:
                        await page.goto(search_url, wait_until="domcontentloaded", timeout=30000)
                        break
                    except Exception as e:
                        if attempt == 2:
                            raise
                        logger.warning(f"Navigation attempt {attempt + 1} failed: {e}")
                        await asyncio.sleep(2)
                
                # Check for blocking
                is_blocked, block_reason = await check_if_blocked(page)
                if is_blocked:
                    errors.append(f"BOT_BLOCKED: {block_reason}")
                    logger.error(f"Blocked on page {page_num}: {block_reason}")
                    break
                
                # Wait for results
                await asyncio.sleep(random.uniform(*DELAY_BETWEEN_REQUESTS))
                
                # Human-like scroll to load lazy images
                await human_like_scroll(page)
                
                # Extract products
                page_products = await extract_products_from_page(page)
                
                if page_products:
                    products.extend(page_products)
                    pages_scraped += 1
                    logger.info(f"Found {len(page_products)} products on page {page_num}")
                else:
                    logger.warning(f"No products found on page {page_num}")
                    # Check if we got an empty results page
                    no_results = await page.query_selector(".srp-save-null-search, .srp-results--empty")
                    if no_results:
                        logger.info("No more results available")
                        break
                
                # Delay between pages
                if page_num < max_pages:
                    await asyncio.sleep(random.uniform(*DELAY_BETWEEN_PAGES))
                    
        except Exception as e:
            error_msg = f"Scraping error: {str(e)}"
            errors.append(error_msg)
            logger.error(error_msg)
        finally:
            await browser.close()
    
    completed_at = datetime.now(timezone.utc)
    duration = (completed_at - started_at).total_seconds()
    
    return ScrapingResult(
        success=len(products) > 0,
        products=products,
        total_products=len(products),
        pages_scraped=pages_scraped,
        errors=errors,
        started_at=started_at.isoformat(),
        completed_at=completed_at.isoformat(),
        duration_seconds=round(duration, 2),
    )


async def extract_products_from_page(page: Page) -> List[Product]:
    """Extract products from eBay search results page."""
    products = []
    
    # Wait for results to load
    try:
        await page.wait_for_selector("a[href*='/itm/']", timeout=10000)
    except Exception:
        logger.warning("Timeout waiting for results selector")
    
    # Extract all products using comprehensive JavaScript
    raw_products = await page.evaluate("""() => {
        const products = [];
        const seenIds = new Set();
        
        // Find all links to item pages
        const links = document.querySelectorAll('a[href*="/itm/"]');
        
        links.forEach(link => {
            try {
                const href = link.href;
                const match = href.match(/\\/itm\\/(\\d+)/);
                if (!match) return;
                
                const itemId = match[1];
                if (seenIds.has(itemId)) return;
                seenIds.add(itemId);
                
                // Navigate up to find the product container (usually 5-7 levels up)
                let container = link;
                for (let i = 0; i < 8 && container.parentElement; i++) {
                    container = container.parentElement;
                    // Stop if we find a data-viewport element (product container)
                    if (container.hasAttribute && container.hasAttribute('data-viewport')) break;
                }
                
                // Get all text in container
                const containerText = container.innerText || '';
                
                // Skip if too little text (probably not a product card)
                if (containerText.length < 20) return;
                
                // Find title - usually the link text or first significant line
                let title = link.getAttribute('title') || '';
                if (!title || title.length < 5) {
                    // Get text from the container, first line is usually the title
                    const lines = containerText.split('\\n').filter(l => l.trim().length > 5);
                    // Find a line that looks like a title (not price, not "Free shipping", etc)
                    for (const line of lines) {
                        const trimmed = line.trim();
                        const lower = trimmed.toLowerCase();
                        // Skip common non-title patterns
                        if (trimmed.startsWith('$')) continue;
                        if (trimmed.match(/^\\d+%\\s*off/i)) continue;
                        if (lower.includes('free shipping')) continue;
                        if (lower.includes('shop on ebay')) continue;
                        if (lower.includes('see all')) continue;
                        if (lower === 'new' || lower === 'used' || lower === 'refurbished') continue;
                        if (lower.includes('best offer')) continue;
                        if (lower.includes('new low price')) continue;
                        if (lower.includes('price drop')) continue;
                        if (lower.includes('sponsored')) continue;
                        if (lower.includes('trending at')) continue;
                        if (lower.includes('was:')) continue;
                        if (lower.includes('list price')) continue;
                        if (lower.match(/^\\d+\\s*(sold|watching|watchers)/i)) continue;
                        if (trimmed.match(/^[\\d,]+\\s*(sold|watchers)/i)) continue;
                        // Title should be descriptive (contains letters and be reasonably long)
                        if (trimmed.length > 15 && trimmed.length < 300 && /[a-zA-Z]{3,}/.test(trimmed)) {
                            title = trimmed;
                            break;
                        }
                    }
                }
                
                if (!title || title.length < 10) return;
                
                // Find price
                const priceMatch = containerText.match(/\\$(\\d{1,3}(?:,\\d{3})*(?:\\.\\d{2})?)/);
                if (!priceMatch) return;
                const price = parseFloat(priceMatch[1].replace(/,/g, ''));
                if (!price || price <= 0) return;
                
                // Find image
                let imageUrl = null;
                const img = container.querySelector('img[src*="ebayimg.com"]');
                if (img) {
                    imageUrl = img.src;
                }
                
                // Find sold count
                const soldMatch = containerText.match(/(\\d+(?:,\\d+)*(?:\\.\\d+)?k?)\\s*sold/i);
                let soldCount = null;
                if (soldMatch) {
                    let soldStr = soldMatch[1].replace(/,/g, '');
                    if (soldStr.toLowerCase().includes('k')) {
                        soldCount = Math.round(parseFloat(soldStr) * 1000);
                    } else {
                        soldCount = parseInt(soldStr);
                    }
                }
                
                products.push({
                    itemId: itemId,
                    title: title,
                    price: price,
                    imageUrl: imageUrl,
                    soldCount: soldCount
                });
                
            } catch (e) {
                // Skip on error
            }
        });
        
        return products;
    }""")
    
    logger.info(f"JavaScript extracted {len(raw_products)} products")
    
    for raw in raw_products:
        try:
            product = Product(
                name=raw['title'],
                price=raw['price'],
                source_url=f"https://www.ebay.com/itm/{raw['itemId']}",
                source_id=raw['itemId'],
                image_url=raw.get('imageUrl'),
                supplier_review_count=raw.get('soldCount'),
                supplier_name="eBay Seller",
            )
            products.append(product)
        except Exception as e:
            logger.debug(f"Error creating product: {e}")
    
    return products


def generate_demo_results(query: str, max_pages: int) -> ScrapingResult:
    """Generate demo/sample results for development."""
    started_at = datetime.now(timezone.utc)
    
    demo_products = [
        Product(
            name=f"NEW {query.title()} Premium Quality Fast Shipping",
            price=24.99,
            source_url="https://www.ebay.com/itm/123456789012",
            source_id="123456789012",
            image_url="https://i.ebayimg.com/images/g/demo1/s-l300.jpg",
            supplier_rating=4.9,
            supplier_review_count=1250,
        ),
        Product(
            name=f"Professional {query.title()} - Top Rated Seller",
            price=39.99,
            source_url="https://www.ebay.com/itm/234567890123",
            source_id="234567890123",
            image_url="https://i.ebayimg.com/images/g/demo2/s-l300.jpg",
            supplier_rating=5.0,
            supplier_review_count=3420,
        ),
        Product(
            name=f"Cheap {query.title()} - Best Deal Free Shipping",
            price=12.99,
            source_url="https://www.ebay.com/itm/345678901234",
            source_id="345678901234",
            image_url="https://i.ebayimg.com/images/g/demo3/s-l300.jpg",
            supplier_rating=4.7,
            supplier_review_count=890,
        ),
        Product(
            name=f"Bulk Lot {query.title()} Wholesale Price",
            price=89.99,
            source_url="https://www.ebay.com/itm/456789012345",
            source_id="456789012345",
            image_url="https://i.ebayimg.com/images/g/demo4/s-l300.jpg",
            supplier_rating=4.8,
            supplier_review_count=5670,
        ),
        Product(
            name=f"Vintage {query.title()} Rare Collectible",
            price=149.99,
            source_url="https://www.ebay.com/itm/567890123456",
            source_id="567890123456",
            image_url="https://i.ebayimg.com/images/g/demo5/s-l300.jpg",
            supplier_rating=4.6,
            supplier_review_count=234,
        ),
    ]
    
    # Adjust products per page
    products_count = min(len(demo_products), max_pages * 5)
    products = demo_products[:products_count]
    
    completed_at = datetime.now(timezone.utc)
    
    return ScrapingResult(
        success=True,
        products=products,
        total_products=len(products),
        pages_scraped=max_pages,
        errors=[],
        started_at=started_at.isoformat(),
        completed_at=completed_at.isoformat(),
        duration_seconds=0.5,
    )


# ============================================================================
# Django/Celery Integration
# ============================================================================

def scrape_ebay_sync(
    query: str,
    max_pages: int = 1,
    headless: bool = True,
    proxy: Optional[str] = None,
) -> Dict[str, Any]:
    """
    Synchronous wrapper for Celery/Django integration.
    
    Usage in Celery task:
        @celery_app.task
        def scrape_ebay_task(query, max_pages=1):
            return scrape_ebay_sync(query, max_pages)
    """
    demo_mode = os.environ.get("EBAY_DEMO_MODE", "false").lower() == "true"
    
    result = asyncio.run(scrape_ebay(
        query=query,
        max_pages=max_pages,
        headless=headless,
        proxy=proxy,
        demo_mode=demo_mode,
    ))
    
    return result.to_dict()


# ============================================================================
# CLI Interface
# ============================================================================

async def main():
    parser = argparse.ArgumentParser(description="eBay Product Scraper")
    parser.add_argument("query", help="Search query")
    parser.add_argument("pages", type=int, nargs="?", default=1, help="Number of pages to scrape")
    parser.add_argument("--headed", action="store_true", help="Run with visible browser")
    parser.add_argument("--proxy", type=str, help="Proxy URL (http://user:pass@host:port)")
    parser.add_argument("--demo", action="store_true", help="Use demo mode")
    parser.add_argument("--output", type=str, help="Output JSON file path")
    
    args = parser.parse_args()
    
    # Check for demo mode env var
    demo_mode = args.demo or os.environ.get("EBAY_DEMO_MODE", "false").lower() == "true"
    
    result = await scrape_ebay(
        query=args.query,
        max_pages=args.pages,
        headless=not args.headed,
        proxy=args.proxy,
        demo_mode=demo_mode,
    )
    
    # Generate output filename
    if args.output:
        output_file = args.output
    else:
        timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
        output_file = f"ebay_results_{timestamp}.json"
    
    # Save results
    with open(output_file, "w", encoding="utf-8") as f:
        json.dump(result.to_dict(), f, indent=2, ensure_ascii=False)
    
    # Print summary
    print(f"\n{'='*60}")
    print(f"eBay Scraping Results")
    print(f"{'='*60}")
    print(f"Query: {args.query}")
    print(f"Success: {result.success}")
    print(f"Total Products: {result.total_products}")
    print(f"Pages Scraped: {result.pages_scraped}")
    print(f"Duration: {result.duration_seconds}s")
    
    if result.errors:
        print(f"\nErrors:")
        for error in result.errors:
            print(f"  - {error}")
    
    if result.products:
        print(f"\nSample Products:")
        for i, product in enumerate(result.products[:3], 1):
            print(f"\n  {i}. {product.name[:60]}...")
            print(f"     Price: ${product.price:.2f} | Cost: ${product.cost:.2f} | Profit: ${product.profit:.2f}")
            print(f"     Category: {product.category} | Score: {product.score}")
            print(f"     Rating: {product.supplier_rating} | Sold: {product.supplier_review_count}")
            print(f"     Trending: {product.is_trending}")
    
    print(f"\nResults saved to: {output_file}")
    print(f"{'='*60}")


if __name__ == "__main__":
    asyncio.run(main())
