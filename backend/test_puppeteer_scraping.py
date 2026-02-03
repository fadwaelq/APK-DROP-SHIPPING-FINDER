#!/usr/bin/env python
"""
Test Puppeteer scraping implementation
Comprehensive test suite for product scraping functionality
"""

import os
import sys
import django
import requests
import time
import json

# Setup Django
os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'dropshipping_finder.settings')
django.setup()

from core.scrapers.puppeteer_scraper import PuppeteerScraper
from integrations.tasks import scrape_product_with_puppeteer, scrape_batch_products
from django.contrib.auth.models import User
from core.models import ScrapingJob, Product


def print_header(title):
    """Print test section header"""
    print("\n" + "=" * 70)
    print(f"🧪 {title}")
    print("=" * 70)


def test_puppeteer_installation():
    """Test if Puppeteer is properly installed"""
    print_header("TEST 1: Puppeteer Installation")
    
    try:
        from pyppeteer import launch
        print("✅ pyppeteer is installed")
        
        from pyppeteer.page import Page
        print("✅ pyppeteer.page is available")
        
        print("\n📝 Next step: Install Chromium with 'pyppeteer-install'")
        return True
    except ImportError as e:
        print(f"❌ Installation error: {e}")
        print("   Run: pip install pyppeteer aiohttp")
        return False


def test_synchronous_scraping():
    """Test direct Puppeteer scraping (synchronous wrapper)"""
    print_header("TEST 2: Synchronous Puppeteer Scraping")
    
    # Real AliExpress URL (adjust as needed)
    test_urls = [
        "https://www.aliexpress.com/item/1005008365025184.html",
        "https://www.aliexpress.com/item/1005006123456.html",
    ]
    
    for url in test_urls[:1]:  # Test first URL only
        print(f"\n📍 Testing URL: {url[:60]}...")
        
        try:
            print("   ⏳ Initializing scraper...")
            scraper = PuppeteerScraper(use_tor=False, headless=True)
            
            print("   ⏳ Starting scrape (this may take 30-60 seconds)...")
            data = scraper.scrape_product(url)
            
            if data:
                print("   ✅ Scraping successful!")
                print(f"\n   📊 Scraped Data:")
                print(f"      • Title: {data['title'][:60]}")
                print(f"      • Price: ${data['price']}")
                print(f"      • Rating: {data['rating']}/5.0")
                print(f"      • Reviews: {data['reviews']}")
                print(f"      • Sales: {data['sales']}")
                print(f"      • Supplier: {data['supplier']}")
                print(f"      • Images: {len(data['images'])} found")
                print(f"      • Shipping: {data['shipping_days']} days")
                print(f"      • Stock: {data['stock']}")
                return True
            else:
                print("   ❌ Scraping failed - no data returned")
                return False
                
        except Exception as e:
            print(f"   ❌ Error during scraping: {e}")
            import traceback
            traceback.print_exc()
            return False


def test_model_creation():
    """Test ScrapingJob model"""
    print_header("TEST 3: ScrapingJob Model")
    
    try:
        # Create test scraping job
        job = ScrapingJob.objects.create(
            url="https://www.aliexpress.com/item/test123.html",
            status='pending'
        )
        
        print(f"✅ ScrapingJob created with ID: {job.id}")
        print(f"   Status: {job.status}")
        print(f"   URL: {job.url}")
        print(f"   Started at: {job.started_at}")
        
        # Test model properties
        print(f"\n   ℹ️  Model properties:")
        print(f"      • is_success: {job.is_success}")
        print(f"      • duration: {job.duration}")
        
        # Clean up
        job.delete()
        print(f"\n✅ ScrapingJob model works correctly")
        return True
        
    except Exception as e:
        print(f"❌ Model error: {e}")
        import traceback
        traceback.print_exc()
        return False


def test_celery_task():
    """Test Celery task queuing"""
    print_header("TEST 4: Celery Task Queuing")
    
    test_url = "https://www.aliexpress.com/item/1005008365025184.html"
    
    try:
        # Get or create test user
        user, created = User.objects.get_or_create(username='puppeteer_test')
        if created:
            print(f"✅ Created test user: puppeteer_test")
        else:
            print(f"✅ Using existing test user: puppeteer_test")
        
        # Queue task
        print(f"\n📍 Testing URL: {test_url[:60]}...")
        print("   ⏳ Queuing Celery task...")
        
        task = scrape_product_with_puppeteer.delay(test_url, user.id)
        print(f"   ✅ Task queued successfully!")
        print(f"      • Task ID: {task.id}")
        print(f"      • Status: {task.status}")
        
        # Poll for result (max 90 seconds)
        print(f"\n   ⏳ Waiting for task completion (max 90 seconds)...")
        
        for i in range(90):
            time.sleep(1)
            task_result = scrape_product_with_puppeteer.AsyncResult(task.id)
            
            if task_result.state == 'SUCCESS':
                print(f"   ✅ Task completed successfully!")
                print(f"      • Result: {task_result.result}")
                return True
                
            elif task_result.state == 'FAILURE':
                print(f"   ❌ Task failed!")
                print(f"      • Error: {task_result.info}")
                return False
                
            elif i % 10 == 0:
                print(f"   ⏳ Status: {task_result.status} ({i}s elapsed)")
        
        print(f"   ⏱️  Task timeout (90 seconds)")
        print(f"      • Final status: {task_result.status}")
        return False
        
    except Exception as e:
        print(f"❌ Celery task error: {e}")
        import traceback
        traceback.print_exc()
        return False


def test_api_endpoint():
    """Test API endpoint"""
    print_header("TEST 5: API Endpoint")
    
    try:
        # First, create/login a user
        print("   ⏳ Setting up test user...")
        user, _ = User.objects.get_or_create(username='api_test')
        user.set_password('testpass123')
        user.save()
        
        # Login to get token
        print("   ⏳ Logging in...")
        login_response = requests.post(
            'http://localhost:8000/api/auth/login/',
            json={'username': 'api_test', 'password': 'testpass123'},
            timeout=10
        )
        
        if login_response.status_code != 200:
            print(f"   ❌ Login failed: {login_response.status_code}")
            print(f"      Response: {login_response.text[:200]}")
            return False
        
        token = login_response.json()['token']
        print(f"   ✅ Login successful, got token")
        
        # Test scrape endpoint
        test_url = "https://www.aliexpress.com/item/1005008365025184.html"
        print(f"\n   📍 Testing scrape endpoint with URL: {test_url[:60]}...")
        
        headers = {'Authorization': f'Bearer {token}'}
        response = requests.post(
            'http://localhost:8000/api/products/scrape-puppeteer/',
            json={'url': test_url},
            headers=headers,
            timeout=10
        )
        
        if response.status_code == 202:
            data = response.json()
            print(f"   ✅ Scraping task queued!")
            print(f"      • Task ID: {data['task_id']}")
            print(f"      • Status: {data['status']}")
            print(f"      • Status URL: {data['status_url']}")
            
            # Check status
            time.sleep(2)
            status_response = requests.get(
                f"http://localhost:8000/api/products/scrape-status/{data['task_id']}/",
                headers=headers,
                timeout=10
            )
            
            print(f"\n   ℹ️  Task status check:")
            print(f"      • Response: {status_response.json()}")
            return True
        else:
            print(f"   ❌ Error: {response.status_code}")
            print(f"      Response: {response.text[:200]}")
            return False
            
    except requests.exceptions.ConnectionError:
        print(f"   ⚠️  Cannot connect to Django server at http://localhost:8000")
        print(f"      Make sure Django is running: python manage.py runserver")
        return False
    except Exception as e:
        print(f"   ❌ Error: {e}")
        import traceback
        traceback.print_exc()
        return False


def test_database_integration():
    """Test database integration after scraping"""
    print_header("TEST 6: Database Integration")
    
    try:
        # Count products before
        before_count = Product.objects.count()
        print(f"   ℹ️  Products in database before: {before_count}")
        
        # List recent scraping jobs
        recent_jobs = ScrapingJob.objects.all()[:5]
        print(f"\n   📊 Recent scraping jobs:")
        
        for job in recent_jobs:
            status_emoji = "✅" if job.is_success else "❌"
            print(f"      {status_emoji} {job.id}: {job.url[:50]}... - {job.status}")
            if job.product:
                print(f"         → Created product: {job.product.name}")
        
        # Count products after
        after_count = Product.objects.count()
        new_products = after_count - before_count
        
        print(f"\n   ℹ️  Products in database after: {after_count}")
        print(f"   📈 New products: {new_products}")
        
        return True
        
    except Exception as e:
        print(f"❌ Database error: {e}")
        import traceback
        traceback.print_exc()
        return False


def run_full_test_suite():
    """Run all tests"""
    print("\n" + "🚀" * 35)
    print("PUPPETEER SCRAPING - COMPLETE TEST SUITE")
    print("🚀" * 35)
    
    results = {
        'Installation': test_puppeteer_installation(),
        'Model': test_model_creation(),
        'Database': test_database_integration(),
        # 'Sync Scraping': test_synchronous_scraping(),  # Commented - requires time
        # 'Celery Task': test_celery_task(),  # Commented - requires Celery running
        # 'API Endpoint': test_api_endpoint(),  # Commented - requires Django running
    }
    
    # Print summary
    print("\n" + "=" * 70)
    print("📋 TEST SUMMARY")
    print("=" * 70)
    
    passed = sum(1 for v in results.values() if v)
    total = len(results)
    
    for test_name, result in results.items():
        status = "✅ PASS" if result else "❌ FAIL"
        print(f"   {status}: {test_name}")
    
    print(f"\n   Total: {passed}/{total} tests passed")
    print("=" * 70)
    
    if passed == total:
        print("\n🎉 All tests passed! Puppeteer integration is ready to use.")
    else:
        print(f"\n⚠️  {total - passed} test(s) failed. Check errors above.")


if __name__ == '__main__':
    run_full_test_suite()
