"""
Celery tasks for automatic product import
Includes both traditional web scraping and Puppeteer-based scraping
"""
from celery import shared_task
from django.utils import timezone
from core.models import Product
from .aliexpress_connector import AliExpressConnector
from core.scrapers.puppeteer_scraper import PuppeteerScraper
import logging

logger = logging.getLogger(__name__)


@shared_task(name='integrations.sync_aliexpress_products')
def sync_aliexpress_products(query, max_pages=3, use_tor=True):
    """
    Sync products from AliExpress
    
    Args:
        query: Search query
        max_pages: Maximum number of pages to scrape
        use_tor: Use Tor for anonymity
        
    Returns:
        dict: Statistics about the import
    """
    logger.info(f"Starting AliExpress sync for query: {query}")
    
    connector = AliExpressConnector(use_tor=use_tor)
    
    stats = {
        'total_found': 0,
        'created': 0,
        'updated': 0,
        'errors': 0,
    }
    
    try:
        for page in range(1, max_pages + 1):
            logger.info(f"Processing page {page}/{max_pages}")
            
            # Search products
            products = connector.search_products(query, page=page)
            stats['total_found'] += len(products)
            
            for product_data in products:
                try:
                    # Get detailed information
                    if product_data.get('source_url'):
                        details = connector.get_product_details(product_data['source_url'])
                        product_data.update(details)
                    
                    # Normalize data
                    normalized = connector.normalize_product(product_data)
                    
                    # Create or update product
                    product, created = Product.objects.update_or_create(
                        source_url=normalized['source_url'],
                        defaults={
                            'title': normalized['title'],
                            'description': normalized['description'],
                            'price': normalized['price'],
                            'image_url': normalized['image_url'],
                            'sales_volume': normalized['sales_volume'],
                            'rating': normalized['rating'],
                            'reviews_count': normalized['reviews_count'],
                            'source_platform': normalized['source_platform'],
                            'supplier_name': normalized['supplier_name'],
                            'supplier_url': normalized['supplier_url'],
                            'category': normalized['category'] or query,
                            'last_updated': timezone.now(),
                        }
                    )
                    
                    if created:
                        stats['created'] += 1
                        logger.info(f"Created product: {product.title}")
                    else:
                        stats['updated'] += 1
                        logger.info(f"Updated product: {product.title}")
                    
                    # Calculate AI score
                    product.calculate_ai_score()
                    product.save()
                    
                except Exception as e:
                    stats['errors'] += 1
                    logger.error(f"Error processing product: {e}")
                    continue
    
    except Exception as e:
        logger.error(f"Error in sync_aliexpress_products: {e}")
        stats['errors'] += 1
    
    logger.info(f"AliExpress sync completed: {stats}")
    return stats


@shared_task(name='integrations.sync_trending_products')
def sync_trending_products(categories=None, use_tor=True):
    """
    Sync trending products from multiple categories
    
    Args:
        categories: List of categories to sync (default: popular categories)
        use_tor: Use Tor for anonymity
        
    Returns:
        dict: Statistics about the import
    """
    if categories is None:
        categories = [
            'phone accessories',
            'smart watch',
            'wireless earbuds',
            'led lights',
            'home decor',
            'fitness equipment',
            'beauty products',
            'pet supplies',
        ]
    
    logger.info(f"Starting trending products sync for {len(categories)} categories")
    
    total_stats = {
        'categories_processed': 0,
        'total_created': 0,
        'total_updated': 0,
        'total_errors': 0,
    }
    
    for category in categories:
        logger.info(f"Syncing category: {category}")
        
        try:
            stats = sync_aliexpress_products(category, max_pages=2, use_tor=use_tor)
            total_stats['categories_processed'] += 1
            total_stats['total_created'] += stats['created']
            total_stats['total_updated'] += stats['updated']
            total_stats['total_errors'] += stats['errors']
        except Exception as e:
            logger.error(f"Error syncing category {category}: {e}")
            total_stats['total_errors'] += 1
    
    logger.info(f"Trending products sync completed: {total_stats}")
    return total_stats


@shared_task(name='integrations.update_product_scores')
def update_product_scores():
    """
    Update AI scores for all products
    """
    logger.info("Starting product scores update")
    
    products = Product.objects.all()
    updated_count = 0
    
    for product in products:
        try:
            product.calculate_ai_score()
            product.save()
            updated_count += 1
        except Exception as e:
            logger.error(f"Error updating score for product {product.id}: {e}")
    
    logger.info(f"Updated scores for {updated_count} products")
    return {'updated': updated_count}


@shared_task(name='integrations.cleanup_old_products')
def cleanup_old_products(days=30):
    """
    Remove products that haven't been updated in X days
    
    Args:
        days: Number of days of inactivity before deletion
    """
    from datetime import timedelta
    
    logger.info(f"Starting cleanup of products older than {days} days")
    
    cutoff_date = timezone.now() - timedelta(days=days)
    old_products = Product.objects.filter(last_updated__lt=cutoff_date)
    
    count = old_products.count()
    old_products.delete()
    
    logger.info(f"Deleted {count} old products")
    return {'deleted': count}


# ============================================
# PUPPETEER-BASED SCRAPING TASKS
# ============================================

@shared_task(bind=True, max_retries=3, time_limit=300, name='integrations.scrape_product_with_puppeteer')
def scrape_product_with_puppeteer(self, url: str, user_id: int = None):
    """
    Async scraping task using Puppeteer
    Handles JavaScript-rendered content and dynamic prices
    
    Args:
        url: AliExpress product URL
        user_id: Optional user ID for tracking
        
    Returns:
        Dict with scraping results
    """
    
    job = None
    
    try:
        # Import here to avoid circular imports
        from core.models import ScrapingJob
        
        # Create scraping job record
        job = ScrapingJob.objects.create(
            url=url,
            user_id=user_id,
            status='processing',
            started_at=timezone.now()
        )
        
        logger.info(f"🚀 Starting Puppeteer scrape: {url} (Job: {job.id})")
        
        # Scrape with Puppeteer
        scraper = PuppeteerScraper(use_tor=True, headless=True)
        data = scraper.scrape_product(url)
        
        if not data:
            job.status = 'failed'
            job.error_message = 'Scraping returned no data'
            job.ended_at = timezone.now()
            job.save()
            logger.error(f"❌ No data scraped for {url}")
            return {'status': 'failed', 'message': 'No data'}
        
        # Check for duplicates
        product, created = Product.objects.update_or_create(
            source_url=url,
            defaults={
                'name': data['title'],
                'description': data.get('description', ''),
                'price': data.get('price') or 0,
                'cost': (data.get('price') or 0) * 0.3,  # 30% cost
                'profit': (data.get('price') or 0) * 0.7,  # 70% profit
                'images': data.get('images', []),
                'image_url': data.get('images', [''])[0] if data.get('images') else '',
                'source': 'aliexpress',
                'category': 'electronics',  # Auto-detect in production
                'supplier_name': data.get('supplier', 'Unknown'),
                'supplier_rating': float(data.get('supplier_rating', 0)),
                'supplier_review_count': data.get('reviews', 0),
                'is_trending': data.get('sales', 0) > 1000,
                'trend_percentage': _calculate_trend_score(data.get('sales', 0)),
                'last_scraped_at': timezone.now(),
            }
        )
        
        # Update job
        job.status = 'completed'
        job.product = product
        job.ended_at = timezone.now()
        job.save()
        
        logger.info(f"✅ Scraping completed: {product.name} ({'Created' if created else 'Updated'})")
        
        return {
            'status': 'success',
            'product_id': product.id,
            'created': created,
            'title': product.name,
            'price': float(product.price),
        }
        
    except Exception as exc:
        logger.error(f"❌ Scraping failed: {exc}")
        
        if job:
            job.status = 'failed'
            job.error_message = str(exc)
            job.ended_at = timezone.now()
            job.save()
        
        # Retry with exponential backoff: 2s, 4s, 8s
        countdown = 2 ** self.request.retries
        raise self.retry(exc=exc, countdown=countdown)


@shared_task(bind=True, name='integrations.scrape_batch_products')
def scrape_batch_products(self, urls: list, user_id: int = None):
    """
    Scrape multiple products in batch
    Queues individual Puppeteer scraping tasks
    
    Args:
        urls: List of AliExpress URLs
        user_id: Optional user ID for tracking
        
    Returns:
        Dict with queued task information
    """
    logger.info(f"🔄 Starting batch scrape: {len(urls)} products")
    
    results = []
    for url in urls:
        try:
            result = scrape_product_with_puppeteer.delay(url, user_id)
            results.append(result.id)
        except Exception as e:
            logger.error(f"Failed to queue {url}: {e}")
    
    return {
        'status': 'queued',
        'task_ids': results,
        'total': len(urls)
    }


def _calculate_trend_score(sales: int) -> float:
    """Calculate trend percentage based on sales"""
    if sales > 10000:
        return 95.0
    elif sales > 5000:
        return 85.0
    elif sales > 1000:
        return 70.0
    else:
        return 40.0


# ============================================
# CELERY BEAT SCHEDULED TASKS (Daily Scraping)
# ============================================

@shared_task(name='integrations.scrape_trending_daily', bind=True)
def scrape_trending_daily(self):
    """
    Daily scheduled task: Scrape trending products from all categories
    Runs every day at midnight (00:00)
    Populates database with fresh data for mobile app discovery
    
    Returns:
        dict: Statistics about the daily scrape
    """
    categories = ['tech', 'home', 'fashion', 'sport', 'beauty', 'toys', 'health']
    
    logger.info(f"🌙 Starting daily trending scrape for {len(categories)} categories")
    
    total_stats = {
        'categories_processed': 0,
        'total_products': 0,
        'timestamp': timezone.now().isoformat(),
    }
    
    for category in categories:
        try:
            result = scrape_category_trending.delay(category)
            total_stats['categories_processed'] += 1
            logger.info(f"Queued category scrape: {category} (task_id: {result.id})")
        except Exception as e:
            logger.error(f"Error queueing category {category}: {e}")
    
    logger.info(f"✅ Daily scrape scheduled: {total_stats}")
    return total_stats


@shared_task(name='integrations.scrape_category_trending', bind=True, max_retries=3)
def scrape_category_trending(self, category):
    """
    Scrape trending products for a specific category
    Called by daily scheduler
    Updates existing products with fresh data
    
    Args:
        category: Category to scrape (tech, home, fashion, etc.)
        
    Returns:
        dict: Statistics about the category scrape
    """
    logger.info(f"📊 Scraping trending products for category: {category}")
    
    try:
        from core.scrapers.aliexpress_import import import_product_from_aliexpress
        
        # Category search queries on AliExpress
        category_queries = {
            'tech': 'wireless headphones',
            'home': 'smart home devices',
            'fashion': 'winter fashion',
            'sport': 'fitness equipment',
            'beauty': 'skincare products',
            'toys': 'educational toys',
            'health': 'health supplements',
        }
        
        query = category_queries.get(category, category)
        stats = sync_aliexpress_products(query, max_pages=2, use_tor=False)
        
        logger.info(f"✅ Category {category} scraped: {stats}")
        return stats
        
    except Exception as exc:
        logger.error(f"❌ Error scraping category {category}: {exc}")
        # Retry with exponential backoff
        raise self.retry(exc=exc, countdown=60 * (self.request.retries + 1), max_retries=3)


@shared_task(name='integrations.update_trending_flags', bind=True)
def update_trending_flags(self):
    """
    Update is_trending flag for products based on sales volume
    Runs every 4 hours
    
    Returns:
        dict: Number of products marked as trending
    """
    from django.db.models import Q
    
    logger.info("📈 Updating trending product flags")
    
    try:
        # Mark products with high sales as trending
        trending_count = Product.objects.filter(
            supplier_review_count__gte=100
        ).update(is_trending=True)
        
        # Unmark products with low sales
        not_trending_count = Product.objects.filter(
            supplier_review_count__lt=50
        ).update(is_trending=False)
        
        logger.info(f"✅ Updated {trending_count} trending products, {not_trending_count} non-trending")
        return {
            'trending_updated': trending_count,
            'not_trending_updated': not_trending_count,
            'timestamp': timezone.now().isoformat(),
        }
        
    except Exception as exc:
        logger.error(f"❌ Error updating trending flags: {exc}")
        raise self.retry(exc=exc, countdown=300)


@shared_task(name='integrations.cleanup_old_scraping_jobs', bind=True)
def cleanup_old_scraping_jobs(self):
    """
    Clean up old scraping job records (older than 7 days)
    Runs weekly on Sunday at 03:00
    
    Returns:
        dict: Number of deleted jobs
    """
    from core.models import ScrapingJob
    from datetime import timedelta
    
    logger.info("🧹 Cleaning up old scraping job records")
    
    try:
        cutoff_date = timezone.now() - timedelta(days=7)
        
        deleted_count, _ = ScrapingJob.objects.filter(
            started_at__lt=cutoff_date
        ).delete()
        
        logger.info(f"✅ Deleted {deleted_count} old scraping jobs")
        return {
            'deleted_jobs': deleted_count,
            'timestamp': timezone.now().isoformat(),
        }
        
    except Exception as exc:
        logger.error(f"❌ Error cleaning up jobs: {exc}")
        raise self.retry(exc=exc, countdown=300)
