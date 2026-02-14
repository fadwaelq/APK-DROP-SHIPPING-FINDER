"""
Unified Multi-Source Product Scraper.
Runs Amazon, eBay, Shopify, and AliExpress scrapers in parallel.
"""

import asyncio
import json
import argparse
import logging
from datetime import datetime
from typing import Dict, Any, List, Optional

# Import scrapers
from amazon_scraper import scrape_amazon
from ebay_scraper import scrape_ebay
from shopify_scraper import scrape_shopify
from aliexpress_scraper import scrape_aliexpress

logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s'
)
logger = logging.getLogger(__name__)


async def scrape_all_sources(
    query: str,
    max_products: int = 20,
    sources: List[str] = None,
    headless: bool = True,
    shopify_stores: List[str] = None,
) -> Dict[str, Any]:
    """
    Scrape products from multiple sources in parallel.
    """
    if sources is None:
        sources = ['amazon', 'ebay', 'shopify', 'aliexpress']  # All sources
    
    started_at = datetime.now()
    tasks = []
    source_names = []
    
    if 'amazon' in sources:
        tasks.append(scrape_amazon(query, max_pages=1, headless=headless))
        source_names.append('amazon')
    
    if 'ebay' in sources:
        tasks.append(scrape_ebay(query, max_pages=1, headless=headless))
        source_names.append('ebay')
    
    if 'shopify' in sources:
        tasks.append(scrape_shopify(
            store_urls=shopify_stores,
            query=query,
            max_products_per_store=max_products,
            headless=headless
        ))
        source_names.append('shopify')
    
    if 'aliexpress' in sources:
        tasks.append(scrape_aliexpress(query, num_pages=1, headless=headless))
        source_names.append('aliexpress')
    
    logger.info(f"Starting parallel scrape for '{query}' from: {', '.join(source_names)}")
    results = await asyncio.gather(*tasks, return_exceptions=True)
    
    all_products = []
    source_stats = {}
    errors = []
    
    for source_name, result in zip(source_names, results):
        if isinstance(result, Exception):
            errors.append(f"{source_name}: {str(result)}")
            source_stats[source_name] = {"success": False, "products": 0, "error": str(result)}
        else:
            products = result.products[:max_products]
            all_products.extend(products)
            source_stats[source_name] = {
                "success": result.success,
                "products": len(products),
                "duration": result.duration_seconds
            }
            if result.errors:
                errors.extend([f"{source_name}: {e}" for e in result.errors])
    
    completed_at = datetime.now()
    duration = (completed_at - started_at).total_seconds()
    
    return {
        "success": len(all_products) > 0,
        "query": query,
        "total_products": len(all_products),
        "products": [p.to_dict() for p in all_products],
        "sources": source_stats,
        "errors": errors,
        "started_at": started_at.isoformat(),
        "completed_at": completed_at.isoformat(),
        "duration_seconds": round(duration, 2),
    }


def scrape_all_sync(query: str, max_products: int = 20, sources: List[str] = None, headless: bool = True) -> Dict[str, Any]:
    """Synchronous wrapper for Django/Celery integration."""
    return asyncio.run(scrape_all_sources(query=query, max_products=max_products, sources=sources, headless=headless))


async def main():
    parser = argparse.ArgumentParser(description="Multi-Source Product Scraper")
    parser.add_argument("query", help="Search query")
    parser.add_argument("--max", type=int, default=20, help="Max products per source")
    parser.add_argument("--sources", nargs="+", choices=['amazon', 'ebay', 'shopify', 'aliexpress'], default=['amazon', 'ebay', 'shopify', 'aliexpress'])
    parser.add_argument("--headed", action="store_true", help="Run with visible browser")
    parser.add_argument("--output", type=str, help="Output JSON file")
    
    args = parser.parse_args()
    
    result = await scrape_all_sources(query=args.query, max_products=args.max, sources=args.sources, headless=not args.headed)
    
    output_file = args.output or f"combined_results_{datetime.now().strftime('%Y%m%d_%H%M%S')}.json"
    with open(output_file, "w", encoding="utf-8") as f:
        json.dump(result, f, indent=2, ensure_ascii=False)
    
    print(f"\n{'='*60}")
    print(f"Query: {args.query} | Total: {result['total_products']} products | Duration: {result['duration_seconds']}s")
    for source, stats in result['sources'].items():
        print(f"  [{'OK' if stats['success'] else 'FAIL'}] {source}: {stats['products']} products")
    print(f"Saved to: {output_file}\n{'='*60}")


if __name__ == "__main__":
    asyncio.run(main())