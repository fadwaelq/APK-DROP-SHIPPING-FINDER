"""
Amazon Product Scraper using Playwright (async).
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
    "Electronics": ["phone", "cable", "charger", "headphone", "earphone", "bluetooth", "usb", "adapter", "speaker", "camera", "watch", "smart", "laptop", "tablet", "kindle", "echo", "alexa"],
    "Fashion": ["dress", "shirt", "pants", "shoes", "bag", "wallet", "jewelry", "necklace", "ring", "bracelet", "clothing", "fashion", "sneakers", "boots"],
    "Home & Garden": ["home", "kitchen", "garden", "furniture", "lamp", "light", "decor", "bed", "pillow", "curtain", "coffee", "blender", "vacuum"],
    "Sports": ["sport", "fitness", "gym", "yoga", "bicycle", "running", "outdoor", "camping", "golf", "tennis", "basketball"],
    "Beauty": ["makeup", "beauty", "skincare", "cosmetic", "hair", "nail", "perfume", "shampoo", "lotion"],
    "Toys": ["toy", "game", "puzzle", "doll", "kid", "baby", "children", "lego", "nerf"],
    "Automotive": ["car", "auto", "vehicle", "motor", "bike", "motorcycle", "dash cam"],
    "Books": ["book", "paperback", "hardcover", "kindle edition", "audiobook"],
    "Pet Supplies": ["pet", "dog", "cat", "fish", "bird", "aquarium", "leash", "collar"],
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
    source: str = "amazon"
    source_id: Optional[str] = None
    supplier_name: str = "Amazon Seller"
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
            self.description = f"Product from Amazon - {self.name[:100]}"
        
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
    """Parse price from Amazon price string."""
    if not price_text:
        return None
    
    # Remove currency symbols and clean
    clean = re.sub(r'[^\d.,]', '', price_text)
    
    # Handle different formats (1,234.56 or 1.234,56)
    if ',' in clean and '.' in clean:
        if clean.index(',') < clean.index('.'):
            clean = clean.replace(',', '')  # 1,234.56 format
        else:
            clean = clean.replace('.', '').replace(',', '.')  # 1.234,56 format
    elif ',' in clean:
        # Could be thousand separator or decimal
        parts = clean.split(',')
        if len(parts[-1]) == 2:
            clean = clean.replace(',', '.')  # Decimal separator
        else:
            clean = clean.replace(',', '')  # Thousand separator
    
    try:
        return round(float(clean), 2)
    except ValueError:
        return None


def parse_rating(rating_text: str) -> Optional[float]:
    """Parse rating from Amazon rating string (e.g., '4.5 out of 5 stars')."""
    if not rating_text:
        return None
    
    match = re.search(r'([\d.]+)\s*out of\s*5|^([\d.]+)$', rating_text)
    if match:
        rating_str = match.group(1) or match.group(2)
        try:
            return float(rating_str)
        except ValueError:
            return None
    return None


def parse_review_count(review_text: str) -> Optional[int]:
    """Parse review count from string (e.g., '1,234 ratings' or '(1.2k)')."""
    if not review_text:
        return None
    
    # Handle 'k' suffix (thousands)
    if 'k' in review_text.lower():
        match = re.search(r'([\d.]+)\s*k', review_text.lower())
        if match:
            return int(float(match.group(1)) * 1000)
    
    # Regular number extraction
    clean = re.sub(r'[^\d]', '', review_text)
    if clean:
        try:
            return int(clean)
        except ValueError:
            return None
    return None


def extract_asin(url: str) -> Optional[str]:
    """Extract Amazon ASIN from product URL."""
    patterns = [
        r'/dp/([A-Z0-9]{10})',
        r'/gp/product/([A-Z0-9]{10})',
        r'/product/([A-Z0-9]{10})',
    ]
    for pattern in patterns:
        match = re.search(pattern, url)
        if match:
            return match.group(1)
    return None


async def check_if_blocked(page: Page) -> tuple[bool, str]:
    """Check if Amazon has blocked the request."""
    content = await page.content()
    
    blocked_indicators = [
        ("captcha", "CAPTCHA required"),
        ("robot check", "Robot check detected"),
        ("automated access", "Automated access blocked"),
        ("api-services-support@amazon.com", "Bot detection triggered"),
        ("Sorry, we just need to make sure you're not a robot", "Robot verification required"),
        ("Enter the characters you see below", "CAPTCHA challenge"),
    ]
    
    content_lower = content.lower()
    for indicator, message in blocked_indicators:
        if indicator in content_lower:
            return True, message
    
    return False, ""


async def scrape_amazon(
    query: str,
    max_pages: int = 1,
    headless: bool = True,
    proxy: Optional[str] = None,
    demo_mode: bool = False,
) -> ScrapingResult:
    """
    Scrape Amazon search results.
    
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
    
    logger.info(f"Starting Amazon scrape: query='{query}', pages={max_pages}")
    
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
                search_url = f"https://www.amazon.com/s?k={query.replace(' ', '+')}"
                if page_num > 1:
                    search_url += f"&page={page_num}"
                
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
                
                # Extract products using multiple selector strategies
                page_products = await extract_products_from_page(page)
                
                if page_products:
                    products.extend(page_products)
                    pages_scraped += 1
                    logger.info(f"Found {len(page_products)} products on page {page_num}")
                else:
                    logger.warning(f"No products found on page {page_num}")
                    # Check if we got an empty results page
                    no_results = await page.query_selector("div.s-no-outline") 
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
    """Extract products from Amazon search results page."""
    products = []
    
    # Multiple selector strategies for resilience
    selectors = [
        "div[data-component-type='s-search-result']",  # Main search result container
        "div.s-result-item[data-asin]:not([data-asin=''])",  # Alternative
    ]
    
    items = []
    for selector in selectors:
        items = await page.query_selector_all(selector)
        if items:
            logger.info(f"Found {len(items)} items using selector: {selector}")
            break
    
    if not items:
        logger.warning("No product items found with any selector")
        return products
    
    for item in items:
        try:
            # Skip sponsored ads without ASIN
            asin = await item.get_attribute("data-asin")
            if not asin:
                continue
            
            # Skip ad placeholders
            ad_badge = await item.query_selector("span:has-text('Sponsored')")
            
            # Product URL and ASIN - broader selector
            link_elem = await item.query_selector("a[href*='/dp/'], a.a-link-normal.s-no-outline")
            if not link_elem:
                logger.debug(f"No link found for ASIN {asin}")
                continue
                
            href = await link_elem.get_attribute("href")
            if not href or '/dp/' not in href:
                logger.debug(f"Invalid href for ASIN {asin}: {href}")
                continue
            
            source_url = f"https://www.amazon.com{href}" if href.startswith('/') else href
            # Clean up URL - keep only the /dp/ASIN part
            asin_match = re.search(r'/dp/([A-Z0-9]{10})', source_url)
            if asin_match:
                source_url = f"https://www.amazon.com/dp/{asin_match.group(1)}"
            source_id = asin or (asin_match.group(1) if asin_match else None)
            
            # Product name - try multiple selectors (more comprehensive)
            name = None
            name_selectors = [
                "h2 span",
                "h2 a span",
                "h2 a",
                "[data-cy='title-recipe'] h2 span",
                "span.a-size-medium.a-color-base.a-text-normal",
                "span.a-size-base-plus.a-color-base.a-text-normal",
                "span.a-text-normal",
            ]
            for name_sel in name_selectors:
                name_elem = await item.query_selector(name_sel)
                if name_elem:
                    name = await name_elem.inner_text()
                    if name and len(name.strip()) > 5:
                        name = name.strip()
                        break
            
            if not name:
                logger.debug(f"No name found for ASIN {asin}")
                continue
            
            # Price - try multiple selectors (more comprehensive)
            price = None
            price_selectors = [
                "span.a-price span.a-offscreen",
                "span.a-price:not([data-a-strike]) span.a-offscreen",
                "span[data-a-color='price'] span.a-offscreen",
                "span.a-price-whole",
            ]
            for price_sel in price_selectors:
                price_elem = await item.query_selector(price_sel)
                if price_elem:
                    price_text = await price_elem.inner_text()
                    price = parse_price(price_text)
                    if price and price > 0:
                        break
            
            if not price or price <= 0:
                logger.debug(f"No price found for ASIN {asin}: {name[:30]}")
                continue
            
            # Image URL
            image_url = None
            img_elem = await item.query_selector("img.s-image")
            if img_elem:
                image_url = await img_elem.get_attribute("src")
            
            # Rating
            rating = None
            rating_elem = await item.query_selector("span.a-icon-alt")
            if rating_elem:
                rating_text = await rating_elem.inner_text()
                rating = parse_rating(rating_text)
            
            # Review count - look for the ratings link text
            review_count = None
            review_selectors = [
                "a[href*='customerReviews'] span",
                "span.a-size-base.s-underline-text",
                "a.s-underline-text span",
                "[data-cy='reviews-block'] span.a-size-base",
                "div[data-cy='reviews-ratings-count'] span",
            ]
            for rev_sel in review_selectors:
                review_elem = await item.query_selector(rev_sel)
                if review_elem:
                    review_text = await review_elem.inner_text()
                    if review_text:
                        review_count = parse_review_count(review_text)
                        if review_count and review_count > 0:
                            break
            
            # Create product with auto-computed fields
            product = Product(
                name=name,
                price=price,
                source_url=source_url,
                source_id=source_id,
                image_url=image_url,
                supplier_rating=rating,
                supplier_review_count=review_count,
                supplier_name="Amazon Seller" if not ad_badge else "Amazon Sponsored",
            )
            
            products.append(product)
            logger.debug(f"Extracted: {name[:50]}... @ ${price}")
            
        except Exception as e:
            logger.debug(f"Error extracting product: {e}")
            continue
    
    return products


def generate_demo_results(query: str, max_pages: int) -> ScrapingResult:
    """Generate demo/sample results for development."""
    started_at = datetime.now(timezone.utc)
    
    demo_products = [
        Product(
            name=f"Premium {query.title()} - High Quality Edition",
            price=29.99,
            source_url=f"https://www.amazon.com/dp/B0DEMO001",
            source_id="B0DEMO001",
            image_url="https://m.media-amazon.com/images/I/demo1.jpg",
            supplier_rating=4.5,
            supplier_review_count=1250,
        ),
        Product(
            name=f"Professional {query.title()} Kit with Accessories",
            price=49.99,
            source_url=f"https://www.amazon.com/dp/B0DEMO002",
            source_id="B0DEMO002",
            image_url="https://m.media-amazon.com/images/I/demo2.jpg",
            supplier_rating=4.7,
            supplier_review_count=3420,
        ),
        Product(
            name=f"Budget {query.title()} - Best Value",
            price=14.99,
            source_url=f"https://www.amazon.com/dp/B0DEMO003",
            source_id="B0DEMO003",
            image_url="https://m.media-amazon.com/images/I/demo3.jpg",
            supplier_rating=4.2,
            supplier_review_count=890,
        ),
        Product(
            name=f"Deluxe {query.title()} Bundle Pack",
            price=79.99,
            source_url=f"https://www.amazon.com/dp/B0DEMO004",
            source_id="B0DEMO004",
            image_url="https://m.media-amazon.com/images/I/demo4.jpg",
            supplier_rating=4.8,
            supplier_review_count=5670,
        ),
        Product(
            name=f"Compact {query.title()} for Travel",
            price=19.99,
            source_url=f"https://www.amazon.com/dp/B0DEMO005",
            source_id="B0DEMO005",
            image_url="https://m.media-amazon.com/images/I/demo5.jpg",
            supplier_rating=4.3,
            supplier_review_count=456,
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

def scrape_amazon_sync(
    query: str,
    max_pages: int = 1,
    headless: bool = True,
    proxy: Optional[str] = None,
) -> Dict[str, Any]:
    """
    Synchronous wrapper for Celery/Django integration.
    
    Usage in Celery task:
        @celery_app.task
        def scrape_amazon_task(query, max_pages=1):
            return scrape_amazon_sync(query, max_pages)
    """
    demo_mode = os.environ.get("AMAZON_DEMO_MODE", "false").lower() == "true"
    
    result = asyncio.run(scrape_amazon(
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
    parser = argparse.ArgumentParser(description="Amazon Product Scraper")
    parser.add_argument("query", help="Search query")
    parser.add_argument("pages", type=int, nargs="?", default=1, help="Number of pages to scrape")
    parser.add_argument("--headed", action="store_true", help="Run with visible browser")
    parser.add_argument("--proxy", type=str, help="Proxy URL (http://user:pass@host:port)")
    parser.add_argument("--demo", action="store_true", help="Use demo mode")
    parser.add_argument("--output", type=str, help="Output JSON file path")
    
    args = parser.parse_args()
    
    # Check for demo mode env var
    demo_mode = args.demo or os.environ.get("AMAZON_DEMO_MODE", "false").lower() == "true"
    
    result = await scrape_amazon(
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
        output_file = f"amazon_results_{timestamp}.json"
    
    # Save results
    with open(output_file, "w", encoding="utf-8") as f:
        json.dump(result.to_dict(), f, indent=2, ensure_ascii=False)
    
    # Print summary
    print(f"\n{'='*60}")
    print(f"Amazon Scraping Results")
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
            print(f"     Rating: {product.supplier_rating} | Reviews: {product.supplier_review_count}")
            print(f"     Trending: {product.is_trending}")
    
    print(f"\nResults saved to: {output_file}")
    print(f"{'='*60}")


if __name__ == "__main__":
    asyncio.run(main())