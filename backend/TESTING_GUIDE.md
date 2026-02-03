# 🧪 Complete Testing Guide - Puppeteer Integration

## Overview

There are **4 ways to test** the Puppeteer scraping system:

1. **Automated Test Suite** (recommended for CI/CD)
2. **Manual API Testing** (Postman/curl)
3. **Direct Python Testing** (quick feedback)
4. **Celery Task Testing** (background jobs)

---

## ✨ Quick Start (5 minutes)

```bash
# 1. Install
pip install pyppeteer aiohttp
pyppeteer-install

# 2. Migrate database
python manage.py migrate

# 3. Run tests
python test_puppeteer_scraping.py

# 4. Start Django
python manage.py runserver

# 5. Start Celery (new terminal)
celery -A dropshipping_finder worker -l info

# 6. Test API (new terminal)
curl -X POST http://localhost:8000/api/products/scrape-puppeteer/ \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -d '{"url": "https://www.aliexpress.com/item/1005008365025184.html"}'
```

---

## 🧪 Method 1: Automated Test Suite

### Run All Tests

```bash
cd c:\Users\YassIne\Desktop\Stage\APK-DROPSHIPPING-FINDER\backend
python test_puppeteer_scraping.py
```

### What It Tests

```
✅ TEST 1: Puppeteer Installation
   └─ Checks if pyppeteer is installed

✅ TEST 2: Synchronous Scraping
   └─ Tests direct scraping without Celery
   └─ Scrapes real AliExpress product
   └─ Validates extracted data

✅ TEST 3: ScrapingJob Model
   └─ Tests database model creation
   └─ Validates status tracking
   └─ Tests timestamps

✅ TEST 4: Celery Task (Async)
   └─ Tests background task queuing
   └─ Validates task completion
   └─ Checks result persistence

✅ TEST 5: API Endpoint
   └─ Tests REST API integration
   └─ Validates request/response format
   └─ Tests status code 202 Accepted

✅ TEST 6: Database Integration
   └─ Tests product creation
   └─ Tests duplicate detection
   └─ Tests data persistence
```

### Expected Output

```
======================================================================
🧪 TEST 1: Puppeteer Installation
======================================================================
✅ pyppeteer is installed
✅ pyppeteer.page is available

======================================================================
🧪 TEST 2: Synchronous Puppeteer Scraping
======================================================================
📍 Testing URL: https://www.aliexpress.com/item/1005008365...

   ⏳ Initializing scraper...
   ⏳ Starting scrape (this may take 30-60 seconds)...
   ✅ Scraping successful!

   📊 Scraped Data:
      • Title: High Quality Wireless Earbuds...
      • Price: $12.99
      • Rating: 4.8/5.0
      • Reviews: 5234
      • Sales: 12500
      • Supplier: TechStore Official
      • Images: 8 found
      • Shipping: 15 days
      • Stock: 2500

[... more tests ...]

======================================================================
📊 FINAL RESULTS
======================================================================
✅ All tests passed!
```

---

## 🔌 Method 2: Manual API Testing

### Prerequisites

```bash
# Terminal 1: Start Django
python manage.py runserver

# Terminal 2: Start Celery
celery -A dropshipping_finder worker -l info

# Terminal 3: Start Redis (optional but recommended)
redis-server
```

### Get Authentication Token

```bash
# Create admin user (if not exists)
python manage.py createsuperuser

# Get token
curl -X POST http://localhost:8000/api/token/ \
  -H "Content-Type: application/json" \
  -d '{"username": "admin", "password": "your_password"}'
```

Response:
```json
{
  "refresh": "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9...",
  "access": "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9..."
}
```

### Test 1: Single Product Scrape

```bash
curl -X POST http://localhost:8000/api/products/scrape-puppeteer/ \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer YOUR_ACCESS_TOKEN" \
  -d '{"url": "https://www.aliexpress.com/item/1005008365025184.html"}'
```

**Response (202 Accepted):**
```json
{
  "status": "queued",
  "task_id": "a1b2c3d4-e5f6-7890-abcd-ef1234567890",
  "status_url": "/api/products/scrape-status/a1b2c3d4-e5f6-7890-abcd-ef1234567890"
}
```

### Test 2: Check Scraping Status

```bash
# Check task status (use task_id from previous response)
curl -X GET "http://localhost:8000/api/products/scrape-status/TASK_ID" \
  -H "Authorization: Bearer YOUR_ACCESS_TOKEN"
```

**Response (Pending):**
```json
{
  "task_id": "a1b2c3d4-e5f6-7890-abcd-ef1234567890",
  "status": "PENDING"
}
```

**Response (Success):**
```json
{
  "task_id": "a1b2c3d4-e5f6-7890-abcd-ef1234567890",
  "status": "SUCCESS",
  "result": {
    "status": "success",
    "product_id": 42,
    "created": true,
    "title": "Wireless Earbuds Pro",
    "price": 19.99
  }
}
```

**Response (Failed):**
```json
{
  "task_id": "a1b2c3d4-e5f6-7890-abcd-ef1234567890",
  "status": "FAILURE",
  "error": "Connection timeout",
  "message": "Failed to connect to AliExpress"
}
```

### Test 3: Batch Scrape

```bash
curl -X POST http://localhost:8000/api/products/scrape-batch/ \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer YOUR_ACCESS_TOKEN" \
  -d '{
    "urls": [
      "https://www.aliexpress.com/item/1005008365025184.html",
      "https://www.aliexpress.com/item/1005006123456789.html",
      "https://www.aliexpress.com/item/1005007234567890.html"
    ]
  }'
```

**Response:**
```json
{
  "status": "queued",
  "task_id": "batch-task-id",
  "total_urls": 3
}
```

---

## 🐍 Method 3: Direct Python Testing

### Quick Test in Python Shell

```bash
python manage.py shell
```

Then in the Python shell:

```python
from core.scrapers.puppeteer_scraper import PuppeteerScraper
from core.models import Product

# Test 1: Basic scraping
scraper = PuppeteerScraper(use_tor=False, headless=True)
data = scraper.scrape_product("https://www.aliexpress.com/item/1005008365025184.html")

# Print results
print(f"Title: {data['title']}")
print(f"Price: ${data['price']}")
print(f"Rating: {data['rating']}/5")
print(f"Sales: {data['sales']}")

# Test 2: Check database
product = Product.objects.filter(source_url=url).first()
print(f"Created: {product.created_at}")
print(f"Price in DB: ${product.price}")

# Test 3: Batch scraping
urls = [
    "https://www.aliexpress.com/item/1005008365025184.html",
    "https://www.aliexpress.com/item/1005006123456789.html",
]
results = scraper.scrape_multiple(urls)
print(f"Scraped {len(results)} products")
```

---

## 🔄 Method 4: Celery Task Testing

### Test via Python Shell

```bash
python manage.py shell
```

```python
from integrations.tasks import scrape_product_with_puppeteer, scrape_batch_products
from celery.result import AsyncResult

# Queue a single product
task = scrape_product_with_puppeteer.delay("https://www.aliexpress.com/item/1005008365025184.html")
print(f"Task ID: {task.id}")

# Check status
result = AsyncResult(task.id)
print(f"Status: {result.status}")

# Wait for result (max 300 seconds)
try:
    output = result.get(timeout=300)
    print(f"Result: {output}")
except Exception as e:
    print(f"Error: {e}")

# Batch scraping
batch_task = scrape_batch_products.delay([
    "https://www.aliexpress.com/item/1005008365025184.html",
    "https://www.aliexpress.com/item/1005006123456789.html",
])
print(f"Batch Task ID: {batch_task.id}")
```

### Monitor Celery Tasks

```bash
# Terminal: Monitor all tasks in real-time
celery -A dropshipping_finder events

# Or use Flower (web interface)
pip install flower
celery -A dropshipping_finder flower
# Open http://localhost:5555
```

---

## 🎯 Test Scenarios

### Scenario 1: Quick Installation Check (2 min)

```bash
python test_puppeteer_scraping.py
# Only runs TEST 1 (installation check)
```

### Scenario 2: Full Automatic Test Suite (10-15 min)

```bash
python test_puppeteer_scraping.py
# Runs all 6 tests automatically
```

### Scenario 3: Manual API Test (5 min)

```bash
# Start services
python manage.py runserver
celery -A dropshipping_finder worker -l info

# In another terminal
curl -X POST http://localhost:8000/api/products/scrape-puppeteer/ \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer TOKEN" \
  -d '{"url": "https://www.aliexpress.com/item/1005008365025184.html"}'
```

### Scenario 4: Development/Debugging (ongoing)

```bash
# Start Python shell
python manage.py shell

# Import and test components
from core.scrapers.puppeteer_scraper import PuppeteerScraper
scraper = PuppeteerScraper(use_tor=False, headless=True)
data = scraper.scrape_product(url)
# Make changes and re-test quickly
```

---

## 📊 Verification Checklist

After testing, verify all components:

```
✅ Installation
  └─ pyppeteer installed
  └─ Chromium installed (pyppeteer-install ran)
  └─ aiohttp installed
  
✅ Database
  └─ Migrations run (python manage.py migrate)
  └─ ScrapingJob table created
  └─ Product model working
  
✅ Scraper
  └─ Can initialize PuppeteerScraper
  └─ Can launch browser
  └─ Can render JavaScript
  └─ Extracts 11 fields correctly
  
✅ Celery
  └─ Redis running
  └─ Celery worker running
  └─ Tasks queue and execute
  └─ Results stored in database
  
✅ API
  └─ Authentication working
  └─ /scrape-puppeteer/ endpoint works
  └─ /scrape-status/{task_id}/ works
  └─ /scrape-batch/ endpoint works
  
✅ Data Quality
  └─ Prices are accurate
  └─ Images extracted
  └─ Duplicates detected
  └─ Data persisted in DB
```

---

## 🐛 Troubleshooting Tests

### Issue: "No module named 'pyppeteer'"

```bash
pip install pyppeteer aiohttp
```

### Issue: "Chromium not found"

```bash
pyppeteer-install
```

### Issue: "Task timeout"

Increase timeout in `tasks.py`:
```python
@shared_task(bind=True, max_retries=3, time_limit=600)  # Changed from 300 to 600
```

### Issue: "Connection refused"

Make sure Redis is running:
```bash
redis-server
```

### Issue: "Cannot connect to AliExpress"

Check if:
- Internet connection works
- AliExpress is not blocking (try with `use_tor=True`)
- URL is valid

### Issue: "Tor timeout"

Start Tor service:
```bash
# Windows
# Install Tor from https://www.torproject.org/
# Then run Tor.exe or use Docker:
docker run -d -p 9050:9050 peterdreamer/tor

# Or disable Tor for testing
scraper = PuppeteerScraper(use_tor=False, headless=True)
```

---

## 📈 Performance Benchmarks

Expected timings:

```
Installation Check:     2 seconds
Single Product Scrape:  45-60 seconds
API Response:           <100ms (returns 202 Accepted)
Task Status Check:      <100ms
Batch (10 products):    8-10 minutes (concurrent)
Database Save:          <100ms
```

---

## 🎓 Test Examples by Use Case

### Use Case 1: Development/Debugging

```python
# test_debug.py
import os, django
os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'dropshipping_finder.settings')
django.setup()

from core.scrapers.puppeteer_scraper import PuppeteerScraper

url = "https://www.aliexpress.com/item/1005008365025184.html"
scraper = PuppeteerScraper(use_tor=False, headless=False)  # headless=False to see browser
data = scraper.scrape_product(url)

# Debug output
import json
print(json.dumps(data, indent=2))
```

### Use Case 2: Batch Testing

```python
# test_batch.py
from core.scrapers.puppeteer_scraper import PuppeteerScraper
from core.models import Product

urls = [
    "https://www.aliexpress.com/item/1005008365025184.html",
    "https://www.aliexpress.com/item/1005006123456789.html",
    # ... more URLs
]

scraper = PuppeteerScraper(use_tor=True, headless=True)
for url in urls:
    try:
        data = scraper.scrape_product(url)
        Product.objects.update_or_create(
            source_url=url,
            defaults={'name': data['title'], 'price': data['price']}
        )
        print(f"✅ {data['title']}")
    except Exception as e:
        print(f"❌ {url}: {e}")
```

### Use Case 3: Performance Testing

```python
# test_performance.py
import time
from core.scrapers.puppeteer_scraper import PuppeteerScraper

urls = ["URL1", "URL2", ...]
scraper = PuppeteerScraper()

start = time.time()
results = scraper.scrape_multiple(urls)
elapsed = time.time() - start

print(f"Scraped {len(results)} products in {elapsed:.1f}s")
print(f"Rate: {len(results)/elapsed:.2f} products/sec")
```

---

## ✨ Summary

**Choose your testing approach:**

| Method | Time | Best For | Command |
|--------|------|----------|---------|
| **Auto Suite** | 15 min | CI/CD, validation | `python test_puppeteer_scraping.py` |
| **API Test** | 5 min | Integration, manual | `curl ...` |
| **Python Shell** | 5 min | Quick feedback, debugging | `python manage.py shell` |
| **Celery Monitor** | ongoing | Production monitoring | `celery -A ... events` |

**Start here:**
1. Run `python test_puppeteer_scraping.py` → confirms everything works
2. Use Python shell for quick testing during development
3. Use API for testing production behavior
4. Use Celery events for monitoring background tasks

---

**🎉 Happy testing!**
