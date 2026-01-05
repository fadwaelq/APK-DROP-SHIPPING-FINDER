"""
Celery tasks for automatic product import
"""
from celery import shared_task
from django.utils import timezone
from core.models import Product
from .aliexpress_connector import AliExpressConnector
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
